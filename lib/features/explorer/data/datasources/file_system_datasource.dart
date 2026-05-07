import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../../domain/entities/file_node.dart';

abstract interface class FileSystemDataSource {
  Future<List<FileNode>> list(String path);
}

@LazySingleton(as: FileSystemDataSource)
class FileSystemDataSourceImpl implements FileSystemDataSource {
  static const _alwaysHidden = {
    '.git',
    '.svn',
    '.hg',
    'node_modules',
    '.dart_tool',
    'build',
    '.idea',
    '.vscode',
    '.DS_Store',
  };

  @override
  Future<List<FileNode>> list(String path) async {
    final dir = Directory(path);
    final entries = <FileNode>[];

    await for (final entity in dir.list(followLinks: false)) {
      final name = p.basename(entity.path);
      if (_alwaysHidden.contains(name)) continue;
      entries.add(FileNode(name: name, path: entity.path, isDir: entity is Directory));
    }

    entries.sort((a, b) {
      if (a.isDir != b.isDir) return a.isDir ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return entries;
  }
}
