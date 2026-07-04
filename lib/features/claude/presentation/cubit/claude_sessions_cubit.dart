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
import '../../domain/utils/attachment_token.dart';

part 'claude_sessions_cubit.freezed.dart';
part 'claude_sessions_cubit.state.dart';

@lazySingleton
class ClaudeSessionsCubit extends Cubit<ClaudeSessionsState> {
  ClaudeSessionsCubit(
    this._sendPrompt,
    this._stopRun,
    this._listMcpServers,
    this._authenticateMcpServer,
    this._loadSessionMessages,
    this._historyDs,
    this._workspacesCubit,
    this._claudeRepository,
    this._prefs,
    this._talker,
  ) : super(const ClaudeSessionsState());

  final SendPrompt _sendPrompt;
  final StopRun _stopRun;
  final ListMcpServers _listMcpServers;
  final AuthenticateMcpServer _authenticateMcpServer;
  final LoadSessionMessages _loadSessionMessages;
  final ClaudeHistoryDataSource _historyDs;
  final WorkspacesCubit _workspacesCubit;
  final ClaudeRepository _claudeRepository;
  final SharedPreferences _prefs;
  final Talker _talker;

  /// Tracks which workspace owns each interactive permission request so the
  /// UI can route the answer back to the right session.
  final Map<String, String> _permissionRequestToWorkspace = {};

  // The MCP server list lives in emitted state (`state.mcpServers`) so the UI
  // count stays reactive; this timestamp gates the TTL refresh only.
  DateTime? _mcpServersCachedAt;
  static const Duration _mcpCacheTtl = Duration(minutes: 2);

  StreamSubscription<WorkspacesState>? _workspacesSub;
  StreamSubscription<Either<Failure, ClaudeEvent>>? _runSub;
  Timer? _chunkFlushTimer;
  DateTime? _lastFlushAt;

  String? _runningWorkspaceId;
  String? _runningTabId;
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
  static const _openSessionsPrefix = 'claude.openSessions.';
  static const _flushMs = 16;

  String _genId(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}';

  String _truncate(String s, int max) {
    if (s.length <= max) return s;
    return '${s.substring(0, max)}…(+${s.length - max})';
  }

  String _oneLine(String s) => s.replaceAll('\r', '').replaceAll('\n', r'\n').trim();

  // Skip the jsonEncode entirely for huge tool inputs (e.g. Bash dumps,
  // multi-MB tool outputs). The truncated preview is debug-only and not
  // worth the encode cost on the hot tool-event path.
  String _describeToolInput(Map<String, dynamic>? input) {
    if (input == null) return '';
    if (input.isEmpty) return ' input={}';
    if (input.length > 16) return ' input=<${input.length} keys>';
    return ' input=${_oneLine(_truncate(jsonEncode(input), 300))}';
  }

  /// Returns the ACTIVE tab of a workspace.
  ClaudeSessionData? _active(String wid) => state.workspaces[wid]?.activeTab;

  /// Returns the tab currently owning the in-flight run for [wid] (which may
  /// differ from the active tab if the user switched tabs meanwhile). Falls
  /// back to the active tab when no run is tracked for this workspace.
  ClaudeSessionData? _runTab(String wid) {
    final tabId = _runningTabId;
    if (tabId == null) return _active(wid);
    return state.workspaces[wid]?.tabById(tabId) ?? _active(wid);
  }

  /// Rewrites the ACTIVE tab of the workspace, preserving other tabs and
  /// activeTabId.
  void _emitActive(String wid, ClaudeSessionData data) {
    final ws = state.workspaces[wid];
    if (ws == null) return;
    final tabs = [
      for (final t in ws.tabs)
        if (t.tabId == data.tabId) data else t,
    ];
    emit(
      state.copyWith(
        workspaces: {
          ...state.workspaces,
          wid: ws.copyWith(tabs: tabs),
        },
      ),
    );
  }

  /// Rewrites an explicit tab (not necessarily the active one) of a
  /// workspace, preserving other tabs and activeTabId.
  void _emitTab(String wid, String tabId, ClaudeSessionData data) {
    final ws = state.workspaces[wid];
    if (ws == null) return;
    final tabs = [
      for (final t in ws.tabs)
        if (t.tabId == tabId) data else t,
    ];
    emit(
      state.copyWith(
        workspaces: {
          ...state.workspaces,
          wid: ws.copyWith(tabs: tabs),
        },
      ),
    );
  }

  /// Rewrites the tab that owns the current in-flight run, wherever it is.
  void _emitRunTab(String wid, ClaudeSessionData data) {
    final tabId = _runningTabId;
    if (tabId == null) {
      _emitActive(wid, data);
      return;
    }
    _emitTab(wid, tabId, data);
  }

  String? _toolNameFor(String wid, String? toolUseId) {
    final session = _runTab(wid);
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
    final session = _runTab(wid);
    if (session == null) return null;
    for (var i = session.messages.length - 1; i >= 0; i--) {
      final m = session.messages[i];
      if (m is ClaudeMessageAssistant && m.isStreaming) return m.id;
    }
    return null;
  }

  @PostConstruct()
  void init() {
    _workspacesSub = _workspacesCubit.stream.listen(_onWorkspacesChanged);
    _onWorkspacesChanged(_workspacesCubit.state);
  }

