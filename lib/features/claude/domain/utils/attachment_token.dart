const _shellSensitiveChars = {' ', '\t', '"', "'", r'$', r'\', '`'};

String formatAttachmentToken(String path) {
  if (path.isEmpty) return '';

  final needsQuoting = path.runes.any((r) => _shellSensitiveChars.contains(String.fromCharCode(r)));

  if (!needsQuoting) return '@$path';

  final escaped = path.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  return '@"$escaped"';
}
