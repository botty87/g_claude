import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/file_content.dart';

abstract interface class FileContentDataSource {
  Future<FileContent> readFile({required String path});
}

@LazySingleton(as: FileContentDataSource)
class FileContentDataSourceImpl implements FileContentDataSource {
  static const _maxBytes = 2 * 1024 * 1024;
  static const _peekBytes = 8192;

  @override
  Future<FileContent> readFile({required String path}) async {
    final file = File(path);
    final stat = await file.stat();

    if (stat.size > _maxBytes) {
      throw FileTooLargeException(stat.size);
    }

    // Peek first 8 KB for null bytes (binary detection)
    final raf = await file.open();
    try {
      final peek = await raf.read(_peekBytes);
      if (peek.contains(0)) {
        throw const BinaryFileException();
      }
    } finally {
      await raf.close();
    }

    final content = await file.readAsString();
    return FileContent(
      path: path,
      content: content,
      language: _languageFor(path),
      sizeBytes: stat.size,
    );
  }

  String? _languageFor(String path) {
    final ext = p.extension(path).toLowerCase();
    return switch (ext) {
      '.dart' => 'dart',
      '.json' => 'json',
      '.yaml' || '.yml' => 'yaml',
      '.md' => 'markdown',
      '.html' => 'xml',
      '.xml' => 'xml',
      '.css' => 'css',
      '.js' => 'javascript',
      '.ts' => 'typescript',
      '.py' => 'python',
      '.go' => 'go',
      '.rs' => 'rust',
      '.swift' => 'swift',
      '.kt' => 'kotlin',
      '.java' => 'java',
      '.sh' || '.bash' => 'bash',
      '.toml' => 'ini',
      _ => null,
    };
  }
}
