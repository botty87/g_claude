import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../domain/entities/claude_event.dart';
import '../../domain/entities/claude_model.dart';
import '../../domain/entities/claude_permission_mode.dart';
import 'claude_settings_writer.dart';
import 'permission_server.dart';

/// Wraps the `claude -p` subprocess: spawn, NDJSON parsing, normalization.
abstract interface class ClaudeProcessDataSource {
  Stream<ClaudeEvent> startRun({
    required String cwd,
    required String prompt,
    required ClaudePermissionMode mode,
    ClaudeModel? model,
    String? resumeSessionId,
  });

  Future<void> stop();
}

class ClaudeBinaryNotFoundException implements Exception {
  const ClaudeBinaryNotFoundException();
  @override
  String toString() => 'ClaudeBinaryNotFoundException';
}

class ClaudeSpawnException implements Exception {
  ClaudeSpawnException(this.message);
  final String message;
  @override
  String toString() => 'ClaudeSpawnException: $message';
}

@LazySingleton(as: ClaudeProcessDataSource)
class ClaudeProcessDataSourceImpl implements ClaudeProcessDataSource {
  ClaudeProcessDataSourceImpl(
    this._talker,
    this._permissionServer,
    this._settingsWriter,
  );

  final Talker _talker;
  final PermissionServer _permissionServer;
  final ClaudeSettingsWriter _settingsWriter;

  Process? _current;
  String? _binaryPath;

  static const _stderrTailMax = 200;

  // Per-run state for reconstructing tool input from `input_json_delta`
  // streams and matching `content_block_stop` to the right tool.
  final Map<int, _ToolBlockState> _toolByIndex = {};

  @override
  Stream<ClaudeEvent> startRun({
    required String cwd,
    required String prompt,
    required ClaudePermissionMode mode,
    ClaudeModel? model,
    String? resumeSessionId,
  }) {
    final controller = StreamController<ClaudeEvent>();

    () async {
      final binary = _binaryPath ?? await _resolveBinary();
      if (binary == null) {
        controller.addError(const ClaudeBinaryNotFoundException());
        await controller.close();
        return;
      }
      _binaryPath = binary;

      final port = await _permissionServer.start();
      final settingsPath = await _settingsWriter.ensure(port);

      final args = <String>[
        '-p',
        '--input-format', 'stream-json',
        '--output-format', 'stream-json',
        '--verbose',
        '--include-partial-messages',
        '--permission-mode', 'default',
        '--settings', settingsPath,
        '--append-system-prompt', mode.systemPromptHint,
        if (model != null) ...['--model', model.cliId],
        if (resumeSessionId != null) ...['--resume', resumeSessionId],
      ];

      _talker.debug('Spawning claude: $binary ${args.join(' ')} (cwd=$cwd)');

      Process process;
      try {
        process = await Process.start(
          binary,
          args,
          workingDirectory: cwd,
          environment: _buildEnv(),
          runInShell: false,
        );
      } catch (e) {
        controller.addError(ClaudeSpawnException('$e'));
        await controller.close();
        return;
      }
      _current = process;
      _toolByIndex.clear();

      final stderrTail = Queue<String>();
      final stderrSub = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        stderrTail.add(line);
        while (stderrTail.length > _stderrTailMax) {
          stderrTail.removeFirst();
        }
        _talker.debug('[claude stderr] $line');
      });

