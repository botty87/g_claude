import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

abstract interface class WorkspaceFileWatcher {
  Stream<FileSystemEvent> watch(String workspacePath);

  /// Stream filtered to events touching [filePath].
  ///
  /// The watcher locates the owning workspace among active handles via prefix
  /// match; if [filePath] is not under any watched workspace, the returned
  /// stream is empty. Move events are matched on both source and destination.
  Stream<FileSystemEvent> watchFile(String filePath);

  Future<void> dispose(String workspacePath);
}

@LazySingleton(as: WorkspaceFileWatcher)
class WorkspaceFileWatcherImpl implements WorkspaceFileWatcher {
  WorkspaceFileWatcherImpl(this._talker);

  final Talker _talker;
  final Map<String, _WatchHandle> _handles = {};

  @override
  Stream<FileSystemEvent> watch(String workspacePath) {
    final handle = _handles.putIfAbsent(workspacePath, () => _WatchHandle.start(workspacePath, _talker));
    return handle.controller.stream;
  }

  @override
  Stream<FileSystemEvent> watchFile(String filePath) {
    final root = _findOwningRoot(filePath);
    if (root == null) {
      _talker.warning('watchFile: no active workspace owns $filePath');
      return const Stream.empty();
    }
    final canonical = p.canonicalize(filePath);
    return watch(root).where((e) => _eventMatchesPath(e, filePath, canonical));
  }

  @override
  Future<void> dispose(String workspacePath) async {
    final handle = _handles.remove(workspacePath);
    if (handle == null) return;
    await handle.dispose();
  }

  String? _findOwningRoot(String filePath) {
    final canonicalFile = p.canonicalize(filePath);
    String? best;
    for (final root in _handles.keys) {
      if (p.equals(root, filePath) || p.isWithin(root, filePath)) {
        if (best == null || root.length > best.length) best = root;
        continue;
      }
      final canonicalRoot = p.canonicalize(root);
      if (p.equals(canonicalRoot, canonicalFile) || p.isWithin(canonicalRoot, canonicalFile)) {
        if (best == null || root.length > best.length) best = root;
      }
    }
    return best;
  }
}

bool _eventMatchesPath(FileSystemEvent event, String target, String canonicalTarget) {
  final src = event.path;
  if (p.equals(src, target) || p.canonicalize(src) == canonicalTarget) {
    return true;
  }
  if (event is FileSystemMoveEvent) {
    final dest = event.destination;
    if (dest != null && (p.equals(dest, target) || p.canonicalize(dest) == canonicalTarget)) {
      return true;
    }
  }
  return false;
}

// Path segments filtered upstream: build artifacts, VCS internals, dependency
// caches. Tools (build_runner, git, npm) churn these at very high rates and
// no UI surface cares about them; cutting them at the source avoids fanning
// out hundreds of events/sec to every cubit and CodeView listener.
const _ignoredSegments = {
  '.git',
  '.dart_tool',
  '.idea',
  '.vscode',
  'build',
  '.build',
  'node_modules',
  '.gradle',
  'DerivedData',
};

class _WatchHandle {
  _WatchHandle._(this.path, this._talker, this.controller);

  factory _WatchHandle.start(String path, Talker talker) {
    final controller = StreamController<FileSystemEvent>.broadcast();
    final handle = _WatchHandle._(path, talker, controller);
    handle._start();
    return handle;
  }

  final String path;
  final Talker _talker;
  final StreamController<FileSystemEvent> controller;
  StreamSubscription<FileSystemEvent>? _sub;

  bool _isIgnored(String eventPath) {
    final rel = p.relative(eventPath, from: path);
    if (rel == '.' || rel.startsWith('..')) return false;
    for (final seg in p.split(rel)) {
      if (_ignoredSegments.contains(seg)) return true;
    }
    return false;
  }

  void _start() {
    try {
      _sub = Directory(path)
          .watch(recursive: true)
          .listen(
            (event) {
              if (_isIgnored(event.path)) return;
              if (event is FileSystemMoveEvent) {
                final dest = event.destination;
                if (dest != null && _isIgnored(dest)) return;
              }
              controller.add(event);
            },
            onError: (Object e, StackTrace st) {
              _talker.error('WorkspaceFileWatcher: stream error for $path', e, st);
            },
          );
      _talker.debug('WorkspaceFileWatcher: watching $path');
    } catch (e, st) {
      _talker.error('WorkspaceFileWatcher: cannot start for $path', e, st);
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    await controller.close();
    _talker.debug('WorkspaceFileWatcher: stopped $path');
  }
}
