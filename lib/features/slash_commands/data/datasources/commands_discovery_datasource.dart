import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../claude/domain/entities/claude_event.dart';

class CommandsDiscoveryResult {
  const CommandsDiscoveryResult({required this.slashCommands, required this.skills, required this.plugins});

  final List<String> slashCommands;
  final List<String> skills;
  final List<ClaudePluginInfo> plugins;

  static const empty = CommandsDiscoveryResult(slashCommands: [], skills: [], plugins: []);
}

/// Pre-warm a `claude -p` subprocess with `/help` to capture the
/// `system/init` payload (slash_commands, skills, plugins). Costs $0
/// because the CLI rejects `/help` locally without an LLM call.
@lazySingleton
class CommandsDiscoveryDataSource {
  CommandsDiscoveryDataSource(this._talker);
  final Talker _talker;

  final Map<String, CommandsDiscoveryResult> _cache = {};

  Future<CommandsDiscoveryResult> discover({
    required String binary,
    required String cwd,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _cache[cwd];
      if (cached != null) return cached;
    }

    final result = await _spawnAndCapture(binary: binary, cwd: cwd);
    _cache[cwd] = result;
    return result;
  }

  void invalidate(String cwd) => _cache.remove(cwd);

  Future<CommandsDiscoveryResult> _spawnAndCapture({required String binary, required String cwd}) async {
    Process process;
    try {
      process = await Process.start(
        binary,
        const ['-p', '--input-format', 'stream-json', '--output-format', 'stream-json', '--verbose'],
        workingDirectory: cwd,
        environment: Platform.environment,
        runInShell: false,
      );
    } catch (e) {
      _talker.warning('discovery: spawn failed: $e');
      return CommandsDiscoveryResult.empty;
    }

    final completer = Completer<CommandsDiscoveryResult>();
    final stdoutSub = process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      if (completer.isCompleted) return;
      if (line.trim().isEmpty) return;
      try {
        final raw = jsonDecode(line);
        if (raw is! Map<String, dynamic>) return;
        if (raw['type'] != 'system' || raw['subtype'] != 'init') return;
        final pluginsRaw = raw['plugins'];
        final plugins = pluginsRaw is List
            ? pluginsRaw
                  .whereType<Map<String, dynamic>>()
                  .map(
                    (m) => ClaudePluginInfo(
                      name: m['name'] as String? ?? '',
                      path: m['path'] as String? ?? '',
                      source: m['source'] as String?,
                    ),
                  )
                  .where((p) => p.name.isNotEmpty && p.path.isNotEmpty)
                  .toList()
            : const <ClaudePluginInfo>[];
        completer.complete(
          CommandsDiscoveryResult(
            slashCommands: (raw['slash_commands'] as List?)?.cast<String>() ?? const [],
            skills: (raw['skills'] as List?)?.cast<String>() ?? const [],
            plugins: plugins,
          ),
        );
      } catch (_) {
        // ignore non-JSON lines
      }
    });

    process.stderr.drain<void>();

    try {
      process.stdin.writeln(
        jsonEncode({
          'type': 'user',
          'message': {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': '/help'},
            ],
          },
        }),
      );
      await process.stdin.flush();
      await process.stdin.close();
    } catch (e) {
      _talker.warning('discovery: stdin write failed: $e');
    }

    final result = await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _talker.warning('discovery: timed out for cwd=$cwd');
        return CommandsDiscoveryResult.empty;
      },
    );

    process.kill(ProcessSignal.sigterm);
    await stdoutSub.cancel();
    await process.exitCode.timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        process.kill(ProcessSignal.sigkill);
        return -1;
      },
    );

    return result;
  }
}
