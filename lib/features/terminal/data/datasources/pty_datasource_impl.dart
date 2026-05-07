import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_pty/flutter_pty.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:xterm/xterm.dart';

import '../../../../core/process/graceful_kill.dart';
import 'pty_datasource.dart';

class _TerminalSession {
  _TerminalSession({required this.terminal, required this.controller, this.pty});

  // null when the spawn failed and no PTY process exists.
  final Pty? pty;
  final Terminal terminal;
  final TerminalController controller;
  StreamSubscription<String>? sub;
  Timer? resizeDebounce;
  int? exitCode;
}

@LazySingleton(as: PtyDataSource)
class PtyDataSourceImpl implements PtyDataSource {
  PtyDataSourceImpl(this._talker);

  final Talker _talker;

  final Map<String, _TerminalSession> _sessions = {};
  final _eventsController = StreamController<PtySessionEvent>.broadcast();

  @override
  Stream<PtySessionEvent> get events => _eventsController.stream;

  /// Add an event only if the controller is still open. The PTY exit
  /// callback can fire asynchronously after `disposeAll()` closed the
  /// controller; without this guard `add` would throw StateError.
  void _emitEvent(PtySessionEvent event) {
    if (_eventsController.isClosed) return;
    _eventsController.add(event);
  }

  @override
  String detectShell() {
    final shell = Platform.environment['SHELL'];
    if (shell != null && shell.isNotEmpty) return shell;
    return '/bin/zsh';
  }

  static const int _scrollbackLines = 10000;

  @override
  void getOrCreate({required String workspaceId, required String cwd}) {
    final existing = _sessions[workspaceId];
    if (existing != null) return;

    final shellPath = detectShell();
    final terminal = Terminal(maxLines: _scrollbackLines);
    final controller = TerminalController();

    _talker.info('PTY spawning $shellPath in $cwd for workspace $workspaceId');

    try {
      final pty = Pty.start(
        shellPath,
        workingDirectory: cwd,
        environment: {'SHELL': shellPath, ...Platform.environment},
        columns: terminal.viewWidth,
        rows: terminal.viewHeight,
      );

      final session = _TerminalSession(terminal: terminal, controller: controller, pty: pty);
      _sessions[workspaceId] = session;

      session.sub = pty.output
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true))
          .listen(terminal.write);

      terminal.onOutput = (data) {
        pty.write(const Utf8Encoder().convert(data));
      };

      // PTY API is resize(rows, cols); xterm onResize gives (width, height, …).
      // Debounce: window-drag fires per-frame, which would SIGWINCH-storm the
      // shell and trigger redundant prompt redraws. 60ms = barely perceptible
      // pause once the user stops dragging.
      terminal.onResize = (w, h, pw, ph) {
        session.resizeDebounce?.cancel();
        session.resizeDebounce = Timer(const Duration(milliseconds: 60), () => pty.resize(h, w));
      };

      _emitEvent(PtySessionEvent.running(workspaceId: workspaceId));

      // Capture session reference: a later restart() may have replaced
      // _sessions[workspaceId] with a new entry; without identity check the
      // exit of the killed PTY would mark the new session as exited.
      final mySession = session;
      pty.exitCode.then((code) {
        if (!identical(_sessions[workspaceId], mySession)) {
          // Stale: the session was replaced (restart) or removed.
          _talker.debug('PTY exit ignored (stale session) wid=$workspaceId code=$code');
          return;
        }
        mySession.exitCode = code;
        terminal.write('\r\n[Process exited with code $code]\r\n');
        _talker.info('PTY exited for workspace $workspaceId (code=$code)');
        _emitEvent(PtySessionEvent.exited(workspaceId: workspaceId, exitCode: code));
      });
    } catch (e, st) {
      _talker.error('PTY spawn failed for workspace $workspaceId', e, st);
      // Swallow input on dead session — onOutput would otherwise hit a null pty.
      terminal.onOutput = (_) {};
      _sessions[workspaceId] = _TerminalSession(terminal: terminal, controller: controller);
      terminal.write('\r\n[Failed to start shell: $e]\r\n');
      _emitEvent(PtySessionEvent.failed(workspaceId: workspaceId, error: '$e'));
    }
  }

  @override
  Terminal? terminalFor(String workspaceId) {
    return _sessions[workspaceId]?.terminal;
  }

  @override
  TerminalController? controllerFor(String workspaceId) {
    return _sessions[workspaceId]?.controller;
  }

  @override
  Future<void> dispose(String workspaceId) async {
    final session = _sessions.remove(workspaceId);
    if (session == null) return;
    await _killSession(session);
  }

  @override
  Future<void> disposeAll() async {
    final entries = List<MapEntry<String, _TerminalSession>>.from(_sessions.entries);
    _sessions.clear();
    await Future.wait(entries.map((e) => _killSession(e.value)));
    if (!_eventsController.isClosed) {
      await _eventsController.close();
    }
  }

  Future<void> _killSession(_TerminalSession session) async {
    session.resizeDebounce?.cancel();
    session.resizeDebounce = null;
    await session.sub?.cancel();
    session.sub = null;
    session.controller.dispose();

    final pty = session.pty;
    if (pty == null) return; // spawn failed; no process to kill.
    if (session.exitCode != null) return; // already exited.

    await gracefulKill(kill: pty.kill, exitCode: pty.exitCode);
  }
}
