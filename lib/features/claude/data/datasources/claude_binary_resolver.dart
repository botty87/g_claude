import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

@lazySingleton
class ClaudeBinaryResolver {
  ClaudeBinaryResolver(this._talker);
  final Talker _talker;

  String? _cached;

  Future<String?> resolve() async {
    if (_cached != null) return _cached;

    final candidates = <String>[
      'claude',
      '/usr/local/bin/claude',
      '/opt/homebrew/bin/claude',
      _expandHome('~/.npm-global/bin/claude'),
      _expandHome('~/.local/bin/claude'),
      _expandHome('~/.bun/bin/claude'),
      _expandHome('~/.deno/bin/claude'),
    ];

    for (final c in candidates) {
      if (await _isExecutable(c)) {
        _cached = c;
        return c;
      }
    }

    final viaShell = await _resolveViaShell();
    if (viaShell != null && await _isExecutable(viaShell)) {
      _cached = viaShell;
      return viaShell;
    }

    _talker.error('Could not locate `claude` binary in PATH or common dirs');
    return null;
  }

  String _expandHome(String path) {
    if (!path.startsWith('~')) return path;
    final home = Platform.environment['HOME'];
    if (home == null) return path;
    return path.replaceFirst('~', home);
  }

  Future<bool> _isExecutable(String path) async {
    try {
      if (path == 'claude') {
        final r = await Process.run('claude', ['--version'], runInShell: false);
        return r.exitCode == 0;
      }
      final stat = await FileStat.stat(path);
      return stat.type == FileSystemEntityType.file;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _resolveViaShell() async {
    if (!Platform.isMacOS && !Platform.isLinux) return null;
    try {
      final r = await Process.run('zsh', ['-ilc', 'command -v claude'], runInShell: false);
      if (r.exitCode != 0) return null;
      final out = (r.stdout as String).trim();
      if (out.isEmpty) return null;
      return out.split('\n').first;
    } catch (_) {
      return null;
    }
  }
}
