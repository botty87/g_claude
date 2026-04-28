part of 'workspaces_cubit.dart';

@freezed
sealed class WorkspacesState with _$WorkspacesState {
  const WorkspacesState._();

  const factory WorkspacesState.initial() = WorkspacesStateInitial;

  const factory WorkspacesState.loaded({
    required List<Workspace> workspaces,
    WorkspaceId? activeId,
  }) = WorkspacesStateLoaded;

  const factory WorkspacesState.error({
    required Failure failure,
    @Default(<Workspace>[]) List<Workspace> workspaces,
    WorkspaceId? activeId,
  }) = WorkspacesStateError;

  List<Workspace> get workspacesOrEmpty => switch (this) {
        WorkspacesStateInitial() => const [],
        WorkspacesStateLoaded(:final workspaces) => workspaces,
        WorkspacesStateError(:final workspaces) => workspaces,
      };

  WorkspaceId? get activeIdOrNull => switch (this) {
        WorkspacesStateInitial() => null,
        WorkspacesStateLoaded(:final activeId) => activeId,
        WorkspacesStateError(:final activeId) => activeId,
      };

  Workspace? get activeWorkspace {
    final id = activeIdOrNull;
    if (id == null) return null;
    final list = workspacesOrEmpty;
    for (final w in list) {
      if (w.id == id) return w;
    }
    return null;
  }
}
