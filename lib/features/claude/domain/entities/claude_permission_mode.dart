enum ClaudePermissionMode {
  plan('plan', 'claude.permission.plan'),
  acceptEdits('acceptEdits', 'claude.permission.acceptEdits'),
  bypassPermissions('bypassPermissions', 'claude.permission.bypassPermissions'),
  defaultMode('default', 'claude.permission.default');

  const ClaudePermissionMode(this.cliFlag, this.labelKey);

  final String cliFlag;
  final String labelKey;

  static const ClaudePermissionMode defaultChoice = ClaudePermissionMode.acceptEdits;

  bool get requiresHookServer => this == ClaudePermissionMode.defaultMode;
  bool get isBypass => this == ClaudePermissionMode.bypassPermissions;

  /// System-prompt hint appended to each run so the model's verbal output
  /// reflects the GUI-selected mode. Tool enforcement is still done by the
  /// PermissionServer hook; this is purely about narrative coherence.
  String get systemPromptHint {
    switch (this) {
      case ClaudePermissionMode.plan:
        return 'GUI_PERMISSION_MODE: PLAN. Treat this turn as plan mode '
            '(read-only). Do not modify files (Edit/Write/MultiEdit/'
            'NotebookEdit) and do not run shell commands (Bash). Read-only '
            'tools (Read/Glob/Grep/WebFetch/WebSearch/TodoWrite/'
            'NotebookRead) are allowed. Use ExitPlanMode when you have a '
            'plan to propose. The GUI hook will deny disallowed tools '
            'automatically.';
      case ClaudePermissionMode.acceptEdits:
        return 'GUI_PERMISSION_MODE: ACCEPT_EDITS. File edits and shell '
            'commands are auto-approved by the user via the GUI hook. '
            'Proceed without asking permission. Previous turns may have '
            'been in a different mode; the current mode supersedes them.';
      case ClaudePermissionMode.bypassPermissions:
        return 'GUI_PERMISSION_MODE: BYPASS. All tools are auto-approved by '
            'the GUI hook. Proceed without asking permission. Previous turns '
            'may have been in a different mode; the current mode supersedes '
            'them.';
      case ClaudePermissionMode.defaultMode:
        return 'GUI_PERMISSION_MODE: DEFAULT. Tool calls go through the GUI '
            'permission hook; for now the hook auto-approves. Behave as a '
            'normal collaborative assistant.';
    }
  }

  static ClaudePermissionMode fromName(String? name) {
    if (name == null) return defaultChoice;
    for (final m in ClaudePermissionMode.values) {
      if (m.name == name) return m;
    }
    return defaultChoice;
  }
}
