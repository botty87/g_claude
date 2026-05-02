enum ClaudeModel {
  opus47('claude-opus-4-7', 'claude.model.opus47'),
  sonnet46('claude-sonnet-4-6', 'claude.model.sonnet46'),
  haiku45('claude-haiku-4-5-20251001', 'claude.model.haiku45');

  const ClaudeModel(this.cliId, this.labelKey);

  final String cliId;
  final String labelKey;

  static const ClaudeModel defaultModel = ClaudeModel.sonnet46;

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
