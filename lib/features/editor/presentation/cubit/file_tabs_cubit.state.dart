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
  }) = _WorkspaceFiles;
}
