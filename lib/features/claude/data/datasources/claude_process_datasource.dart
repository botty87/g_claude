import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../domain/entities/claude_event.dart';
import '../../domain/entities/claude_effort.dart';
import '../../domain/entities/claude_model.dart';
import '../../domain/entities/claude_permission_mode.dart';
import 'claude_binary_resolver.dart';
import 'claude_settings_writer.dart';
import 'permission_server.dart';

/// Wraps the `claude -p` subprocess: spawn, NDJSON parsing, normalization.
abstract interface class ClaudeProcessDataSource {
  Stream<ClaudeEvent> startRun({
    required String cwd,
    required String prompt,
    required ClaudePermissionMode mode,
    ClaudeModel? model,
    ClaudeEffort? effort,
    String? resumeSessionId,
    List<String> imagePaths = const [],
  });

  Future<void> stop();

  /// Sends a control_request envelope to the active subprocess stdin and waits
  /// for the matching control_response. Returns the inner `response` payload
  /// (may be empty). Throws [McpControlException] on error or [StateError] if
  /// no subprocess is active.
  Future<Map<String, dynamic>> sendControlRequest({
    required String subtype,
    required Map<String, dynamic> payload,
  });

  /// Writes a `tool_result` user message to stdin. Used to answer interactive
  /// tool calls (e.g. `AskUserQuestion`) so Claude can resume the run.
  /// `content` is JSON-encoded into the `content` field; pass already-stringified
  /// data when needed. Throws [StateError] if no subprocess is active.
  Future<void> sendToolResult({
    required String toolUseId,
    required Object content,
    bool isError = false,
  });
}

class McpControlException implements Exception {
  McpControlException(this.message);
  final String message;
  @override
  String toString() => 'McpControlException: $message';
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

/// Temporary kill-switch for the interactive `AskUserQuestion` card. The CLI
/// in `stream-json` mode auto-completes the tool with a synthetic error
/// instead of waiting for our `tool_result` (issue anthropics/claude-code
/// #16712), so the card never gets a chance to drive the run. Until that's
/// fixed upstream we disallow the tool: Claude falls back to asking the
/// questions as plain text, exactly like the non-IDE CLI. Flip this back to
/// `true` once Anthropic ships the fix.
const askUserQuestionInteractiveEnabled = false;

// NDJSON envelope keys per `claude -p --output-format stream-json` contract.
const _kType = 'type';
const _kSubtype = 'subtype';
const _kEvent = 'event';
const _kDelta = 'delta';
const _kIndex = 'index';
const _kContentBlock = 'content_block';
const _kMessage = 'message';
const _kContent = 'content';
const _kSessionId = 'session_id';
const _kModel = 'model';
const _kTools = 'tools';
const _kSkills = 'skills';
const _kSlashCommands = 'slash_commands';
const _kPlugins = 'plugins';

@LazySingleton(as: ClaudeProcessDataSource)
class ClaudeProcessDataSourceImpl implements ClaudeProcessDataSource {
  ClaudeProcessDataSourceImpl(
    this._talker,
    this._permissionServer,
    this._settingsWriter,
    this._binaryResolver,
  );

  final Talker _talker;
  final PermissionServer _permissionServer;
  final ClaudeSettingsWriter _settingsWriter;
  final ClaudeBinaryResolver _binaryResolver;

  Process? _current;

  static const _stderrTailMax = 200;

  final Map<int, _ToolBlockState> _toolByIndex = {};
  final Map<String, Completer<Map<String, dynamic>>> _pendingControlResponses = {};

  static final _rng = Random.secure();

