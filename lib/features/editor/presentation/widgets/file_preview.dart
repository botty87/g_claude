import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;

import 'code_view.dart';
import 'image_view.dart';
import 'markdown_view.dart';
import 'pdf_view.dart';
import 'unsupported_binary_view.dart';

/// Dispatches to the correct viewer widget based on file extension.
class FilePreview extends StatelessWidget {
  const FilePreview({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return switch (_typeFor(path)) {
      _PreviewType.markdown => MarkdownView(path: path),
      _PreviewType.image => ImageView(path: path),
      _PreviewType.pdf => PdfView(path: path),
      _PreviewType.unsupported => UnsupportedBinaryView(path: path),
      _PreviewType.code => CodeView(path: path),
    };
  }

  static _PreviewType _typeFor(String path) {
    final ext = p.extension(path).toLowerCase();
    if (ext == '.md') return _PreviewType.markdown;
    if (_imageExts.contains(ext)) return _PreviewType.image;
    if (ext == '.pdf') return _PreviewType.pdf;
    if (_unsupportedExts.contains(ext)) return _PreviewType.unsupported;
    return _PreviewType.code;
  }

  static const _imageExts = {'.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp'};

  static const _unsupportedExts = {
    '.zip', '.gz', '.tar', '.bz2', '.7z', '.rar',
    '.exe', '.dmg', '.pkg', '.deb', '.rpm',
    '.bin', '.o', '.a', '.so', '.dylib', '.dll',
    '.class', '.pyc',
    '.mp3', '.mp4', '.mov', '.avi', '.mkv', '.flac', '.wav',
    '.db', '.sqlite', '.sqlite3',
    '.woff', '.woff2', '.ttf', '.otf',
  };
}

enum _PreviewType { markdown, image, pdf, unsupported, code }
