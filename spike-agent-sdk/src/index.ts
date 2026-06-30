import { query, type CanUseTool, type PermissionResult, type Query } from '@anthropic-ai/claude-agent-sdk';
import * as readline from 'node:readline/promises';
import { stdin, stdout } from 'node:process';
import { writeFileSync, mkdirSync, rmSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

// ── setup ────────────────────────────────────────────────────────────────────
const __dirname = dirname(fileURLToPath(import.meta.url));
const SPIKE_ROOT = join(__dirname, '..');
const SANDBOX = join(SPIKE_ROOT, 'sandbox');

const mode = (process.argv[2] ?? '').toLowerCase();
if (mode !== 'plan' && mode !== 'question') {
  console.error('Usage: tsx src/index.ts <plan|question>');
  process.exit(1);
}

// Reset sandbox so the agent has a clean working dir (never touches the repo).
rmSync(SANDBOX, { recursive: true, force: true });
mkdirSync(SANDBOX, { recursive: true });

const INTERACTIVE = Boolean(stdin.isTTY);
const rl = INTERACTIVE ? readline.createInterface({ input: stdin, output: stdout }) : null;
// When run headless (piped/no TTY) auto-answer so the round-trip completes
// deterministically; with a real TTY this reads genuine user input from stdin.
async function ask(prompt: string, auto: string): Promise<string> {
  if (!rl) {
    console.log(`${prompt}[auto:${auto}]`);
    return auto;
  }
  return (await rl.question(prompt)).trim();
}

// Capture every canUseTool invocation verbatim for FINDINGS.
type Capture = { toolName: string; input: unknown; options: unknown; returned: unknown };
const captures: Capture[] = [];
function persist() {
  writeFileSync(
    join(SPIKE_ROOT, `last-run-${mode}.json`),
    JSON.stringify({ mode, sdk: '0.3.197', captures }, null, 2),
  );
}

function banner(s: string) {
  console.log(`\n${'═'.repeat(72)}\n${s}\n${'═'.repeat(72)}`);
}

// `q` is referenced inside canUseTool (closure); assigned before iteration starts.
let q: Query;

// ── canUseTool ────────────────────────────────────────────────────────────────
const canUseTool: CanUseTool = async (toolName, input, options) => {
  // Log the FULL inbound payload (minus the AbortSignal, which isn't serializable).
  const { signal, ...loggableOptions } = options as any;
  banner(`canUseTool FIRED  →  toolName = ${toolName}`);
  console.log('input:', JSON.stringify(input, null, 2));
  console.log('options (sans signal):', JSON.stringify(loggableOptions, null, 2));

  let returned: PermissionResult;

  if (toolName === 'ExitPlanMode') {
    const plan = (input as any).plan ?? '(no plan field)';
    console.log(`\n── PROPOSED PLAN ──\n${plan}\n──────────────────`);
    const a = (await ask('Approve plan? (y/n): ', process.env.SPIKE_DENY ? 'n' : 'y')).toLowerCase();
    if (a === 'y' || a === 'yes' || a === '') {
      // Approve the plan AND lift plan mode so subsequent edits can proceed.
      await q.setPermissionMode('acceptEdits');
      returned = { behavior: 'allow', updatedInput: input };
    } else {
      returned = { behavior: 'deny', message: 'User rejected the plan. Stop and wait for further instructions.', interrupt: Boolean(process.env.SPIKE_INTERRUPT) };
    }
  } else if (toolName === 'AskUserQuestion') {
    const questions = (input as any).questions ?? [];
    const answers: Record<string, string> = {};
    for (const ques of questions) {
      console.log(`\n[${ques.header}] ${ques.question}${ques.multiSelect ? '  (multi-select)' : ''}`);
      ques.options.forEach((o: any, i: number) =>
        console.log(`  ${i + 1}. ${o.label} — ${o.description}`),
      );
      const raw = await ask('Choice (number, comma-separated for multi, or free text): ', '1');
      const idxs = raw.split(',').map((s) => parseInt(s.trim(), 10) - 1);
      const labels = idxs
        .filter((i) => !isNaN(i) && i >= 0 && i < ques.options.length)
        .map((i) => ques.options[i].label);
      answers[ques.question] = labels.length ? labels.join(', ') : raw;
    }
    returned = { behavior: 'allow', updatedInput: { questions, answers } };
    console.log('\nReturning answers:', JSON.stringify(answers, null, 2));
  } else {
    // Any other tool reaching the callback (e.g. a Write that wasn't auto-approved).
    const a = (await ask(`Allow ${toolName}? (y/n): `, 'y')).toLowerCase();
    returned =
      a === 'y' || a === 'yes' || a === ''
        ? { behavior: 'allow', updatedInput: input }
        : { behavior: 'deny', message: 'User denied.' };
  }

  console.log('\nRETURNED:', JSON.stringify(returned, null, 2));
  captures.push({ toolName, input, options: loggableOptions, returned });
  persist();
  return returned;
};

// ── prompts ───────────────────────────────────────────────────────────────────
const PROMPTS = {
  plan:
    'Create a new file `calc.js` in the current directory that exports a function ' +
    '`add(a, b)` returning their sum, plus a `subtract(a, b)`. Use plan mode: present ' +
    'your plan via ExitPlanMode and wait for my approval before writing anything.',
  question:
    'I want to scaffold a brand-new backend service but I have not decided the stack. ' +
    'Before doing ANYTHING else, use the AskUserQuestion tool to ask me to choose: ' +
    '(1) the programming language, and (2) the database. Do not write any files until I answer.',
};

// ── run ─────────────────────────────────────────────────────────────────────--
async function main() {
  banner(`SPIKE MODE: ${mode}   |   API key present: ${process.env.ANTHROPIC_API_KEY ? 'YES' : 'NO'}`);

  q = query({
    prompt: PROMPTS[mode],
    options: {
      cwd: SANDBOX,
      permissionMode: mode === 'plan' ? 'plan' : 'default',
      canUseTool,
    },
  });

  for await (const message of q as any) {
    if (message.type === 'system' && message.subtype === 'init') {
      console.log(`\n[system:init] model=${message.model} permissionMode=${message.permissionMode} cwd=${message.cwd}`);
    } else if (message.type === 'assistant') {
      for (const block of message.message.content) {
        if (block.type === 'text' && block.text.trim()) console.log(`\n[assistant] ${block.text.trim()}`);
        else if (block.type === 'tool_use') console.log(`[assistant→tool_use] ${block.name}`);
      }
    } else if (message.type === 'result') {
      banner(`RESULT  subtype=${message.subtype}  is_error=${message.is_error}`);
      if (message.result) console.log(message.result);
      console.log(`\nusage: ${JSON.stringify(message.usage)}`);
    }
  }

  rl?.close();
  persist();
  banner('DONE');
}

main().catch((e) => {
  console.error('FATAL:', e);
  persist();
  rl?.close();
  process.exit(1);
});
