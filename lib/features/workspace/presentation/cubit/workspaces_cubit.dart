import 'dart:async';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/either.dart';
import '../../../git/domain/entities/git_branch.dart';
import '../../../git/domain/entities/git_folder_inspection.dart';
import '../../../git/domain/entities/git_worktree.dart';
import '../../../git/domain/usecases/add_worktree.dart';
import '../../../git/domain/usecases/delete_branch.dart';
import '../../../git/domain/usecases/inspect_folder.dart';
import '../../../git/domain/usecases/list_branches.dart';
import '../../../git/domain/usecases/list_worktrees.dart';
import '../../../git/domain/usecases/remove_worktree.dart';
import '../../data/datasources/workspace_file_watcher.dart';
import '../../data/datasources/workspaces_persistence_datasource.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/entities/workspace_group.dart';
import '../../domain/usecases/open_workspace.dart';

part 'workspaces_cubit.freezed.dart';
part 'workspaces_cubit.state.dart';

@lazySingleton
class WorkspacesCubit extends Cubit<WorkspacesState> {
  WorkspacesCubit(
    this._openWorkspace,
    this._listWorktrees,
    this._removeWorktree,
    this._deleteBranch,
    this._addWorktree,
    this._listBranches,
    this._inspectFolder,
    this._persistence,
    this._fileWatcher,
    this._talker,
  ) : super(const WorkspacesState.initial());

  final OpenWorkspace _openWorkspace;
  final ListWorktrees _listWorktrees;
  final RemoveWorktree _removeWorktree;
  final DeleteBranch _deleteBranch;
  final AddWorktree _addWorktree;
  final ListBranches _listBranches;
  final InspectFolder _inspectFolder;
  final WorkspacesPersistenceDataSource _persistence;
  final WorkspaceFileWatcher _fileWatcher;
  final Talker _talker;

  bool _restoring = false;
  Timer? _saveDebounce;
  StreamSubscription<WorkspacesState>? _selfSub;

  /// Soft cache of live worktrees per repoRoot, to seed [useFuture] without
  /// flicker. Invalidated when the open-workspace set changes.
  final Map<String, List<GitWorktree>> _worktreeCache = {};

  static const _saveDebounceMs = 250;

  @PostConstruct()
  void init() {
    _selfSub = stream.listen((_) {
      if (_restoring) return;
      _saveDebounce?.cancel();
      _saveDebounce = Timer(const Duration(milliseconds: _saveDebounceMs), _persist);
    });
  }

  String _normalize(String path) => p.normalize(p.absolute(path));

  Future<void> openFromPicker() async {
    final selected = await FilePicker.getDirectoryPath(dialogTitle: Locales.Workspace.Picker.title);
    if (selected == null) {
      _talker.debug('Workspace picker dismissed');
      return;
    }
    await openPath(selected);
  }

  Future<void> openPath(String path) async {
    final start = DateTime.now();
    final normalized = _normalize(path);
    final existing = state.workspacesOrEmpty;

    final duplicate = existing.firstWhereOrNull((w) => w.id == normalized);
    if (duplicate != null) {
      _talker.info('Workspace already open: $normalized — activating existing tab');
      setActive(duplicate.id);
      return;
    }

    final result = await _openWorkspace(path: normalized);

    result.fold(
      (failure) {
        _talker.error('Failed to open workspace: $normalized', failure);
        emit(WorkspacesState.loaded(workspaces: existing, activeId: state.activeIdOrNull, lastFailure: failure));
      },
      (workspace) {
        _worktreeCache.clear();
        emit(WorkspacesState.loaded(workspaces: [...existing, workspace], activeId: workspace.id));
        final ms = DateTime.now().difference(start).inMilliseconds;
        _talker.info('Workspace opened: ${workspace.name} (${ms}ms, claudeMd=${workspace.claudeMd != null})');
      },
    );
  }

