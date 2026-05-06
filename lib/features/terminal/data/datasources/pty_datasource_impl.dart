import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_pty/flutter_pty.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:xterm/xterm.dart';

import 'pty_datasource.dart';

class _TerminalSession {
  _TerminalSession({
    required this.terminal,
    required this.controller,
    this.pty,
  });

  // null when the spawn failed and no PTY process exists.
  final Pty? pty;
  final Terminal terminal;
  final TerminalController controller;
  StreamSubscription<String>? sub;
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

  @override
  String detectShell() => _detectShellStatic();

  static String _detectShellStatic() {
    final shell = Platform.environment['SHELL'];
    if (shell != null && shell.isNotEmpty) return shell;
    return '/bin/zsh';
  }

  @override
  Terminal getOrCreate({required String workspaceId, required String cwd}) {
    final existing = _sessions[workspaceId];
    if (existing != null) return existing.terminal;

    final shellPath = _detectShellStatic();
    final terminal = Terminal(maxLines: 10000);
    final controller = TerminalController();

    _talker.info('PTY spawning $shellPath in $cwd for workspace $workspaceId');

    try {
      final pty = Pty.start(
        shellPath,
        workingDirectory: cwd,
        environment: {
          'SHELL': shellPath,
          ...Platform.environment,
        },
        columns: terminal.viewWidth,
        rows: terminal.viewHeight,
      );

      final session = _TerminalSession(
        terminal: terminal,
        controller: controller,
        pty: pty,
      );
      _sessions[workspaceId] = session;

      session.sub = pty.output
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true))
          .listen(terminal.write);

      terminal.onOutput = (data) {
        pty.write(const Utf8Encoder().convert(data));
      };

      // PTY API is resize(rows, cols); xterm onResize gives (width, height, …).
      terminal.onResize = (w, h, pw, ph) {
        pty.resize(h, w);
      };

      _eventsController.add(PtySessionEvent(
        workspaceId: workspaceId,
        status: TerminalRunStatus.running,
      ));

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
        _eventsController.add(PtySessionEvent(
          workspaceId: workspaceId,
          status: TerminalRunStatus.exited,
          exitCode: code,
        ));
      });
    } catch (e, st) {
      _talker.error('PTY spawn failed for workspace $workspaceId', e, st);
      // Swallow input on dead session — onOutput would otherwise hit a null pty.
      terminal.onOutput = (_) {};
      _sessions[workspaceId] = _TerminalSession(
        terminal: terminal,
        controller: controller,
      );
      terminal.write('\r\n[Failed to start shell: $e]\r\n');
      _eventsController.add(PtySessionEvent(
        workspaceId: workspaceId,
        status: TerminalRunStatus.failed,
        error: '$e',
      ));
    }

    return terminal;
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
    final entries = List<MapEntry<String, _TerminalSession>>.from(
      _sessions.entries,
    );
    _sessions.clear();
    await Future.wait(entries.map((e) => _killSession(e.value)));
    if (!_eventsController.isClosed) {
      await _eventsController.close();
    }
  }

  Future<void> _killSession(_TerminalSession session) async {
    await session.sub?.cancel();
    session.sub = null;
    session.controller.dispose();

    final pty = session.pty;
    if (pty == null) return; // spawn failed; no process to kill.
    if (session.exitCode != null) return; // already exited.

    pty.kill(ProcessSignal.sigterm);
    try {
      await pty.exitCode.timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          pty.kill(ProcessSignal.sigkill);
          return -1;
        },
      );
    } catch (_) {
      // Process may already be gone; ignore.
    }
  }

}
