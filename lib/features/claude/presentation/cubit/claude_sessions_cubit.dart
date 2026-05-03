import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../data/datasources/claude_history_datasource.dart';
import '../../data/datasources/permission_server.dart';
import '../../domain/entities/claude_event.dart';
import '../../domain/entities/claude_message.dart';
import '../../domain/entities/claude_model.dart';
import '../../domain/entities/claude_effort.dart';
import '../../domain/entities/claude_permission_mode.dart';
import '../../domain/entities/claude_thinking_mode.dart';
import '../../domain/entities/mcp_server.dart';
import '../../domain/usecases/list_mcp_servers.dart';
import '../../domain/usecases/authenticate_mcp_server.dart';
import '../../domain/usecases/load_session_messages.dart';
import '../../domain/usecases/send_prompt.dart';
import '../../domain/usecases/stop_run.dart';
import '../../domain/usecases/toggle_mcp_server.dart';

part 'claude_sessions_cubit.freezed.dart';
part 'claude_sessions_cubit.state.dart';

@lazySingleton
class ClaudeSessionsCubit extends Cubit<ClaudeSessionsState> {
  ClaudeSessionsCubit(
    this._sendPrompt,
    this._stopRun,
    this._listMcpServers,
    this._toggleMcpServer,
    this._authenticateMcpServer,
    this._loadSessionMessages,
    this._historyDs,
    this._workspacesCubit,
    this._permissionServer,
    this._prefs,
    this._talker,
  ) : super(const ClaudeSessionsState());

  final SendPrompt _sendPrompt;
  final StopRun _stopRun;
  final ListMcpServers _listMcpServers;
  final ToggleMcpServer _toggleMcpServer;
  final AuthenticateMcpServer _authenticateMcpServer;
  final LoadSessionMessages _loadSessionMessages;
  final ClaudeHistoryDataSource _historyDs;
  final WorkspacesCubit _workspacesCubit;
  final PermissionServer _permissionServer;
  final SharedPreferences _prefs;
  final Talker _talker;

  List<McpServer>? _mcpServersCache;
  DateTime? _mcpServersCachedAt;
  static const Duration _mcpCacheTtl = Duration(minutes: 2);

  StreamSubscription<WorkspacesState>? _workspacesSub;
  StreamSubscription<Either<Failure, ClaudeEvent>>? _runSub;
  Timer? _chunkFlushTimer;
  DateTime? _lastFlushAt;

  String? _runningWorkspaceId;
  String _streamingText = '';

  final Map<String, String> _sessionToWorkspace = {};

  static const _modelPrefix = 'claude.model.';
  static const _permPrefix = 'claude.permission.';
  static const _effortPrefix = 'claude.effort.';
  static const _thinkingPrefix = 'claude.thinking.';
  static const _mcpDisabledPrefix = 'claude.mcp_disabled.';
  static const _activeSessionPrefix = 'claude.activeSession.';
  static const _flushMs = 16;

