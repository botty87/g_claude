import 'dart:async';

import 'package:xterm/xterm.dart';

enum TerminalRunStatus { starting, running, exited, failed }

class PtySessionEvent {
  const PtySessionEvent({
    required this.workspaceId,
    required this.status,
    this.exitCode,
    this.error,
  });

  final String workspaceId;
  final TerminalRunStatus status;
  final int? exitCode;
  final String? error;
}

abstract class PtyDataSource {
  /// Resolves the shell binary from `$SHELL`, with `/bin/zsh` fallback.
  String detectShell();

  /// Spawn or get existing PTY for workspace. Idempotent.
  /// Returns the xterm Terminal handle for UI binding.
  Terminal getOrCreate({required String workspaceId, required String cwd});

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
