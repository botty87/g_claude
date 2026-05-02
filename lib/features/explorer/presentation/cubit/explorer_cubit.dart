import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;

import '../../../../core/error/failures.dart';
import '../../../editor/domain/usecases/read_file.dart';
import '../../../editor/presentation/cubit/file_tabs_cubit.dart';
import '../../../workspace/data/datasources/workspace_file_watcher.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../domain/entities/file_node.dart';
import '../../domain/usecases/list_directory.dart';

part 'explorer_cubit.freezed.dart';
part 'explorer_cubit.state.dart';

@lazySingleton
class ExplorerCubit extends Cubit<ExplorerState> {
  ExplorerCubit(
    this._listDirectory,
    this._readFile,
    this._workspacesCubit,
    this._fileTabsCubit,
    this._fileWatcher,
    this._talker,
  ) : super(const ExplorerState());

  final ListDirectory _listDirectory;
  final ReadFile _readFile;
  final WorkspacesCubit _workspacesCubit;
  final FileTabsCubit _fileTabsCubit;
  final WorkspaceFileWatcher _fileWatcher;
  final Talker _talker;
  StreamSubscription<WorkspacesState>? _wsSub;
  StreamSubscription<FileTabsState>? _ftSub;
  final Map<WorkspaceId, Set<String>> _knownOpenPaths = {};
  final Map<WorkspaceId, WorkspaceFiles> _lastFilesRef = {};
  final Map<WorkspaceId, StreamSubscription<FileSystemEvent>> _fsSubs = {};
  final Map<String, Timer> _refreshTimers = {};

  static const _refreshDebounceMs = 250;

  @PostConstruct()
  void init() {
    _wsSub = _workspacesCubit.stream.listen(_onWorkspacesChanged);
    for (final entry in _fileTabsCubit.state.perWorkspace.entries) {
      _knownOpenPaths[entry.key] = entry.value.openPaths.toSet();
      _lastFilesRef[entry.key] = entry.value;
    }
    _ftSub = _fileTabsCubit.stream.listen(_onFileTabsChanged);
    for (final w in _workspacesCubit.state.workspacesOrEmpty) {
      _attachWatcher(w);
    }
  }

  void _attachWatcher(Workspace w) {
    if (_fsSubs.containsKey(w.id)) return;
    _fsSubs[w.id] = _fileWatcher.watch(w.path).listen(
      (event) => _onFsEvent(w, event),
      onError: (Object e, StackTrace st) {
        _talker.error('ExplorerCubit: watcher error for ${w.path}', e, st);
      },
    );
  }

  void _detachWatcher(WorkspaceId id) {
    final sub = _fsSubs.remove(id);
    if (sub != null) unawaited(sub.cancel());
    _refreshTimers.removeWhere((key, timer) {
      if (key.startsWith('$id::')) {
        timer.cancel();
        return true;
      }
      return false;
    });
  }

  void _onFsEvent(Workspace w, FileSystemEvent event) {
    final affected = <String>{};
    affected.add(p.dirname(event.path));
    if (event is FileSystemMoveEvent) {
      final dest = event.destination;
      if (dest != null) affected.add(p.dirname(dest));
    }
    final tree = state.trees[w.id];
    if (tree == null) return;
    for (final parent in affected) {
      final isRoot = p.equals(parent, w.path);
      final isExpanded = tree.expanded.contains(parent);
      if (!isRoot && !isExpanded) continue;
      _scheduleRefresh(w.id, parent);
    }
  }

  void _scheduleRefresh(WorkspaceId id, String parent) {
    final key = '$id::$parent';
    _refreshTimers[key]?.cancel();
    _refreshTimers[key] = Timer(
      const Duration(milliseconds: _refreshDebounceMs),
      () {
        _refreshTimers.remove(key);
        unawaited(_refreshFolder(id, parent));
      },
    );
  }

