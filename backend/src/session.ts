import { query, type CanUseTool, type PermissionResult, type Query, type SDKUserMessage } from '@anthropic-ai/claude-agent-sdk';
import { readFileSync } from 'node:fs';
import { extname } from 'node:path';
import { decisionFor } from './permissions.js';
import { EventMapper } from './mapping.js';
import type { DomainEvt, Evt, PermissionMode, Req } from './protocol.js';

type StartReq = Extract<Req, { t: 'start' }>;
type Emit = (e: Evt) => void;

// Async iterable fed externally; backs the SDK streaming-input mode so we can
// push follow-up prompts into the same session and keep canUseTool alive.
class InputQueue implements AsyncIterable<SDKUserMessage> {
  private items: SDKUserMessage[] = [];
  private waiters: ((r: IteratorResult<SDKUserMessage>) => void)[] = [];
  private closed = false;

  push(item: SDKUserMessage) {
    if (this.closed) return;
    const w = this.waiters.shift();
    if (w) w({ value: item, done: false });
    else this.items.push(item);
  }

  close() {
    this.closed = true;
    let w;
    while ((w = this.waiters.shift())) w({ value: undefined as never, done: true });
  }

  [Symbol.asyncIterator](): AsyncIterator<SDKUserMessage> {
    return {
      next: (): Promise<IteratorResult<SDKUserMessage>> => {
        const item = this.items.shift();
        if (item) return Promise.resolve({ value: item, done: false });
        if (this.closed) return Promise.resolve({ value: undefined as never, done: true });
        return new Promise((res) => this.waiters.push(res));
      },
    };
  }
}

function userMessage(text: string, images: string[] = []): SDKUserMessage {
  const blocks: Record<string, unknown>[] = [];
  for (const path of images) {
    try {
      const data = readFileSync(path).toString('base64');
      blocks.push({ type: 'image', source: { type: 'base64', media_type: mediaType(path), data } });
    } catch {
      // skip unreadable image
    }
  }
  blocks.push({ type: 'text', text });
  return { type: 'user', message: { role: 'user', content: blocks as never }, parent_tool_use_id: null };
}

// 1M-token context beta, auto-enabled for models that support it. The SDK
// documents `context-1m-2025-08-07` for Sonnet 4/4.5; Opus 4.8 carries its own
// large-context model variant so needs no beta flag.
function oneMillionBetas(model?: string): { betas?: never } {
  if (model && model.toLowerCase().includes('sonnet')) {
    return { betas: ['context-1m-2025-08-07'] as never };
  }
  return {};
}

function mediaType(path: string): string {
  switch (extname(path).toLowerCase()) {
    case '.png': return 'image/png';
    case '.gif': return 'image/gif';
    case '.webp': return 'image/webp';
    default: return 'image/jpeg';
  }
}

class Session {
  readonly sid: string;
  private mode: PermissionMode;
  private readonly keepAlive: boolean;
  private allowAlways = false;
  private readonly input = new InputQueue();
  private readonly mapper: EventMapper;
  private readonly pending = new Map<string, (r: PermissionResult) => void>();
  // Original tool input per pending toolUseID, so allow results can echo a
  // valid `updatedInput` record (the SDK's Zod schema rejects undefined).
  private readonly pendingInput = new Map<string, Record<string, unknown>>();
  private readonly stderrTail: string[] = [];
  private query!: Query;

  constructor(req: StartReq, private readonly emit: Emit) {
    this.sid = req.sid;
    this.mode = req.mode;
    this.keepAlive = req.keepAlive ?? false;
    this.mapper = new EventMapper(req.sid);
  }

  start(req: StartReq) {
    this.input.push(userMessage(req.prompt, req.images));
    this.query = query({
      prompt: this.input,
      options: {
        cwd: req.cwd,
        permissionMode: this.mode,
        includePartialMessages: true,
        canUseTool: this.canUseTool,
        ...(req.model ? { model: req.model } : {}),
        ...(req.resume ? { resume: req.resume } : {}),
        ...(req.effort ? { effort: req.effort as never } : {}),
        // Thinking as an On/Off switch: adaptive (Claude decides) vs disabled.
        // Undefined → leave the model default (adaptive on Opus).
        ...(req.thinking === true ? { thinking: { type: 'adaptive' } as never }
          : req.thinking === false ? { thinking: { type: 'disabled' } as never } : {}),
        // 1M context window, auto-enabled where supported (documented: Sonnet).
        ...(oneMillionBetas(req.model)),
        ...(process.env.CLAUDE_CLI_PATH ? { pathToClaudeCodeExecutable: process.env.CLAUDE_CLI_PATH } : {}),
        stderr: (d: string) => {
          this.stderrTail.push(d);
          if (this.stderrTail.length > 200) this.stderrTail.shift();
        },
      },
    });
    void this.runLoop();
  }

