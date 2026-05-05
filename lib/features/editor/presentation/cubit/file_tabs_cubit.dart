import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../features/workspace/data/datasources/workspace_file_watcher.dart';
import '../../../../features/workspace/domain/entities/workspace.dart';
import '../../../../features/workspace/presentation/cubit/workspaces_cubit.dart';
import '../../data/datasources/file_tabs_persistence_datasource.dart';

part 'file_tabs_cubit.freezed.dart';
part 'file_tabs_cubit.state.dart';

@lazySingleton
class FileTabsCubit extends Cubit<FileTabsState> {
  FileTabsCubit(
    this._workspacesCubit,
    this._persistence,
    this._fileWatcher,
    this._talker,
  ) : super(const FileTabsState());

  final WorkspacesCubit _workspacesCubit;
  final FileTabsPersistenceDataSource _persistence;
  final WorkspaceFileWatcher _fileWatcher;
  final Talker _talker;
  StreamSubscription<WorkspacesState>? _wsSub;
  StreamSubscription<FileTabsState>? _selfSub;
  Timer? _saveDebounce;
  bool _restoring = false;
  final Map<WorkspaceId, StreamSubscription<FileSystemEvent>> _fsSubs = {};

  static const _saveDebounceMs = 250;

  @PostConstruct()
  void init() {
    _wsSub = _workspacesCubit.stream.listen(_onWorkspacesChanged);
    _selfSub = stream.listen((_) {
      if (_restoring) return;
      _saveDebounce?.cancel();
      _saveDebounce = Timer(const Duration(milliseconds: _saveDebounceMs), _persist);
    });
    for (final w in _workspacesCubit.state.workspacesOrEmpty) {
      _attachWatcher(w);
    }
  }

  void _attachWatcher(Workspace w) {
    if (_fsSubs.containsKey(w.id)) return;
    _fsSubs[w.id] = _fileWatcher.watch(w.path).listen(
      (event) => _onFsEvent(w, event),
      onError: (Object e, StackTrace st) {
        _talker.error('FileTabsCubit: watcher error for ${w.path}', e, st);
      },
    );
  }

  void _detachWatcher(WorkspaceId id) {
    final sub = _fsSubs.remove(id);
    if (sub != null) unawaited(sub.cancel());
  }

  void _onFsEvent(Workspace w, FileSystemEvent event) {
    if (event is! FileSystemDeleteEvent) return;
    final files = state.perWorkspace[w.id];
    if (files == null || files.openPaths.isEmpty) return;
    final eventCanonical = p.canonicalize(event.path);
    for (final open in files.openPaths) {
      final isMatch = p.equals(event.path, open) ||
          p.canonicalize(open) == eventCanonical;
      if (!isMatch) continue;
      // Defer close: atomic-save (Edit/Write) emits delete + create within
      // a few ms. If the file reappears, treat as in-place overwrite and
      // keep the tab.
      Timer(const Duration(milliseconds: 300), () {
        if (File(open).existsSync()) return;
        final current = state.perWorkspace[w.id];
        if (current == null) return;
        if (!current.openPaths.contains(open)) return;
        _talker.debug('FileTabsCubit: auto-closing $open (deleted)');
        closeFile(w.id, open);
      });
    }
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
    final stale = state.perWorkspace.keys
        .where((id) => !aliveIds.contains(id))
        .toList();
    if (stale.isEmpty) return;
    final next = Map.of(state.perWorkspace)
      ..removeWhere((k, _) => stale.contains(k));
    _talker.debug('FileTabsCubit: pruned ${stale.length} stale workspace(s)');
    emit(state.copyWith(perWorkspace: next));
  }

  void openFile(WorkspaceId id, String path) {
    final files = state.perWorkspace[id] ?? const WorkspaceFiles();

    if (files.openPaths.contains(path)) {
      setActiveFile(id, path);
      return;
    }

    final WorkspaceFiles next;
    if (files.previewPath != null) {
      final previewIdx = files.openPaths.indexOf(files.previewPath!);
      final nextPaths = [...files.openPaths];
      nextPaths[previewIdx] = path;
      next = files.copyWith(
        openPaths: nextPaths,
        activePath: path,
        previewPath: path,
      );
    } else {
      next = files.copyWith(
        openPaths: [...files.openPaths, path],
        activePath: path,
        previewPath: path,
      );
    }

    _talker.debug('FileTabsCubit: opened $path in workspace $id (preview)');
    emit(state.copyWith(perWorkspace: {...state.perWorkspace, id: next}));
  }

  void pinFile(WorkspaceId id, String path) {
    final files = state.perWorkspace[id];
    if (files == null) return;
    if (files.previewPath != path) return;
    _talker.debug('FileTabsCubit: pinned $path');
    emit(state.copyWith(
      perWorkspace: {
        ...state.perWorkspace,
        id: files.copyWith(previewPath: null),
      },
    ));
  }