      final stdoutSub = process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.trim().isEmpty) return;
        try {
          final raw = jsonDecode(line);
          if (raw is! Map<String, dynamic>) return;
          for (final event in _normalize(raw)) {
            controller.add(event);
          }
        } catch (e) {
          _talker.warning('Could not parse NDJSON line: $line ($e)');
        }
      });

      try {
        final payload = {
          'type': 'user',
          'message': {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
            ],
          },
        };
        process.stdin.writeln(jsonEncode(payload));
        await process.stdin.flush();
        await process.stdin.close();
      } catch (e) {
        _talker.warning('Failed to write to claude stdin: $e');
      }

      final exitCode = await process.exitCode;
      await stdoutSub.cancel();
      await stderrSub.cancel();
      _current = null;

      if (!controller.isClosed) {
        controller.add(ClaudeEvent.sessionDead(
          exitCode: exitCode,
          stderrTail: stderrTail.toList(growable: false),
        ));
        await controller.close();
      }
    }();

    return controller.stream;
  }

  @override
  Future<void> stop() async {
    final p = _current;
    if (p == null) return;
    p.kill(ProcessSignal.sigterm);
    final exited = await p.exitCode
        .timeout(const Duration(seconds: 2), onTimeout: () => -1);
    if (exited == -1) {
      p.kill(ProcessSignal.sigkill);
    }
  }

  Map<String, String> _buildEnv() {
    final env = Map<String, String>.from(Platform.environment);
    return env;
  }

  Future<String?> _resolveBinary() async {
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
      if (await _isExecutable(c)) return c;
    }

    final viaShell = await _resolveViaShell();
    if (viaShell != null && await _isExecutable(viaShell)) return viaShell;

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
        // PATH-based; let Process.start resolve it. Probe with --version.
        final r = await Process.run('claude', ['--version'],
            runInShell: false);
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
      final r = await Process.run('zsh', ['-ilc', 'command -v claude'],
          runInShell: false);
      if (r.exitCode != 0) return null;
      final out = (r.stdout as String).trim();
      if (out.isEmpty) return null;
      return out.split('\n').first;
    } catch (_) {
      return null;
    }
  }

  /// Maps a raw NDJSON object (per the `claude -p --output-format stream-json`
  /// contract) into a list of [ClaudeEvent]. May emit zero or more events.
  Iterable<ClaudeEvent> _normalize(Map<String, dynamic> raw) sync* {
    final type = raw['type'] as String?;
    switch (type) {
      case 'system':
        if (raw['subtype'] == 'init') {
          yield ClaudeEvent.sessionInit(
            sessionId: raw['session_id'] as String? ?? '',
            model: raw['model'] as String? ?? '',
            tools: (raw['tools'] as List?)?.cast<String>() ?? const [],
          );
        }
        return;

      case 'stream_event':
        final inner = raw['event'];
        if (inner is! Map<String, dynamic>) return;
        final innerType = inner['type'] as String?;
        switch (innerType) {
          case 'content_block_delta':
            final delta = inner['delta'];
            if (delta is Map<String, dynamic>) {
              final dType = delta['type'] as String?;
              if (dType == 'text_delta') {
                final text = delta['text'] as String? ?? '';
                if (text.isEmpty) return;
                yield ClaudeEvent.textChunk(text: text);
                return;
              }
              if (dType == 'input_json_delta') {
                final partial = delta['partial_json'] as String? ?? '';
                final index = (inner['index'] as int?) ?? 0;
                final tool = _toolByIndex[index];
                if (tool != null) tool.partialJson.write(partial);
                yield ClaudeEvent.toolCallUpdate(
                  toolId: tool?.toolId ?? '',
                  partialInput: partial,
                );
              }
            }
            return;

          case 'content_block_start':
            final block = inner['content_block'];
            final index = (inner['index'] as int?) ?? 0;
            if (block is Map<String, dynamic> && block['type'] == 'tool_use') {
              final toolName = block['name'] as String? ?? '';
              final toolId = block['id'] as String? ?? '';
              _toolByIndex[index] = _ToolBlockState(
                toolName: toolName,
                toolId: toolId,
              );
              yield ClaudeEvent.toolCall(
                toolName: toolName,
                toolId: toolId,
                index: index,
              );
            }
            return;

          case 'content_block_stop':
            final index = (inner['index'] as int?) ?? 0;
            final tool = _toolByIndex.remove(index);
            Map<String, dynamic>? input;
            if (tool != null) {
              final json = tool.partialJson.toString();
              if (json.isNotEmpty) {
                try {
                  final decoded = jsonDecode(json);
                  if (decoded is Map<String, dynamic>) input = decoded;
                } catch (_) {
                  // partial JSON ill-formed; ignore
                }
              }
            }
            yield ClaudeEvent.toolCallComplete(
              index: index,
              toolId: tool?.toolId,
              input: input,
            );
            return;

          default:
            return;
        }

      case 'assistant':
        final message = raw['message'];
        if (message is Map<String, dynamic>) {
          final content = message['content'];
          if (content is List) {
            final buf = StringBuffer();
            for (final block in content) {
              if (block is Map<String, dynamic> && block['type'] == 'text') {
                buf.write(block['text'] as String? ?? '');
              }
            }
            final text = buf.toString();
            if (text.isNotEmpty) {
              yield ClaudeEvent.assistantMessage(text: text);
            }
          }
        }
        return;

      case 'user':
        final message = raw['message'];
        if (message is Map<String, dynamic>) {
          final content = message['content'];
          if (content is List) {
            for (final block in content) {
              if (block is Map<String, dynamic> &&
                  block['type'] == 'tool_result') {
                yield ClaudeEvent.toolResult(
                  toolUseId: block['tool_use_id'] as String? ?? '',
                  content: _flattenToolResultContent(block['content']),
                  isError: block['is_error'] == true,
                );
              }
            }
          }
        }
        return;

      case 'result':
        final isError = raw['is_error'] == true;
        if (isError) {
          yield ClaudeEvent.errorEvent(
            message: raw['result'] as String? ??
                raw['error'] as String? ??
                'Unknown error',
          );
          return;
        }
        yield ClaudeEvent.taskComplete(
          result: raw['result'] as String?,
          costUsd: (raw['total_cost_usd'] as num?)?.toDouble() ??
              (raw['cost_usd'] as num?)?.toDouble(),
          durationMs: (raw['duration_ms'] as num?)?.toInt(),
          numTurns: (raw['num_turns'] as num?)?.toInt(),
        );
        return;

      case 'rate_limit_event':
        yield ClaudeEvent.rateLimit(
          status: raw['status'] as String? ?? 'unknown',
          resetsAt: (raw['resets_at'] as num?)?.toInt(),
        );
        return;

      default:
        return;
    }
  }

  String _flattenToolResultContent(Object? content) {
    if (content == null) return '';
    if (content is String) return content;
    if (content is List) {
      final buf = StringBuffer();
      for (final block in content) {
        if (block is Map<String, dynamic>) {
          final type = block['type'] as String?;
          if (type == 'text') {
            buf.write(block['text'] as String? ?? '');
          } else if (type == 'image') {
            buf.write('[image]');
          } else {
            buf.write(jsonEncode(block));
          }
          buf.write('\n');
        } else {
          buf.write(block.toString());
          buf.write('\n');
        }
      }
      return buf.toString().trimRight();
    }
    return content.toString();
  }
}

class _ToolBlockState {
  _ToolBlockState({required this.toolName, required this.toolId});
  final String toolName;
  final String toolId;
  final StringBuffer partialJson = StringBuffer();
}
