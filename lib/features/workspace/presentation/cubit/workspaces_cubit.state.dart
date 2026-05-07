part of 'workspaces_cubit.dart';

@freezed
sealed class WorkspacesState with _$WorkspacesState {
  const WorkspacesState._();

  const factory WorkspacesState.initial() = WorkspacesStateInitial;

  const factory WorkspacesState.loaded({
    @Default(<Workspace>[]) List<Workspace> workspaces,
    WorkspaceId? activeId,
    Failure? lastFailure,
  }) = WorkspacesStateLoaded;

  List<Workspace> get workspacesOrEmpty => switch (this) {
    WorkspacesStateInitial() => const [],
    WorkspacesStateLoaded(:final workspaces) => workspaces,
  };

  WorkspaceId? get activeIdOrNull => switch (this) {
    WorkspacesStateInitial() => null,
    WorkspacesStateLoaded(:final activeId) => activeId,
  };

  Workspace? get activeWorkspace {
    final id = activeIdOrNull;
    if (id == null) return null;
    return workspacesOrEmpty.firstWhereOrNull((w) => w.id == id);
  }
}