  Future<void> _refreshFolder(WorkspaceId id, String parent) async {
    final tree = state.trees[id];
    if (tree == null) return;
    final result = await _listDirectory(path: parent);
    result.fold(
      (failure) {
        _talker.debug(
          'ExplorerCubit: watcher refresh skipped $parent: $failure',
        );
      },
      (nodes) {
        final current = state.trees[id];
        if (current == null) return;
        final updated = current.copyWith(
          children: {...current.children, parent: nodes},
          errors: Map.of(current.errors)..remove(parent),
        );
        emit(state.copyWith(trees: {...state.trees, id: updated}));
      },
    );
  }

  void _onFileTabsChanged(FileTabsState ft) {
    for (final entry in ft.perWorkspace.entries) {
      final id = entry.key;
      final files = entry.value;
      if (identical(_lastFilesRef[id], files)) continue;
      _lastFilesRef[id] = files;
      final newPaths = files.openPaths.toSet();
      final known = _knownOpenPaths[id] ?? const <String>{};
      final added = newPaths.difference(known);
      _knownOpenPaths[id] = newPaths;
      if (added.isEmpty) continue;
      final workspace = _workspacesCubit.state.workspacesOrEmpty
          .firstWhereOrNull((w) => w.id == id);
      if (workspace == null) continue;
      for (final path in added) {
        unawaited(prewarmReveal(id, workspace.path, path));
        unawaited(_readFile(path: path));
      }
    }
    _knownOpenPaths.removeWhere((id, _) => !ft.perWorkspace.containsKey(id));
    _lastFilesRef.removeWhere((id, _) => !ft.perWorkspace.containsKey(id));
  }

