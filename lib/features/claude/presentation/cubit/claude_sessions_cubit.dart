import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../data/datasources/permission_server.dart';
import '../../domain/entities/claude_event.dart';
import '../../domain/entities/claude_message.dart';
import '../../domain/entities/claude_model.dart';
import '../../domain/entities/claude_permission_mode.dart';
import '../../domain/usecases/send_prompt.dart';
import '../../domain/usecases/stop_run.dart';

part 'claude_sessions_cubit.freezed.dart';
part 'claude_sessions_cubit.state.dart';

@lazySingleton
class ClaudeSessionsCubit extends Cubit<ClaudeSessionsState> {
  ClaudeSessionsCubit(
    this._sendPrompt,
    this._stopRun,
    this._workspacesCubit,
    this._permissionServer,
    this._prefs,
    this._talker,
  ) : super(const ClaudeSessionsState());

  final SendPrompt _sendPrompt;
  final StopRun _stopRun;
  final WorkspacesCubit _workspacesCubit;
  final PermissionServer _permissionServer;
  final SharedPreferences _prefs;
  final Talker _talker;

  StreamSubscription<WorkspacesState>? _workspacesSub;
  StreamSubscription<Either<Failure, ClaudeEvent>>? _runSub;
  Timer? _chunkFlushTimer;

  String? _runningWorkspaceId;
  String? _streamingMessageId;
  String _streamingText = '';

  /// Maps a Claude `session_id` (received in InitEvent) to the workspace
  /// that owns the session, so the PermissionServer hook can lookup the
  /// active permission mode at decision time.
  final Map<String, String> _sessionToWorkspace = {};

  static const _modelPrefix = 'claude.model.';
  static const _permPrefix = 'claude.permission.';
  static const _flushMs = 16;

  /// Tools that can be safely allowed in plan mode (read-only or pure UI).
  static const _readOnlyTools = <String>{
    'Read',
    'Glob',
    'Grep',
    'BashOutput',
    'KillShell',
    'NotebookRead',
    'TodoWrite',
    'WebFetch',
    'WebSearch',
    'ExitPlanMode',
    'ListMcpResourcesTool',
    'ReadMcpResourceTool',
  };

  @PostConstruct()
  void init() {
    _workspacesSub = _workspacesCubit.stream.listen(_onWorkspacesChanged);
    _onWorkspacesChanged(_workspacesCubit.state);
    _permissionServer.setResolver(_resolvePermission);
    unawaited(_permissionServer.start());
  }

  Future<PermissionDecision> _resolvePermission(PermissionRequest req) async {
    final wid = _sessionToWorkspace[req.sessionId];
    if (wid == null) {
      _talker.warning(
        'PermissionServer: unknown session ${req.sessionId} '
        'tool=${req.toolName} -> defaulting allow',
      );
      return PermissionDecision.allow;
    }
    final session = state.sessions[wid];
    if (session == null) return PermissionDecision.allow;
    return _decisionFor(session.permissionMode, req.toolName);
  }

  PermissionDecision _decisionFor(
    ClaudePermissionMode mode,
    String toolName,
  ) {
    switch (mode) {
      case ClaudePermissionMode.plan:
        return _readOnlyTools.contains(toolName)
            ? PermissionDecision.allow
            : PermissionDecision.deny;
      case ClaudePermissionMode.acceptEdits:
      case ClaudePermissionMode.bypassPermissions:
      case ClaudePermissionMode.defaultMode:
        return PermissionDecision.allow;
    }
  }

  void _onWorkspacesChanged(WorkspacesState s) {
    final list = s.workspacesOrEmpty;
    final map = Map<String, ClaudeSessionData>.from(state.sessions);
    for (final w in list) {
      if (!map.containsKey(w.id)) {
        map[w.id] = ClaudeSessionData(
          model: _readModel(w.id),
          permissionMode: _readPermission(w.id),
        );
      }
    }
    final ids = list.map((w) => w.id).toSet();
    final removed = map.keys.where((id) => !ids.contains(id)).toList();
    for (final id in removed) {
      final closed = map[id];
      final claudeSessionId = closed?.claudeSessionId;
      if (claudeSessionId != null) {
        _sessionToWorkspace.remove(claudeSessionId);
      }
      map.remove(id);
    }
    if (removed.isNotEmpty &&
        _runningWorkspaceId != null &&
        removed.contains(_runningWorkspaceId)) {
      _stopRun.call();
      _cleanupRun();
    }
    emit(state.copyWith(sessions: map));
  }

