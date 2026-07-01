import * as readline from 'node:readline';
import { createRequire } from 'node:module';
import { stdin, stdout } from 'node:process';
import { SessionManager } from './session.js';
import type { Evt, Req } from './protocol.js';

// stdout carries ONLY protocol NDJSON. All diagnostics go to stderr.
function emit(e: Evt) {
  stdout.write(JSON.stringify(e) + '\n');
}

// Cosmetic SDK version for the `ready` event. import.meta.url exists under
// tsx/ESM (dev); in the esbuild→SEA CJS bundle it's undefined, so fall back to
// __filename (defined by esbuild in CJS). Guarded: worst case reports 'unknown'.
const sdkVersion: string = (() => {
  try {
    const req = createRequire(import.meta.url ?? __filename);
    return req('@anthropic-ai/claude-agent-sdk/package.json').version as string;
  } catch {
    return 'unknown';
  }
})();

const manager = new SessionManager(emit);

const rl = readline.createInterface({ input: stdin });
rl.on('line', (line) => {
  const trimmed = line.trim();
  if (!trimmed) return;
  let req: Req;
  try {
    req = JSON.parse(trimmed) as Req;
  } catch {
    emit({ t: 'fatal', message: `bad JSON: ${trimmed.slice(0, 120)}` });
    return;
  }
  try {
    manager.dispatch(req);
  } catch (e) {
    emit({ t: 'fatal', message: String(e), sid: (req as { sid?: string }).sid });
  }
});

emit({ t: 'ready', sdk: sdkVersion });
