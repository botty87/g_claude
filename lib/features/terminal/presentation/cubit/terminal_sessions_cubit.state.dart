part of 'terminal_sessions_cubit.dart';

// TerminalRunStatus is defined in pty_datasource.dart and imported by the
// cubit. It is accessible here via the `part of` relationship.

@freezed
abstract class TerminalSessionInfo with _$TerminalSessionInfo {
  const factory TerminalSessionInfo({
    required String shellPath,
    required String cwd,
    @Default(TerminalRunStatus.starting) TerminalRunStatus status,
    int? exitCode,
    String? lastError,

    /// Bumped on each `restart()`. Widgets key off this so the TerminalView
    /// rebinds its listeners against the new Terminal instance even if the
    /// status stays at `running` across the restart (fast respawn).
    @Default(0) int incarnation,
  }) = _TerminalSessionInfo;
}

@freezed
abstract class TerminalSessionsState with _$TerminalSessionsState {
  const factory TerminalSessionsState({
    @Default(<String, TerminalSessionInfo>{}) Map<String, TerminalSessionInfo> sessions,
  }) = _TerminalSessionsState;
}
