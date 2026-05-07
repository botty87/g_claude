import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:xterm/xterm.dart';

import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../data/datasources/pty_datasource.dart';

part 'terminal_sessions_cubit.freezed.dart';
part 'terminal_sessions_cubit.state.dart';

@lazySingleton
class TerminalSessionsCubit extends Cubit<TerminalSessionsState> {
  TerminalSessionsCubit(this._datasource, this._workspacesCubit, this._talker) : super(const TerminalSessionsState());

  final PtyDataSource _datasource;
  final WorkspacesCubit _workspacesCubit;
  final Talker _talker;

  StreamSubscription<WorkspacesState>? _workspacesSub;
  StreamSubscription<PtySessionEvent>? _eventsSub;

  @PostConstruct()
  void init() {
    // Subscribe to datasource events BEFORE listening to workspace changes.
    // WorkspacesCubit may already hold restored workspaces at boot — the
    // synchronous replay in the next line spawns PTYs immediately, and
    // their events must have a listener in place.
    _eventsSub = _datasource.events.listen(_onPtyEvent);
    _workspacesSub = _workspacesCubit.stream.listen(_onWorkspacesChanged);
    _onWorkspacesChanged(_workspacesCubit.state);
  }

  void _onWorkspacesChanged(WorkspacesState s) {
    final list = s.workspacesOrEmpty;
    final ids = list.map((w) => w.id).toSet();

    final added = [
      for (final w in list)
        if (!state.sessions.containsKey(w.id)) w,
    ];
    final removed = [
      for (final k in state.sessions.keys)
        if (!ids.contains(k)) k,
    ];

    if (added.isEmpty && removed.isEmpty) return;

    final map = Map<String, TerminalSessionInfo>.from(state.sessions);

    for (final w in added) {
      map[w.id] = TerminalSessionInfo(
        shellPath: _datasource.detectShell(),
        cwd: w.path,
        status: TerminalRunStatus.starting,
      );
    }

    for (final id in removed) {
      map.remove(id);
    }

    // Emit `starting` BEFORE spawning. `getOrCreate` synchronously fires a
    // `running` event on the broadcast stream; `_onPtyEvent` runs on a
    // microtask and looks up `state.sessions[id]`. If we spawned before the
    // emit, the lookup would miss and the running transition would be
    // silently dropped.
    emit(state.copyWith(sessions: map));

    for (final w in added) {
      _datasource.getOrCreate(workspaceId: w.id, cwd: w.path);
    }

    for (final id in removed) {
      // Fire-and-forget: dispose runs the SIGTERM→SIGKILL sequence.
      unawaited(_datasource.dispose(id));
    }
  }

  void _onPtyEvent(PtySessionEvent event) {
    final session = state.sessions[event.workspaceId];
    if (session == null) return;

    final updated = switch (event) {
      PtySessionEventRunning() => session.copyWith(status: TerminalRunStatus.running),
      PtySessionEventExited(:final exitCode) => session.copyWith(status: TerminalRunStatus.exited, exitCode: exitCode),
      PtySessionEventFailed(:final error) => session.copyWith(status: TerminalRunStatus.failed, lastError: error),
    };
    _emitSession(event.workspaceId, updated);
  }

  void _emitSession(String workspaceId, TerminalSessionInfo info) {
    final map = Map<String, TerminalSessionInfo>.from(state.sessions);
    map[workspaceId] = info;
    emit(state.copyWith(sessions: map));
  }

  /// Returns the live xterm Terminal for UI binding.
  /// Not a state getter — called from widget build, not from context.select.
  Terminal? terminalFor(String workspaceId) {
    return _datasource.terminalFor(workspaceId);
  }

  /// Returns the TerminalController paired with the live Terminal.
  TerminalController? controllerFor(String workspaceId) {
    return _datasource.controllerFor(workspaceId);
  }

  /// Kills the current PTY and spawns a fresh one for the workspace.
  void restart(String workspaceId) {
    final session = state.sessions[workspaceId];
    if (session == null) return;
    if (session.status == TerminalRunStatus.starting) return;

    _talker.info('Restarting terminal for workspace $workspaceId');

    _emitSession(
      workspaceId,
      session.copyWith(
        status: TerminalRunStatus.starting,
        exitCode: null,
        lastError: null,
        incarnation: session.incarnation + 1,
      ),
    );

    _datasource.dispose(workspaceId).then((_) {
      // Workspace may have been closed while dispose was in flight.
      final current = state.sessions[workspaceId];
      if (current == null) return;
      // Re-emit clean starting: the killed PTY's exitCode.then is now stale
      // (datasource filters it via identical()), but in case the cubit
      // received the exited event before that filter took effect, this
      // restores the intended state.
      _emitSession(workspaceId, current.copyWith(status: TerminalRunStatus.starting, exitCode: null, lastError: null));
      _datasource.getOrCreate(workspaceId: workspaceId, cwd: current.cwd);
    });
  }

  @override
  Future<void> close() async {
    await _eventsSub?.cancel();
    await _workspacesSub?.cancel();
    await _datasource.disposeAll();
    return super.close();
  }
}
