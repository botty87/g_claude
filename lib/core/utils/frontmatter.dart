Map<String, String> parseFrontmatter(String content) {
  if (!content.startsWith('---\n')) return const {};
  final end = content.indexOf('\n---\n', 4);
  if (end == -1) return const {};
  final block = content.substring(4, end);
  final result = <String, String>{};
  for (final line in block.split('\n')) {
    final colon = line.indexOf(':');
    if (colon == -1) continue;
    final key = line.substring(0, colon).trim();
    var value = line.substring(colon + 1).trim();
    if (value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1);
    } else if (value.startsWith("'") && value.endsWith("'")) {
      value = value.substring(1, value.length - 1);
    }
    if (key.isNotEmpty) result[key] = value;
  }
  return result;
}
