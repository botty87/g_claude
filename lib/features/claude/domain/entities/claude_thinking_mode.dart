enum ClaudeThinkingMode {
  off('off', 'claude.thinking.off'),
  on('on', 'claude.thinking.on');

  const ClaudeThinkingMode(this.cliId, this.labelKey);

  final String cliId;
  final String labelKey;

  static const ClaudeThinkingMode defaultMode = ClaudeThinkingMode.on;

  ClaudeThinkingMode get next {
    final list = ClaudeThinkingMode.values;
    return list[(index + 1) % list.length];
  }

  static ClaudeThinkingMode fromName(String? name) {
    if (name == null) return defaultMode;
    for (final m in ClaudeThinkingMode.values) {
      if (m.name == name) return m;
    }
    return defaultMode;
  }
}
