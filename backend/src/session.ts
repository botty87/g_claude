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

// Replicates the Claude Code CLI's MCP-server-name → tool-namespace sanitizer.
// The CLI exposes an MCP server's tools as `mcp__<sanitized>__<tool>`, so a
// `disallowedTools` spec of `mcp__<name>__*` only matches if <name> is the
// sanitized form — not the display name the client sends (e.g. "claude.ai
// Slack" → "claude_ai_Slack"). Rule extracted from the CLI binary (fn `Vl`):
// replace every char outside [A-Za-z0-9_-] with "_"; for "claude.ai " servers,
// additionally collapse runs of "_" and trim leading/trailing "_".
export function sanitizeMcpToolPrefix(name: string): string {
  let t = name.replace(/[^a-zA-Z0-9_-]/g, '_');
  if (name.startsWith('claude.ai ')) t = t.replace(/_+/g, '_').replace(/^_|_$/g, '');
  return t;
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
        // Disabled MCP servers → block all their tools (mcp__<name>__*). Names
        // must be sanitized to the CLI's tool namespace or the spec won't match
        // remote/claude.ai servers (see sanitizeMcpToolPrefix).
        ...(req.disabledMcp && req.disabledMcp.length
          ? { disallowedTools: req.disabledMcp.map((n) => `mcp__${sanitizeMcpToolPrefix(n)}__*`) }
          : {}),
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

type McpAuthResponse = { authUrl?: string; requiresUserAction?: boolean; callbackExpected?: boolean };
type McpStatusEntry = { name: string; status: string };

// mcpAuthenticate / mcpServerStatus live on the runtime Query object but aren't
// in the SDK's public typings (0.3.197). Narrow structural type for the calls.
type McpAuthQuery = Query & {
  mcpAuthenticate(serverName: string, redirectUri?: string): Promise<McpAuthResponse>;
  mcpServerStatus(): Promise<McpStatusEntry[]>;
};

const sleep = (ms: number) => new Promise<void>((res) => setTimeout(res, ms));

// Runs an MCP OAuth flow in a throwaway keep-alive query, decoupled from any
// chat turn. The SDK control channel (mcpAuthenticate) needs a live streaming
// query, so we spawn one, wait for the target server to register (claude.ai
// connectors attach asynchronously *after* `init`), fetch the authUrl, emit it,
// and tear the query down — the client opens the URL and claude.ai brokers the
// callback (callbackExpected=false). A trivial prompt only establishes
// streaming mode; we close before any real turn completes.
async function runMcpAuth(req: Extract<Req, { t: 'mcpAuth' }>, emit: Emit): Promise<void> {
  const { sid, serverName } = req;
  const input = new InputQueue();
  input.push(userMessage('.'));
  let q: McpAuthQuery;
  try {
    q = query({
      prompt: input,
      options: {
        cwd: req.cwd,
        permissionMode: 'default',
        ...(process.env.CLAUDE_CLI_PATH ? { pathToClaudeCodeExecutable: process.env.CLAUDE_CLI_PATH } : {}),
      },
    }) as McpAuthQuery;
  } catch (e) {
    emit({ t: 'mcpAuthError', sid, serverName, message: String(e) });
    return;
  }

  const drain = (async () => {
    try { for await (const _ of q as AsyncIterable<unknown>) { /* keep the query alive */ } } catch { /* torn down */ }
  })();

  const deadline = 30_000;
  try {
    // Poll until the server registers (control channel also becomes ready here;
    // claude.ai connectors attach after init, so we can't authenticate at once).
    const start = Date.now();
    let found = false;
    while (Date.now() - start < deadline) {
      try {
        const status = await q.mcpServerStatus();
        if (status.some((s) => s.name === serverName)) { found = true; break; }
      } catch { /* control channel not ready yet */ }
      await sleep(400);
    }
    if (!found) { emit({ t: 'mcpAuthError', sid, serverName, message: `server not found within ${deadline}ms` }); return; }

    const res = await q.mcpAuthenticate(serverName);
    if (res && typeof res.authUrl === 'string' && res.authUrl.length > 0) {
      // claude.ai connectors broker the callback themselves (callbackExpected
      // false). A true here means a bare OAuth server expects us to submit the
      // redirect back via mcpSubmitOAuthCallbackUrl — not yet wired, so warn
      // loudly instead of silently half-completing.
      if (res.callbackExpected === true) {
        process.stderr.write(`[mcpAuth] ${serverName}: callbackExpected=true not supported (only claude.ai connectors)\n`);
      }
      emit({ t: 'mcpAuthUrl', sid, serverName, authUrl: res.authUrl, requiresUserAction: res.requiresUserAction, callbackExpected: res.callbackExpected });
    } else {
      emit({ t: 'mcpAuthError', sid, serverName, message: 'no authUrl returned by SDK' });
    }
  } catch (e) {
    emit({ t: 'mcpAuthError', sid, serverName, message: String(e) });
  } finally {
    input.close();
    try { q.close(); } catch { /* already closed */ }
    void drain;
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
    // Ephemeral, session-less: owns its own throwaway query.
    if (req.t === 'mcpAuth') {
      void runMcpAuth(req, this.emit);
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
