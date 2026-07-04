part of 'git_diff_cubit.dart';

enum DiffViewMode { flat, tree }

@freezed
abstract class WorkspaceDiff with _$WorkspaceDiff {
  const factory WorkspaceDiff({
    @Default(<GitDiffFile>[]) List<GitDiffFile> files,
    @Default(DiffViewMode.flat) DiffViewMode viewMode,
    @Default(false) bool loading,
    // Collapsed directories in tree view. Default (absent) = expanded.
    @Default(<String>{}) Set<String> collapsedDirs,
    Failure? failure,
  }) = _WorkspaceDiff;
}

@freezed
abstract class GitDiffState with _$GitDiffState {
  const GitDiffState._();

  const factory GitDiffState({@Default(<WorkspaceId, WorkspaceDiff>{}) Map<WorkspaceId, WorkspaceDiff> perWorkspace}) =
      _GitDiffState;

  WorkspaceDiff diffFor(WorkspaceId? id) => (id == null ? null : perWorkspace[id]) ?? const WorkspaceDiff();
}
