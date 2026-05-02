import 'package:injectable/injectable.dart';

/// Static fallback descriptions for CLI built-in commands and skills that
/// the runtime exposes via `system/init.slash_commands` but for which no
/// filesystem source carries a description.
@lazySingleton
class BuiltinAppCommands {
  static const _descriptions = <String, String>{
    'add-dir': 'Add a new working directory',
    'agents': 'Manage agent configurations',
    'bashes': 'List background bash shells',
    'bug': 'Submit feedback about Claude Code',
    'clear': 'Start a new session with empty context',
    'compact': 'Compact conversation history',
    'config': 'Open configuration panel',
    'context': 'Show current context usage',
    'cost': 'Show token costs and usage stats',
    'doctor': 'Diagnose installation health',
    'export': 'Export current conversation',
    'extra-usage': 'Show extended usage breakdown',
    'heapdump': 'Capture a heap dump for debugging',
    'help': 'Show available commands',
    'hooks': 'Manage hooks configuration',
    'ide': 'Connect to IDE integration',
    'init': 'Initialize a new CLAUDE.md',
    'insights': 'Show session insights',
    'install-github-app': 'Install the Claude GitHub app',
    'login': 'Sign in to Claude',
    'logout': 'Sign out of Claude',
    'mcp': 'Manage MCP servers',
    'memory': 'Edit CLAUDE.md memory files',
    'migrate-installer': 'Migrate to the local installer',
    'model': 'Switch model',
    'output-style': 'Change output style',
    'permissions': 'Edit allow/deny permission rules',
    'pr_comments': 'View comments on a PR',
    'privacy-settings': 'Configure privacy settings',
    'release-notes': 'Show release notes',
    'resume': 'Resume a previous session',
    'review': 'Review a pull request',
    'security-review': 'Security review of current branch',
    'status': 'Show session and account status',
    'team-onboarding': 'Run team onboarding flow',
    'terminal-setup': 'Configure terminal integration',
    'todos': 'View pending TODOs',
    'upgrade': 'Upgrade Claude Code',
    'usage': 'Show usage statistics',
    'vim': 'Toggle vim editing mode',
  };

  String? descriptionFor(String name) => _descriptions[name];
}
