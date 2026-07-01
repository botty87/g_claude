import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

    final backendDir = _findBackendDir();
    if (backendDir == null) {
      _talker.error(
        'SidecarTransport: could not locate backend/ directory with src/sidecar.ts. '
        'Search started from ${Directory.current.path} up to 6 parent levels.',
      );
      throw StateError('sidecar: backend directory not found');
    }

    final claudePath = await _binaryResolver.resolve();
    if (claudePath == null) {
      throw StateError('sidecar: claude binary not found');
    }

    _readyCompleter = Completer<void>();

    _talker.info('SidecarTransport: starting sidecar in $backendDir');

    _process = await Process.start(
      'npx',
      ['tsx', 'src/sidecar.ts'],
      workingDirectory: backendDir,
      environment: {...Platform.environment, 'CLAUDE_CLI_PATH': claudePath},
      runInShell: false,
    );

    _stderrSub = _process!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) => _talker.warning('[sidecar stderr] $line'));

    _stdoutSub = _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_onLine, onDone: _onProcessDone);

    // Handle unexpected process exit before ready.
    _process!.exitCode.then((code) {
      _talker.warning('SidecarTransport: process exited with code $code');
      if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
        _readyCompleter!.completeError(StateError('sidecar exited before ready (code=$code)'));
      }
      _process = null;
    });

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

  void _onProcessDone() {
    _talker.info('SidecarTransport: stdout closed');
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
}