  @override
  Stream<ClaudeEvent> startRun({
    required String cwd,
    required String prompt,
    required ClaudePermissionMode mode,
    ClaudeModel? model,
    ClaudeEffort? effort,
    String? resumeSessionId,
    List<String> imagePaths = const [],
  }) {
    final controller = StreamController<ClaudeEvent>();

    () async {
      final binary = await _binaryResolver.resolve();
      if (binary == null) {
        controller.addError(const ClaudeBinaryNotFoundException());
        await controller.close();
        return;
      }

      final port = await _permissionServer.start();
      final settingsPath = await _settingsWriter.ensure(port);

      final args = <String>[
        '-p',
        '--input-format',
        'stream-json',
        '--output-format',
        'stream-json',
        '--verbose',
        '--include-partial-messages',
        '--permission-mode',
        ClaudePermissionMode.defaultMode.cliFlag,
        '--settings',
        settingsPath,
        if (!askUserQuestionInteractiveEnabled) ...[
          '--disallowedTools',
          'AskUserQuestion',
        ],
        '--append-system-prompt',
        mode.systemPromptHint,
        if (model != null) ...['--model', model.cliId],
        if (effort != null) ...['--effort', effort.cliId],
        if (resumeSessionId != null) ...['--resume', resumeSessionId],
      ];

      _talker.debug('Spawning claude: $binary ${args.join(' ')} (cwd=$cwd)');

      Process process;
      try {
        process = await Process.start(binary, args, workingDirectory: cwd, environment: _buildEnv(), runInShell: false);
      } catch (e) {
        controller.addError(ClaudeSpawnException('$e'));
        await controller.close();
        return;
      }
      _current = process;
      _toolByIndex.clear();

      final stderrTail = Queue<String>();
      final stderrSub = process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        stderrTail.add(line);
        while (stderrTail.length > _stderrTailMax) {
          stderrTail.removeFirst();
        }
        _talker.debug('[claude stderr] $line');
      });