  ClaudeModel _readModel(String workspaceId) {
    final raw = _prefs.getString('$_modelPrefix$workspaceId');
    return ClaudeModel.fromName(raw);
  }

  ClaudePermissionMode _readPermission(String workspaceId) {
    final raw = _prefs.getString('$_permPrefix$workspaceId');
    return ClaudePermissionMode.fromName(raw);
  }

  void setModel(String workspaceId, ClaudeModel model) {
    final session = state.sessions[workspaceId];
    if (session == null) return;
    final next = Map<String, ClaudeSessionData>.from(state.sessions);
    next[workspaceId] = session.copyWith(model: model);
    emit(state.copyWith(sessions: next));
    _prefs.setString('$_modelPrefix$workspaceId', model.name);
  }

  void setPermissionMode(String workspaceId, ClaudePermissionMode mode) {
    final session = state.sessions[workspaceId];
    if (session == null) return;
    final next = Map<String, ClaudeSessionData>.from(state.sessions);
    next[workspaceId] = session.copyWith(permissionMode: mode);
    emit(state.copyWith(sessions: next));
    _prefs.setString('$_permPrefix$workspaceId', mode.name);
  }

  void clearConversation(String workspaceId) {
    final session = state.sessions[workspaceId];
    if (session == null) return;
    if (_runningWorkspaceId == workspaceId) {
      _stopRun.call();
      _cleanupRun();
    }
    final oldId = session.claudeSessionId;
    if (oldId != null) _sessionToWorkspace.remove(oldId);
    final next = Map<String, ClaudeSessionData>.from(state.sessions);
    next[workspaceId] = session.copyWith(
      messages: const [],
      claudeSessionId: null,
      runStatus: ClaudeRunStatus.idle,
      lastError: null,
      stderrTail: const [],
    );
    emit(state.copyWith(sessions: next));
  }

  Future<void> stopRun() async {
    if (_runningWorkspaceId == null) return;
    await _stopRun.call();
  }

  Future<void> sendPrompt(String workspaceId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final session = state.sessions[workspaceId];
    if (session == null) {
      _talker.warning('sendPrompt for unknown workspace: $workspaceId');
      return;
    }
    if (_runningWorkspaceId != null) {
      _talker.warning('sendPrompt while another run in progress; ignored');
      return;
    }

    final now = DateTime.now();
    final userMsgId = 'u-${now.microsecondsSinceEpoch}';
    final assistantMsgId = 'a-${now.microsecondsSinceEpoch}';
    final messages = [
      ...session.messages,
      ClaudeMessage.user(id: userMsgId, text: trimmed, createdAt: now),
      ClaudeMessage.assistant(
        id: assistantMsgId,
        text: '',
        isStreaming: true,
        createdAt: now,
      ),
    ];

    final next = Map<String, ClaudeSessionData>.from(state.sessions);
    next[workspaceId] = session.copyWith(
      messages: messages,
      runStatus: ClaudeRunStatus.connecting,
      lastError: null,
      stderrTail: const [],
    );
    emit(state.copyWith(sessions: next));

    _runningWorkspaceId = workspaceId;
    _streamingMessageId = assistantMsgId;
    _streamingText = '';

    final params = SendPromptParams(
      cwd: workspaceId,
      prompt: trimmed,
      mode: session.permissionMode,
      model: session.model,
      resumeSessionId: session.claudeSessionId,
    );

    _runSub = _sendPrompt.call(params).listen(
      _onEvent,
      onError: (e, st) {
        _talker.error('Claude run errored', e, st);
        _finishRun(
          status: ClaudeRunStatus.error,
          failure: UnexpectedFailure('$e'),
        );
      },
      onDone: () {
        if (_runningWorkspaceId != null) {
          _finishRun(status: ClaudeRunStatus.idle);
        }
      },
    );
  }

  void _onEvent(Either<Failure, ClaudeEvent> result) {
    result.fold(
      (failure) {
        _finishRun(status: ClaudeRunStatus.error, failure: failure);
      },
      _handleEvent,
    );
  }