  String _genId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}';

  String _truncate(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}…(+${s.length - max})';
  }

  String _oneLine(String s) =>
      s.replaceAll('\r', '').replaceAll('\n', r'\n').trim();

  // Skip the jsonEncode entirely for huge tool inputs (e.g. Bash dumps,
  // multi-MB tool outputs). The truncated preview is debug-only and not
  // worth the encode cost on the hot tool-event path.
  String _describeToolInput(Map<String, dynamic>? input) {
    if (input == null) return '';
    if (input.isEmpty) return ' input={}';
    if (input.length > 16) return ' input=<${input.length} keys>';
    return ' input=${_oneLine(_truncate(jsonEncode(input), 300))}';
  }

  String? _toolNameFor(String wid, String? toolUseId) {
    final session = state.sessions[wid];
    if (session == null) return null;
    for (var i = session.messages.length - 1; i >= 0; i--) {
      final m = session.messages[i];
      if (m is! ClaudeMessageTool) continue;
      if (toolUseId != null && m.toolUseId != toolUseId) continue;
      return m.toolName;
    }
    return null;
  }

  String? _streamingMessageIdFor(String wid) {
    final session = state.sessions[wid];
    if (session == null) return null;
    for (var i = session.messages.length - 1; i >= 0; i--) {
      final m = session.messages[i];
      if (m is ClaudeMessageAssistant && m.isStreaming) return m.id;
    }
    return null;
  }

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
    unawaited(
      _permissionServer
          .start()
          .timeout(const Duration(seconds: 5))
          .catchError((Object e, StackTrace st) {
            _talker.error('PermissionServer.start failed', e, st);
            return -1;
          }),
    );
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
    final ids = list.map((w) => w.id).toSet();
    final added = [for (final w in list) if (!state.sessions.containsKey(w.id)) w];
    final removed = [for (final k in state.sessions.keys) if (!ids.contains(k)) k];
    if (added.isEmpty && removed.isEmpty) return;

    final map = Map<String, ClaudeSessionData>.from(state.sessions);
    for (final w in added) {
      map[w.id] = ClaudeSessionData(
        model: _readModel(w.id),
        permissionMode: _readPermission(w.id),
        effort: _readEffort(w.id),
        thinkingMode: _readThinking(w.id),
        disabledMcpServers: _readMcpDisabled(w.id),
      );
      final savedSessionId = _readActiveSession(w.id);
      if (savedSessionId != null) {
        unawaited(_hydrateSession(w.id, savedSessionId));
      }
    }
    for (final id in removed) {
      final claudeSessionId = map[id]?.claudeSessionId;
      if (claudeSessionId != null) {
        _sessionToWorkspace.remove(claudeSessionId);
      }
      map.remove(id);
    }
    if (_runningWorkspaceId != null && removed.contains(_runningWorkspaceId)) {
      _stopRun.call();
      _cleanupRun();
    }
    emit(state.copyWith(sessions: map));
  }

  Future<void> _hydrateSession(String workspaceId, String sessionId) async {
    final ws = _workspacesCubit.state.workspacesOrEmpty
        .firstWhereOrNull((w) => w.id == workspaceId);
    if (ws == null) return;

    final session = state.sessions[workspaceId];
    if (session == null) return;
    if (session.messages.isNotEmpty || session.claudeSessionId != null) return;

    final encoded = _historyDs.encodeCwd(ws.path);
    final result = await _loadSessionMessages(
      encodedPath: encoded,
      sessionId: sessionId,
    );
    result.fold(
      (f) {
        _talker.error('hydrateSession failed for $sessionId: $f');
        unawaited(_writeActiveSession(workspaceId, null));
      },
      (messages) {
        final current = state.sessions[workspaceId];
        if (current == null) return;
        if (current.messages.isNotEmpty || current.claudeSessionId != null) return;
        _sessionToWorkspace[sessionId] = workspaceId;
        _emitSession(
          workspaceId,
          current.copyWith(
            messages: messages,
            claudeSessionId: sessionId,
            runStatus: ClaudeRunStatus.idle,
            lastError: null,
            stderrTail: const [],
          ),
        );
      },
    );
  }

  ClaudeModel _readModel(String workspaceId) {
    final raw = _prefs.getString('$_modelPrefix$workspaceId');
    return ClaudeModel.fromName(raw);
  }

  ClaudePermissionMode _readPermission(String workspaceId) {
    final raw = _prefs.getString('$_permPrefix$workspaceId');
    return ClaudePermissionMode.fromName(raw);
  }

  ClaudeEffort _readEffort(String workspaceId) {
    final raw = _prefs.getString('$_effortPrefix$workspaceId');
    return ClaudeEffort.fromName(raw);
  }

  ClaudeThinkingMode _readThinking(String workspaceId) {
    final raw = _prefs.getString('$_thinkingPrefix$workspaceId');
    return ClaudeThinkingMode.fromName(raw);
  }

  Set<String> _readMcpDisabled(String workspaceId) {
    final raw = _prefs.getStringList('$_mcpDisabledPrefix$workspaceId');
    return raw == null ? <String>{} : raw.toSet();
  }

  Future<void> _writeMcpDisabled(
    String workspaceId,
    Set<String> disabled,
  ) async {
    final key = '$_mcpDisabledPrefix$workspaceId';
    if (disabled.isEmpty) {
      await _prefs.remove(key);
    } else {
      await _prefs.setStringList(key, disabled.toList());
    }
  }

  String? _readActiveSession(String wid) =>
      _prefs.getString('$_activeSessionPrefix$wid');

  Future<void> _writeActiveSession(String wid, String? id) async {
    final key = '$_activeSessionPrefix$wid';
    if (id == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, id);
    }
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

  void setEffort(String workspaceId, ClaudeEffort effort) {
    final session = state.sessions[workspaceId];
    if (session == null) return;
    final next = Map<String, ClaudeSessionData>.from(state.sessions);
    next[workspaceId] = session.copyWith(effort: effort);
    emit(state.copyWith(sessions: next));
    _prefs.setString('$_effortPrefix$workspaceId', effort.name);
  }

  void setThinking(String workspaceId, ClaudeThinkingMode mode) {
    final session = state.sessions[workspaceId];
    if (session == null) return;
    final next = Map<String, ClaudeSessionData>.from(state.sessions);
    next[workspaceId] = session.copyWith(thinkingMode: mode);
    emit(state.copyWith(sessions: next));
    _prefs.setString('$_thinkingPrefix$workspaceId', mode.name);
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
    unawaited(_writeActiveSession(workspaceId, null));
  }

  void newSession(String workspaceId) => clearConversation(workspaceId);

  Future<void> resumeSession(String workspaceId, String sessionId) async {
    final ws = _workspacesCubit.state.workspacesOrEmpty
        .firstWhereOrNull((w) => w.id == workspaceId);
    final session = state.sessions[workspaceId];
    if (ws == null || session == null) return;

    if (_runningWorkspaceId == workspaceId) {
      await _stopRun.call();
      _cleanupRun();
    }

    final oldId = session.claudeSessionId;
    if (oldId != null) _sessionToWorkspace.remove(oldId);

    final encoded = _historyDs.encodeCwd(ws.path);
    final result = await _loadSessionMessages(
      encodedPath: encoded,
      sessionId: sessionId,
    );
    result.fold(
      (f) => _talker.error('resumeSession load failed for $sessionId: $f'),
      (messages) {
        final current = state.sessions[workspaceId];
        if (current == null) return;
        _sessionToWorkspace[sessionId] = workspaceId;
        _emitSession(
          workspaceId,
          current.copyWith(
            messages: messages,
            claudeSessionId: sessionId,
            runStatus: ClaudeRunStatus.idle,
            lastError: null,
            stderrTail: const [],
          ),
        );
        unawaited(_writeActiveSession(workspaceId, sessionId));
      },
    );
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

    final cliPrompt = session.thinkingMode.keyword.isEmpty
        ? trimmed
        : '${session.thinkingMode.keyword} $trimmed';

    final now = DateTime.now();
    final userMsgId = _genId('u');
    final assistantMsgId = _genId('a');
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

    _talker.debug('[cc] u> ${_oneLine(_truncate(cliPrompt, 800))}');

    _runningWorkspaceId = workspaceId;
    _streamingText = '';
    _lastFlushAt = null;

    final params = SendPromptParams(
      cwd: workspaceId,
      prompt: cliPrompt,
      mode: session.permissionMode,
      model: session.model,
      effort: session.effort,
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
      case ClaudeEventSessionInit(:final sessionId, :final model, :final skills):
        _talker.debug('Claude session init: $sessionId model=$model');
        if (sessionId.isNotEmpty) {
          _sessionToWorkspace[sessionId] = wid;
        }
        final next = Map<String, ClaudeSessionData>.from(state.sessions);
        next[wid] = session.copyWith(
          claudeSessionId: sessionId.isEmpty ? null : sessionId,
          runStatus: ClaudeRunStatus.running,
          availableSkills: skills,
        );
        emit(state.copyWith(sessions: next));
        unawaited(
          _writeActiveSession(wid, sessionId.isEmpty ? null : sessionId),
        );
        unawaited(_applyMcpDisabledOnSpawn(wid));

      case ClaudeEventTextChunk(:final text):
        _ensureStreamingMessage(wid);
        _streamingText += text;
        final now = DateTime.now();
        final since = _lastFlushAt == null
            ? const Duration(days: 1)
            : now.difference(_lastFlushAt!);
        if (since.inMilliseconds >= _flushMs) {
          _flushStreamingChunks();
        } else {
          _chunkFlushTimer ??= Timer(
            Duration(milliseconds: _flushMs - since.inMilliseconds),
            _flushStreamingChunks,
          );
        }

      case ClaudeEventAssistantMessage(:final text):
        _flushChunkTimerCancel();
        _streamingText = '';
        _ensureStreamingMessage(wid);
        _replaceStreamingMessage(wid, text, isStreaming: false);
        if (text.trim().isNotEmpty) {
          _talker.debug('[cc] a> ${_oneLine(_truncate(text, 800))}');
        }

      case ClaudeEventToolCall(:final toolName, :final toolId):
        _appendMessage(
          wid,
          ClaudeMessage.tool(
            id: _genId('t'),
            toolName: toolName,
            toolUseId: toolId.isEmpty ? null : toolId,
            status: ClaudeToolStatus.running,
            createdAt: DateTime.now(),
          ),
        );

      case ClaudeEventToolCallUpdate():
        break;

      case ClaudeEventToolCallComplete(
          :final toolId,
          :final input,
          :final index,
        ):
        _completeToolMessage(wid, toolUseId: toolId, input: input);
        _talker.debug(
          '[cc] tool> ${_toolNameFor(wid, toolId) ?? "?"}#$index'
          '${_describeToolInput(input)}',
        );

      case ClaudeEventToolResult(:final toolUseId, :final content, :final isError):
        _attachToolResult(
          wid,
          toolUseId: toolUseId,
          output: content,
          isError: isError,
        );
        _talker.debug(
          '[cc] result> ${_toolNameFor(wid, toolUseId) ?? "?"} '
          'err=$isError ${_oneLine(_truncate(content, 300))}',
        );

      case ClaudeEventTaskComplete():
        _flushStreamingChunks();
        _talker.info('[cc] done');
        _finishRun(status: ClaudeRunStatus.idle);

      case ClaudeEventErrorEvent(:final message):
        _flushStreamingChunks();
        _talker.error('[cc] error> ${_oneLine(message)}');
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
    if (wid == null) return;
    final mid = _streamingMessageIdFor(wid);
    if (mid == null) return;
    if (_streamingText.isEmpty) return;
    _replaceStreamingMessage(wid, _streamingText, isStreaming: true);
    _lastFlushAt = DateTime.now();
  }

  void _flushChunkTimerCancel() {
    _chunkFlushTimer?.cancel();
    _chunkFlushTimer = null;
  }

  void _ensureStreamingMessage(String wid) {
    if (_streamingMessageIdFor(wid) != null) return;
    final session = state.sessions[wid];
    if (session == null) return;
    final placeholder = ClaudeMessage.assistant(
      id: _genId('a'),
      text: '',
      isStreaming: true,
      createdAt: DateTime.now(),
    );
    final next = Map<String, ClaudeSessionData>.from(state.sessions);
    next[wid] = session.copyWith(
      messages: [...session.messages, placeholder],
    );
    emit(state.copyWith(sessions: next));
  }

  void _replaceStreamingMessage(
    String wid,
    String text, {
    required bool isStreaming,
  }) {
    final session = state.sessions[wid];
    if (session == null) return;
    final mid = _streamingMessageIdFor(wid);
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

  /// Stub system message when last turn had tools but no text reply, so user
  /// has a visible completion marker.
  List<ClaudeMessage> _appendCompletionStubIfNeeded(
    List<ClaudeMessage> messages,
  ) {
    if (messages.isEmpty) return messages;
    var lastUser = -1;
    var hasToolAfterUser = false;
    for (var i = messages.length - 1; i >= 0; i--) {
      final m = messages[i];
      if (m is ClaudeMessageUser) {
        lastUser = i;
        break;
      }
      if (m is ClaudeMessageTool) hasToolAfterUser = true;
    }
    if (lastUser == -1 || !hasToolAfterUser) return messages;
    final last = messages.last;
    final endsWithText =
        last is ClaudeMessageAssistant && last.text.trim().isNotEmpty;
    if (endsWithText) return messages;
    final now = DateTime.now();
    return [
      ...messages,
      ClaudeMessage.system(
        id: _genId('s'),
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
        final mid = _streamingMessageIdFor(wid);
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
    _streamingText = '';
    _lastFlushAt = null;
  }

  Future<List<McpServer>> ensureMcpServers({bool force = false}) async {
    final now = DateTime.now();
    if (!force &&
        _mcpServersCache != null &&
        _mcpServersCachedAt != null &&
        now.difference(_mcpServersCachedAt!) < _mcpCacheTtl) {
      return _mcpServersCache!;
    }
    final result = await _listMcpServers();
    return result.fold(
      (f) {
        _talker.warning('mcp list failed: $f');
        return _mcpServersCache ?? const <McpServer>[];
      },
      (servers) {
        _mcpServersCache = servers;
        _mcpServersCachedAt = now;
        return servers;
      },
    );
  }

  bool isSessionActive(String workspaceId) {
    if (_runningWorkspaceId != workspaceId) return false;
    final session = state.sessions[workspaceId];
    if (session == null) return false;
    return session.runStatus == ClaudeRunStatus.running ||
        session.runStatus == ClaudeRunStatus.connecting;
  }

  Future<void> toggleMcpServer(
    String workspaceId,
    String serverName,
    bool enabled,
  ) async {
    final session = state.sessions[workspaceId];
    if (session == null) return;

    final original = session.disabledMcpServers;
    final next = Set<String>.from(original);
    if (enabled) {
      next.remove(serverName);
    } else {
      next.add(serverName);
    }
    _emitSession(workspaceId, session.copyWith(disabledMcpServers: next));
    await _writeMcpDisabled(workspaceId, next);

    if (!isSessionActive(workspaceId)) {
      _talker.info(
        'mcp toggle persisted (no live session): '
        '$serverName=${enabled ? "on" : "off"}',
      );
      return;
    }

    final result = await _toggleMcpServer(
      serverName: serverName,
      enabled: enabled,
    );
    result.fold(
      (f) {
        _talker.error('mcp toggle failed: ${f.toString()}');
        final current = state.sessions[workspaceId];
        if (current != null) {
          _emitSession(
            workspaceId,
            current.copyWith(disabledMcpServers: original),
          );
          _writeMcpDisabled(workspaceId, original);
        }
      },
      (_) =>
          _talker.info('mcp toggle ok: $serverName=${enabled ? "on" : "off"}'),
    );
  }

  Future<void> authenticateMcpServer(
    String workspaceId,
    String serverName,
  ) async {
    if (!isSessionActive(workspaceId)) {
      _talker.warning('mcp auth: no active session for $workspaceId');
      return;
    }
    _talker.info('mcp auth: starting flow for $serverName');
    final result = await _authenticateMcpServer(serverName: serverName);
    await result.fold(
      (f) async {
        _talker.error('mcp auth failed: ${f.toString()}');
      },
      (authUrl) async {
        if (authUrl == null || authUrl.isEmpty) {
          _talker.warning('mcp auth: no authUrl returned for $serverName');
          return;
        }
        _talker.info('mcp auth: opening $authUrl');
        try {
          await Process.run('open', [authUrl]);
        } catch (e) {
          _talker.error('mcp auth: failed to open browser: $e');
        }
      },
    );
  }

  Future<void> _applyMcpDisabledOnSpawn(String workspaceId) async {
    final session = state.sessions[workspaceId];
    if (session == null) return;
    final disabled = session.disabledMcpServers;
    if (disabled.isEmpty) return;
    _talker.info(
      'mcp: applying ${disabled.length} disabled server(s) on spawn',
    );
    await Future.wait(
      disabled.map((name) async {
        final result = await _toggleMcpServer(serverName: name, enabled: false);
        result.fold(
          (f) => _talker.warning('mcp pre-disable failed for $name: $f'),
          (_) => null,
        );
      }),
    );
  }

  void _emitSession(String workspaceId, ClaudeSessionData data) {
    final next = Map<String, ClaudeSessionData>.from(state.sessions);
    next[workspaceId] = data;
    emit(state.copyWith(sessions: next));
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
