import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../domain/entities/claude_effort.dart';
import '../../domain/entities/claude_event.dart';
import '../../domain/entities/claude_model.dart';
import '../../domain/entities/claude_permission_mode.dart';
import 'sidecar_transport.dart';

@lazySingleton
class SidecarClientDataSource {
  SidecarClientDataSource(this._transport, this._talker);

  final SidecarTransport _transport;
  final Talker _talker;

  /// Cache of raw question lists per toolUseID so answerQuestion can replay
  /// them verbatim in the protocol request (sidecar requires them back).
  final Map<String, List<Map<String, dynamic>>> _questionCache = {};

  Stream<ClaudeEvent> startRun({
    required String cwd,
    required String prompt,
    required ClaudePermissionMode mode,
    ClaudeModel? model,
    ClaudeEffort? effort,
    bool thinking = true,
    String? resumeSessionId,
    List<String> imagePaths = const [],
  }) async* {
    await _transport.start();

    final sid = cwd;
    final req = <String, dynamic>{
      't': 'start',
      'sid': sid,
      'cwd': cwd,
      'prompt': prompt,
      'mode': mode.cliFlag,
      if (model != null) 'model': model.cliId,
      if (effort != null) 'effort': effort.cliId,
      'thinking': thinking,
      // ignore: use_null_aware_elements
      if (resumeSessionId != null) 'resume': resumeSessionId,
      if (imagePaths.isNotEmpty) 'images': imagePaths,
    };
    _transport.send(req);

    // Stream events for this sid until sessionDead arrives.
    final controller = StreamController<ClaudeEvent>();

    late StreamSubscription<Map<String, dynamic>> sub;
    sub = _transport.events
        .where((raw) => raw['sid'] == sid)
        .listen(
          (raw) {
            final type = raw['t'] as String?;
            final event = _mapEvent(raw, type);
            if (event != null) {
              controller.add(event);
            }
            if (type == 'sessionDead') {
              sub.cancel();
              controller.close();
            }
          },
          onError: (Object e, StackTrace st) {
            controller.addError(e, st);
            controller.close();
          },
          onDone: () {
            if (!controller.isClosed) controller.close();
          },
        );

    yield* controller.stream;
  }

  Future<void> stop({required String sid}) async {
    _transport.send({'t': 'stop', 'sid': sid});
  }

  void respondPermission({required String sid, required String toolUseID, required bool allow, bool remember = false}) {
    _transport.send({
      't': 'permission',
      'sid': sid,
      'toolUseID': toolUseID,
      'decision': allow ? 'allow' : 'deny',
      if (remember) 'remember': true,
    });
  }

  void answerQuestion({required String sid, required String toolUseID, required Map<String, String> answers}) {
    final questions = _questionCache[toolUseID];
    if (questions == null) {
      _talker.warning('answerQuestion: no cached questions for toolUseID=$toolUseID');
      return;
    }
    _transport.send({
      't': 'answerQuestion',
      'sid': sid,
      'toolUseID': toolUseID,
      'questions': questions,
      'answers': answers,
    });
    _questionCache.remove(toolUseID);
  }

  void answerPlan({required String sid, required String toolUseID, required bool approve, ClaudePermissionMode? mode}) {
    _transport.send({
      't': 'plan',
      'sid': sid,
      'toolUseID': toolUseID,
      'decision': approve ? 'approve' : 'reject',
      if (mode != null) 'mode': mode.cliFlag,
    });
  }

  void setMode({required String sid, required ClaudePermissionMode mode}) {
    _transport.send({'t': 'setMode', 'sid': sid, 'mode': mode.cliFlag});
  }

  // ---------------------------------------------------------------------------
  // Protocol event → ClaudeEvent mapping
  // ---------------------------------------------------------------------------

