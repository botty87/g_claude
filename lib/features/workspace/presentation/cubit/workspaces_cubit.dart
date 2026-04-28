import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/usecases/close_workspace.dart';
import '../../domain/usecases/open_workspace.dart';

part 'workspaces_cubit.freezed.dart';
part 'workspaces_cubit.state.dart';

@lazySingleton
class WorkspacesCubit extends Cubit<WorkspacesState> {
  WorkspacesCubit(this._openWorkspace, this._closeWorkspace, this._talker)
      : super(const WorkspacesState.initial());

  final OpenWorkspace _openWorkspace;
  final CloseWorkspace _closeWorkspace;
  final Talker _talker;

  Future<void> openFromPicker() async {
    final selected = await FilePicker.getDirectoryPath(
      dialogTitle: 'Open folder',
    );
    if (selected == null) {
      _talker.debug('Workspace picker dismissed');
      return;
    }
    await openPath(selected);
  }

  Future<void> openPath(String path) async {
    final start = DateTime.now();
    final existing = state.workspacesOrEmpty;

    final duplicate = existing.where((w) => w.path == path).cast<Workspace?>();
    if (duplicate.isNotEmpty) {
      _talker.info('Workspace already open: $path — activating existing tab');
      setActive(duplicate.first!.id);
      return;
    }

    _talker.info('Opening workspace at: $path');
    final result = await _openWorkspace(path: path);

    result.fold(
      (failure) {
        _talker.error('Failed to open workspace: $path', failure);
        emit(WorkspacesState.error(
          failure: failure,
          workspaces: existing,
          activeId: state.activeIdOrNull,
        ));
      },
      (workspace) {
        final next = [...existing, workspace];
        emit(WorkspacesState.loaded(
          workspaces: next,
          activeId: workspace.id,
        ));
        final ms = DateTime.now().difference(start).inMilliseconds;
        _talker.info('Workspace opened: ${workspace.name} (${ms}ms, claudeMd=${workspace.claudeMd != null})');
      },
    );
  }

  Future<void> closeWorkspace(WorkspaceId id) async {
    final list = state.workspacesOrEmpty;
    final index = list.indexWhere((w) => w.id == id);
    if (index < 0) return;

    final result = await _closeWorkspace(id: id);
    result.fold(
      (failure) => _talker.error('Failed to close workspace: $id', failure),
      (_) => _talker.info('Closed workspace: $id'),
    );

    final next = [...list]..removeAt(index);
    if (next.isEmpty) {
      emit(const WorkspacesState.loaded(workspaces: []));
      return;
    }

    WorkspaceId? newActive = state.activeIdOrNull;
    if (newActive == id) {
      final fallbackIndex = index < next.length ? index : next.length - 1;
      newActive = next[fallbackIndex].id;
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
}