  ClaudeSessionData _freshTab(String workspaceId, {String? claudeSessionId}) {
    return ClaudeSessionData(
      tabId: _genId('tab'),
      model: _readModel(workspaceId),
      permissionMode: _readPermission(workspaceId),
      effort: _readEffort(workspaceId),
      thinkingMode: _readThinking(workspaceId),
      disabledMcpServers: _readMcpDisabled(workspaceId),
      claudeSessionId: claudeSessionId,
    );
  }

  void _onWorkspacesChanged(WorkspacesState s) {
    final list = s.workspacesOrEmpty;
    final ids = list.map((w) => w.id).toSet();
    final added = [
      for (final w in list)
        if (!state.workspaces.containsKey(w.id)) w,
    ];
    final removed = [
      for (final k in state.workspaces.keys)
        if (!ids.contains(k)) k,
    ];
    if (added.isEmpty && removed.isEmpty) return;

    final map = Map<String, WorkspaceSessions>.from(state.workspaces);
    // Hydrations must be dispatched AFTER the emit below: _hydrateSession
    // reads state.workspaces to find the tab, which does not exist until the
    // new map is emitted.
    final pendingHydrations = <(String wid, String tabId, String sessionId)>[];
    for (final w in added) {
      final openSessions = _readOpenSessions(w.id);
      if (openSessions != null && openSessions.ids.isNotEmpty) {
        final tabs = [
          for (final claudeId in openSessions.ids) _freshTab(w.id, claudeSessionId: claudeId.isEmpty ? null : claudeId),
        ];
        final activeTab = tabs[openSessions.activeIndex]; // index clamped in _readOpenSessions
        map[w.id] = WorkspaceSessions(tabs: tabs, activeTabId: activeTab.tabId);
        // Eagerly hydrate ONLY the active tab; other tabs stay lazy (loaded
        // on demand when switched to, see [switchTab]).
        if (activeTab.claudeSessionId != null) {
          pendingHydrations.add((w.id, activeTab.tabId, activeTab.claudeSessionId!));
        }
      } else {
        // Retro-compat: migrate from the old single-session pref.
        final legacyId = _readActiveSession(w.id);
        final tab = _freshTab(w.id, claudeSessionId: legacyId);
        map[w.id] = WorkspaceSessions(tabs: [tab], activeTabId: tab.tabId);
        if (legacyId != null) {
          pendingHydrations.add((w.id, tab.tabId, legacyId));
        }
      }
      // Warm the TTL cache in the background so the MCP picker opens
      // instantly instead of blocking on `claude mcp list`.
      unawaited(ensureMcpServers());
    }
    for (final id in removed) {
      final ws = map[id];
      if (ws != null) {
        for (final t in ws.tabs) {
          final claudeSessionId = t.claudeSessionId;
          if (claudeSessionId != null) _sessionToWorkspace.remove(claudeSessionId);
        }
      }
      map.remove(id);
    }
    if (_runningWorkspaceId != null && removed.contains(_runningWorkspaceId)) {
      unawaited(_stopRun.call(sid: _runningWorkspaceId!));
      _cleanupRun();
    }
    emit(state.copyWith(workspaces: map));
    for (final (wid, tabId, sessionId) in pendingHydrations) {
      unawaited(_hydrateSession(wid, tabId, sessionId));
    }
  }

