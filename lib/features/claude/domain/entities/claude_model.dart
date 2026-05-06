enum ClaudeModel {
  haiku('haiku', 'claude.model.haiku'),
  sonnet('sonnet', 'claude.model.sonnet'),
  opus('opus', 'claude.model.opus');

  const ClaudeModel(this.cliId, this.labelKey);

  final String cliId;
  final String labelKey;

  static const ClaudeModel defaultModel = ClaudeModel.sonnet;

  static ClaudeModel? fromCliId(String? id) {
    if (id == null) return null;
    for (final m in ClaudeModel.values) {
      if (m.cliId == id) return m;
    }
    return null;
  }

  static ClaudeModel fromName(String? name) {
    if (name == null) return defaultModel;
    for (final m in ClaudeModel.values) {
      if (m.name == name) return m;
    }
    return defaultModel;
  }
}

extension ClaudeModelContext on ClaudeModel {
  /// Standard context window in tokens (200k for all current models).
  int get contextLimit => 200000;
}
