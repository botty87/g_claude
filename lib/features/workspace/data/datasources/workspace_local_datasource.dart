import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../../../../core/error/exceptions.dart';

abstract interface class WorkspaceLocalDataSource {
  Future<void> ensureDirectoryExists(String path);

  Future<String?> readClaudeMd(String path);
}

@LazySingleton(as: WorkspaceLocalDataSource)
class WorkspaceLocalDataSourceImpl implements WorkspaceLocalDataSource {
  static const _candidates = ['CLAUDE.md', 'claude.md', 'Claude.md'];

  @override
  Future<void> ensureDirectoryExists(String path) async {
    final stat = await FileStat.stat(path);
    switch (stat.type) {
      case FileSystemEntityType.notFound:
        throw WorkspaceNotFoundException(path);
      case FileSystemEntityType.directory:
        return;
      default:
        throw WorkspaceNotADirectoryException(path);
    }
  }

  @override
  Future<String?> readClaudeMd(String path) async {
    for (final name in _candidates) {
      try {
        return await File(p.join(path, name)).readAsString();
      } on PathNotFoundException {
        continue;
      } on FileSystemException {
        continue;
      }
    }
    return null;
  }
}
