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

  static ClaudePermissionMode fromName(String? name) {
    if (name == null) return defaultChoice;
    for (final m in ClaudePermissionMode.values) {
      if (m.name == name) return m;
    }
    return defaultChoice;
  }
}
