// Headless protocol driver: spawns the sidecar, runs a scenario, validates the
// round-trips end-to-end over stdio NDJSON. Mirrors what Clyde's Dart client
// will do. Usage: tsx test/client.ts <plan|plan-deny|question>
import { spawn } from 'node:child_process';
import * as readline from 'node:readline';
import { mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');
// Sandbox OUTSIDE any git repo: Claude Code anchors to the git root containing
// cwd, so a sandbox nested in this worktree would let it walk up to the repo root.
const SANDBOX = mkdtempSync(join(tmpdir(), 'clyde-sidecar-'));
const SID = 's1';

const scenario = (process.argv[2] ?? 'question').toLowerCase();
console.log(`sandbox=${SANDBOX}`);

const PROMPTS: Record<string, { prompt: string; mode: string }> = {
  plan: {
    prompt: 'Create a file calc.js IN THE CURRENT WORKING DIRECTORY (use a relative path) exporting add(a,b) and subtract(a,b). Present your plan via ExitPlanMode and wait for approval.',
    mode: 'plan',
  },
  'plan-deny': {
    prompt: 'Create a file calc.js IN THE CURRENT WORKING DIRECTORY (use a relative path) exporting add(a,b) and subtract(a,b). Present your plan via ExitPlanMode and wait for approval.',
    mode: 'plan',
  },
  question: {
    prompt: 'Before doing anything, use AskUserQuestion to ask me (1) the programming language and (2) the database for a new backend. Do not write files until I answer.',
    mode: 'default',
  },
};

// Default: run the TS source via tsx. Set CLYDE_SIDECAR_CJS to a bundled .cjs
// to exercise the packaged sidecar (spawned with system node).
const cjs = process.env.CLYDE_SIDECAR_CJS;
const [cmd, cmdArgs] = cjs ? ['node', [cjs]] : ['npx', ['tsx', join(ROOT, 'src/sidecar.ts')]];
const child = spawn(cmd, cmdArgs, { stdio: ['pipe', 'pipe', 'inherit'] });
const send = (req: object) => child.stdin.write(JSON.stringify(req) + '\n');
const rl = readline.createInterface({ input: child.stdout });

const kill = setTimeout(() => { console.error('TIMEOUT'); child.kill(); process.exit(1); }, 180_000);

rl.on('line', (line) => {
  let e: any;
  try { e = JSON.parse(line); } catch { return; }
  console.log(`◀ EVT ${e.t}${e.toolName ? ' ' + e.toolName : ''}`);

  switch (e.t) {
    case 'ready': {
      console.log(`  sidecar ready, sdk=${e.sdk}`);
      const cfg = PROMPTS[scenario];
      send({ t: 'start', sid: SID, cwd: SANDBOX, prompt: cfg.prompt, mode: cfg.mode });
      break;
    }
    case 'sessionInit':
      console.log(`  apiKeySource=${e.apiKeySource} model=${e.model} cwd=${e.cwd}`);
      break;
    case 'toolCallComplete':
      if (e.input?.file_path) console.log(`  [Write/Edit file_path=${e.input.file_path}]`);
      if (e.input?.command) console.log(`  [Bash command=${e.input.command}]`);
      break;
    case 'textChunk':
      process.stdout.write(e.text);
      break;
    case 'planProposed': {
      console.log(`\n── PLAN ──\n${e.plan}\n──────────`);
      const decision = scenario === 'plan-deny' ? 'reject' : 'approve';
      console.log(`▶ REQ plan ${decision}`);
      send({ t: 'plan', sid: SID, toolUseID: e.toolUseID, decision, mode: 'acceptEdits' });
      break;
    }
    case 'askUserQuestion': {
      const answers: Record<string, string> = {};
      for (const q of e.questions) answers[q.question] = q.options[0].label;
      console.log(`▶ REQ answerQuestion ${JSON.stringify(answers)}`);
      send({ t: 'answerQuestion', sid: SID, toolUseID: e.toolUseID, questions: e.questions, answers });
      break;
    }
    case 'permissionRequest':
      console.log(`▶ REQ permission allow (${e.toolName})`);
      send({ t: 'permission', sid: SID, toolUseID: e.toolUseID, decision: 'allow' });
      break;
    case 'taskComplete':
      // End-of-TURN in streaming-input mode (session stays alive for more input).
      // For this one-shot validator we close the session and finish here.
      console.log(`\n  taskComplete: ${e.result ?? ''}`);
      console.log('▶ REQ close');
      send({ t: 'close', sid: SID });
      clearTimeout(kill);
      setTimeout(() => { child.kill(); process.exit(0); }, 500);
      break;
    case 'sessionDead':
      console.log(`  sessionDead exit=${e.exitCode}`);
      clearTimeout(kill);
      child.kill();
      process.exit(0);
      break;
    case 'fatal':
      console.error(`  FATAL: ${e.message}`);
      break;
  }
});
