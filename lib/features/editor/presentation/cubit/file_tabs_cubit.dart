import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../features/workspace/domain/entities/workspace.dart';
import '../../../../features/workspace/presentation/cubit/workspaces_cubit.dart';
import '../../data/datasources/file_tabs_persistence_datasource.dart';

part 'file_tabs_cubit.freezed.dart';
part 'file_tabs_cubit.state.dart';

@lazySingleton
class FileTabsCubit extends Cubit<FileTabsState> {
  FileTabsCubit(this._workspacesCubit, this._persistence, this._talker)
      : super(const FileTabsState());

  final WorkspacesCubit _workspacesCubit;
  final FileTabsPersistenceDataSource _persistence;
  final Talker _talker;
  StreamSubscription<WorkspacesState>? _wsSub;
  StreamSubscription<FileTabsState>? _selfSub;
  Timer? _saveDebounce;
  bool _restoring = false;

  static const _saveDebounceMs = 250;

  @PostConstruct()
  void init() {
    _wsSub = _workspacesCubit.stream.listen(_onWorkspacesChanged);
    _selfSub = stream.listen((_) {
      if (_restoring) return;
      _saveDebounce?.cancel();
      _saveDebounce = Timer(const Duration(milliseconds: _saveDebounceMs), _persist);
    });
  }

  void _onWorkspacesChanged(WorkspacesState ws) {
    final aliveIds = ws.workspacesOrEmpty.map((w) => w.id).toSet();
    final stale = state.perWorkspace.keys
        .where((id) => !aliveIds.contains(id))
        .toList();
    if (stale.isEmpty) return;
    final next = Map.of(state.perWorkspace)
      ..removeWhere((k, _) => stale.contains(k));
    _talker.debug('FileTabsCubit: pruned ${stale.length} stale workspace(s)');
    emit(state.copyWith(perWorkspace: next));
  }

  void openFile(WorkspaceId id, String path) {
    final files = state.perWorkspace[id] ?? const WorkspaceFiles();

    if (files.openPaths.contains(path)) {
      setActiveFile(id, path);
      return;
    }

    final WorkspaceFiles next;
    if (files.previewPath != null) {
      final previewIdx = files.openPaths.indexOf(files.previewPath!);
      final nextPaths = [...files.openPaths];
      nextPaths[previewIdx] = path;
      next = files.copyWith(
        openPaths: nextPaths,
        activePath: path,
        previewPath: path,
      );
    } else {
      next = files.copyWith(
        openPaths: [...files.openPaths, path],
        activePath: path,
        previewPath: path,
      );
    }

    _talker.debug('FileTabsCubit: opened $path in workspace $id (preview)');
    emit(state.copyWith(perWorkspace: {...state.perWorkspace, id: next}));
  }

  void pinFile(WorkspaceId id, String path) {
    final files = state.perWorkspace[id];
    if (files == null) return;
    if (files.previewPath != path) return;
    _talker.debug('FileTabsCubit: pinned $path');
    emit(state.copyWith(
      perWorkspace: {
        ...state.perWorkspace,
        id: files.copyWith(previewPath: null),
      },
    ));
  }

  void closeFile(WorkspaceId id, String path) {
    final files = state.perWorkspace[id];
    if (files == null) return;
    final index = files.openPaths.indexOf(path);
    if (index < 0) return;

    final nextPaths = [...files.openPaths]..removeAt(index);
    final nextPreview = files.previewPath == path ? null : files.previewPath;

    if (nextPaths.isEmpty) {
      final next = files.copyWith(
        openPaths: [],
        activePath: null,
        previewPath: null,
      );
      emit(state.copyWith(perWorkspace: {...state.perWorkspace, id: next}));
      return;
    }

    String? newActive = files.activePath;
    if (newActive == path) {
      newActive =
          nextPaths[index < nextPaths.length ? index : nextPaths.length - 1];
    }
    final next = files.copyWith(
      openPaths: nextPaths,
      activePath: newActive,
      previewPath: nextPreview,
    );
    _talker.debug('FileTabsCubit: closed $path in workspace $id');
    emit(state.copyWith(perWorkspace: {...state.perWorkspace, id: next}));
  }

  void setActiveFile(WorkspaceId id, String path) {
    final files = state.perWorkspace[id];
    if (files == null) return;
    if (files.activePath == path) return;
    if (!files.openPaths.contains(path)) return;
    final next = files.copyWith(activePath: path);
    emit(state.copyWith(perWorkspace: {...state.perWorkspace, id: next}));
  }

  Future<void> restore() async {
    _restoring = true;
    try {
      final snapshot = await _persistence.read();
      if (snapshot == null || snapshot.perWorkspace.isEmpty) return;
      final aliveIds = _workspacesCubit.state.workspacesOrEmpty
          .map((w) => w.id)
          .toSet();
      final filtered = <WorkspaceId, WorkspaceFiles>{};
      snapshot.perWorkspace.forEach((id, files) {
        if (!aliveIds.contains(id)) return;
        if (files.openPaths.isEmpty) return;
        var active = files.activePath;
        if (active != null && !files.openPaths.contains(active)) {
          active = files.openPaths.first;
        }
        var preview = files.previewPath;
        if (preview != null && !files.openPaths.contains(preview)) {
          preview = null;
        }
        filtered[id] = WorkspaceFiles(
          openPaths: List.unmodifiable(files.openPaths),
          activePath: active,
          previewPath: preview,
        );
      });
      if (filtered.isEmpty) return;
      emit(state.copyWith(perWorkspace: filtered));
      _talker.info('Restored file tabs for ${filtered.length} workspace(s)');
    } catch (e, st) {
      _talker.error('Failed to restore file tabs', e, st);
    } finally {
      _restoring = false;
    }
  }

  Future<void> _persist() async {
    try {
      final perWs = state.perWorkspace.map(
        (id, files) => MapEntry(
          id,
          PersistedWorkspaceFiles(
            openPaths: files.openPaths,
            activePath: files.activePath,
            previewPath: files.previewPath,
          ),
        ),
      );
      await _persistence.write(PersistedFileTabs(perWorkspace: perWs));
    } catch (e, st) {
      _talker.error('Failed to persist file tabs', e, st);
    }
  }

  @override
  Future<void> close() async {
    _saveDebounce?.cancel();
    await _wsSub?.cancel();
    await _selfSub?.cancel();
    return super.close();
  }
}
