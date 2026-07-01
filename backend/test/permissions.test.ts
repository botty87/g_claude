import { test } from 'node:test';
import assert from 'node:assert/strict';
import { decisionFor, READ_ONLY_TOOLS } from '../src/permissions.ts';

test('plan mode: read-only tools allowed, everything else denied', () => {
  assert.equal(decisionFor('plan', 'Read', false), 'allow');
  assert.equal(decisionFor('plan', 'Grep', false), 'allow');
  assert.equal(decisionFor('plan', 'ExitPlanMode', false), 'allow');
  assert.equal(decisionFor('plan', 'Write', false), 'deny');
  assert.equal(decisionFor('plan', 'Bash', false), 'deny');
});

test('acceptEdits and bypassPermissions allow everything', () => {
  for (const mode of ['acceptEdits', 'bypassPermissions'] as const) {
    assert.equal(decisionFor(mode, 'Write', false), 'allow');
    assert.equal(decisionFor(mode, 'Bash', false), 'allow');
  }
});

test('dontAsk denies everything (no prompt)', () => {
  assert.equal(decisionFor('dontAsk', 'Read', false), 'deny');
  assert.equal(decisionFor('dontAsk', 'Write', false), 'deny');
});

test('default: read-only allowed, writes ask unless allowAlways', () => {
  assert.equal(decisionFor('default', 'Read', false), 'allow');
  assert.equal(decisionFor('default', 'Write', false), 'ask');
  assert.equal(decisionFor('default', 'Write', true), 'allow'); // allowAlways
});

test('auto: same fallback shape as default when canUseTool is reached', () => {
  assert.equal(decisionFor('auto', 'Read', false), 'allow');
  assert.equal(decisionFor('auto', 'Write', false), 'ask');
  assert.equal(decisionFor('auto', 'Write', true), 'allow');
});

test('read-only set contains the expected safe tools', () => {
  for (const t of ['Read', 'Glob', 'Grep', 'WebFetch', 'ExitPlanMode']) {
    assert.ok(READ_ONLY_TOOLS.has(t), `${t} should be read-only`);
  }
  assert.ok(!READ_ONLY_TOOLS.has('Write'));
  assert.ok(!READ_ONLY_TOOLS.has('Bash'));
});