      final stdoutSub = process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        if (line.trim().isEmpty) return;
        try {
          final raw = jsonDecode(line);
          if (raw is! Map<String, dynamic>) return;
          // Intercept control_response before normal event parsing.
          if (raw['type'] == 'control_response') {
            final response = raw['response'] as Map<String, dynamic>?;
            final reqId = response?['request_id'] as String?;
            if (reqId != null) {
              final pending = _pendingControlResponses.remove(reqId);
              pending?.complete(response ?? {});
            }
            return;
          }
          for (final event in _normalize(raw)) {
            controller.add(event);
          }
        } catch (e) {
          _talker.warning('Could not parse NDJSON line: $line ($e)');
        }
      });

      try {
        final imageBlocks = <Map<String, Object>>[];
        for (final path in imagePaths) {
          try {
            final bytes = await File(path).readAsBytes();
            imageBlocks.add({
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': 'image/jpeg',
                'data': base64Encode(bytes),
              },
            });
          } catch (e) {
            _talker.warning('Failed to read screenshot image: $path ($e)');
          }
        }
        final payload = {
          'type': 'user',
          'message': {
            'role': 'user',
            'content': [
              ...imageBlocks,
              {'type': 'text', 'text': prompt},
            ],
          },
        };
        process.stdin.writeln(jsonEncode(payload));
        await process.stdin.flush();
        // stdin is intentionally kept open so control_request messages can be
        // written during the run. It is closed after the process exits.
      } catch (e) {
        _talker.warning('Failed to write to claude stdin: $e');
      }

      final exitCode = await process.exitCode;
      await stdoutSub.cancel();
      await stderrSub.cancel();

      // Fail any control_requests still pending — the process is gone.
      _failPendingControlResponses('subprocess exited');

      // Close stdin now that the process has exited.
      try {
        await process.stdin.close();
      } catch (_) {}

      _current = null;

      if (!controller.isClosed) {
        controller.add(ClaudeEvent.sessionDead(exitCode: exitCode, stderrTail: stderrTail.toList(growable: false)));
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
    final exited = await p.exitCode.timeout(const Duration(seconds: 2), onTimeout: () => -1);
    if (exited == -1) {
      p.kill(ProcessSignal.sigkill);
    }
  }

  @override
  Future<void> sendToolResult({
    required String toolUseId,
    required Object content,
    bool isError = false,
  }) async {
    final process = _current;
    if (process == null) {
      throw StateError('sendToolResult: no active subprocess');
    }
    final encoded = content is String ? content : jsonEncode(content);
    final envelope = {
      'type': 'user',
      'message': {
        'role': 'user',
        'content': [
          {
            'type': 'tool_result',
            'tool_use_id': toolUseId,
            'content': encoded,
            if (isError) 'is_error': true,
          },
        ],
      },
    };
    try {
      process.stdin.writeln(jsonEncode(envelope));
      await process.stdin.flush();
    } catch (e) {
      _talker.warning('sendToolResult: stdin write failed: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> sendControlRequest({
    required String subtype,
    required Map<String, dynamic> payload,
  }) async {
    final process = _current;
    if (process == null) {
      throw StateError('sendControlRequest: no active subprocess');
    }
    final id = _generateRequestId();
    final completer = Completer<Map<String, dynamic>>();
    _pendingControlResponses[id] = completer;
    final envelope = {
      'type': 'control_request',
      'request_id': id,
      'request': {'subtype': subtype, ...payload},
    };
    try {
      process.stdin.writeln(jsonEncode(envelope));
      await process.stdin.flush();
    } catch (e) {
      _pendingControlResponses.remove(id);
      rethrow;
    }
    try {
      final response = await completer.future.timeout(const Duration(seconds: 30));
      final subtypeResp = response['subtype'] as String?;
      if (subtypeResp == 'error') {
        throw McpControlException(response['error']?.toString() ?? 'unknown error');
      }
      final inner = response['response'];
      return inner is Map<String, dynamic> ? inner : <String, dynamic>{};
    } on TimeoutException {
      _pendingControlResponses.remove(id);
      throw McpControlException('control_request timed out');
    }
  }

  String _generateRequestId() {
    // No uuid package in pubspec — generate a sufficiently unique local ID.
    final ts = DateTime.now().microsecondsSinceEpoch;
    final rand = _rng.nextInt(1 << 32);
    return '$ts-$rand';
  }

  void _failPendingControlResponses(String reason) {
    final pending = Map.of(_pendingControlResponses);
    _pendingControlResponses.clear();
    for (final completer in pending.values) {
      if (!completer.isCompleted) {
        completer.completeError(McpControlException(reason));
      }
    }
  }

  Map<String, String> _buildEnv() {
    final env = Map<String, String>.from(Platform.environment);
    return env;
  }

  /// Test-only entry point for the NDJSON normalizer. Use real fixtures as
  /// input — synthesizing JSON in a test re-encodes our assumptions about the
  /// stream-json contract instead of the contract itself.
  @visibleForTesting
  Iterable<ClaudeEvent> normalizeForTest(Map<String, dynamic> raw) => _normalize(raw);

  /// Resets the in-flight tool block tracker. Tests that reuse the same
  /// instance across scenarios should call this between scenarios.
  @visibleForTesting
  void resetParserStateForTest() => _toolByIndex.clear();

  /// Maps a raw NDJSON object (per the `claude -p --output-format stream-json`
  /// contract) into a list of [ClaudeEvent]. May emit zero or more events.
  Iterable<ClaudeEvent> _normalize(Map<String, dynamic> raw) sync* {
    final type = raw[_kType] as String?;
    switch (type) {
      case 'system':
        if (raw[_kSubtype] == 'init') {
          final pluginsRaw = raw[_kPlugins];
          final plugins = pluginsRaw is List
              ? pluginsRaw
                  .whereType<Map<String, dynamic>>()
                  .map((m) => ClaudePluginInfo(
                        name: m['name'] as String? ?? '',
                        path: m['path'] as String? ?? '',
                        source: m['source'] as String?,
                      ))
                  .where((p) => p.name.isNotEmpty && p.path.isNotEmpty)
                  .toList()
              : const <ClaudePluginInfo>[];
          yield ClaudeEvent.sessionInit(
            sessionId: raw[_kSessionId] as String? ?? '',
            model: raw[_kModel] as String? ?? '',
            tools: (raw[_kTools] as List?)?.cast<String>() ?? const [],
            skills: (raw[_kSkills] as List?)?.cast<String>() ?? const [],
            slashCommands: (raw[_kSlashCommands] as List?)?.cast<String>() ?? const [],
            plugins: plugins,
          );
        }
        return;

      case 'stream_event':
        final inner = raw[_kEvent];
        if (inner is! Map<String, dynamic>) return;
        final innerType = inner[_kType] as String?;
        switch (innerType) {
          case 'content_block_delta':
            final delta = inner[_kDelta];
            if (delta is Map<String, dynamic>) {
              final dType = delta[_kType] as String?;
              if (dType == 'text_delta') {
                final text = delta['text'] as String? ?? '';
                if (text.isEmpty) return;
                yield ClaudeEvent.textChunk(text: text);
                return;
              }
              if (dType == 'input_json_delta') {
                final partial = delta['partial_json'] as String? ?? '';
                final index = (inner[_kIndex] as int?) ?? 0;
                final tool = _toolByIndex[index];
                if (tool != null) tool.partialJson.write(partial);
                yield ClaudeEvent.toolCallUpdate(toolId: tool?.toolId ?? '', partialInput: partial);
              }
            }
            return;

          case 'content_block_start':
            final block = inner[_kContentBlock];
            final index = (inner[_kIndex] as int?) ?? 0;
            if (block is Map<String, dynamic> && block[_kType] == 'tool_use') {
              final toolName = block['name'] as String? ?? '';
              final toolId = block['id'] as String? ?? '';
              _toolByIndex[index] = _ToolBlockState(toolName: toolName, toolId: toolId);
              yield ClaudeEvent.toolCall(toolName: toolName, toolId: toolId, index: index);
            }
            return;

          case 'content_block_stop':
            final index = (inner[_kIndex] as int?) ?? 0;
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
            yield ClaudeEvent.toolCallComplete(index: index, toolId: tool?.toolId, input: input);
            if (askUserQuestionInteractiveEnabled &&
                tool != null &&
                tool.toolName == 'AskUserQuestion' &&
                tool.toolId.isNotEmpty &&
                input != null) {
              final questions = _parseAskUserQuestions(input);
              if (questions.isNotEmpty) {
                yield ClaudeEvent.askUserQuestion(
                  toolUseId: tool.toolId,
                  questions: questions,
                );
              }
            }
            return;

          default:
            return;
        }

      case 'assistant':
        final message = raw[_kMessage];
        if (message is Map<String, dynamic>) {
          final content = message[_kContent];
          if (content is List) {
            final buf = StringBuffer();
            for (final block in content) {
              if (block is Map<String, dynamic> && block[_kType] == 'text') {
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
        final message = raw[_kMessage];
        if (message is Map<String, dynamic>) {
          final content = message[_kContent];
          if (content is List) {
            for (final block in content) {
              if (block is Map<String, dynamic> && block[_kType] == 'tool_result') {
                yield ClaudeEvent.toolResult(
                  toolUseId: block['tool_use_id'] as String? ?? '',
                  content: _flattenToolResultContent(block[_kContent]),
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
          yield ClaudeEvent.errorEvent(message: raw['result'] as String? ?? raw['error'] as String? ?? 'Unknown error');
          return;
        }
        yield ClaudeEvent.taskComplete(
          result: raw['result'] as String?,
          costUsd: (raw['total_cost_usd'] as num?)?.toDouble() ?? (raw['cost_usd'] as num?)?.toDouble(),
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

  List<AskUserQuestionItem> _parseAskUserQuestions(Map<String, dynamic> input) {
    final raw = input['questions'];
    if (raw is! List) return const [];
    final result = <AskUserQuestionItem>[];
    for (final q in raw) {
      if (q is! Map) continue;
      final question = q['question'] as String? ?? '';
      if (question.isEmpty) continue;
      final optsRaw = q['options'];
      final options = <AskUserQuestionOption>[];
      if (optsRaw is List) {
        for (final o in optsRaw) {
          if (o is Map) {
            final label = o['label'] as String? ?? '';
            if (label.isEmpty) continue;
            options.add(AskUserQuestionOption(
              label: label,
              description: o['description'] as String? ?? '',
            ));
          }
        }
      }
      result.add(AskUserQuestionItem(
        question: question,
        header: q['header'] as String? ?? '',
        multiSelect: q['multiSelect'] == true,
        options: options,
      ));
    }
    return result;
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
