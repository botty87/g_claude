import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../domain/entities/mcp_server.dart';
import 'claude_binary_resolver.dart';

@lazySingleton
class McpListDataSource {
  McpListDataSource(this._talker, this._binary);
  final Talker _talker;
  final ClaudeBinaryResolver _binary;

  Future<List<McpServer>> list() async {
    final binary = await _binary.resolve() ?? 'claude';
    final result = await Process.run(binary, ['mcp', 'list']);
    if (result.exitCode != 0) {
      throw McpListException('mcp list exit ${result.exitCode}: ${result.stderr}');
    }
    final stdout = result.stdout is String ? result.stdout as String : utf8.decode(result.stdout as List<int>);
    final servers = parseOutput(stdout);
    _talker.verbose('mcp list parsed: ${servers.length} servers');
    return servers;
  }

  // Exposed for testing (visible for testing).
  static List<McpServer> parseOutput(String stdout) {
    final out = <McpServer>[];
    for (final line in const LineSplitter().convert(stdout)) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      if (trimmed.startsWith('Checking')) continue;
      final m = _lineRegex.firstMatch(trimmed);
      if (m == null) continue;
      final name = m.group(1)!.trim();
      final cmd = m.group(2)!.trim();
      final statusStr = m.group(3)!.trim();
      out.add(McpServer(name: name, displayName: _cleanName(name), commandOrUrl: cmd, status: _parseStatus(statusStr)));
    }
    return out;
  }

  static final RegExp _lineRegex = RegExp(r'^(.+?): (.+?) - (.+)$');

  /// Matches on wording, not the leading glyph: the CLI varies the mark
  /// (`✔` U+2714 for connected, `✗`/`!`), so an exact-glyph map silently
  /// degraded every connected server to `unknown`.
  ///
  /// Order matters. `connected` is checked before `failed` so the warning
  /// variant `! Connected · tools fetch failed` (server up, tools unavailable)
  /// counts as connected — while `✗ Failed to connect` has no "connected"
  /// substring ("connect" ≠ "connected") and still falls through to failed.
  static McpServerStatus _parseStatus(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('needs authentication')) return McpServerStatus.needsAuth;
    if (s.contains('connected')) return McpServerStatus.connected;
    if (s.contains('failed')) return McpServerStatus.failed;
    return McpServerStatus.unknown;
  }

  static String _cleanName(String raw) {
    if (raw.startsWith('plugin:')) {
      final parts = raw.split(':');
      return parts.length >= 3 ? parts.last : raw;
    }
    const claudeAiPrefix = 'claude.ai ';
    if (raw.startsWith(claudeAiPrefix)) {
      return raw.substring(claudeAiPrefix.length);
    }
    return raw;
  }
}

class McpListException implements Exception {
  McpListException(this.message);
  final String message;

  @override
  String toString() => 'McpListException: $message';
}
