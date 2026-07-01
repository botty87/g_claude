enum ClaudePermissionMode {
  plan('plan', 'claude.permission.plan'),
  acceptEdits('acceptEdits', 'claude.permission.acceptEdits'),
  auto('auto', 'claude.permission.auto'),
  bypassPermissions('bypassPermissions', 'claude.permission.bypassPermissions'),
  defaultMode('default', 'claude.permission.default');

  const ClaudePermissionMode(this.cliFlag, this.labelKey);

  final String cliFlag;
  final String labelKey;

  static const ClaudePermissionMode defaultChoice = ClaudePermissionMode.acceptEdits;

  ClaudePermissionMode get next {
    final list = ClaudePermissionMode.values;
    return list[(index + 1) % list.length];
  }

  static ClaudePermissionMode fromName(String? name) {
    if (name == null) return defaultChoice;
    for (final m in ClaudePermissionMode.values) {
      if (m.name == name) return m;
    }
    return defaultChoice;
  }
}
