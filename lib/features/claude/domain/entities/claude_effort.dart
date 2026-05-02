enum ClaudeEffort {
  low('low', 'claude.effort.low'),
  medium('medium', 'claude.effort.medium'),
  high('high', 'claude.effort.high'),
  xhigh('xhigh', 'claude.effort.xhigh'),
  max('max', 'claude.effort.max');

  const ClaudeEffort(this.cliId, this.labelKey);

  final String cliId;
  final String labelKey;

  static const ClaudeEffort defaultEffort = ClaudeEffort.high;

  static ClaudeEffort fromName(String? name) {
    if (name == null) return defaultEffort;
    for (final e in ClaudeEffort.values) {
      if (e.name == name) return e;
    }
    return defaultEffort;
  }
}
