import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/usecases/open_workspace.dart';

part 'workspaces_cubit.freezed.dart';
part 'workspaces_cubit.state.dart';

@lazySingleton
class WorkspacesCubit extends Cubit<WorkspacesState> {
  WorkspacesCubit(this._openWorkspace, this._talker)
      : super(const WorkspacesState.initial());

  final OpenWorkspace _openWorkspace;
  final Talker _talker;

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
}
