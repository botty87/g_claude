import type { DomainEvt } from './protocol.js';

type Any = Record<string, any>;

// Stateful per-session mapper: SDKMessage → protocol DomainEvt[].
// Mirrors Clyde's ClaudeProcessDataSource._normalize so the emitted stream
// is byte-for-byte compatible with the existing ClaudeEvent contract.
export class EventMapper {
  constructor(private readonly sid: string) {}

  private readonly toolByIndex = new Map<number, { toolName: string; toolId: string; partial: string }>();

  map(m: Any): DomainEvt[] {
    const sid = this.sid;
    switch (m?.type) {
      case 'system':
        if (m.subtype === 'init') {
          return [{
            t: 'sessionInit', sid,
            sessionId: m.session_id ?? '',
            model: m.model ?? '',
            tools: m.tools ?? [],
            skills: m.skills ?? [],
            slashCommands: m.slash_commands ?? [],
            plugins: (m.plugins ?? []).map((p: Any) => ({ name: p.name, path: p.path, source: p.source })),
            apiKeySource: m.apiKeySource ?? 'unknown',
            cwd: m.cwd ?? '',
          }];
        }
        return [];

      case 'stream_event':
        return this.mapStreamEvent(m.event);

      case 'assistant': {
        const text = (m.message?.content ?? [])
          .filter((b: Any) => b.type === 'text')
          .map((b: Any) => b.text)
          .join('');
        return text ? [{ t: 'assistantMessage', sid, text }] : [];
      }

      case 'user': {
        const out: DomainEvt[] = [];
        for (const b of m.message?.content ?? []) {
          if (b.type === 'tool_result') {
            out.push({
              t: 'toolResult', sid,
              toolUseId: b.tool_use_id ?? '',
              content: normalizeContent(b.content),
              isError: b.is_error === true,
            });
          }
        }
        return out;
      }

      case 'result': {
        if (m.is_error === true) {
          return [{ t: 'errorEvent', sid, message: m.result ?? m.subtype ?? 'error' }];
        }
        return [{
          t: 'taskComplete', sid,
          result: m.result,
          costUsd: m.total_cost_usd,
          durationMs: m.duration_ms,
          numTurns: m.num_turns,
        }];
      }

      default:
        // Rate-limit and other informational frames: best-effort.
        if (typeof m?.type === 'string' && m.type.includes('rate_limit')) {
          return [{ t: 'rateLimit', sid, status: m.status ?? m.subtype ?? 'unknown', resetsAt: m.resetsAt ?? m.resets_at }];
        }
        return [];
    }
  }

  private mapStreamEvent(ev: Any): DomainEvt[] {
    const sid = this.sid;
    if (!ev) return [];
    switch (ev.type) {
      case 'message_start': {
        const u = ev.message?.usage ?? {};
        return [{
          t: 'usageUpdate', sid,
          inputTokens: u.input_tokens,
          cacheReadTokens: u.cache_read_input_tokens,
          cacheCreationTokens: u.cache_creation_input_tokens,
          outputTokens: u.output_tokens,
        }];
      }
      case 'message_delta': {
        const u = ev.usage ?? {};
        return u.output_tokens != null ? [{ t: 'usageUpdate', sid, outputTokens: u.output_tokens }] : [];
      }
      case 'content_block_start': {
        const cb = ev.content_block;
        if (cb?.type === 'tool_use') {
          this.toolByIndex.set(ev.index, { toolName: cb.name, toolId: cb.id, partial: '' });
          return [{ t: 'toolCall', sid, toolName: cb.name, toolId: cb.id, index: ev.index }];
        }
        return [];
      }
      case 'content_block_delta': {
        const d = ev.delta;
        if (d?.type === 'text_delta') return [{ t: 'textChunk', sid, text: d.text }];
        if (d?.type === 'input_json_delta') {
          const tool = this.toolByIndex.get(ev.index);
          if (tool) {
            tool.partial += d.partial_json ?? '';
            return [{ t: 'toolCallUpdate', sid, toolId: tool.toolId, partialInput: d.partial_json ?? '' }];
          }
        }
        return [];
      }
      case 'content_block_stop': {
        const tool = this.toolByIndex.get(ev.index);
        if (!tool) return [];
        this.toolByIndex.delete(ev.index);
        let input: Record<string, unknown> | undefined;
        try { input = tool.partial ? JSON.parse(tool.partial) : {}; } catch { input = undefined; }
        return [{ t: 'toolCallComplete', sid, index: ev.index, toolId: tool.toolId, input }];
      }
      default:
        return [];
    }
  }
}

function normalizeContent(content: unknown): string {
  if (typeof content === 'string') return content;
  if (Array.isArray(content)) {
    return content.map((b: Any) => (b?.type === 'text' ? b.text : JSON.stringify(b))).join('');
  }
  return content == null ? '' : JSON.stringify(content);
}
