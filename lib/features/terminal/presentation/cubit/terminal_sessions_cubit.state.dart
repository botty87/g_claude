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
  }) = _TerminalSessionInfo;
}

@freezed
abstract class TerminalSessionsState with _$TerminalSessionsState {
  const factory TerminalSessionsState({
    @Default(<String, TerminalSessionInfo>{})
    Map<String, TerminalSessionInfo> sessions,
  }) = _TerminalSessionsState;
}
