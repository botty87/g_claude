import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:re_editor/re_editor.dart';

import '../../../workspace/domain/entities/workspace.dart';

class ActiveEditorRef {
  const ActiveEditorRef({
    required this.workspaceId,
    required this.path,
    required this.controller,
  });

  final WorkspaceId workspaceId;
  final String path;
  final CodeLineEditingController controller;
}

class EditorSelectionSnapshot {
  const EditorSelectionSnapshot({
    required this.path,
    required this.startLine,
    required this.endLine,
    required this.snippet,
  });

  final String path;
  final int startLine;
  final int endLine;
  final String snippet;

  bool get isEmpty => snippet.isEmpty;
}

@lazySingleton
class ActiveEditorCubit extends Cubit<Map<WorkspaceId, String>> {
  ActiveEditorCubit() : super(const {});

  final Map<WorkspaceId, ActiveEditorRef> _refs = {};

  void register(ActiveEditorRef ref) {
    _refs[ref.workspaceId] = ref;
    final next = Map<WorkspaceId, String>.from(state);
    next[ref.workspaceId] = ref.path;
    emit(next);
  }

  void unregister(WorkspaceId workspaceId, String path) {
    final current = _refs[workspaceId];
    if (current == null || current.path != path) return;
    _refs.remove(workspaceId);
    final next = Map<WorkspaceId, String>.from(state)..remove(workspaceId);
    emit(next);
  }

  EditorSelectionSnapshot? snapshotFor(WorkspaceId workspaceId) {
    final ref = _refs[workspaceId];
    if (ref == null) return null;
    final ctrl = ref.controller;
    final sel = ctrl.selection;
    final selectedText = ctrl.selectedText;
    if (selectedText.isEmpty) return null;
    final start = sel.baseIndex < sel.extentIndex ? sel.baseIndex : sel.extentIndex;
    final end = sel.baseIndex < sel.extentIndex ? sel.extentIndex : sel.baseIndex;
    return EditorSelectionSnapshot(
      path: ref.path,
      startLine: start + 1,
      endLine: end + 1,
      snippet: selectedText,
    );
  }
}
