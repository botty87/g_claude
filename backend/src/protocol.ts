// Single message protocol between Clyde (client) and this sidecar.
// Transport-agnostic payloads; see PROTOCOL.md. Current transport: stdio NDJSON.

export type PermissionMode = 'default' | 'acceptEdits' | 'bypassPermissions' | 'plan' | 'auto' | 'dontAsk';

// ── REQ: client → sidecar ────────────────────────────────────────────────────
export type Req =
  | { t: 'start'; sid: string; cwd: string; prompt: string; mode: PermissionMode;
      model?: string; effort?: string; thinking?: boolean; resume?: string;
      images?: string[]; disabledMcp?: string[];
      // When false (default) the session closes after the turn's result (emits
      // sessionDead → the client's per-run stream completes). Clyde runs one
      // turn per start (+resume). Set true for a persistent multi-turn session.
      keepAlive?: boolean }
  | { t: 'input'; sid: string; text: string; images?: string[] }
  | { t: 'permission'; sid: string; toolUseID: string; decision: 'allow' | 'deny';
      updatedInput?: Record<string, unknown>; message?: string; remember?: boolean }
  | { t: 'answerQuestion'; sid: string; toolUseID: string;
      questions: unknown[]; answers: Record<string, string | string[]> }
  | { t: 'plan'; sid: string; toolUseID: string; decision: 'approve' | 'reject';
      mode?: PermissionMode; message?: string }
  | { t: 'setMode'; sid: string; mode: PermissionMode }
  | { t: 'stop'; sid: string }
  | { t: 'close'; sid: string };

// ── EVT: sidecar → client ────────────────────────────────────────────────────
// Domain events (map 1:1 onto Dart ClaudeEvent). All carry `sid`.
export type DomainEvt =
  | { t: 'sessionInit'; sid: string; sessionId: string; model: string; tools: string[];
      skills: string[]; slashCommands: string[];
      plugins: { name: string; path: string; source?: string }[]; apiKeySource: string; cwd: string }
  | { t: 'textChunk'; sid: string; text: string }
  | { t: 'toolCall'; sid: string; toolName: string; toolId: string; index: number }
  | { t: 'toolCallUpdate'; sid: string; toolId: string; partialInput: string }
  | { t: 'toolCallComplete'; sid: string; index: number; toolId?: string; input?: Record<string, unknown> }
  | { t: 'toolResult'; sid: string; toolUseId: string; content: string; isError: boolean }
  | { t: 'assistantMessage'; sid: string; text: string }
  | { t: 'usageUpdate'; sid: string; inputTokens?: number; cacheReadTokens?: number;
      cacheCreationTokens?: number; outputTokens?: number }
  | { t: 'taskComplete'; sid: string; result?: string; costUsd?: number; durationMs?: number; numTurns?: number }
  | { t: 'errorEvent'; sid: string; message: string }
  | { t: 'rateLimit'; sid: string; status: string; resetsAt?: number }
  | { t: 'sessionDead'; sid: string; exitCode?: number; stderrTail: string[] }
  | { t: 'permissionRequest'; sid: string; toolUseID: string; toolName: string; toolInput: Record<string, unknown> }
  | { t: 'askUserQuestion'; sid: string; toolUseID: string; questions: unknown[] }
  | { t: 'planProposed'; sid: string; toolUseID: string; plan: string; planFilePath?: string };

// Transport/system events (not ClaudeEvent).
export type SystemEvt =
  | { t: 'ready'; sdk: string; cli?: string }
  | { t: 'fatal'; message: string; sid?: string };

export type Evt = DomainEvt | SystemEvt;
