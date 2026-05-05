enum ClaudeThinkingMode {
  off('', 'claude.thinking.off'),
  think('think', 'claude.thinking.think'),
  thinkHard('think hard', 'claude.thinking.thinkHard'),
  ultrathink('ultrathink', 'claude.thinking.ultrathink');

  const ClaudeThinkingMode(this.keyword, this.labelKey);

  final String keyword;
  final String labelKey;

  static const ClaudeThinkingMode defaultMode = ClaudeThinkingMode.off;

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
