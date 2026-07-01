part of 'editor_view_cubit.dart';

/// Which surface the center area shows for a workspace.
enum CenterView { chat, code, terminal }

@freezed
abstract class EditorViewData with _$EditorViewData {
  const factory EditorViewData({@Default(CenterView.chat) CenterView view, @Default(false) bool peekOpen}) =
      _EditorViewData;
}

@freezed
abstract class EditorViewState with _$EditorViewState {
  const EditorViewState._();

  const factory EditorViewState({
    @Default(<WorkspaceId, EditorViewData>{}) Map<WorkspaceId, EditorViewData> perWorkspace,
  }) = _EditorViewState;

  EditorViewData dataFor(WorkspaceId? id) => (id == null ? null : perWorkspace[id]) ?? const EditorViewData();
}
