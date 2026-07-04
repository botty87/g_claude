import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/persistence/key_value_store.dart';
import '../../../../core/utils/either.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../domain/entities/file_diff.dart';
import '../../domain/entities/git_diff_file.dart';
import '../../domain/usecases/list_changed_files.dart';
import '../../domain/usecases/read_file_diff.dart';

part 'git_diff_cubit.freezed.dart';
part 'git_diff_cubit.state.dart';

/// Owns the "changed files" list per workspace (flat/tree view, load state)
/// backing the git diff panel. Persists only the per-workspace [DiffViewMode]
/// choice; the file list itself is always reloaded on demand via [load].
///
/// [restore] is `preResolve: true`, so `configureDependencies()` (`getIt.init()`)
/// awaits it during boot — same pattern as `SessionsDatabase`/`AppLogsDatabase`.
/// This makes `getIt<GitDiffCubit>()` safe to call synchronously anywhere
/// after boot (e.g. `BlocProvider(create: (_) => getIt<GitDiffCubit>())`);
/// without `preResolve`, injectable registers an async singleton and a plain
/// sync `getIt<GitDiffCubit>()` throws.
@lazySingleton
class GitDiffCubit extends Cubit<GitDiffState> {
  GitDiffCubit(this._listChangedFiles, this._readFileDiff, this._store, this._talker) : super(const GitDiffState());

  final ListChangedFiles _listChangedFiles;
  final ReadFileDiff _readFileDiff;
  final KeyValueStore _store;
  final Talker _talker;

  static const _persistenceKey = 'persistence.git_diff.v1';

  @PostConstruct(preResolve: true)
  Future<void> restore() async {
    final raw = await _store.readString(_persistenceKey);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final perWsRaw = json['perWorkspace'] as Map<String, dynamic>? ?? const {};
      final perWorkspace = <WorkspaceId, WorkspaceDiff>{};
      perWsRaw.forEach((id, value) {
        final mode = _modeFromString(value as String?);
        if (mode != null) perWorkspace[id] = WorkspaceDiff(viewMode: mode);
      });
      if (perWorkspace.isNotEmpty) {
        emit(state.copyWith(perWorkspace: perWorkspace));
      }
    } catch (e, st) {
      _talker.error('GitDiffCubit: failed to restore persisted view modes', e, st);
    }
  }

  /// Loads (or reloads) the changed-files list for [workspaceId] at [path].
  /// Preserves the existing [DiffViewMode] and collapsed-dirs while loading.
  Future<void> load({required WorkspaceId workspaceId, required String path}) async {
    _updateDiff(workspaceId, state.diffFor(workspaceId).copyWith(loading: true));
    final result = await _listChangedFiles(cwd: path);
    result.fold(
      (failure) => _updateDiff(
        workspaceId,
        state.diffFor(workspaceId).copyWith(loading: false, failure: failure, files: const []),
      ),
      (files) =>
          _updateDiff(workspaceId, state.diffFor(workspaceId).copyWith(loading: false, failure: null, files: files)),
    );
  }

  Future<void> refresh({required WorkspaceId workspaceId, required String path}) =>
      load(workspaceId: workspaceId, path: path);

  /// Stateless pass-through: reads a single file's unified diff on demand
  /// (e.g. when the user selects a row in the changed-files list). Not
  /// cached in [GitDiffState] — callers own their own loading/display state.
  Future<Either<Failure, FileDiff>> readFileDiff({required String cwd, required GitDiffFile file}) =>
      _readFileDiff(cwd: cwd, file: file);

  void setViewMode(WorkspaceId workspaceId, DiffViewMode mode) {
    final current = state.diffFor(workspaceId);
    if (current.viewMode == mode) return;
    _updateDiff(workspaceId, current.copyWith(viewMode: mode));
    unawaited(_persist());
  }

  void toggleDir(WorkspaceId workspaceId, String dir) {
    final current = state.diffFor(workspaceId);
    final collapsed = Set<String>.of(current.collapsedDirs);
    if (!collapsed.remove(dir)) collapsed.add(dir);
    _updateDiff(workspaceId, current.copyWith(collapsedDirs: collapsed));
  }

  void _updateDiff(WorkspaceId workspaceId, WorkspaceDiff diff) {
    emit(state.copyWith(perWorkspace: {...state.perWorkspace, workspaceId: diff}));
  }

  Future<void> _persist() async {
    final json = <String, dynamic>{
      'perWorkspace': state.perWorkspace.map((id, diff) => MapEntry(id, diff.viewMode.name)),
    };
    try {
      await _store.writeString(_persistenceKey, jsonEncode(json));
    } catch (e, st) {
      _talker.error('GitDiffCubit: failed to persist view modes', e, st);
    }
  }

  DiffViewMode? _modeFromString(String? raw) => switch (raw) {
    'flat' => DiffViewMode.flat,
    'tree' => DiffViewMode.tree,
    _ => null,
  };
}
