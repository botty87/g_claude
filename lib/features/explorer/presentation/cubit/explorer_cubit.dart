import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../domain/entities/file_node.dart';
import '../../domain/usecases/list_directory.dart';

part 'explorer_cubit.freezed.dart';
part 'explorer_cubit.state.dart';

@lazySingleton
class ExplorerCubit extends Cubit<ExplorerState> {
  ExplorerCubit(this._listDirectory, this._workspacesCubit, this._talker)
      : super(const ExplorerState());

  final ListDirectory _listDirectory;
  final WorkspacesCubit _workspacesCubit;
  final Talker _talker;
  StreamSubscription<WorkspacesState>? _wsSub;

  @PostConstruct()
  void init() {
    _wsSub = _workspacesCubit.stream.listen(_onWorkspacesChanged);
  }

  void _onWorkspacesChanged(WorkspacesState ws) {
    final aliveIds = ws.workspacesOrEmpty.map((w) => w.id).toSet();
    final stale = state.trees.keys.where((id) => !aliveIds.contains(id)).toList();
    if (stale.isEmpty) return;
    final next = Map.of(state.trees)..removeWhere((k, _) => stale.contains(k));
    _talker.debug('ExplorerCubit: pruned ${stale.length} stale tree(s)');
    emit(state.copyWith(trees: next));
  }

  Future<void> ensureRootLoaded(WorkspaceId id, String rootPath) async {
    final tree = state.trees[id];
    if (tree != null && tree.children.containsKey(rootPath)) return;

    final current = tree ?? const WorkspaceTree();
    final withLoading = current.copyWith(
      loading: {...current.loading, rootPath},
    );
    emit(state.copyWith(trees: {...state.trees, id: withLoading}));

    final result = await _listDirectory(path: rootPath);

    result.fold(
      (failure) {
        _talker.error('ExplorerCubit: failed to load root $rootPath', failure);
        final afterError = withLoading.copyWith(
          loading: withLoading.loading.difference({rootPath}),
          errors: {...withLoading.errors, rootPath: failure},
        );
        emit(state.copyWith(trees: {...state.trees, id: afterError}));
      },
      (nodes) {
        final afterLoad = withLoading.copyWith(
          children: {...withLoading.children, rootPath: nodes},
          expanded: {...withLoading.expanded, rootPath},
          loading: withLoading.loading.difference({rootPath}),
        );
        emit(state.copyWith(trees: {...state.trees, id: afterLoad}));
      },
    );
  }

  Future<void> toggleFolder(WorkspaceId id, String absPath) async {
    final tree = state.trees[id];
    if (tree == null) return;

    if (tree.expanded.contains(absPath)) {
      // Collapse — keep children cached for fast re-expand
      final collapsed = tree.copyWith(
        expanded: tree.expanded.difference({absPath}),
      );
      emit(state.copyWith(trees: {...state.trees, id: collapsed}));
      return;
    }

    if (tree.children.containsKey(absPath)) {
      // Already cached — just expand
      final expanded = tree.copyWith(
        expanded: {...tree.expanded, absPath},
      );
      emit(state.copyWith(trees: {...state.trees, id: expanded}));
      return;
    }

    // Load then expand
    final withLoading = tree.copyWith(
      loading: {...tree.loading, absPath},
      errors: Map.of(tree.errors)..remove(absPath),
    );
    emit(state.copyWith(trees: {...state.trees, id: withLoading}));

    final result = await _listDirectory(path: absPath);

    result.fold(
      (failure) {
        _talker.error('ExplorerCubit: failed to load $absPath', failure);
        final afterError = withLoading.copyWith(
          loading: withLoading.loading.difference({absPath}),
          errors: {...withLoading.errors, absPath: failure},
        );
        emit(state.copyWith(trees: {...state.trees, id: afterError}));
      },
      (nodes) {
        final afterLoad = withLoading.copyWith(
          children: {...withLoading.children, absPath: nodes},
          expanded: {...withLoading.expanded, absPath},
          loading: withLoading.loading.difference({absPath}),
        );
        emit(state.copyWith(trees: {...state.trees, id: afterLoad}));
      },
    );
  }

  Future<void> refresh(WorkspaceId id, String rootPath) async {
    final tree = state.trees[id];
    if (tree == null) return;

    // Re-load root unconditionally
    final result = await _listDirectory(path: rootPath);

    result.fold(
      (failure) {
        _talker.error('ExplorerCubit: failed to refresh root $rootPath', failure);
        final afterError = tree.copyWith(
          errors: {...tree.errors, rootPath: failure},
        );
        emit(state.copyWith(trees: {...state.trees, id: afterError}));
      },
      (nodes) async {
        var refreshed = tree.copyWith(
          children: {...tree.children, rootPath: nodes},
          errors: Map.of(tree.errors)..remove(rootPath),
        );
        emit(state.copyWith(trees: {...state.trees, id: refreshed}));

        // Best-effort refresh of all expanded non-root paths
        for (final expandedPath in tree.expanded.where((p) => p != rootPath)) {
          final subResult = await _listDirectory(path: expandedPath);
          subResult.fold(
            (failure) {
              _talker.debug('ExplorerCubit: refresh skipping $expandedPath: $failure');
            },
            (subNodes) {
              refreshed = refreshed.copyWith(
                children: {...refreshed.children, expandedPath: subNodes},
              );
              emit(state.copyWith(trees: {...state.trees, id: refreshed}));
            },
          );
        }
      },
    );
  }

  void toggleHidden() => emit(state.copyWith(showHidden: !state.showHidden));

  @override
  Future<void> close() async {
    await _wsSub?.cancel();
    return super.close();
  }
}
