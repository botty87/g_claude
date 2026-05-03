import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../domain/entities/chat_session_summary.dart';
import '../../domain/entities/claude_message.dart';
import '../../domain/usecases/delete_chat_session.dart';
import '../../domain/usecases/export_chat_session.dart';
import '../../domain/usecases/load_chat_history.dart';
import '../../domain/usecases/load_session_messages.dart';
import '../../domain/usecases/refresh_sessions_index.dart';
import '../../data/datasources/claude_history_datasource.dart';

part 'chat_history_cubit.freezed.dart';
part 'chat_history_cubit.state.dart';

@lazySingleton
class ChatHistoryCubit extends Cubit<ChatHistoryState> {
  ChatHistoryCubit(
    this._loadHistory,
    this._loadMessages,
    this._refreshIndex,
    this._deleteSession,
    this._exportSession,
    this._historyDs,
    this._workspacesCubit,
    this._talker,
  ) : super(const ChatHistoryState());

  final LoadChatHistory _loadHistory;
  final LoadSessionMessages _loadMessages;
  final RefreshSessionsIndex _refreshIndex;
  final DeleteChatSession _deleteSession;
  final ExportChatSession _exportSession;
  final ClaudeHistoryDataSource _historyDs;
  final WorkspacesCubit _workspacesCubit;
  final Talker _talker;

  StreamSubscription<WorkspacesState>? _wsSub;

  @PostConstruct()
  void init() {
    _wsSub = _workspacesCubit.stream.listen(_onWorkspacesChanged);
    _onWorkspacesChanged(_workspacesCubit.state);
  }

  void _onWorkspacesChanged(WorkspacesState s) {
    final list = s.workspacesOrEmpty;
    final ids = list.map((w) => w.id).toSet();
    final added = [
      for (final w in list) if (!state.byWorkspace.containsKey(w.id)) w,
    ];
    final removed = [
      for (final k in state.byWorkspace.keys) if (!ids.contains(k)) k,
    ];
    if (added.isEmpty && removed.isEmpty) return;

    final map = Map<String, WorkspaceHistory>.from(state.byWorkspace);
    for (final w in added) {
      map[w.id] = const WorkspaceHistory();
      unawaited(refresh(w.id, w.path));
    }
    for (final id in removed) {
      map.remove(id);
    }
    emit(state.copyWith(byWorkspace: map));
  }

  Future<void> refresh(WorkspaceId workspaceId, String cwd) async {
    _emitWs(workspaceId, _historyOrEmpty(workspaceId).copyWith(status: HistoryStatus.loading));

    final refreshResult = await _refreshIndex(
      workspaceId: workspaceId,
      workspaceCwd: cwd,
    );
    refreshResult.fold(
      (f) => _talker.warning('refreshIndex failed for $workspaceId: $f'),
      (_) => null,
    );

    final loadResult = await _loadHistory(workspaceId);
    loadResult.fold(
      (f) {
        _talker.error('loadHistory failed for $workspaceId: $f');
        _emitWs(
          workspaceId,
          _historyOrEmpty(workspaceId).copyWith(
            status: HistoryStatus.error,
            lastError: f,
          ),
        );
      },
      (sessions) {
        _emitWs(
          workspaceId,
          _historyOrEmpty(workspaceId).copyWith(
            sessions: sessions,
            status: HistoryStatus.idle,
            lastError: null,
          ),
        );
      },
    );
  }

  void selectSession(WorkspaceId workspaceId, String sessionId) {
    _emitWs(
      workspaceId,
      _historyOrEmpty(workspaceId).copyWith(
        selectedId: sessionId,
        previewMessages: const [],
        previewLoading: true,
      ),
    );
    unawaited(_loadPreview(workspaceId, sessionId));
  }

  Future<void> _loadPreview(WorkspaceId workspaceId, String sessionId) async {
    final history = state.byWorkspace[workspaceId];
    if (history == null) return;

    final summary = history.sessions.firstWhereOrNull((s) => s.id == sessionId);
    if (summary == null) {
      _talker.warning('selectSession: session $sessionId not found in workspace $workspaceId');
      _emitWs(workspaceId, _historyOrEmpty(workspaceId).copyWith(previewLoading: false));
      return;
    }

    final result = await _loadMessages(
      encodedPath: summary.encodedPath,
      sessionId: sessionId,
    );
    result.fold(
      (f) {
        _talker.error('loadMessages failed for $sessionId: $f');
        _emitWs(workspaceId, _historyOrEmpty(workspaceId).copyWith(previewLoading: false));
      },
      (messages) {
        final current = state.byWorkspace[workspaceId];
        if (current?.selectedId != sessionId) return;
        _emitWs(
          workspaceId,
          _historyOrEmpty(workspaceId).copyWith(
            previewMessages: messages,
            previewLoading: false,
          ),
        );
      },
    );
  }

  void clearSelection(WorkspaceId workspaceId) {
    _emitWs(
      workspaceId,
      _historyOrEmpty(workspaceId).copyWith(
        selectedId: null,
        previewMessages: const [],
        previewLoading: false,
      ),
    );
  }

  void setQuery(WorkspaceId workspaceId, String query) {
    _emitWs(workspaceId, _historyOrEmpty(workspaceId).copyWith(query: query));
  }

  Future<void> delete(
    WorkspaceId workspaceId,
    String sessionId,
    String encodedPath,
  ) async {
    final result = await _deleteSession(
      sessionId: sessionId,
      encodedPath: encodedPath,
    );
    result.fold(
      (f) => _talker.error('deleteSession failed for $sessionId: $f'),
      (_) {
        final history = _historyOrEmpty(workspaceId);
        final sessions = history.sessions.where((s) => s.id != sessionId).toList();
        var updated = history.copyWith(sessions: sessions);
        if (history.selectedId == sessionId) {
          updated = updated.copyWith(
            selectedId: null,
            previewMessages: const [],
            previewLoading: false,
          );
        }
        _emitWs(workspaceId, updated);
      },
    );
  }

  Future<String?> export(
    WorkspaceId workspaceId,
    String sessionId,
    String encodedPath,
    String destinationPath,
  ) async {
    final result = await _exportSession(
      encodedPath: encodedPath,
      sessionId: sessionId,
      destinationPath: destinationPath,
    );
    return result.fold(
      (f) {
        _talker.error('exportSession failed for $sessionId: $f');
        return null;
      },
      (path) => path,
    );
  }

  String encodeCwd(String cwd) => _historyDs.encodeCwd(cwd);

  WorkspaceHistory _historyOrEmpty(String workspaceId) =>
      state.byWorkspace[workspaceId] ?? const WorkspaceHistory();

  void _emitWs(String workspaceId, WorkspaceHistory next) {
    final map = Map<String, WorkspaceHistory>.from(state.byWorkspace);
    map[workspaceId] = next;
    emit(state.copyWith(byWorkspace: map));
  }

  @override
  Future<void> close() async {
    await _wsSub?.cancel();
    return super.close();
  }
}