  void closeFile(WorkspaceId id, String path) {
    final files = state.perWorkspace[id];
    if (files == null) return;
    final index = files.openPaths.indexOf(path);
    if (index < 0) return;

    final nextPaths = [...files.openPaths]..removeAt(index);
    final nextPreview = files.previewPath == path ? null : files.previewPath;

    if (nextPaths.isEmpty) {
      final next = files.copyWith(
        openPaths: [],
        activePath: null,
        previewPath: null,
      );
      emit(state.copyWith(perWorkspace: {...state.perWorkspace, id: next}));
      return;
    }

    String? newActive = files.activePath;
    if (newActive == path) {
      newActive =
          nextPaths[index < nextPaths.length ? index : nextPaths.length - 1];
    }
    final next = files.copyWith(
      openPaths: nextPaths,
      activePath: newActive,
      previewPath: nextPreview,
    );
    _talker.debug('FileTabsCubit: closed $path in workspace $id');
    emit(state.copyWith(perWorkspace: {...state.perWorkspace, id: next}));
  }

  void reorderPinned(WorkspaceId id, String fromPath, String toPath) {
    if (fromPath == toPath) return;
    final files = state.perWorkspace[id];
    if (files == null) return;
    if (files.previewPath == fromPath || files.previewPath == toPath) return;
    final fromIdx = files.openPaths.indexOf(fromPath);
    final toIdx = files.openPaths.indexOf(toPath);
    if (fromIdx < 0 || toIdx < 0) return;

    final nextPaths = [...files.openPaths];
    final moved = nextPaths.removeAt(fromIdx);
    nextPaths.insert(toIdx, moved);

    final preview = files.previewPath;
    if (preview != null) {
      final previewIdx = files.openPaths.indexOf(preview);
      final newPreviewIdx = nextPaths.indexOf(preview);
      if (newPreviewIdx != previewIdx) {
        nextPaths.remove(preview);
        nextPaths.insert(previewIdx.clamp(0, nextPaths.length), preview);
      }
    }

    _talker.debug('FileTabsCubit: reordered $fromPath → $toPath in workspace $id');
    emit(state.copyWith(
      perWorkspace: {
        ...state.perWorkspace,
        id: files.copyWith(openPaths: nextPaths),
      },
    ));
  }

  void closeAllFiles(WorkspaceId id) {
    final files = state.perWorkspace[id];
    if (files == null || files.openPaths.isEmpty) return;
    _talker.debug('FileTabsCubit: closed all files in workspace $id');
    emit(state.copyWith(
      perWorkspace: {
        ...state.perWorkspace,
        id: const WorkspaceFiles(),
      },
    ));
  }

  void setActiveFile(WorkspaceId id, String path) {
    final files = state.perWorkspace[id];
    if (files == null) return;
    if (files.activePath == path) return;
    if (!files.openPaths.contains(path)) return;
    final next = files.copyWith(activePath: path);
    emit(state.copyWith(perWorkspace: {...state.perWorkspace, id: next}));
  }

  Future<void> restore() async {
    _restoring = true;
    try {
      final snapshot = await _persistence.read();
      if (snapshot == null || snapshot.perWorkspace.isEmpty) return;
      final aliveIds = _workspacesCubit.state.workspacesOrEmpty
          .map((w) => w.id)
          .toSet();
      final filtered = <WorkspaceId, WorkspaceFiles>{};
      snapshot.perWorkspace.forEach((id, files) {
        if (!aliveIds.contains(id)) return;
        if (files.openPaths.isEmpty) return;
        var active = files.activePath;
        if (active != null && !files.openPaths.contains(active)) {
          active = files.openPaths.first;
        }
        var preview = files.previewPath;
        if (preview != null && !files.openPaths.contains(preview)) {
          preview = null;
        }
        filtered[id] = WorkspaceFiles(
          openPaths: List.unmodifiable(files.openPaths),
          activePath: active,
          previewPath: preview,
        );
      });
      if (filtered.isEmpty) return;
      emit(state.copyWith(perWorkspace: filtered));
      _talker.info('Restored file tabs for ${filtered.length} workspace(s)');
    } catch (e, st) {
      _talker.error('Failed to restore file tabs', e, st);
    } finally {
      _restoring = false;
    }
  }

  Future<void> _persist() async {
    try {
      final perWs = state.perWorkspace.map(
        (id, files) => MapEntry(
          id,
          PersistedWorkspaceFiles(
            openPaths: files.openPaths,
            activePath: files.activePath,
            previewPath: files.previewPath,
          ),
        ),
      );
      await _persistence.write(PersistedFileTabs(perWorkspace: perWs));
    } catch (e, st) {
      _talker.error('Failed to persist file tabs', e, st);
    }
  }

  @override
  Future<void> close() async {
    _saveDebounce?.cancel();
    await _wsSub?.cancel();
    await _selfSub?.cancel();
    for (final s in _fsSubs.values) {
      await s.cancel();
    }
    _fsSubs.clear();
    return super.close();
  }
}
