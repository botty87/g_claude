import 'dart:async';

import 'package:xterm/xterm.dart';

import '../../domain/entities/pty_session_event.dart';

export '../../domain/entities/pty_session_event.dart';
export '../../domain/entities/terminal_run_status.dart';

abstract class PtyDataSource {
  /// Resolves the shell binary from `$SHELL`, with `/bin/zsh` fallback.
  String detectShell();

  /// Spawn or get existing PTY for workspace. Idempotent.
  /// The xterm Terminal handle is retrieved separately via [terminalFor];
  /// callers never need it directly here.
  void getOrCreate({required String workspaceId, required String cwd});

  /// Returns the Terminal for an existing session, or null.
  Terminal? terminalFor(String workspaceId);

  /// Returns the TerminalController for an existing session, or null.
  TerminalController? controllerFor(String workspaceId);

  /// Stream of state transitions for a session.
  /// Subscribed by the cubit to update its metadata state.
  Stream<PtySessionEvent> get events;

  /// Kill PTY and remove from internal map. Idempotent.
  Future<void> dispose(String workspaceId);

  /// Kill all PTYs (called by cubit.close()).
  Future<void> disposeAll();
}
