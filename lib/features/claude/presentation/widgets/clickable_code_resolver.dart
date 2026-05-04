import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../explorer/domain/entities/file_node.dart';
import '../../../explorer/presentation/cubit/explorer_cubit.dart';

/// Resolves the content of an inline `code` markdown span to an absolute file
/// path inside the workspace, or `null` if the content does not look like a
/// path or no matching file exists.
///
/// Resolution order: absolute → relative to [cwd] → basename match in
/// [basenameIndex].
String? resolveCodePath({
  required String content,
  required String cwd,
  required Map<String, List<String>> basenameIndex,
}) {
  final raw = content.trim();
  if (!_looksLikePath(raw)) return null;

  if (p.isAbsolute(raw)) {
    return _existsFile(raw) ? p.normalize(raw) : null;
  }

  final joined = p.normalize(p.join(cwd, raw));
  if (_existsFile(joined)) return joined;

  if (!raw.contains('/') && !raw.contains(r'\')) {
    final hits = basenameIndex[raw];
    if (hits != null && hits.isNotEmpty) return hits.first;
  }

  return null;
}

bool _looksLikePath(String s) {
  if (s.length < 2) return false;
  if (s.contains('\n') || s.contains(' ')) return false;
  if (s.startsWith('--')) return false;
  const reserved = {
    'null',
    'true',
    'false',
    'undefined',
    'void',
    'this',
    'super',
  };
  if (reserved.contains(s)) return false;
  if (RegExp(r'^-?\d+(\.\d+)?$').hasMatch(s)) return false;
  if (!s.contains('/') && !s.contains(r'\') && !s.contains('.')) return false;
  return true;
}

bool _existsFile(String path) {
  try {
    return FileSystemEntity.typeSync(path, followLinks: false) ==
        FileSystemEntityType.file;
  } catch (_) {
    return false;
  }
}

/// Builds a `basename → [absPath...]` index from a loaded explorer tree.
/// Only files (non-dir) are indexed.
Map<String, List<String>> buildBasenameIndex(WorkspaceTree tree) {
  final index = <String, List<String>>{};
  for (final entry in tree.children.entries) {
    for (final FileNode node in entry.value) {
      if (node.isDir) continue;
      (index[node.name] ??= <String>[]).add(node.path);
    }
  }
  return index;
}