  ClaudeEvent? _mapEvent(Map<String, dynamic> raw, String? type) {
    switch (type) {
      case 'sessionInit':
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
        return ClaudeEvent.sessionInit(
          sessionId: raw['sessionId'] as String? ?? '',
          model: raw['model'] as String? ?? '',
          tools: (raw['tools'] as List?)?.cast<String>() ?? const [],
          skills: (raw['skills'] as List?)?.cast<String>() ?? const [],
          slashCommands: (raw['slashCommands'] as List?)?.cast<String>() ?? const [],
          plugins: plugins,
        );

      case 'textChunk':
        return ClaudeEvent.textChunk(text: raw['text'] as String? ?? '');

      case 'toolCall':
        return ClaudeEvent.toolCall(
          toolName: raw['toolName'] as String? ?? '',
          toolId: raw['toolId'] as String? ?? '',
          index: (raw['index'] as num?)?.toInt() ?? 0,
        );

      case 'toolCallUpdate':
        return ClaudeEvent.toolCallUpdate(
          toolId: raw['toolId'] as String? ?? '',
          partialInput: raw['partialInput'] as String? ?? '',
        );

      case 'toolCallComplete':
        Map<String, dynamic>? input;
        final rawInput = raw['input'];
        if (rawInput is Map<String, dynamic>) {
          input = rawInput;
        } else if (rawInput is String && rawInput.isNotEmpty) {
          try {
            final decoded = jsonDecode(rawInput);
            if (decoded is Map<String, dynamic>) input = decoded;
          } catch (_) {}
        }
        return ClaudeEvent.toolCallComplete(
          index: (raw['index'] as num?)?.toInt() ?? 0,
          toolId: raw['toolId'] as String?,
          input: input,
        );

      case 'toolResult':
        return ClaudeEvent.toolResult(
          toolUseId: raw['toolUseId'] as String? ?? '',
          content: raw['content'] as String? ?? '',
          isError: raw['isError'] == true,
        );

      case 'assistantMessage':
        return ClaudeEvent.assistantMessage(text: raw['text'] as String? ?? '');

      case 'usageUpdate':
        return ClaudeEvent.usageUpdate(
          inputTokens: (raw['inputTokens'] as num?)?.toInt(),
          cacheReadTokens: (raw['cacheReadTokens'] as num?)?.toInt(),
          cacheCreationTokens: (raw['cacheCreationTokens'] as num?)?.toInt(),
          outputTokens: (raw['outputTokens'] as num?)?.toInt(),
        );

      case 'taskComplete':
        return ClaudeEvent.taskComplete(
          result: raw['result'] as String?,
          costUsd: (raw['costUsd'] as num?)?.toDouble(),
          durationMs: (raw['durationMs'] as num?)?.toInt(),
          numTurns: (raw['numTurns'] as num?)?.toInt(),
        );

      case 'errorEvent':
        return ClaudeEvent.errorEvent(message: raw['message'] as String? ?? 'unknown');

      case 'rateLimit':
        return ClaudeEvent.rateLimit(
          status: raw['status'] as String? ?? 'unknown',
          resetsAt: (raw['resetsAt'] as num?)?.toInt(),
        );

      case 'sessionDead':
        final tail = raw['stderrTail'];
        return ClaudeEvent.sessionDead(
          exitCode: (raw['exitCode'] as num?)?.toInt(),
          stderrTail: tail is List ? tail.cast<String>() : const [],
        );

      case 'permissionRequest':
        return ClaudeEvent.permissionRequest(
          requestId: raw['toolUseID'] as String? ?? '',
          toolName: raw['toolName'] as String? ?? '',
          toolInput: (raw['toolInput'] as Map?)?.cast<String, dynamic>() ?? const {},
        );

      case 'askUserQuestion':
        final toolUseID = raw['toolUseID'] as String? ?? '';
        final questionsRaw = raw['questions'];
        final rawList = questionsRaw is List
            ? questionsRaw.whereType<Map<String, dynamic>>().toList()
            : const <Map<String, dynamic>>[];
        // Cache raw questions for the answerQuestion round-trip.
        if (toolUseID.isNotEmpty) {
          _questionCache[toolUseID] = rawList;
        }
        final questions = rawList.map(_parseQuestionItem).where((q) => q.question.isNotEmpty).toList();
        return ClaudeEvent.askUserQuestion(toolUseId: toolUseID, questions: questions);

      case 'planProposed':
        return ClaudeEvent.planProposed(
          toolUseId: raw['toolUseID'] as String? ?? '',
          plan: raw['plan'] as String? ?? '',
          planFilePath: raw['planFilePath'] as String?,
        );

      default:
        return null;
    }
  }

  AskUserQuestionItem _parseQuestionItem(Map<String, dynamic> q) {
    final question = q['question'] as String? ?? '';
    final optsRaw = q['options'];
    final options = <AskUserQuestionOption>[];
    if (optsRaw is List) {
      for (final o in optsRaw) {
        if (o is Map) {
          final label = o['label'] as String? ?? '';
          if (label.isEmpty) continue;
          options.add(AskUserQuestionOption(label: label, description: o['description'] as String? ?? ''));
        }
      }
    }
    return AskUserQuestionItem(
      question: question,
      header: q['header'] as String? ?? '',
      multiSelect: q['multiSelect'] == true,
      options: options,
    );
  }
}
