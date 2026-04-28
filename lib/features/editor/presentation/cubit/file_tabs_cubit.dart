import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../features/workspace/domain/entities/workspace.dart';
import '../../../../features/workspace/presentation/cubit/workspaces_cubit.dart';

part 'file_tabs_cubit.freezed.dart';
part 'file_tabs_cubit.state.dart';

@lazySingleton
class FileTabsCubit extends Cubit<FileTabsState> {
  FileTabsCubit(this._workspacesCubit, this._talker)
      : super(const FileTabsState());

  final WorkspacesCubit _workspacesCubit;
  final Talker _talker;
  StreamSubscription<WorkspacesState>? _wsSub;

  @PostConstruct()
  void init() {
    _wsSub = _workspacesCubit.stream.listen(_onWorkspacesChanged);
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

  @override
  Future<void> close() async {
    await _wsSub?.cancel();
    return super.close();
  }
}
