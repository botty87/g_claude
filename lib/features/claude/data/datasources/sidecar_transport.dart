import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'claude_binary_resolver.dart';

abstract interface class SidecarTransport {
  Future<void> start();
  Stream<Map<String, dynamic>> get events;
  void send(Map<String, dynamic> req);
  Future<void> dispose();
}

@LazySingleton(as: SidecarTransport)
class StdioSidecarTransport implements SidecarTransport {
  StdioSidecarTransport(this._talker, this._binaryResolver);

  final Talker _talker;
  final ClaudeBinaryResolver _binaryResolver;

  Process? _process;
  StreamSubscription<String>? _stdoutSub;
  StreamSubscription<String>? _stderrSub;
  final StreamController<Map<String, dynamic>> _eventsController = StreamController<Map<String, dynamic>>.broadcast();

  // Last stderr lines of the current process — surfaced in the death reason so a
  // crash (e.g. ERR_MODULE_NOT_FOUND) becomes an actionable error, not a silent
  // "dead chat".
  final List<String> _stderrTail = [];
  static const _stderrTailMax = 20;

  // Guards [_handleDeath] against the double signal (stdout `onDone` + process
  // `exitCode`) that both fire when the process dies.
  bool _dead = false;

  // Completer that resolves when the sidecar emits the `ready` event.
  Completer<void>? _readyCompleter;

  @override
  Stream<Map<String, dynamic>> get events => _eventsController.stream;

  /// Idempotent: starts the sidecar process exactly once and waits for the
  /// `ready` event before returning. Subsequent calls return immediately.
  @override
  Future<void> start() async {
    if (_process != null && _readyCompleter != null && _readyCompleter!.isCompleted) {
      return;
    }
    if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
      // Already starting — wait for the existing start to finish.
      return _readyCompleter!.future;
    }

    final claudePath = await _binaryResolver.resolve();
    if (claudePath == null) {
      throw StateError('sidecar: claude binary not found');
    }

    // Release: spawn the bundled single-file sidecar (clyde-sidecar.cjs in the
    // .app Resources) with the system node. Debug: run the TS source via tsx.
    final String exe;
    final List<String> args;
    String? workingDirectory;
    if (kReleaseMode) {
      final cjs = _bundledSidecarPath();
      if (cjs == null || !File(cjs).existsSync()) {
        throw StateError('sidecar: bundled clyde-sidecar.cjs not found (expected in app Resources)');
      }
      final node = await _resolveNode();
      if (node == null) {
        throw StateError('sidecar: node runtime not found');
      }
      exe = node;
      args = [cjs];
    } else {
      final backendDir = _findBackendDir();
      if (backendDir == null) {
        _talker.error(
          'SidecarTransport: could not locate backend/ directory with src/sidecar.ts. '
          'Search started from ${Directory.current.path} up to 6 parent levels.',
        );
        throw StateError('sidecar: backend directory not found');
      }
      exe = 'npx';
      args = ['tsx', 'src/sidecar.ts'];
      workingDirectory = backendDir;
    }

    _readyCompleter = Completer<void>();
    _dead = false;
    _stderrTail.clear();

    _talker.info('SidecarTransport: starting sidecar ($exe ${args.join(' ')})');

    _process = await Process.start(
      exe,
      args,
      workingDirectory: workingDirectory,
      environment: {...Platform.environment, 'CLAUDE_CLI_PATH': claudePath},
      runInShell: false,
    );