  /// Live worktrees for a repo group. Caches the result to seed the sidebar's
  /// [useFuture] without flicker; on failure returns the cached list or empty.
  Future<List<GitWorktree>> ensureWorktrees(String repoRoot) async {
    final result = await _listWorktrees(repoRoot: repoRoot);
    return result.fold(
      (failure) {
        _talker.debug('listWorktrees($repoRoot) failed: $failure');
        return _worktreeCache[repoRoot] ?? const [];
      },
      (worktrees) {
        _worktreeCache[repoRoot] = worktrees;
        return worktrees;
      },
    );
  }

  List<GitWorktree>? cachedWorktrees(String repoRoot) => _worktreeCache[repoRoot];

  /// Inspects [path] (git kind, branch, uncommitted changes) to preview it in
  /// the "open existing" flow. On failure returns a plain-folder inspection.
  Future<GitFolderInspection> inspectFolder(String path) async {
    final result = await _inspectFolder(path: path);
    return result.fold((failure) {
      _talker.debug('inspectFolder($path) failed: $failure');
      return const GitFolderInspection();
    }, (inspection) => inspection);
  }

  /// Local and remote-tracking branches of [repoRoot], to populate the "new
  /// worktree" dialog's base picker. On failure returns empty (the dialog
  /// degrades to new-branch-only).
  Future<List<GitBranch>> branchesFor(String repoRoot) async {
    final result = await _listBranches(repoRoot: repoRoot);
    return result.fold((failure) {
      _talker.debug('listBranches($repoRoot) failed: $failure');
      return const <GitBranch>[];
    }, (branches) => branches);
  }

  /// Creates a new worktree at [targetPath] (new branch via [newBranch]/[baseRef],
  /// or checkout of [checkoutBranch]) and opens it as a workspace on success.
  /// On failure the tab is NOT opened and the [Failure] is returned so the
  /// dialog can surface git's message (dir exists, branch taken, …).
  Future<Either<Failure, void>> createWorktree({
    required String repoRoot,
    required String targetPath,
    String? newBranch,
    String? baseRef,
    String? checkoutBranch,
    bool openAfter = true,
  }) async {
    final normalized = _normalize(targetPath);
    final result = await _addWorktree(
      repoRoot: repoRoot,
      worktreePath: normalized,
      newBranch: newBranch,
      baseRef: baseRef,
      checkoutBranch: checkoutBranch,
    );
    if (result.isLeft) {
      _talker.warning('git worktree add failed at $normalized: ${result.left}');
      return result;
    }
    _worktreeCache.clear();
    _talker.info('Created worktree: $normalized (openAfter=$openAfter)');
    if (openAfter) {
      // openPath emits a new loaded state → the sidebar re-fetches worktrees.
      await openPath(normalized);
    } else {
      // No workspace opened: bump the revision so the sidebar's memoized
      // `git worktree list` future re-runs and shows the new worktree.
      final s = state;
      if (s is WorkspacesStateLoaded) {
        emit(s.copyWith(worktreesRevision: s.worktreesRevision + 1));
      }
    }
    return const Right(null);
  }

  void closeWorkspace(WorkspaceId id) {
    final list = state.workspacesOrEmpty;
    final index = list.indexWhere((w) => w.id == id);
    if (index < 0) return;

    final closed = list[index];
    _talker.info('Closed workspace: $id');
    _worktreeCache.clear();
    unawaited(_fileWatcher.dispose(closed.path));
    final next = [...list]..removeAt(index);
    if (next.isEmpty) {
      emit(const WorkspacesState.loaded());
      return;
    }

    var newActive = state.activeIdOrNull;
    if (newActive == id) {
      newActive = next[index < next.length ? index : next.length - 1].id;
    }
    emit(WorkspacesState.loaded(workspaces: next, activeId: newActive));
  }

