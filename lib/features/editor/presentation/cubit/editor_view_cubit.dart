import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../workspace/domain/entities/workspace.dart';

part 'editor_view_cubit.freezed.dart';
part 'editor_view_cubit.state.dart';

/// Owns the center-area view mode (chat / code / terminal) and the "peek"
/// overlay flag, per workspace. The set of open files lives in [FileTabsCubit];
/// this cubit only tracks *how* they are surfaced.
@lazySingleton
class EditorViewCubit extends Cubit<EditorViewState> {
  EditorViewCubit() : super(const EditorViewState());

  EditorViewData _dataFor(WorkspaceId id) => state.perWorkspace[id] ?? const EditorViewData();

  void _write(WorkspaceId id, EditorViewData data) {
    if (state.perWorkspace[id] == data) return;
    emit(state.copyWith(perWorkspace: {...state.perWorkspace, id: data}));
  }

  /// Explicit segmented-control selection. Clears the peek overlay.
  void setView(WorkspaceId id, CenterView view) {
    _write(id, _dataFor(id).copyWith(view: view, peekOpen: false));
  }

  /// Open a file "at a glance" above the chat (peek sheet).
  void openPeek(WorkspaceId id) {
    _write(id, _dataFor(id).copyWith(view: CenterView.chat, peekOpen: true));
  }

  void closePeek(WorkspaceId id) {
    _write(id, _dataFor(id).copyWith(peekOpen: false));
  }

  /// Promote the peeked file to full context (code view fills the center).
  void promoteToFull(WorkspaceId id) {
    _write(id, _dataFor(id).copyWith(view: CenterView.code, peekOpen: false));
  }

  /// Demote the full editor back to a peek over the chat.
  void demoteToPeek(WorkspaceId id) {
    _write(id, _dataFor(id).copyWith(view: CenterView.chat, peekOpen: true));
  }
}