  private canUseTool: CanUseTool = async (toolName, input, opts) => {
    const sid = this.sid;
    const toolUseID = opts.toolUseID;

    if (toolName === 'AskUserQuestion') {
      this.emit({ t: 'askUserQuestion', sid, toolUseID, questions: (input as Record<string, unknown>).questions as unknown[] ?? [] });
      return this.awaitRoundTrip(toolUseID, input);
    }
    if (toolName === 'ExitPlanMode') {
      this.emit({ t: 'planProposed', sid, toolUseID, plan: String((input as Record<string, unknown>).plan ?? ''), planFilePath: (input as Record<string, unknown>).planFilePath as string | undefined });
      return this.awaitRoundTrip(toolUseID, input);
    }

    const decision = decisionFor(this.mode, toolName, this.allowAlways);
    if (decision === 'allow') return { behavior: 'allow', updatedInput: input };
    if (decision === 'deny') return { behavior: 'deny', message: `Denied by permission mode (${this.mode}).` };

    this.emit({ t: 'permissionRequest', sid, toolUseID, toolName, toolInput: input as Record<string, unknown> });
    return this.awaitRoundTrip(toolUseID, input);
  };

  private awaitRoundTrip(toolUseID: string, input: Record<string, unknown>): Promise<PermissionResult> {
    this.pendingInput.set(toolUseID, input);
    return new Promise<PermissionResult>((resolve) => this.pending.set(toolUseID, resolve));
  }

  private resolve(toolUseID: string, result: PermissionResult) {
    const r = this.pending.get(toolUseID);
    if (!r) return;
    this.pending.delete(toolUseID);
    // The SDK's Zod schema requires `updatedInput` to be a record on allow.
    // Backfill it with the original tool input when the client didn't supply one.
    if (result.behavior === 'allow' && result.updatedInput === undefined) {
      result = { ...result, updatedInput: this.pendingInput.get(toolUseID) ?? {} };
    }
    this.pendingInput.delete(toolUseID);
    r(result);
  }

  // ── client-driven round-trip answers ────────────────────────────────────────
  answerPermission(req: Extract<Req, { t: 'permission' }>) {
    if (req.remember) this.allowAlways = true;
    if (req.decision === 'allow') this.resolve(req.toolUseID, { behavior: 'allow', updatedInput: req.updatedInput });
    else this.resolve(req.toolUseID, { behavior: 'deny', message: req.message ?? 'User denied.' });
  }

  answerQuestion(req: Extract<Req, { t: 'answerQuestion' }>) {
    this.resolve(req.toolUseID, { behavior: 'allow', updatedInput: { questions: req.questions, answers: req.answers } });
  }

  async answerPlan(req: Extract<Req, { t: 'plan' }>) {
    if (req.decision === 'approve') {
      const target = req.mode ?? 'auto';
      this.mode = target;
      try { await this.query.setPermissionMode(target); } catch { /* race: query ended */ }
      this.resolve(req.toolUseID, { behavior: 'allow' });
    } else {
      this.resolve(req.toolUseID, { behavior: 'deny', message: req.message ?? 'User rejected the plan.', interrupt: false });
    }
  }

  sendInput(req: Extract<Req, { t: 'input' }>) {
    this.input.push(userMessage(req.text, req.images));
  }

  async setMode(mode: PermissionMode) {
    this.mode = mode;
    try { await this.query.setPermissionMode(mode); } catch { /* race */ }
  }

  async stop() {
    try { await this.query.interrupt(); } catch { /* already stopped */ }
  }

  close() {
    this.input.close();
    void this.stop();
  }

  private async runLoop() {
    try {
      for await (const m of this.query as AsyncIterable<unknown>) {
        const msg = m as Record<string, unknown>;
        for (const e of this.mapper.map(msg)) this.emit(e);
        // One-shot (Clyde model): end the session after the turn's result so the
        // client's per-run stream completes. Closing input ends the query loop.
        if (!this.keepAlive && msg.type === 'result') this.input.close();
      }
      this.emit({ t: 'sessionDead', sid: this.sid, exitCode: 0, stderrTail: [...this.stderrTail] });
    } catch (e) {
      this.emit({ t: 'errorEvent', sid: this.sid, message: String(e) });
      this.emit({ t: 'sessionDead', sid: this.sid, exitCode: 1, stderrTail: [...this.stderrTail] });
    }
  }
}

export class SessionManager {
  private readonly sessions = new Map<string, Session>();
  constructor(private readonly emit: Emit) {}

  dispatch(req: Req) {
    if (req.t === 'start') {
      const existing = this.sessions.get(req.sid);
      if (existing) existing.close();
      const s = new Session(req, this.emit);
      this.sessions.set(req.sid, s);
      s.start(req);
      return;
    }
    const s = this.sessions.get(req.sid);
    if (!s) {
      this.emit({ t: 'fatal', sid: req.sid, message: `unknown session ${req.sid}` });
      return;
    }
    switch (req.t) {
      case 'input': s.sendInput(req); break;
      case 'permission': s.answerPermission(req); break;
      case 'answerQuestion': s.answerQuestion(req); break;
      case 'plan': void s.answerPlan(req); break;
      case 'setMode': void s.setMode(req.mode); break;
      case 'stop': void s.stop(); break;
      case 'close': s.close(); this.sessions.delete(req.sid); break;
    }
  }
}
