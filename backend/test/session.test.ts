import { test } from 'node:test';
import assert from 'node:assert/strict';
import { sanitizeMcpToolPrefix } from '../src/session.ts';

// The disallowedTools spec `mcp__<name>__*` must use the CLI's sanitized tool
// namespace, not the human-readable server name. These cases are ground truth:
// verified against `claude mcp list` names and the live `mcp__*` tool prefixes.
test('sanitizeMcpToolPrefix: stdio servers pass through (hyphens kept)', () => {
  assert.equal(sanitizeMcpToolPrefix('context7'), 'context7');
  assert.equal(sanitizeMcpToolPrefix('clickup-extras'), 'clickup-extras');
  assert.equal(sanitizeMcpToolPrefix('claude-in-chrome'), 'claude-in-chrome');
});

test('sanitizeMcpToolPrefix: claude.ai remote servers → underscore-joined', () => {
  assert.equal(sanitizeMcpToolPrefix('claude.ai Slack'), 'claude_ai_Slack');
  assert.equal(sanitizeMcpToolPrefix('claude.ai n8n'), 'claude_ai_n8n');
  assert.equal(sanitizeMcpToolPrefix('claude.ai Microsoft 365'), 'claude_ai_Microsoft_365');
  assert.equal(sanitizeMcpToolPrefix('claude.ai Fireflies'), 'claude_ai_Fireflies');
});

test('sanitizeMcpToolPrefix: claude.ai branch collapses runs and trims underscores', () => {
  // A trailing punctuation run would otherwise leave a dangling "_".
  assert.equal(sanitizeMcpToolPrefix('claude.ai Foo!!'), 'claude_ai_Foo');
  assert.equal(sanitizeMcpToolPrefix('claude.ai  Bar'), 'claude_ai_Bar');
});

test('sanitizeMcpToolPrefix: plugin servers replace colons', () => {
  assert.equal(sanitizeMcpToolPrefix('plugin:firebase:firebase'), 'plugin_firebase_firebase');
});
