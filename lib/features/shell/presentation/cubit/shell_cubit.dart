import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../editor/presentation/cubit/file_tabs_cubit.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';

part 'shell_cubit.freezed.dart';
part 'shell_cubit.state.dart';

@lazySingleton
class ShellCubit extends Cubit<ShellState> {
  ShellCubit(this._fileTabsCubit, this._workspacesCubit)
    : super(const ShellState(workspaceOpen: true, selectedActivity: ActivityId.explorer));

  final FileTabsCubit _fileTabsCubit;
  final WorkspacesCubit _workspacesCubit;
  StreamSubscription<FileTabsState>? _tabsSub;

  @PostConstruct()
  void init() {
    _tabsSub = _fileTabsCubit.stream.listen(_onFileTabsChanged);
  }

  void _onFileTabsChanged(FileTabsState tabs) {
    if (state.workspaceOpen) return;
    final activeId = _workspacesCubit.state.activeIdOrNull;
    if (activeId == null) return;
    final hasActiveFile = tabs.filesFor(activeId)?.activePath != null;
    if (hasActiveFile) {
      emit(state.copyWith(workspaceOpen: true));
    }
  }

  void toggleWorkspace() {
    emit(state.copyWith(workspaceOpen: !state.workspaceOpen));
  }

  void setWorkspaceOpen(bool value) {
    if (state.workspaceOpen == value) return;
    emit(state.copyWith(workspaceOpen: value));
  }

  void selectActivity(ActivityId id) {
    if (state.selectedActivity == id) return;
    emit(state.copyWith(selectedActivity: id));
  }

  void setPaneSizes(Map<String, double> sizes) {
    final next = {...state.paneSizes, ...sizes};
    emit(state.copyWith(paneSizes: next));
  }

  @override
  Future<void> close() async {
    await _tabsSub?.cancel();
    return super.close();
  }
}