  void _handleEvent(ClaudeEvent event) {
    final wid = _runningWorkspaceId;
    if (wid == null) return;
    final session = state.sessions[wid];
    if (session == null) return;

    switch (event) {
      case ClaudeEventSessionInit(:final sessionId, :final model):
        _talker.debug('Claude session init: $sessionId model=$model');
        if (sessionId.isNotEmpty) {
          _sessionToWorkspace[sessionId] = wid;
        }
        final next = Map<String, ClaudeSessionData>.from(state.sessions);
        next[wid] = session.copyWith(
          claudeSessionId: sessionId.isEmpty ? null : sessionId,
          runStatus: ClaudeRunStatus.running,
        );
        emit(state.copyWith(sessions: next));

      case ClaudeEventTextChunk(:final text):
        _streamingText += text;
        _chunkFlushTimer ??= Timer(
          const Duration(milliseconds: _flushMs),
          _flushStreamingChunks,
        );

      case ClaudeEventAssistantMessage(:final text):
        _flushChunkTimerCancel();
        _streamingText = '';
        _replaceStreamingMessage(wid, text, isStreaming: false);
        _streamingMessageId = null;

      case ClaudeEventToolCall(:final toolName, :final toolId):
        _appendMessage(
          wid,
          ClaudeMessage.tool(
            id: 't-${DateTime.now().microsecondsSinceEpoch}',
            toolName: toolName,
            toolUseId: toolId.isEmpty ? null : toolId,
            status: ClaudeToolStatus.running,
            createdAt: DateTime.now(),
          ),
        );

      case ClaudeEventToolCallUpdate():
        // Skip partial input updates in this iteration.
        break;

      case ClaudeEventToolCallComplete(:final toolId, :final input):
        _completeToolMessage(wid, toolUseId: toolId, input: input);

      case ClaudeEventToolResult(:final toolUseId, :final content, :final isError):
        _attachToolResult(
          wid,
          toolUseId: toolUseId,
          output: content,
          isError: isError,
        );

      case ClaudeEventTaskComplete():
        _flushStreamingChunks();
        _finishRun(status: ClaudeRunStatus.idle);

      case ClaudeEventErrorEvent(:final message):
        _flushStreamingChunks();
        _finishRun(
          status: ClaudeRunStatus.error,
          failure: SubprocessFailure(message: message),
        );

      case ClaudeEventRateLimit(:final status):
        _talker.warning('Claude rate limit: $status');

      case ClaudeEventSessionDead(:final exitCode, :final stderrTail):
        _flushStreamingChunks();
        _finishRun(
          status: exitCode == 0
              ? ClaudeRunStatus.idle
              : ClaudeRunStatus.sessionDead,
          failure: exitCode == 0
              ? null
              : SubprocessFailure(
                  message: 'exit_code',
                  exitCode: exitCode,
                ),
          stderrTail: stderrTail,
        );
    }
  }

  void _flushStreamingChunks() {
    _flushChunkTimerCancel();
    final wid = _runningWorkspaceId;
    final mid = _streamingMessageId;
    if (wid == null || mid == null) return;
    if (_streamingText.isEmpty) return;
    _replaceStreamingMessage(wid, _streamingText, isStreaming: true);
  }

  void _flushChunkTimerCancel() {
    _chunkFlushTimer?.cancel();
    _chunkFlushTimer = null;
  }

  void _replaceStreamingMessage(
    String wid,
    String text, {
    required bool isStreaming,
  }) {
    final session = state.sessions[wid];
    if (session == null) return;
    final mid = _streamingMessageId;
    if (mid == null) return;
    final messages = [
      for (final m in session.messages)
        if (m is ClaudeMessageAssistant && m.id == mid)
          m.copyWith(text: text, isStreaming: isStreaming)
        else
          m,
    ];
    final next = Map<String, ClaudeSessionData>.from(state.sessions);
    next[wid] = session.copyWith(messages: messages);
    emit(state.copyWith(sessions: next));
  }

  void _appendMessage(String wid, ClaudeMessage message) {
    final session = state.sessions[wid];
    if (session == null) return;
    final messages = [...session.messages, message];
    final next = Map<String, ClaudeSessionData>.from(state.sessions);
    next[wid] = session.copyWith(messages: messages);
    emit(state.copyWith(sessions: next));
  }

