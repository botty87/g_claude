part of 'file_tabs_cubit.dart';

@freezed
abstract class FileTabsState with _$FileTabsState {
  const FileTabsState._();

  const factory FileTabsState({
    @Default(<WorkspaceId, WorkspaceFiles>{}) Map<WorkspaceId, WorkspaceFiles> perWorkspace,
  }) = _FileTabsState;

  WorkspaceFiles? filesFor(WorkspaceId id) => perWorkspace[id];
}

@freezed
abstract class WorkspaceFiles with _$WorkspaceFiles {
  const factory WorkspaceFiles({
    @Default(<String>[]) List<String> openPaths,
    String? activePath,
    String? previewPath,
    // Diff tabs live beside the file tabs in the same "Code" tab strip but are
    // ephemeral (derived from git state) — deliberately NOT persisted in
    // tabs.v1. [activeDiffId] discriminates the shown surface: when non-null a
    // diff tab is active (it wins over [activePath]); opening/activating a file
    // tab resets it to null. Identity of a diff tab is its [DiffTabRef.path].
    @Default(<DiffTabRef>[]) List<DiffTabRef> openDiffs,
    String? activeDiffId,
    // Mirrors [previewPath] for diff tabs: a single "preview" diff (shown
    // italic) that the next single-click diff replaces in place, until pinned
    // (double-click) which clears this to null.
    String? previewDiffId,
  }) = _WorkspaceFiles;
}

/// A diff tab in the Code strip. Ephemeral (never persisted); [path] is its
/// stable identity. Carries just enough to re-run the diff read.
@freezed
abstract class DiffTabRef with _$DiffTabRef {
  const factory DiffTabRef({
    required String path,
    required GitFileStatus status,
    @Default(0) int added,
    @Default(0) int deleted,
  }) = _DiffTabRef;
}
