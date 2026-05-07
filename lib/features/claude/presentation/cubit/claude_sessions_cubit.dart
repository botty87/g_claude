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
import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/either.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../data/datasources/claude_history_datasource.dart';
import '../../data/datasources/permission_server.dart';
import '../../domain/entities/chat_attachment.dart';
import '../../domain/entities/chat_input_draft.dart';
import '../../domain/entities/claude_event.dart';
import '../../domain/entities/claude_message.dart';
import '../../domain/entities/claude_model.dart';
import '../../domain/entities/session_usage.dart';
import '../../domain/entities/claude_effort.dart';
import '../../domain/entities/claude_permission_mode.dart';
import '../../domain/entities/claude_thinking_mode.dart';
import '../../domain/entities/mcp_server.dart';
import '../../domain/entities/queued_prompt.dart';
import '../../domain/repositories/claude_repository.dart';
import '../../domain/usecases/list_mcp_servers.dart';
import '../../domain/usecases/authenticate_mcp_server.dart';
import '../../domain/usecases/load_session_messages.dart';
import '../../domain/usecases/send_prompt.dart';
import '../../domain/usecases/stop_run.dart';
import '../../domain/usecases/toggle_mcp_server.dart';
import '../../domain/utils/attachment_token.dart';

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
    this._claudeRepository,
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
  final ClaudeRepository _claudeRepository;
  final SharedPreferences _prefs;
  final Talker _talker;

  /// Tracks which workspace owns each interactive permission request so the
  /// UI can route the answer back to the right session.
  final Map<String, String> _permissionRequestToWorkspace = {};

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

  /// Per-workspace summary text waiting to be injected as bootstrap on the
  /// next sendPrompt after a /compact. Cleared once consumed.
  final Map<String, String> _pendingCompactBootstrap = {};

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
    _permissionServer.setInteractiveHandler(_onInteractivePermissionRequest);
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

  void _onInteractivePermissionRequest(PermissionRequest req) {
    final wid = _sessionToWorkspace[req.sessionId] ?? _runningWorkspaceId;
    if (wid == null) {
      _talker.warning(
        'Interactive permission with no owner workspace; auto-deny',
      );
      _claudeRepository.respondPermission(
        requestId: req.requestId,
        decision: ClaudePermissionDecision.deny,
      );
      return;
    }
    final session = state.sessions[wid];
    if (session == null) {
      _claudeRepository.respondPermission(
        requestId: req.requestId,
        decision: ClaudePermissionDecision.deny,
      );
      return;
    }
    final messageId = _genId('pr');
    _permissionRequestToWorkspace[req.requestId] = wid;
    _appendMessage(
      wid,
      ClaudeMessage.permissionRequest(
        id: messageId,
        requestId: req.requestId,
        toolName: req.toolName,
        toolInput: req.toolInput,
        createdAt: DateTime.now(),
      ),
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
    return _decisionFor(session, req.toolName);
  }

  PermissionDecision _decisionFor(
    ClaudeSessionData session,
    String toolName,
  ) {
    switch (session.permissionMode) {
      case ClaudePermissionMode.plan:
        return _readOnlyTools.contains(toolName)
            ? PermissionDecision.allow
            : PermissionDecision.deny;
      case ClaudePermissionMode.acceptEdits:
      case ClaudePermissionMode.bypassPermissions:
        return PermissionDecision.allow;
      case ClaudePermissionMode.defaultMode:
        if (session.allowAlwaysActive || _readOnlyTools.contains(toolName)) {
          return PermissionDecision.allow;
        }
        return PermissionDecision.ask;
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
    _pendingCompactBootstrap.remove(workspaceId);
    final next = Map<String, ClaudeSessionData>.from(state.sessions);
    next[workspaceId] = session.copyWith(
      messages: const [],
      claudeSessionId: null,
      runStatus: ClaudeRunStatus.idle,
      lastError: null,
      stderrTail: const [],
      allowAlwaysActive: false,
      usage: null,
    );
    emit(state.copyWith(sessions: next));
    unawaited(_writeActiveSession(workspaceId, null));
  }

  void newSession(String workspaceId) => clearConversation(workspaceId);

  /// Toggles the expanded state of a compact summary card.
  void toggleCompactSummaryExpanded(String workspaceId, String messageId) {
    final session = state.sessions[workspaceId];
    if (session == null) return;
    var changed = false;
    final updated = [
      for (final m in session.messages)
        if (m is ClaudeMessageCompactSummary && m.id == messageId)
          () {
            changed = true;
            return m.copyWith(expanded: !m.expanded);
          }()
        else
          m,
    ];
    if (!changed) return;
    _emitSession(workspaceId, session.copyWith(messages: updated));
  }

  /// Runs a one-shot summarization run against the current Claude session,
  /// captures the assistant text, then emits a [ClaudeMessageCompactSummary]
  /// that visually collapses the prior conversation. The CLI-side session is
  /// dropped (next prompt will start a fresh `claude` session bootstrapped
  /// with the summary as its first user turn).
  Future<void> compactSession(String workspaceId) async {
    final session = state.sessions[workspaceId];
    if (session == null) return;
    if (_runningWorkspaceId != null) {
      _talker.warning('compactSession while another run is active; ignored');
      return;
    }
    if (session.messages.isEmpty) {
      _talker.info('compactSession: no messages to compact');
      return;
    }
    final hiddenCount = session.messages.where((m) {
      if (m is ClaudeMessageCompactSummary) return false;
      return true;
    }).length;
    if (hiddenCount == 0) return;

    _talker.info('Compacting session for workspace=$workspaceId');

    final next = Map<String, ClaudeSessionData>.from(state.sessions);
    next[workspaceId] = session.copyWith(
      runStatus: ClaudeRunStatus.compacting,
      lastError: null,
      stderrTail: const [],
    );
    emit(state.copyWith(sessions: next));

    _runningWorkspaceId = workspaceId;

    const summaryPrompt =
        'Produce a faithful first-person recap of OUR conversation so far, '
        'so that a future instance of you can pick it up seamlessly. Write '
        'in this exact form:\n\n'
        '1. What the user asked, in their own framing (paraphrase each turn).\n'
        '2. What you (the assistant) answered or did, including any tools you '
        'ran and their relevant results.\n'
        '3. Any decisions, preferences, or constraints the user expressed.\n'
        '4. Open threads or next steps that were discussed.\n\n'
        'Be dense, concrete, no pleasantries. Do NOT describe the project as '
        'if you were a new assistant looking at it — describe the conversation '
        'as a continuous shared history. Output ONLY the recap.';

    final params = SendPromptParams(
      cwd: workspaceId,
      prompt: summaryPrompt,
      mode: session.permissionMode,
      model: session.model,
      effort: session.effort,
      resumeSessionId: session.claudeSessionId,
      imagePaths: const [],
    );

    final buf = StringBuffer();
    Failure? failure;
    final completer = Completer<void>();

    final sub = _sendPrompt.call(params).listen(
      (result) {
        result.fold(
          (f) {
            _talker.warning('[compact] event failure: $f');
            failure = f;
          },
          (event) {
            if (event is ClaudeEventTextChunk) {
              buf.write(event.text);
            } else if (event is ClaudeEventAssistantMessage) {
              if (buf.isEmpty) buf.write(event.text);
            } else if (event is ClaudeEventTaskComplete ||
                event is ClaudeEventErrorEvent ||
                event is ClaudeEventSessionDead) {
              // The subprocess often keeps stdin open after TaskComplete,
              // so the stream never closes on its own — settle here.
              if (!completer.isCompleted) completer.complete();
            }
          },
        );
      },
      onError: (Object e, StackTrace st) {
        _talker.error('Compact run errored', e, st);
        failure = UnexpectedFailure('$e');
        if (!completer.isCompleted) completer.complete();
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete();
      },
    );

    try {
      await completer.future.timeout(const Duration(minutes: 3));
    } on TimeoutException {
      _talker.warning('[compact] timeout after 3min');
      failure = const UnexpectedFailure('compact: timeout');
    }
    await sub.cancel();
    // Ensure the spawned subprocess is killed; otherwise it sits idle
    // holding stdin open and would block the next sendPrompt.
    unawaited(_stopRun.call());

    _runningWorkspaceId = null;

    final summary = buf.toString().trim();
    final current = state.sessions[workspaceId];
    if (current == null) return;

    if (failure != null || summary.isEmpty) {
      _emitSession(
        workspaceId,
        current.copyWith(
          runStatus: ClaudeRunStatus.error,
          lastError: failure ?? const UnexpectedFailure('compact: empty summary'),
        ),
      );
      return;
    }

    final oldId = current.claudeSessionId;
    if (oldId != null) _sessionToWorkspace.remove(oldId);

    final summaryMessage = ClaudeMessage.compactSummary(
      id: _genId('cs'),
      summary: summary,
      hiddenMessageCount: hiddenCount,
      createdAt: DateTime.now(),
    );

    _pendingCompactBootstrap[workspaceId] = summary;
    _emitSession(
      workspaceId,
      current.copyWith(
        messages: [...current.messages, summaryMessage],
        claudeSessionId: null,
        runStatus: ClaudeRunStatus.idle,
        usage: null,
      ),
    );
    unawaited(_writeActiveSession(workspaceId, null));
    _talker.info('Compact summary appended (hidden=$hiddenCount)');
  }

  _InterceptedCommand? _interceptedSlashCommand(
    String text,
    List<String> chips,
  ) {
    bool matches(String token, String name) =>
        token == '/$name' || token.startsWith('/$name ');
    final candidates = <String>[
      ...chips,
      if (text.startsWith('/')) text,
    ];
    for (final c in candidates) {
      if (matches(c, 'compact')) return _InterceptedCommand.compact;
      if (matches(c, 'clear')) return _InterceptedCommand.clear;
    }
    return null;
  }

  Future<void> answerAskUserQuestion(
    String workspaceId,
    String messageId,
    Map<String, String> answers,
  ) async {
    final session = state.sessions[workspaceId];
    if (session == null) return;
    ClaudeMessageAskUserQuestion? target;
    final list = [...session.messages];
    for (var i = list.length - 1; i >= 0; i--) {
      final m = list[i];
      if (m is! ClaudeMessageAskUserQuestion) continue;
      if (m.id != messageId) continue;
      target = m;
      list[i] = m.copyWith(answers: answers, answered: true);
      break;
    }
    if (target == null) return;
    _emitSession(workspaceId, session.copyWith(messages: list));

    final payload = {
      'questions': [
        for (final q in target.questions)
          {
            'question': q.question,
            'header': q.header,
            'multiSelect': q.multiSelect,
            'options': [
              for (final o in q.options)
                {'label': o.label, 'description': o.description},
            ],
          },
      ],
      'answers': answers,
    };
    final result = await _claudeRepository.sendToolResult(
      toolUseId: target.toolUseId,
      content: payload,
    );
    result.fold(
      (f) => _talker.error('answerAskUserQuestion failed: $f'),
      (_) => null,
    );
  }

  void answerPermission(
    String workspaceId,
    String messageId,
    ClaudePermissionDecision decision,
  ) {
    final session = state.sessions[workspaceId];
    if (session == null) return;
    String? requestId;
    final list = [...session.messages];
    for (var i = list.length - 1; i >= 0; i--) {
      final m = list[i];
      if (m is! ClaudeMessagePermissionRequest) continue;
      if (m.id != messageId) continue;
      requestId = m.requestId;
      list[i] = m.copyWith(decision: decision, answered: true);
      break;
    }
    if (requestId == null) return;
    final allowAlways = decision == ClaudePermissionDecision.allowAlways;
    _emitSession(
      workspaceId,
      session.copyWith(
        messages: list,
        allowAlwaysActive: session.allowAlwaysActive || allowAlways,
      ),
    );
    _permissionRequestToWorkspace.remove(requestId);
    _claudeRepository.respondPermission(
      requestId: requestId,
      decision: decision,
    );
  }

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
            queuedPrompt: null,
            usage: null,
          ),
        );
        unawaited(_writeActiveSession(workspaceId, sessionId));
      },
    );
  }

  Future<void> stopRun() async {
    if (_runningWorkspaceId == null) return;
    final wid = _runningWorkspaceId!;
    final s = state.sessions[wid];
    if (s != null && s.queuedPrompt != null) {
      _emitSession(wid, s.copyWith(queuedPrompt: null));
    }
    await _stopRun.call();
  }

  void setInputDraft(String workspaceId, ChatInputDraft draft) {
    final session = state.sessions[workspaceId];
    if (session == null) return;
    if (session.inputDraft == draft) return;
    final updated = Map<String, ClaudeSessionData>.from(state.sessions);
    updated[workspaceId] = session.copyWith(inputDraft: draft);
    emit(state.copyWith(sessions: updated));
  }

  void clearInputDraft(String workspaceId) {
    setInputDraft(workspaceId, ChatInputDraft.empty);
  }

  void setQueuedPrompt(String workspaceId, String text) {
    final trimmed = text.trim();
    final session = state.sessions[workspaceId];
    if (session == null) return;
    if (trimmed.isEmpty) {
      if (session.queuedPrompt == null) return;
      _emitSession(workspaceId, session.copyWith(queuedPrompt: null));
      return;
    }
    final existing = session.queuedPrompt;
    final next = QueuedPrompt(
      text: trimmed,
      enqueuedAt: existing?.enqueuedAt ?? DateTime.now(),
    );
    if (existing == next) return;
    _emitSession(workspaceId, session.copyWith(queuedPrompt: next));
  }

  void clearQueuedPrompt(String workspaceId) {
    final session = state.sessions[workspaceId];
    if (session == null || session.queuedPrompt == null) return;
    _emitSession(workspaceId, session.copyWith(queuedPrompt: null));
  }

  void _drainQueuedPrompt(String workspaceId) {
    final session = state.sessions[workspaceId];
    if (session == null) return;
    final queued = session.queuedPrompt;
    if (queued == null) return;
    _emitSession(workspaceId, session.copyWith(queuedPrompt: null));
    Future.microtask(() => sendPrompt(workspaceId, queued.text));
  }

  Future<void> sendPrompt(
    String workspaceId,
    String text, {
    List<String> slashTriggers = const [],
    List<ChatAttachment> attachments = const [],
  }) async {
    final trimmed = text.trim();
    final hasContent =
        trimmed.isNotEmpty || slashTriggers.isNotEmpty || attachments.isNotEmpty;
    if (!hasContent) return;
    final session = state.sessions[workspaceId];
    if (session == null) {
      _talker.warning('sendPrompt for unknown workspace: $workspaceId');
      return;
    }
    if (_runningWorkspaceId != null) {
      _talker.warning('sendPrompt while another run in progress; ignored');
      return;
    }

    // Intercept client-side slash commands. The headless `claude -p` CLI does
    // not interpret /compact, /clear, etc — they would otherwise be sent as
    // plain text to the model.
    final intercept = _interceptedSlashCommand(trimmed, slashTriggers);
    if (intercept != null) {
      switch (intercept) {
        case _InterceptedCommand.clear:
          clearConversation(workspaceId);
          return;
        case _InterceptedCommand.compact:
          unawaited(compactSession(workspaceId));
          return;
      }
    }

    final imagePaths = attachments
        .where((a) => a.kind == ChatAttachmentKind.imageCapture)
        .map((a) => a.path)
        .toList();

    final fileTokens = attachments
        .where((a) => a.kind != ChatAttachmentKind.fileRange && a.kind != ChatAttachmentKind.imageCapture)
        .map((a) => formatAttachmentToken(a.path))
        .toList();
    final rangeTokens = attachments
        .where((a) => a.kind == ChatAttachmentKind.fileRange)
        .map((a) => formatAttachmentToken(a.path))
        .toList();
    final rangeBlocks = attachments
        .where((a) => a.kind == ChatAttachmentKind.fileRange)
        .map((a) {
      final header = '${a.path}:${a.startLine}-${a.endLine}';
      final body = a.snippet ?? '';
      return '```\n// $header\n$body\n```';
    }).toList();

    final concatParts = <String>[
      if (slashTriggers.isNotEmpty) slashTriggers.join(' '),
      if (fileTokens.isNotEmpty) fileTokens.join(' '),
      if (rangeTokens.isNotEmpty) rangeTokens.join(' '),
      if (trimmed.isNotEmpty) trimmed,
      if (rangeBlocks.isNotEmpty) rangeBlocks.join('\n\n'),
    ];
    final concatPrompt = concatParts.join(' ');

    final basePrompt = session.thinkingMode.keyword.isEmpty
        ? concatPrompt
        : '${session.thinkingMode.keyword} $concatPrompt';
    final bootstrap = _pendingCompactBootstrap[workspaceId];
    final cliPrompt = (bootstrap != null && bootstrap.isNotEmpty)
        ? 'The following is a recap of our prior conversation (compacted to '
            'save context). Treat it as already-shared history between us — '
            'do NOT say you have no prior context, do NOT re-introduce '
            'yourself, just continue naturally from where it left off.\n\n'
            '<prior-conversation-recap>\n'
            '$bootstrap\n'
            '</prior-conversation-recap>\n\n'
            'My next message:\n\n$basePrompt'
        : basePrompt;

    final now = DateTime.now();
    final userMsgId = _genId('u');
    final assistantMsgId = _genId('a');
    final messages = [
      ...session.messages,
      ClaudeMessage.user(
        id: userMsgId,
        text: trimmed,
        createdAt: now,
        slashTriggers: slashTriggers,
        attachments: attachments,
      ),
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
    _pendingCompactBootstrap.remove(workspaceId);

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
      imagePaths: imagePaths,
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

      case ClaudeEventAskUserQuestion(:final toolUseId, :final questions):
        _appendMessage(
          wid,
          ClaudeMessage.askUserQuestion(
            id: _genId('q'),
            toolUseId: toolUseId,
            questions: questions,
            createdAt: DateTime.now(),
          ),
        );

      case ClaudeEventPermissionRequest():
        // Surfaced via PermissionServer interactive handler — nothing to do
        // here. Kept exhaustive so the compiler enforces handling.
        break;

      case ClaudeEventUsageUpdate(
          :final inputTokens,
          :final cacheReadTokens,
          :final cacheCreationTokens,
          :final outputTokens,
        ):
        final current = session.usage ?? const SessionUsage();
        final updated = current.copyWith(
          inputTokens: inputTokens ?? current.inputTokens,
          cacheReadTokens: cacheReadTokens ?? current.cacheReadTokens,
          cacheCreationTokens: cacheCreationTokens ?? current.cacheCreationTokens,
          outputTokens: outputTokens ?? current.outputTokens,
        );
        if (updated == current) {
          return;
        }
        final next = Map<String, ClaudeSessionData>.from(state.sessions);
        next[wid] = session.copyWith(usage: updated);
        emit(state.copyWith(sessions: next));

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
        text: LocaleKeys.claude_message_completionStub,
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
    if (wid != null && status == ClaudeRunStatus.idle) {
      _drainQueuedPrompt(wid);
    }
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

enum _InterceptedCommand { compact, clear }
