import { test } from 'node:test';
import assert from 'node:assert/strict';
import { EventMapper } from '../src/mapping.ts';

const SID = 's1';
const m = () => new EventMapper(SID);

test('system init → sessionInit with fields incl mcpServers', () => {
  const out = m().map({
    type: 'system', subtype: 'init', session_id: 'abc', model: 'claude-sonnet-5',
    tools: ['Read'], skills: ['x'], slash_commands: ['/c'],
    plugins: [{ name: 'p', path: '/p' }], apiKeySource: 'none', cwd: '/tmp',
    mcp_servers: [{ name: 'context7', status: 'connected' }, { name: 'n8n', status: 'needs-auth' }],
  });
  assert.equal(out.length, 1);
  const e = out[0] as any;
  assert.equal(e.t, 'sessionInit');
  assert.equal(e.sessionId, 'abc');
  assert.equal(e.model, 'claude-sonnet-5');
  assert.equal(e.apiKeySource, 'none');
  assert.deepEqual(e.mcpServers, [{ name: 'context7', status: 'connected' }, { name: 'n8n', status: 'needs-auth' }]);
});

test('stream_event message_start → usageUpdate', () => {
  const out = m().map({ type: 'stream_event', event: { type: 'message_start', message: { usage: { input_tokens: 10, cache_read_input_tokens: 5, output_tokens: 2 } } } });
  const e = out[0] as any;
  assert.equal(e.t, 'usageUpdate');
  assert.equal(e.inputTokens, 10);
  assert.equal(e.cacheReadTokens, 5);
  assert.equal(e.outputTokens, 2);
});

test('text_delta → textChunk', () => {
  const out = m().map({ type: 'stream_event', event: { type: 'content_block_delta', index: 0, delta: { type: 'text_delta', text: 'hi' } } });
  assert.deepEqual(out, [{ t: 'textChunk', sid: SID, text: 'hi' }]);
});

test('tool_use lifecycle: start → update (accumulate) → stop parses input', () => {
  const mapper = m();
  const start = mapper.map({ type: 'stream_event', event: { type: 'content_block_start', index: 0, content_block: { type: 'tool_use', id: 't1', name: 'Write' } } });
  assert.deepEqual(start, [{ t: 'toolCall', sid: SID, toolName: 'Write', toolId: 't1', index: 0 }]);

  mapper.map({ type: 'stream_event', event: { type: 'content_block_delta', index: 0, delta: { type: 'input_json_delta', partial_json: '{"file_path":"a.txt"' } } });
  mapper.map({ type: 'stream_event', event: { type: 'content_block_delta', index: 0, delta: { type: 'input_json_delta', partial_json: ',"content":"x"}' } } });

  const stop = mapper.map({ type: 'stream_event', event: { type: 'content_block_stop', index: 0 } });
  const e = stop[0] as any;
  assert.equal(e.t, 'toolCallComplete');
  assert.equal(e.toolId, 't1');
  assert.deepEqual(e.input, { file_path: 'a.txt', content: 'x' });
});

test('assistant text blocks → assistantMessage; empty → nothing', () => {
  const out = m().map({ type: 'assistant', message: { content: [{ type: 'text', text: 'done' }, { type: 'tool_use', id: 't', name: 'X' }] } });
  assert.deepEqual(out, [{ t: 'assistantMessage', sid: SID, text: 'done' }]);
  assert.deepEqual(m().map({ type: 'assistant', message: { content: [{ type: 'tool_use', id: 't', name: 'X' }] } }), []);
});

test('user tool_result → toolResult (string and block-array content)', () => {
  const s = m().map({ type: 'user', message: { content: [{ type: 'tool_result', tool_use_id: 't1', content: 'ok', is_error: false }] } });
  assert.deepEqual(s, [{ t: 'toolResult', sid: SID, toolUseId: 't1', content: 'ok', isError: false }]);
  const arr = m().map({ type: 'user', message: { content: [{ type: 'tool_result', tool_use_id: 't2', content: [{ type: 'text', text: 'hey' }], is_error: true }] } });
  const e = arr[0] as any;
  assert.equal(e.content, 'hey');
  assert.equal(e.isError, true);
});

test('result: success → taskComplete, is_error → errorEvent', () => {
  const ok = m().map({ type: 'result', subtype: 'success', is_error: false, result: 'r', total_cost_usd: 0.1, duration_ms: 5, num_turns: 1 });
  assert.deepEqual(ok, [{ t: 'taskComplete', sid: SID, result: 'r', costUsd: 0.1, durationMs: 5, numTurns: 1 }]);
  const err = m().map({ type: 'result', subtype: 'error_during_execution', is_error: true, result: 'boom' });
  assert.deepEqual(err, [{ t: 'errorEvent', sid: SID, message: 'boom' }]);
});

test('unknown/rate-limit frames are handled defensively', () => {
  assert.deepEqual(m().map({ type: 'something_else' }), []);
  const rl = m().map({ type: 'rate_limit_event', status: 'limited', resets_at: 123 });
  assert.deepEqual(rl, [{ t: 'rateLimit', sid: SID, status: 'limited', resetsAt: 123 }]);
});
