part of 'explorer_cubit.dart';

@freezed
abstract class ExplorerState with _$ExplorerState {
  const factory ExplorerState({
    @Default(<WorkspaceId, WorkspaceTree>{}) Map<WorkspaceId, WorkspaceTree> trees,
    @Default(false) bool showHidden,
  }) = _ExplorerState;
}

@freezed
abstract class WorkspaceTree with _$WorkspaceTree {
  const factory WorkspaceTree({
    @Default(<String, List<FileNode>>{}) Map<String, List<FileNode>> children,
    @Default(<String>{}) Set<String> expanded,
    @Default(<String>{}) Set<String> loading,
    @Default(<String, Failure>{}) Map<String, Failure> errors,
    String? selectedPath,
  }) = _WorkspaceTree;
}
