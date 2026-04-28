import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

abstract interface class WorkspaceLocalDataSource {
  Future<void> ensureDirectoryExists(String path);

  Future<String?> readClaudeMd(String path);
}

@LazySingleton(as: WorkspaceLocalDataSource)
class WorkspaceLocalDataSourceImpl implements WorkspaceLocalDataSource {
  static const _candidates = [
    'CLAUDE.md',
    'claude.md',
    'Claude.md',
  ];

  @override
  Future<void> ensureDirectoryExists(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      throw const FileSystemException('Directory does not exist');
    }
    final stat = await dir.stat();
    if (stat.type != FileSystemEntityType.directory) {
      throw const FileSystemException('Path is not a directory');
    }
  }

  @override
  Future<String?> readClaudeMd(String path) async {
    for (final name in _candidates) {
      final file = File(p.join(path, name));
      if (await file.exists()) {
        return file.readAsString();
      }
    }
    return null;
  }
}