  void _onWorkspacesChanged(WorkspacesState ws) {
    final aliveIds = ws.workspacesOrEmpty.map((w) => w.id).toSet();
    for (final w in ws.workspacesOrEmpty) {
      _attachWatcher(w);
    }
    final orphans = _fsSubs.keys.where((id) => !aliveIds.contains(id)).toList();
    for (final id in orphans) {
      _detachWatcher(id);
    }
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

        final subPaths = tree.expanded
            .where((p) => p != rootPath)
            .toList(growable: false);
        if (subPaths.isEmpty) return;
        final subResults = await Future.wait(
          subPaths.map((p) => _listDirectory(path: p)),
        );
        final mergedChildren = {...refreshed.children};
        for (var i = 0; i < subPaths.length; i++) {
          subResults[i].fold(
            (failure) => _talker
                .debug('ExplorerCubit: refresh skipping ${subPaths[i]}: $failure'),
            (subNodes) => mergedChildren[subPaths[i]] = subNodes,
          );
        }
        refreshed = refreshed.copyWith(children: mergedChildren);
        emit(state.copyWith(trees: {...state.trees, id: refreshed}));
      },
    );
  }

  void toggleHidden() => emit(state.copyWith(showHidden: !state.showHidden));

  /// Expands the directory chain leading to [targetPath] within workspace [id]
  /// and marks it as the visually selected node.
  ///
  /// Parents that are not yet cached are loaded in parallel, then the entire
  /// chain (cached + freshly loaded) is committed in a single emit together
  /// with [selectedPath]. This avoids the per-parent round-trip flicker and
  /// keeps the visible scroll/highlight in sync with the tree expansion.
  Future<void> revealPath(WorkspaceId id, String rootPath, String targetPath) =>
      _revealInternal(id, rootPath, targetPath, select: true);

  /// Expands the directory chain leading to [targetPath] without marking it as
  /// selected. Used for boot-time pre-warm so the first click on a persisted
  /// active tab finds the parent chain already cached.
  Future<void> prewarmReveal(WorkspaceId id, String rootPath, String targetPath) =>
      _revealInternal(id, rootPath, targetPath, select: false);

  Future<void> _revealInternal(
    WorkspaceId id,
    String rootPath,
    String targetPath, {
    required bool select,
  }) async {
    if (targetPath == rootPath) return;
    if (!p.isWithin(rootPath, targetPath)) {
      _talker.debug('ExplorerCubit.revealPath: $targetPath outside $rootPath');
      return;
    }

    await ensureRootLoaded(id, rootPath);

    final relative = p.relative(targetPath, from: rootPath);
    final segments = p.split(relative);
    if (segments.isEmpty) return;

    final initialTree = state.trees[id];
    if (initialTree == null) return;

    // Build the parent chain (all segments except the file itself).
    final parents = <String>[];
    var current = rootPath;
    for (var i = 0; i < segments.length - 1; i++) {
      current = p.join(current, segments[i]);
      parents.add(current);
    }

    final cached = parents
        .where((path) => initialTree.children.containsKey(path))
        .toList(growable: false);
    final missing = parents
        .where((path) => !initialTree.children.containsKey(path))
        .toList(growable: false);

    // Phase 1 (sync, optimistic) — applies only to user-driven reveals.
    // Expand the parents we already have in cache and commit selection
    // immediately so the highlight/scroll feedback fires on the next frame,
    // before any I/O completes. The remaining parents will be expanded by
    // phase 2 once their listings arrive.
    if (select) {
      final immediateExpanded = <String>{...initialTree.expanded, ...cached};
      final hasNewExpanded = immediateExpanded.length != initialTree.expanded.length;
      final hasNewSelection = initialTree.selectedPath != targetPath;
      if (hasNewExpanded || hasNewSelection) {
        final immediate = initialTree.copyWith(
          expanded: immediateExpanded,
          selectedPath: targetPath,
        );
        emit(state.copyWith(trees: {...state.trees, id: immediate}));
      }
    }

    if (missing.isEmpty) return; // nothing to load — phase 1 already committed

    // Phase 2 (async) — load missing parents in parallel, then commit.
    final results = await Future.wait(
      missing.map((path) => _listDirectory(path: path)),
    );
    final loaded = <String, List<FileNode>>{};
    for (var i = 0; i < missing.length; i++) {
      final path = missing[i];
      results[i].fold(
        (failure) => _talker.debug(
          'ExplorerCubit.revealPath: failed to load $path: $failure',
        ),
        (nodes) => loaded[path] = nodes,
      );
    }

    final treeNow = state.trees[id];
    if (treeNow == null) return;

    // Stop the chain at the first parent that failed to load. Anything beyond
    // that point cannot be revealed without a child listing we don't have.
    final reachableExpanded = <String>{};
    for (final path in parents) {
      final hasCache = treeNow.children.containsKey(path) || loaded.containsKey(path);
      if (!hasCache) break;
      reachableExpanded.add(path);
    }

    if (loaded.isEmpty && reachableExpanded.every(treeNow.expanded.contains)) {
      return; // phase 1 already covered everything reachable
    }

    final mergedChildren = <String, List<FileNode>>{
      ...treeNow.children,
      ...loaded,
    };
    final mergedExpanded = <String>{
      ...treeNow.expanded,
      ...reachableExpanded,
    };

    final next = treeNow.copyWith(
      children: mergedChildren,
      expanded: mergedExpanded,
      selectedPath: select ? targetPath : treeNow.selectedPath,
    );
    emit(state.copyWith(trees: {...state.trees, id: next}));
  }

  void clearSelection(WorkspaceId id) {
    final tree = state.trees[id];
    if (tree == null || tree.selectedPath == null) return;
    emit(state.copyWith(trees: {...state.trees, id: tree.copyWith(selectedPath: null)}));
  }

  @override
  Future<void> close() async {
    await _wsSub?.cancel();
    await _ftSub?.cancel();
    for (final t in _refreshTimers.values) {
      t.cancel();
    }
    _refreshTimers.clear();
    for (final s in _fsSubs.values) {
      await s.cancel();
    }
    _fsSubs.clear();
    return super.close();
  }
}