    _stderrSub = _process!.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
      _talker.warning('[sidecar stderr] $line');
      _stderrTail.add(line);
      if (_stderrTail.length > _stderrTailMax) _stderrTail.removeAt(0);
    });

    _stdoutSub = _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_onLine, onDone: () => _handleDeath());

    // Death arrives as two racing signals (stdout onDone + exitCode); whichever
    // wins, [_handleDeath] both unblocks a pending start() AND errors any active
    // run stream so runStatus never stays stuck at `connecting`/`running`.
    _process!.exitCode.then((code) => _handleDeath(exitCode: code));

    return _readyCompleter!.future;
  }

  void _onLine(String line) {
    if (line.trim().isEmpty) return;
    try {
      final raw = jsonDecode(line);
      if (raw is! Map<String, dynamic>) return;

      final type = raw['t'] as String?;

      if (type == 'ready') {
        _talker.info('SidecarTransport: sidecar ready (sdk=${raw['sdk']})');
        if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
          _readyCompleter!.complete();
        }
        return;
      }

      if (type == 'fatal') {
        _talker.error('SidecarTransport: fatal from sidecar: ${raw['message']}');
        _eventsController.addError(StateError('sidecar fatal: ${raw['message']}'));
        return;
      }

      // Broadcast every other event to all session listeners.
      _eventsController.add(raw);
    } catch (e) {
      _talker.warning('SidecarTransport: failed to parse line: $line ($e)');
    }
  }

  /// Handles process death from either racing signal exactly once: unblocks a
  /// pending [start] with an error and errors the shared event stream so every
  /// in-flight run terminates (the datasource maps it to a run error). The
  /// broadcast controller stays open so the next prompt can respawn.
  void _handleDeath({int? exitCode}) {
    if (_dead) return;
    _dead = true;
    final tail = _stderrTail.isEmpty ? '' : ': ${_stderrTail.join(' | ')}';
    final reason = 'sidecar exited (code=${exitCode ?? 'unknown'})$tail';
    _talker.warning('SidecarTransport: $reason');
    if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
      _readyCompleter!.completeError(StateError(reason));
    }
    if (!_eventsController.isClosed) {
      _eventsController.addError(StateError(reason));
    }
    _process = null;
    _readyCompleter = null;
  }

  @override
  void send(Map<String, dynamic> req) {
    final p = _process;
    if (p == null) {
      _talker.warning('SidecarTransport.send: no active process, dropping: ${req['t']}');
      return;
    }
    try {
      p.stdin.writeln(jsonEncode(req));
    } catch (e) {
      _talker.error('SidecarTransport.send: stdin write failed: $e');
    }
  }

  @override
  Future<void> dispose() async {
    await _stdoutSub?.cancel();
    await _stderrSub?.cancel();
    await _eventsController.close();
    _process?.kill();
    _process = null;
    _readyCompleter = null;
  }

  /// Walks up from the current directory (max 6 levels) looking for a
  /// `backend/` folder containing `src/sidecar.ts`.
  String? _findBackendDir() {
    Directory dir = Directory.current;
    for (var i = 0; i < 6; i++) {
      final candidate = Directory('${dir.path}/backend');
      final ts = File('${candidate.path}/src/sidecar.ts');
      if (ts.existsSync()) return candidate.path;
      final parent = dir.parent;
      if (parent.path == dir.path) break; // filesystem root
      dir = parent;
    }
    return null;
  }

  /// Release: `Clyde.app/Contents/MacOS/Clyde` → `../Resources/clyde-sidecar.cjs`.
  String? _bundledSidecarPath() {
    try {
      final macosDir = File(Platform.resolvedExecutable).parent; // Contents/MacOS
      return '${macosDir.parent.path}/Resources/clyde-sidecar.cjs';
    } catch (_) {
      return null;
    }
  }

  /// Resolves the `node` runtime. A Finder-launched app has a minimal PATH, so
  /// probe common locations and fall back to a login shell (like the claude resolver).
  Future<String?> _resolveNode() async {
    for (final c in ['/opt/homebrew/bin/node', '/usr/local/bin/node', 'node']) {
      try {
        final r = await Process.run(c, ['--version'], runInShell: false);
        if (r.exitCode == 0) return c;
      } catch (_) {}
    }
    if (Platform.isMacOS || Platform.isLinux) {
      try {
        final r = await Process.run('zsh', ['-ilc', 'command -v node'], runInShell: false);
        if (r.exitCode == 0) {
          final out = (r.stdout as String).trim();
          if (out.isNotEmpty) return out.split('\n').first;
        }
      } catch (_) {}
    }
    return null;
  }
}