  Future<void> _hydrateSession(String workspaceId, String tabId, String sessionId) async {
    final ws = _workspacesCubit.state.workspacesOrEmpty.firstWhereOrNull((w) => w.id == workspaceId);
    if (ws == null) return;

    final tab = state.workspaces[workspaceId]?.tabById(tabId);
    if (tab == null) return;
    if (tab.messages.isNotEmpty || tab.claudeSessionId == null) return;

    final encoded = _historyDs.encodeCwd(ws.path);
    final result = await _loadSessionMessages(encodedPath: encoded, sessionId: sessionId);
    result.fold(
      (f) {
        // Stale persisted id (JSONL deleted/moved): strip it so the tab heals
        // into a genuinely fresh chat instead of re-failing on every switch
        // (and instead of resuming a nonexistent session on the next prompt).
        _talker.warning('hydrateSession: dropping stale session $sessionId: $f');
        final current = state.workspaces[workspaceId]?.tabById(tabId);
        if (current == null || current.messages.isNotEmpty) return;
        _sessionToWorkspace.remove(sessionId);
        _emitTab(workspaceId, tabId, current.copyWith(claudeSessionId: null, lastError: null));
        unawaited(_writeOpenSessions(workspaceId));
      },
      (messages) {
        final current = state.workspaces[workspaceId]?.tabById(tabId);
        if (current == null) return;
        if (current.messages.isNotEmpty) return;
        _sessionToWorkspace[sessionId] = workspaceId;
        _emitTab(
          workspaceId,
          tabId,
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

  Future<void> _writeMcpDisabled(String workspaceId, Set<String> disabled) async {
    final key = '$_mcpDisabledPrefix$workspaceId';
    if (disabled.isEmpty) {
      await _prefs.remove(key);
    } else {
      await _prefs.setStringList(key, disabled.toList());
    }
  }

  /// Read-only retro-compat: old installs persisted a single active session
  /// id per workspace. Only used to seed the first tab when no
  /// `openSessions` entry exists yet; never written again after this point.
  String? _readActiveSession(String wid) => _prefs.getString('$_activeSessionPrefix$wid');

  ({int activeIndex, List<String> ids})? _readOpenSessions(String wid) {
    final raw = _prefs.getString('$_openSessionsPrefix$wid');
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ids = (map['ids'] as List?)?.cast<String>() ?? const <String>[];
      int activeIndex;
      final ai = map['activeIndex'];
      if (ai is int) {
        activeIndex = ai;
      } else {
        // Legacy format stored `active` as a claudeSessionId. A fresh active
        // tab had an empty id (unmatchable) → default to the first tab.
        final active = map['active'] as String? ?? '';
        final i = ids.indexOf(active);
        activeIndex = i >= 0 ? i : 0;
      }
      if (activeIndex < 0 || activeIndex >= ids.length) activeIndex = 0;
      return (activeIndex: activeIndex, ids: ids);
    } catch (e) {
      _talker.warning('openSessions parse failed for $wid: $e');
      return null;
    }
  }

  Future<void> _writeOpenSessions(String wid) async {
    final ws = state.workspaces[wid];
    final key = '$_openSessionsPrefix$wid';
    if (ws == null || ws.tabs.isEmpty) {
      await _prefs.remove(key);
      return;
    }
    final ids = [for (final t in ws.tabs) t.claudeSessionId ?? ''];
    // Persist the active tab by index: a fresh "New chat" has an empty
    // claudeSessionId, so an id-based marker could not identify it on restore.
    final activeIndex = ws.tabs.indexWhere((t) => t.tabId == ws.activeTabId);
    await _prefs.setString(key, jsonEncode({'activeIndex': activeIndex < 0 ? 0 : activeIndex, 'ids': ids}));
  }

  void setModel(String workspaceId, ClaudeModel model) {
    final session = _active(workspaceId);
    if (session == null) return;
    final modelChanged = session.model != model;
    // Resuming an existing claudeSessionId pins the CLI/SDK session to the
    // model it was created with, so a mid-conversation model switch would
    // silently keep replying with the old model. Dropping the resume id
    // forces the next prompt to start a fresh session with the new model.
    final oldId = session.claudeSessionId;
    if (modelChanged && oldId != null) _sessionToWorkspace.remove(oldId);
    _emitActive(
      workspaceId,
      session.copyWith(model: model, claudeSessionId: modelChanged ? null : session.claudeSessionId),
    );
    _prefs.setString('$_modelPrefix$workspaceId', model.name);
    if (modelChanged) unawaited(_writeOpenSessions(workspaceId));
  }

  void setPermissionMode(String workspaceId, ClaudePermissionMode mode) {
    final session = _active(workspaceId);
    if (session == null) return;
    _emitActive(workspaceId, session.copyWith(permissionMode: mode));
    _prefs.setString('$_permPrefix$workspaceId', mode.name);
    if (_runningWorkspaceId == workspaceId) {
      _claudeRepository.setMode(sid: workspaceId, mode: mode);
    }
  }

  void setEffort(String workspaceId, ClaudeEffort effort) {
    final session = _active(workspaceId);
    if (session == null) return;
    _emitActive(workspaceId, session.copyWith(effort: effort));
    _prefs.setString('$_effortPrefix$workspaceId', effort.name);
  }

  void setThinking(String workspaceId, ClaudeThinkingMode mode) {
    final session = _active(workspaceId);
    if (session == null) return;
    _emitActive(workspaceId, session.copyWith(thinkingMode: mode));
    _prefs.setString('$_thinkingPrefix$workspaceId', mode.name);
  }

  void clearConversation(String workspaceId) {
    final session = _active(workspaceId);
    if (session == null) return;
    if (_runningWorkspaceId == workspaceId) {
      unawaited(_stopRun.call(sid: workspaceId));
      _cleanupRun();
    }
    final oldId = session.claudeSessionId;
    if (oldId != null) _sessionToWorkspace.remove(oldId);
    _pendingCompactBootstrap.remove(session.tabId);
    _emitActive(
      workspaceId,
      session.copyWith(
        messages: const [],
        claudeSessionId: null,
        runStatus: ClaudeRunStatus.idle,
        lastError: null,
        stderrTail: const [],
        allowAlwaysActive: false,
        usage: null,
      ),
    );
    unawaited(_writeOpenSessions(workspaceId));
  }

  void newSession(String workspaceId) => clearConversation(workspaceId);

  void openNewSession(String workspaceId) {
    final ws = state.workspaces[workspaceId];
    if (ws == null) return;
    final tab = _freshTab(workspaceId);
    emit(
      state.copyWith(
        workspaces: {
          ...state.workspaces,
          workspaceId: ws.copyWith(tabs: [...ws.tabs, tab], activeTabId: tab.tabId),
        },
      ),
    );
    unawaited(_writeOpenSessions(workspaceId));
  }

  void switchTab(String workspaceId, String tabId) {
    final ws = state.workspaces[workspaceId];
    if (ws == null || ws.activeTabId == tabId) return;
    final target = ws.tabById(tabId);
    if (target == null) return;
    emit(
      state.copyWith(
        workspaces: {
          ...state.workspaces,
          workspaceId: ws.copyWith(activeTabId: tabId),
        },
      ),
    );
    unawaited(_writeOpenSessions(workspaceId));
    // Lazy hydration: if the tab has a claudeSessionId but empty messages,
    // load it now.
    if (target.messages.isEmpty && target.claudeSessionId != null) {
      unawaited(_hydrateSession(workspaceId, tabId, target.claudeSessionId!));
    }
  }

  void closeTab(String workspaceId, String tabId) {
    final ws = state.workspaces[workspaceId];
    if (ws == null) return;
    final idx = ws.tabs.indexWhere((t) => t.tabId == tabId);
    if (idx == -1) return;

    if (_runningWorkspaceId == workspaceId && _runningTabId == tabId) {
      unawaited(stopRun());
    }

    final closedClaudeId = ws.tabs[idx].claudeSessionId;
    if (closedClaudeId != null) _sessionToWorkspace.remove(closedClaudeId);
    _pendingCompactBootstrap.remove(tabId);

    final remaining = [...ws.tabs]..removeAt(idx);
    List<ClaudeSessionData> finalTabs;
    String nextActiveId;
    if (remaining.isEmpty) {
      // Never zero tabs: create a fresh empty tab.
      final fresh = _freshTab(workspaceId);
      finalTabs = [fresh];
      nextActiveId = fresh.tabId;
    } else {
      finalTabs = remaining;
      if (ws.activeTabId == tabId) {
        // Pick the neighboring tab: previous index if it exists, otherwise
        // the one now occupying idx (next).
        final newIdx = (idx - 1).clamp(0, remaining.length - 1);
        nextActiveId = remaining[newIdx].tabId;
      } else {
        nextActiveId = ws.activeTabId;
      }
    }
    emit(
      state.copyWith(
        workspaces: {
          ...state.workspaces,
          workspaceId: ws.copyWith(tabs: finalTabs, activeTabId: nextActiveId),
        },
      ),
    );
    unawaited(_writeOpenSessions(workspaceId));
  }

  /// Toggles the expanded state of a compact summary card.
  void toggleCompactSummaryExpanded(String workspaceId, String messageId) {
    final session = _active(workspaceId);
    if (session == null) return;
    var changed = false;
    final updated = <ClaudeMessage>[];
    for (final m in session.messages) {
      if (m is ClaudeMessageCompactSummary && m.id == messageId) {
        updated.add(m.copyWith(expanded: !m.expanded));
        changed = true;
      } else {
        updated.add(m);
      }
    }
    if (!changed) return;
    _emitActive(workspaceId, session.copyWith(messages: updated));
  }

  /// Runs a one-shot summarization run against the current Claude session,
  /// captures the assistant text, then emits a [ClaudeMessageCompactSummary]
  /// that visually collapses the prior conversation. The CLI-side session is
  /// dropped (next prompt will start a fresh `claude` session bootstrapped
  /// with the summary as its first user turn).
  Future<void> compactSession(String workspaceId) async {
    final session = _active(workspaceId);
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

    _runningWorkspaceId = workspaceId;
    _runningTabId = session.tabId;

    _emitActive(
      workspaceId,
      session.copyWith(runStatus: ClaudeRunStatus.compacting, lastError: null, stderrTail: const []),
    );

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
      thinking: session.thinkingMode == ClaudeThinkingMode.on,
      resumeSessionId: session.claudeSessionId,
      imagePaths: const [],
      disabledMcp: session.disabledMcpServers,
    );

    final buf = StringBuffer();
    Failure? failure;
    final completer = Completer<void>();

    final sub = _sendPrompt
        .call(params)
        .listen(
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
    await _stopRun.call(sid: workspaceId);

    final tabId = _runningTabId;
    _runningWorkspaceId = null;
    _runningTabId = null;

    final summary = buf.toString().trim();
    final current = tabId == null ? null : state.workspaces[workspaceId]?.tabById(tabId);
    if (current == null) return;

    // A late onError can land after the summary already arrived; treat the
    // run as a failure only if we genuinely have nothing usable.
    if (summary.isEmpty) {
      _emitTab(
        workspaceId,
        current.tabId,
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

    _pendingCompactBootstrap[current.tabId] = summary;
    _emitTab(
      workspaceId,
      current.tabId,
      current.copyWith(
        messages: [...current.messages, summaryMessage],
        claudeSessionId: null,
        runStatus: ClaudeRunStatus.idle,
        usage: null,
      ),
    );
    unawaited(_writeOpenSessions(workspaceId));
    _talker.info('Compact summary appended (hidden=$hiddenCount)');
  }

  _InterceptedCommand? _interceptedSlashCommand(String text, List<String> chips) {
    bool matches(String token, String name) => token == '/$name' || token.startsWith('/$name ');
    final candidates = <String>[...chips, if (text.startsWith('/')) text];
    for (final c in candidates) {
      if (matches(c, 'compact')) return _InterceptedCommand.compact;
      if (matches(c, 'clear')) return _InterceptedCommand.clear;
    }
    return null;
  }

  Future<void> answerAskUserQuestion(String workspaceId, String messageId, Map<String, String> answers) async {
    final session = _active(workspaceId);
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
    _emitActive(workspaceId, session.copyWith(messages: list));

    _claudeRepository.answerQuestion(sid: workspaceId, toolUseId: target.toolUseId, answers: answers);
  }

  void answerPlan(String workspaceId, String messageId, bool approve) {
    final session = _active(workspaceId);
    if (session == null) return;
    ClaudeMessagePlan? target;
    final list = [...session.messages];
    for (var i = list.length - 1; i >= 0; i--) {
      final m = list[i];
      if (m is! ClaudeMessagePlan) continue;
      if (m.id != messageId) continue;
      target = m;
      list[i] = m.copyWith(answered: true, approved: approve);
      break;
    }
    if (target == null) return;

    // When approving a plan, switch to auto mode so Claude can proceed
    // without re-prompting for every tool call; on reject, stay in plan.
    final approveMode = approve ? ClaudePermissionMode.auto : null;
    final updatedSession = approveMode != null
        ? session.copyWith(messages: list, permissionMode: approveMode)
        : session.copyWith(messages: list);
    _emitActive(workspaceId, updatedSession);
    if (approveMode != null) {
      _prefs.setString('$_permPrefix$workspaceId', approveMode.name);
    }

    _claudeRepository.respondPlan(sid: workspaceId, toolUseId: target.toolUseId, approve: approve, mode: approveMode);
  }

  void answerPermission(String workspaceId, String messageId, ClaudePermissionDecision decision) {
    final session = _active(workspaceId);
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
    _emitActive(
      workspaceId,
      session.copyWith(messages: list, allowAlwaysActive: session.allowAlwaysActive || allowAlways),
    );
    _permissionRequestToWorkspace.remove(requestId);
    _claudeRepository.respondPermission(sid: workspaceId, toolUseId: requestId, decision: decision);
  }

  Future<void> resumeSession(String workspaceId, String sessionId) async {
    final ws = _workspacesCubit.state.workspacesOrEmpty.firstWhereOrNull((w) => w.id == workspaceId);
    final wsSessions = state.workspaces[workspaceId];
    final active = wsSessions?.activeTab;
    if (ws == null || wsSessions == null || active == null) return;

    if (_runningWorkspaceId == workspaceId) {
      await _stopRun.call(sid: workspaceId);
      _cleanupRun();
    }

    final isActiveEmpty = active.messages.isEmpty && active.claudeSessionId == null;

    final targetTabId = isActiveEmpty ? active.tabId : _genId('tab');
    if (!isActiveEmpty) {
      final tab = _freshTab(workspaceId).copyWith(tabId: targetTabId);
      final ws2 = state.workspaces[workspaceId];
      if (ws2 == null) return;
      emit(
        state.copyWith(
          workspaces: {
            ...state.workspaces,
            workspaceId: ws2.copyWith(tabs: [...ws2.tabs, tab], activeTabId: targetTabId),
          },
        ),
      );
    } else {
      final oldId = active.claudeSessionId;
      if (oldId != null) _sessionToWorkspace.remove(oldId);
    }

    final encoded = _historyDs.encodeCwd(ws.path);
    final result = await _loadSessionMessages(encodedPath: encoded, sessionId: sessionId);
    result.fold((f) => _talker.error('resumeSession load failed for $sessionId: $f'), (messages) {
      final current = state.workspaces[workspaceId]?.tabById(targetTabId);
      if (current == null) return;
      _sessionToWorkspace[sessionId] = workspaceId;
      _emitTab(
        workspaceId,
        targetTabId,
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
      unawaited(_writeOpenSessions(workspaceId));
    });
  }

  Future<void> stopRun() async {
    if (_runningWorkspaceId == null) return;
    final wid = _runningWorkspaceId!;
    final s = _runTab(wid);
    if (s != null && s.queuedPrompt != null) {
      _emitRunTab(wid, s.copyWith(queuedPrompt: null));
    }
    await _stopRun.call(sid: wid);
  }

  void setInputDraft(String workspaceId, ChatInputDraft draft) {
    final session = _active(workspaceId);
    if (session == null) return;
    if (session.inputDraft == draft) return;
    _emitActive(workspaceId, session.copyWith(inputDraft: draft));
  }

  void clearInputDraft(String workspaceId) {
    setInputDraft(workspaceId, ChatInputDraft.empty);
  }

  void setQueuedPrompt(String workspaceId, String text) {
    final trimmed = text.trim();
    final session = _active(workspaceId);
    if (session == null) return;
    if (trimmed.isEmpty) {
      if (session.queuedPrompt == null) return;
      _emitActive(workspaceId, session.copyWith(queuedPrompt: null));
      return;
    }
    final existing = session.queuedPrompt;
    final next = QueuedPrompt(text: trimmed, enqueuedAt: existing?.enqueuedAt ?? DateTime.now());
    if (existing == next) return;
    _emitActive(workspaceId, session.copyWith(queuedPrompt: next));
  }

  void clearQueuedPrompt(String workspaceId) {
    final session = _active(workspaceId);
    if (session == null || session.queuedPrompt == null) return;
    _emitActive(workspaceId, session.copyWith(queuedPrompt: null));
  }

  /// After a run finishes, start the next queued prompt (single-run model).
  /// Prefers the just-finished tab, then falls back to the globally oldest
  /// queued prompt by `enqueuedAt` so nothing sits stuck behind a busy tab.
  void _drainNextQueued({String? preferWid, String? preferTabId}) {
    if (_runningWorkspaceId != null) return;

    (String wid, ClaudeSessionData tab)? pick;
    if (preferWid != null && preferTabId != null) {
      final t = state.workspaces[preferWid]?.tabById(preferTabId);
      if (t?.queuedPrompt != null) pick = (preferWid, t!);
    }
    if (pick == null) {
      DateTime? oldest;
      state.workspaces.forEach((wid, ws) {
        for (final t in ws.tabs) {
          final q = t.queuedPrompt;
          if (q == null) continue;
          if (oldest == null || q.enqueuedAt.isBefore(oldest!)) {
            oldest = q.enqueuedAt;
            pick = (wid, t);
          }
        }
      });
    }
    if (pick == null) return;

    final (wid, tab) = pick!;
    final text = tab.queuedPrompt!.text;
    _emitTab(wid, tab.tabId, tab.copyWith(queuedPrompt: null));
    Future.microtask(() => sendPrompt(wid, text, tabId: tab.tabId));
  }

  Future<void> sendPrompt(
    String workspaceId,
    String text, {
    List<String> slashTriggers = const [],
    List<ChatAttachment> attachments = const [],
    String? tabId,
  }) async {
    final trimmed = text.trim();
    final hasContent = trimmed.isNotEmpty || slashTriggers.isNotEmpty || attachments.isNotEmpty;
    if (!hasContent) return;
    // Target the requested tab, defaulting to the active one. Threading the id
    // keeps a drained queued prompt on its origin tab instead of the (possibly
    // different) active tab.
    final targetTabId = tabId ?? state.workspaces[workspaceId]?.activeTabId;
    final session = targetTabId == null ? null : state.workspaces[workspaceId]?.tabById(targetTabId);
    if (session == null || targetTabId == null) {
      _talker.warning('sendPrompt for unknown workspace/tab: $workspaceId/$tabId');
      return;
    }
    if (_runningWorkspaceId != null) {
      // Single-run model: a run is already in flight (this or another tab).
      // Don't drop the message — queue it on its target tab, FIFO-drained when
      // the current run finishes (see _drainNextQueued).
      if (trimmed.isNotEmpty) {
        _emitTab(
          workspaceId,
          targetTabId,
          session.copyWith(
            queuedPrompt: QueuedPrompt(text: trimmed, enqueuedAt: session.queuedPrompt?.enqueuedAt ?? DateTime.now()),
          ),
        );
      }
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

    final imagePaths = attachments.where((a) => a.kind == ChatAttachmentKind.imageCapture).map((a) => a.path).toList();

    final fileTokens = attachments
        .where((a) => a.kind != ChatAttachmentKind.fileRange && a.kind != ChatAttachmentKind.imageCapture)
        .map((a) => formatAttachmentToken(a.path))
        .toList();
    final rangeTokens = attachments
        .where((a) => a.kind == ChatAttachmentKind.fileRange)
        .map((a) => formatAttachmentToken(a.path))
        .toList();
    final rangeBlocks = attachments.where((a) => a.kind == ChatAttachmentKind.fileRange).map((a) {
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

    // `thinking` is now sent as a proper protocol field on `start` (see
    // SendPromptParams below) rather than prepended as a CLI keyword prefix.
    final basePrompt = concatPrompt;
    final bootstrap = _pendingCompactBootstrap[targetTabId];
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
      ClaudeMessage.assistant(id: assistantMsgId, text: '', isStreaming: true, createdAt: now),
    ];

    _emitTab(
      workspaceId,
      targetTabId,
      session.copyWith(
        messages: messages,
        runStatus: ClaudeRunStatus.connecting,
        lastError: null,
        stderrTail: const [],
      ),
    );
    // Note: bootstrap is removed only after the run reaches `idle`
    // (see _finishRun); a synchronous failure preserves it so the next
    // retry still injects the recap.

    _talker.debug('[cc] u> ${_oneLine(_truncate(cliPrompt, 800))}');

    _runningWorkspaceId = workspaceId;
    _runningTabId = targetTabId;
    _streamingText = '';
    _lastFlushAt = null;

    final params = SendPromptParams(
      cwd: workspaceId,
      prompt: cliPrompt,
      mode: session.permissionMode,
      model: session.model,
      effort: session.effort,
      thinking: session.thinkingMode == ClaudeThinkingMode.on,
      resumeSessionId: session.claudeSessionId,
      imagePaths: imagePaths,
      disabledMcp: session.disabledMcpServers,
    );

    _runSub = _sendPrompt
        .call(params)
        .listen(
          _onEvent,
          onError: (e, st) {
            _talker.error('Claude run errored', e, st);
            _finishRun(status: ClaudeRunStatus.error, failure: UnexpectedFailure('$e'));
          },
          onDone: () {
            if (_runningWorkspaceId != null) {
              _finishRun(status: ClaudeRunStatus.idle);
            }
          },
        );
  }

  void _onEvent(Either<Failure, ClaudeEvent> result) {
    result.fold((failure) {
      _finishRun(status: ClaudeRunStatus.error, failure: failure);
    }, _handleEvent);
  }

  void _handleEvent(ClaudeEvent event) {
    final wid = _runningWorkspaceId;
    final tabId = _runningTabId;
    if (wid == null || tabId == null) return;
    final session = state.workspaces[wid]?.tabById(tabId);
    if (session == null) return;

    switch (event) {
      case ClaudeEventSessionInit(:final sessionId, :final model, :final skills, :final mcpServers):
        _talker.debug('Claude session init: $sessionId model=$model');
        if (sessionId.isNotEmpty) {
          _sessionToWorkspace[sessionId] = wid;
        }
        // Subprocess has read the prompt — safe to drop the consumed
        // post-compact bootstrap so it is not re-injected on the next turn.
        _pendingCompactBootstrap.remove(tabId);
        _emitTab(
          wid,
          tabId,
          session.copyWith(
            claudeSessionId: sessionId.isEmpty ? null : sessionId,
            runStatus: ClaudeRunStatus.running,
            availableSkills: skills,
          ),
        );
        unawaited(_writeOpenSessions(wid));
        mergeMcpServersFromSessionInit(mcpServers);

      case ClaudeEventTextChunk(:final text):
        _ensureStreamingMessage(wid);
        _streamingText += text;
        final now = DateTime.now();
        final since = _lastFlushAt == null ? const Duration(days: 1) : now.difference(_lastFlushAt!);
        if (since.inMilliseconds >= _flushMs) {
          _flushStreamingChunks();
        } else {
          _chunkFlushTimer ??= Timer(Duration(milliseconds: _flushMs - since.inMilliseconds), _flushStreamingChunks);
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

      case ClaudeEventToolCallComplete(:final toolId, :final input, :final index):
        _completeToolMessage(wid, toolUseId: toolId, input: input);
        _talker.debug(
          '[cc] tool> ${_toolNameFor(wid, toolId) ?? "?"}#$index'
          '${_describeToolInput(input)}',
        );

      case ClaudeEventToolResult(:final toolUseId, :final content, :final isError):
        _attachToolResult(wid, toolUseId: toolUseId, output: content, isError: isError);
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

      case ClaudeEventPermissionRequest(:final requestId, :final toolName, :final toolInput):
        _permissionRequestToWorkspace[requestId] = wid;
        final messageId = _genId('pr');
        _appendMessage(
          wid,
          ClaudeMessage.permissionRequest(
            id: messageId,
            requestId: requestId,
            toolName: toolName,
            toolInput: toolInput,
            createdAt: DateTime.now(),
          ),
        );

      case ClaudeEventPlanProposed(:final toolUseId, :final plan, :final planFilePath):
        _appendMessage(
          wid,
          ClaudeMessage.plan(
            id: _genId('pl'),
            toolUseId: toolUseId,
            plan: plan,
            planFilePath: planFilePath,
            createdAt: DateTime.now(),
          ),
        );

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
        _emitTab(wid, tabId, session.copyWith(usage: updated));

      case ClaudeEventSessionDead(:final exitCode, :final stderrTail):
        _flushStreamingChunks();
        _finishRun(
          status: exitCode == 0 ? ClaudeRunStatus.idle : ClaudeRunStatus.sessionDead,
          failure: exitCode == 0 ? null : SubprocessFailure(message: 'exit_code', exitCode: exitCode),
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
    final tabId = _runningTabId;
    if (tabId == null) return;
    final session = state.workspaces[wid]?.tabById(tabId);
    if (session == null) return;
    final placeholder = ClaudeMessage.assistant(
      id: _genId('a'),
      text: '',
      isStreaming: true,
      createdAt: DateTime.now(),
    );
    _emitTab(wid, tabId, session.copyWith(messages: [...session.messages, placeholder]));
  }

  void _replaceStreamingMessage(String wid, String text, {required bool isStreaming}) {
    final tabId = _runningTabId;
    if (tabId == null) return;
    final session = state.workspaces[wid]?.tabById(tabId);
    if (session == null) return;
    final mid = _streamingMessageIdFor(wid);
    if (mid == null) return;
    final messages = [
      for (final m in session.messages)
        if (m is ClaudeMessageAssistant && m.id == mid) m.copyWith(text: text, isStreaming: isStreaming) else m,
    ];
    _emitTab(wid, tabId, session.copyWith(messages: messages));
  }

  void _appendMessage(String wid, ClaudeMessage message) {
    final tabId = _runningTabId;
    if (tabId == null) return;
    final session = state.workspaces[wid]?.tabById(tabId);
    if (session == null) return;
    final messages = [...session.messages, message];
    _emitTab(wid, tabId, session.copyWith(messages: messages));
  }

  void _completeToolMessage(String wid, {String? toolUseId, Map<String, dynamic>? input}) {
    final tabId = _runningTabId;
    if (tabId == null) return;
    final session = state.workspaces[wid]?.tabById(tabId);
    if (session == null) return;
    final list = [...session.messages];
    for (var i = list.length - 1; i >= 0; i--) {
      final m = list[i];
      if (m is! ClaudeMessageTool) continue;
      if (m.status != ClaudeToolStatus.running) continue;
      if (toolUseId != null && m.toolUseId != null && m.toolUseId != toolUseId) {
        continue;
      }
      list[i] = m.copyWith(status: ClaudeToolStatus.completed, input: input ?? m.input);
      break;
    }
    _emitTab(wid, tabId, session.copyWith(messages: list));
  }

  void _attachToolResult(String wid, {required String toolUseId, required String output, required bool isError}) {
    if (toolUseId.isEmpty) return;
    final tabId = _runningTabId;
    if (tabId == null) return;
    final session = state.workspaces[wid]?.tabById(tabId);
    if (session == null) return;
    final list = [...session.messages];
    for (var i = list.length - 1; i >= 0; i--) {
      final m = list[i];
      if (m is! ClaudeMessageTool) continue;
      if (m.toolUseId != toolUseId) continue;
      list[i] = m.copyWith(
        output: output,
        isError: isError,
        status: isError ? ClaudeToolStatus.error : ClaudeToolStatus.completed,
      );
      break;
    }
    _emitTab(wid, tabId, session.copyWith(messages: list));
  }

  /// Stub system message when last turn had tools but no text reply, so user
  /// has a visible completion marker.
  List<ClaudeMessage> _appendCompletionStubIfNeeded(List<ClaudeMessage> messages) {
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
    final endsWithText = last is ClaudeMessageAssistant && last.text.trim().isNotEmpty;
    if (endsWithText) return messages;
    final now = DateTime.now();
    return [
      ...messages,
      ClaudeMessage.system(id: _genId('s'), text: LocaleKeys.claude_message_completionStub, createdAt: now),
    ];
  }

  void _finishRun({required ClaudeRunStatus status, Failure? failure, List<String>? stderrTail}) {
    final wid = _runningWorkspaceId;
    final tabId = _runningTabId;
    if (wid != null && tabId != null) {
      final session = state.workspaces[wid]?.tabById(tabId);
      if (session != null) {
        final mid = _streamingMessageIdFor(wid);
        var messages = session.messages;
        if (mid != null) {
          messages = [
            for (final m in messages)
              if (m is ClaudeMessageAssistant && m.id == mid) m.copyWith(isStreaming: false) else m,
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
        _emitTab(
          wid,
          tabId,
          session.copyWith(
            messages: messages,
            runStatus: status,
            lastError: failure,
            stderrTail: stderrTail ?? session.stderrTail,
          ),
        );
      }
    }
    _cleanupRun();
    // Drain on ANY terminal status (idle/error/sessionDead) so a queued prompt
    // never gets stuck behind a run that ended badly.
    _drainNextQueued(preferWid: wid, preferTabId: tabId);
  }

  void _cleanupRun() {
    _flushChunkTimerCancel();
    _runSub?.cancel();
    _runSub = null;
    _runningWorkspaceId = null;
    _runningTabId = null;
    _streamingText = '';
    _lastFlushAt = null;
  }

  /// Last known MCP server list from emitted state (empty until first load).
  /// Read-only convenience for cheap UI (e.g. the settings snippet count);
  /// callers that need freshness use [ensureMcpServers].
  List<McpServer> get cachedMcpServers => state.mcpServers;

  Future<List<McpServer>> ensureMcpServers({bool force = false}) async {
    final now = DateTime.now();
    if (!force &&
        _mcpServersCachedAt != null &&
        state.mcpServers.isNotEmpty &&
        now.difference(_mcpServersCachedAt!) < _mcpCacheTtl) {
      return state.mcpServers;
    }
    final result = await _listMcpServers();
    return result.fold(
      (f) {
        _talker.warning('mcp list failed: $f');
        return state.mcpServers;
      },
      (servers) {
        _mcpServersCachedAt = now;
        emit(state.copyWith(mcpServers: servers));
        return servers;
      },
    );
  }

  /// Merges the free MCP status snapshot carried by `sessionInit` into the
  /// emitted list: updates the status of servers already known from `claude mcp
  /// list`, and adds any missing ones. Never downgrades an entry's
  /// `commandOrUrl` (sessionInit does not provide it).
  ///
  /// Exposed for testing: the merge is otherwise reachable only through a full
  /// `sessionInit` event round-trip; the seam lets a test assert the merged
  /// `state.mcpServers` deterministically.
  @visibleForTesting
  void mergeMcpServersFromSessionInit(List<McpServer> fromInit) {
    if (fromInit.isEmpty) return;
    final existing = {for (final s in state.mcpServers) s.name: s};
    for (final incoming in fromInit) {
      final current = existing[incoming.name];
      existing[incoming.name] = current == null ? incoming : current.copyWith(status: incoming.status);
    }
    _mcpServersCachedAt = DateTime.now();
    emit(state.copyWith(mcpServers: existing.values.toList()));
  }

  /// Toggling doesn't touch a live session — one-shot runs pick up
  /// `disabledMcpServers` as `disabledMcp` on the *next* prompt (see
  /// [sendPrompt]/[compactSession]). Just persist the flag.
  Future<void> toggleMcpServer(String workspaceId, String serverName, bool enabled) async {
    final session = _active(workspaceId);
    if (session == null) return;

    final next = Set<String>.from(session.disabledMcpServers);
    if (enabled) {
      next.remove(serverName);
    } else {
      next.add(serverName);
    }
    _emitActive(workspaceId, session.copyWith(disabledMcpServers: next));
    await _writeMcpDisabled(workspaceId, next);
    _talker.info('mcp toggle: $serverName=${enabled ? "on" : "off"} (applies to next run)');
  }

  /// Kicks off the OAuth flow for a `needs-auth` MCP server. Runs in an
  /// ephemeral sidecar query (no chat run required) and opens the returned
  /// authUrl in the browser; claude.ai brokers the callback server-side. The
  /// flow completes out-of-band in the browser, so the picker's refresh button
  /// (or the TTL expiry) surfaces the new `connected` status — a forced
  /// `claude mcp list` reflects it since claude.ai auth is account-wide.
  Future<void> authenticateMcpServer(String workspaceId, String serverName) async {
    // Re-entrancy guard: a second tap while the first flow is in flight would
    // spawn a duplicate ephemeral sidecar query (same sid, no backend dedup) →
    // two browser tabs + a doubled leak. Bail if already running.
    if (state.mcpAuthInFlight.contains(serverName)) {
      _talker.info('mcp auth: already in flight for $serverName');
      return;
    }
    emit(state.copyWith(mcpAuthInFlight: {...state.mcpAuthInFlight, serverName}));
    _talker.info('mcp auth: starting flow for $serverName');
    try {
      final result = await _authenticateMcpServer(cwd: workspaceId, serverName: serverName);
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
    } finally {
      emit(state.copyWith(mcpAuthInFlight: state.mcpAuthInFlight.difference({serverName})));
    }
  }

  /// Derives a human-readable tab title from the first user message, since
  /// tabs don't carry a separate persisted title field.
  static String sessionTitle(ClaudeSessionData d) {
    for (final m in d.messages) {
      if (m is ClaudeMessageUser && m.text.trim().isNotEmpty) {
        final t = m.text.trim();
        return t.length > 40 ? '${t.substring(0, 40)}…' : t;
      }
    }
    return Locales.Claude.Session.newTab;
  }

  @override
  Future<void> close() async {
    _cleanupRun();
    await _workspacesSub?.cancel();
    if (_runningWorkspaceId != null) {
      await _stopRun.call(sid: _runningWorkspaceId!);
    }
    return super.close();
  }
}

enum _InterceptedCommand { compact, clear }
