import 'dart:async';
import 'dart:io';

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
import '../../../git/domain/entities/git_worktree.dart';
import '../../../git/domain/usecases/delete_branch.dart';
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
    this._persistence,
    this._fileWatcher,
    this._talker,
  ) : super(const WorkspacesState.initial());

  final OpenWorkspace _openWorkspace;
  final ListWorktrees _listWorktrees;
  final RemoveWorktree _removeWorktree;
  final DeleteBranch _deleteBranch;
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
  Future<Either<Failure, void>> removeWorktree(
    WorkspaceId id, {
    bool deleteBranch = false,
    bool force = false,
    bool forceBranch = false,
  }) async {
    final ws = state.workspacesOrEmpty.firstWhereOrNull((w) => w.id == id);
    if (ws == null) return const Left(NotFoundFailure('Workspace not found'));
    final repoRoot = ws.repoRoot;
    if (repoRoot == null) {
      return const Left(UnexpectedFailure('removeWorktree called on a non-git workspace'));
    }

    if (await Directory(ws.path).exists()) {
      final removed = await _removeWorktree(repoRoot: repoRoot, worktreePath: ws.path, force: force);
      if (removed.isLeft) {
        _talker.warning('git worktree remove failed for ${ws.path}: ${removed.left}');
        return removed;
      }
    }

    final branch = ws.branch;
    if (deleteBranch && branch != null) {
      final branchResult = await _deleteBranch(repoRoot: repoRoot, branch: branch, force: forceBranch);
      if (branchResult.isLeft) {
        _talker.warning('git branch delete failed for $branch: ${branchResult.left}');
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
