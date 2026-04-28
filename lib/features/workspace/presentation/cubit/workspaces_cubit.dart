import 'dart:async';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/workspaces_persistence_datasource.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/usecases/open_workspace.dart';

part 'workspaces_cubit.freezed.dart';
part 'workspaces_cubit.state.dart';

@lazySingleton
class WorkspacesCubit extends Cubit<WorkspacesState> {
  WorkspacesCubit(this._openWorkspace, this._persistence, this._talker)
      : super(const WorkspacesState.initial());

  final OpenWorkspace _openWorkspace;
  final WorkspacesPersistenceDataSource _persistence;
  final Talker _talker;

  bool _restoring = false;
  Timer? _saveDebounce;
  StreamSubscription<WorkspacesState>? _selfSub;

  static const _saveDebounceMs = 250;

  @PostConstruct()
  void init() {
    _selfSub = stream.listen((_) {
      if (_restoring) return;
      _saveDebounce?.cancel();
      _saveDebounce = Timer(const Duration(milliseconds: _saveDebounceMs), _persist);
    });
  }

  String _normalize(String path) => p.normalize(p.absolute(path));

  Future<void> openFromPicker() async {
    final selected = await FilePicker.getDirectoryPath(
      dialogTitle: 'workspace.picker.title'.tr(),
    );
    if (selected == null) {
      _talker.debug('Workspace picker dismissed');
      return;
    }
    await openPath(selected);
  }

  Future<void> openPath(String path) async {
    final start = DateTime.now();
    final normalized = _normalize(path);
    final existing = state.workspacesOrEmpty;

    final duplicate = existing.firstWhereOrNull((w) => w.id == normalized);
    if (duplicate != null) {
      _talker.info('Workspace already open: $normalized — activating existing tab');
      setActive(duplicate.id);
      return;
    }

    final result = await _openWorkspace(path: normalized);

    result.fold(
      (failure) {
        _talker.error('Failed to open workspace: $normalized', failure);
        emit(WorkspacesState.loaded(
          workspaces: existing,
          activeId: state.activeIdOrNull,
          lastFailure: failure,
        ));
      },
      (workspace) {
        emit(WorkspacesState.loaded(
          workspaces: [...existing, workspace],
          activeId: workspace.id,
        ));
        final ms = DateTime.now().difference(start).inMilliseconds;
        _talker.info('Workspace opened: ${workspace.name} (${ms}ms, claudeMd=${workspace.claudeMd != null})');
      },
    );
  }

  void closeWorkspace(WorkspaceId id) {
    final list = state.workspacesOrEmpty;
    final index = list.indexWhere((w) => w.id == id);
    if (index < 0) return;

    _talker.info('Closed workspace: $id');
    final next = [...list]..removeAt(index);
    if (next.isEmpty) {
      emit(const WorkspacesState.loaded());
      return;
    }

    var newActive = state.activeIdOrNull;
    if (newActive == id) {
      newActive = next[index < next.length ? index : next.length - 1].id;
    }
    emit(WorkspacesState.loaded(workspaces: next, activeId: newActive));
  }

  void setActive(WorkspaceId id) {
    final list = state.workspacesOrEmpty;
    if (!list.any((w) => w.id == id)) return;
    if (state.activeIdOrNull == id) return;
    _talker.debug('Switching active workspace: $id');
    emit(WorkspacesState.loaded(workspaces: list, activeId: id));
  }

  Future<void> restore() async {
    _restoring = true;
    try {
      final snapshot = await _persistence.read();
      if (snapshot == null || snapshot.workspaces.isEmpty) {
        emit(const WorkspacesState.loaded());
        return;
      }
      final results = await Future.wait(snapshot.workspaces.map((entry) async {
        final r = await _openWorkspace(path: entry.path);
        return r.fold(
          (failure) {
            _talker.info('Skipped restoring workspace ${entry.path}: $failure');
            return null;
          },
          (ws) => ws.copyWith(openedAt: entry.openedAt),
        );
      }));
      final restored = results.whereType<Workspace>().toList(growable: false);
      var activeId = snapshot.activeId;
      if (activeId == null || !restored.any((w) => w.id == activeId)) {
        activeId = restored.isNotEmpty ? restored.first.id : null;
      }
      emit(WorkspacesState.loaded(workspaces: restored, activeId: activeId));
      _talker.info('Restored ${restored.length}/${snapshot.workspaces.length} workspace(s)');
    } finally {
      _restoring = false;
    }
  }

  Future<void> _persist() async {
    final s = state;
    if (s is! WorkspacesStateLoaded) return;
    try {
      await _persistence.write(PersistedWorkspaces(
        activeId: s.activeId,
        workspaces: s.workspaces
            .map((w) => PersistedWorkspaceEntry(
                  id: w.id,
                  path: w.path,
                  name: w.name,
                  openedAt: w.openedAt,
                ))
            .toList(growable: false),
      ));
    } catch (e, st) {
      _talker.error('Failed to persist workspaces', e, st);
    }
  }

  @override
  Future<void> close() async {
    _saveDebounce?.cancel();
    await _selfSub?.cancel();
    return super.close();
  }
}