  void _completeToolMessage(
    String wid, {
    String? toolUseId,
    Map<String, dynamic>? input,
  }) {
    final session = state.sessions[wid];
    if (session == null) return;
    final list = [...session.messages];
    for (var i = list.length - 1; i >= 0; i--) {
      final m = list[i];
      if (m is! ClaudeMessageTool) continue;
      if (m.status != ClaudeToolStatus.running) continue;
      if (toolUseId != null && m.toolUseId != null && m.toolUseId != toolUseId) {
        continue;
      }
      list[i] = m.copyWith(
        status: ClaudeToolStatus.completed,
        input: input ?? m.input,
      );
      break;
    }
    final next = Map<String, ClaudeSessionData>.from(state.sessions);
    next[wid] = session.copyWith(messages: list);
    emit(state.copyWith(sessions: next));
  }

  void _attachToolResult(
    String wid, {
    required String toolUseId,
    required String output,
    required bool isError,
  }) {
    if (toolUseId.isEmpty) return;
    final session = state.sessions[wid];
    if (session == null) return;
    final list = [...session.messages];
    for (var i = list.length - 1; i >= 0; i--) {
      final m = list[i];
      if (m is! ClaudeMessageTool) continue;
      if (m.toolUseId != toolUseId) continue;
      list[i] = m.copyWith(
        output: output,
        isError: isError,
        status:
            isError ? ClaudeToolStatus.error : ClaudeToolStatus.completed,
      );
      break;
    }
    final next = Map<String, ClaudeSessionData>.from(state.sessions);
    next[wid] = session.copyWith(messages: list);
    emit(state.copyWith(sessions: next));
  }

  /// If the last turn ended with at least one tool but no non-empty
  /// assistant text, append a [ClaudeMessageSystem] stub so the user has a
  /// visible completion marker.
  List<ClaudeMessage> _appendCompletionStubIfNeeded(
    List<ClaudeMessage> messages,
  ) {
    if (messages.isEmpty) return messages;
    var lastUser = -1;
    for (var i = messages.length - 1; i >= 0; i--) {
      if (messages[i] is ClaudeMessageUser) {
        lastUser = i;
        break;
      }
    }
    if (lastUser == -1) return messages;
    var hasTool = false;
    var hasText = false;
    for (var i = lastUser + 1; i < messages.length; i++) {
      final m = messages[i];
      if (m is ClaudeMessageTool) {
        hasTool = true;
      } else if (m is ClaudeMessageAssistant && m.text.isNotEmpty) {
        hasText = true;
      }
    }
    if (!hasTool || hasText) return messages;
    final now = DateTime.now();
    return [
      ...messages,
      ClaudeMessage.system(
        id: 's-${now.microsecondsSinceEpoch}',
        text: 'claude.message.completionStub',
        createdAt: now,
      ),
    ];
  }

  void _finishRun({
    required ClaudeRunStatus status,
    Failure? failure,
    List<String>? stderrTail,
  }) {
    final wid = _runningWorkspaceId;
    if (wid != null) {
      final session = state.sessions[wid];
      if (session != null) {
        final mid = _streamingMessageId;
        var messages = session.messages;
        if (mid != null) {
          messages = [
            for (final m in messages)
              if (m is ClaudeMessageAssistant && m.id == mid)
                m.copyWith(isStreaming: false)
              else
                m,
          ];
          if (messages.isNotEmpty &&
              messages.last is ClaudeMessageAssistant &&
              (messages.last as ClaudeMessageAssistant).text.isEmpty) {
            messages = messages.sublist(0, messages.length - 1);
          }
        }
        if (status == ClaudeRunStatus.idle) {
          messages = _appendCompletionStubIfNeeded(messages);
        }
        final next = Map<String, ClaudeSessionData>.from(state.sessions);
        next[wid] = session.copyWith(
          messages: messages,
          runStatus: status,
          lastError: failure,
          stderrTail: stderrTail ?? session.stderrTail,
        );
        emit(state.copyWith(sessions: next));
      }
    }
    _cleanupRun();
  }

  void _cleanupRun() {
    _flushChunkTimerCancel();
    _runSub?.cancel();
    _runSub = null;
    _runningWorkspaceId = null;
    _streamingMessageId = null;
    _streamingText = '';
  }

  @override
  Future<void> close() async {
    _cleanupRun();
    await _workspacesSub?.cancel();
    await _stopRun.call();
    await _permissionServer.stop();
    return super.close();
  }
}