  /// Removes a linked worktree from disk via `git worktree remove`, optionally
  /// deleting its branch too. Does NOT call [closeWorkspace] until the whole
  /// operation fully succeeds — this is deliberate: nothing in this codebase
  /// auto-closes a workspace on external deletion (verified: `closeWorkspace`
  /// is only ever called explicitly), so keeping the tab open on partial
  /// failure (e.g. branch not merged after the worktree dir is already gone)
  /// lets the caller retry with `forceBranch` using the same id. The worktree
  /// removal step is idempotent via an `exists()` check, so a retry after a
  /// worktree-remove success + branch-delete failure skips straight to the
  /// branch step instead of erroring on an already-removed path.
  /// Removes a linked worktree, optionally deleting its branch. [branch] is the
  /// branch the UI showed the user (which may be enriched from the live git
  /// list); it takes precedence over the workspace's own `branch` field so the
  /// branch actually deleted matches what was on screen. The worktree removal
  /// itself is idempotent in the datasource (a retry after a partial failure —
  /// worktree gone but branch delete failed — skips the already-done removal).
  Future<Either<Failure, void>> removeWorktree(
    WorkspaceId id, {
    bool deleteBranch = false,
    bool force = false,
    bool forceBranch = false,
    String? branch,
  }) async {
    final ws = state.workspacesOrEmpty.firstWhereOrNull((w) => w.id == id);
    if (ws == null) return const Left(NotFoundFailure('Workspace not found'));
    final repoRoot = ws.repoRoot;
    if (repoRoot == null) {
      return const Left(UnexpectedFailure('removeWorktree called on a non-git workspace'));
    }

    final removed = await _removeWorktree(repoRoot: repoRoot, worktreePath: ws.path, force: force);
    if (removed.isLeft) {
      _talker.warning('git worktree remove failed for ${ws.path}: ${removed.left}');
      return removed;
    }
    // The worktree dir is gone now — invalidate the cache even if a later step
    // fails, so the sidebar never keeps showing a removed worktree.
    _worktreeCache.clear();

    final branchToDelete = branch ?? ws.branch;
    if (deleteBranch && branchToDelete != null) {
      final branchResult = await _deleteBranch(repoRoot: repoRoot, branch: branchToDelete, force: forceBranch);
      if (branchResult.isLeft) {
        _talker.warning('git branch delete failed for $branchToDelete: ${branchResult.left}');
        return branchResult;
      }
    }

    _talker.info('Removed worktree: ${ws.path}');
    closeWorkspace(id);
    return const Right(null);
  }

  void setActive(WorkspaceId id) {
    final list = state.workspacesOrEmpty;
    if (!list.any((w) => w.id == id)) return;
    if (state.activeIdOrNull == id) return;
    _talker.debug('Switching active workspace: $id');
    emit(WorkspacesState.loaded(workspaces: list, activeId: id));
  }

  Future<void> restore() async {
    _restoring = true;
    try {
      final snapshot = await _persistence.read();
      if (snapshot == null || snapshot.workspaces.isEmpty) {
        emit(const WorkspacesState.loaded());
        return;
      }
      final results = await Future.wait(
        snapshot.workspaces.map((entry) async {
          final r = await _openWorkspace(path: entry.path);
          return r.fold((failure) {
            _talker.info('Skipped restoring workspace ${entry.path}: $failure');
            return null;
          }, (ws) => ws.copyWith(openedAt: entry.openedAt));
        }),
      );
      final restored = results.whereType<Workspace>().toList(growable: false);
      var activeId = snapshot.activeId;
      if (activeId == null || !restored.any((w) => w.id == activeId)) {
        activeId = restored.isNotEmpty ? restored.first.id : null;
      }
      emit(WorkspacesState.loaded(workspaces: restored, activeId: activeId));
      _talker.info('Restored ${restored.length}/${snapshot.workspaces.length} workspace(s)');
    } finally {
      _restoring = false;
    }
  }

  Future<void> _persist() async {
    final s = state;
    if (s is! WorkspacesStateLoaded) return;
    try {
      await _persistence.write(
        PersistedWorkspaces(
          activeId: s.activeId,
          workspaces: s.workspaces
              .map((w) => PersistedWorkspaceEntry(id: w.id, path: w.path, name: w.name, openedAt: w.openedAt))
              .toList(growable: false),
        ),
      );
    } catch (e, st) {
      _talker.error('Failed to persist workspaces', e, st);
    }
  }

  @override
  Future<void> close() async {
    _saveDebounce?.cancel();
    await _selfSub?.cancel();
    for (final w in state.workspacesOrEmpty) {
      await _fileWatcher.dispose(w.path);
    }
    return super.close();
  }
}
