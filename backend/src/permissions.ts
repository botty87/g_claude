import type { PermissionMode } from './protocol.js';

// Mirrors Clyde's cubit `_readOnlyTools` (claude_sessions_cubit.dart).
export const READ_ONLY_TOOLS = new Set<string>([
  'Read', 'Glob', 'Grep', 'BashOutput', 'KillShell', 'NotebookRead', 'TodoWrite',
  'WebFetch', 'WebSearch', 'ExitPlanMode', 'ListMcpResourcesTool', 'ReadMcpResourceTool',
]);

export type Decision = 'allow' | 'deny' | 'ask';

// Mirrors Clyde's `_decisionFor`. AskUserQuestion and ExitPlanMode are handled
// out-of-band (own round-trips) before this is consulted.
export function decisionFor(mode: PermissionMode, toolName: string, allowAlways: boolean): Decision {
  switch (mode) {
    case 'plan':
      return READ_ONLY_TOOLS.has(toolName) ? 'allow' : 'deny';
    case 'acceptEdits':
    case 'bypassPermissions':
      return 'allow';
    case 'default':
      return allowAlways || READ_ONLY_TOOLS.has(toolName) ? 'allow' : 'ask';
  }
}
