import 'package:freezed_annotation/freezed_annotation.dart';

part 'pty_session_event.freezed.dart';

/// State transition emitted by `PtyDataSource.events` for a single
/// workspace PTY session. Sealed so the cubit's switch is exhaustive.
@freezed
sealed class PtySessionEvent with _$PtySessionEvent {
  const factory PtySessionEvent.running({required String workspaceId}) = PtySessionEventRunning;

  const factory PtySessionEvent.exited({required String workspaceId, required int exitCode}) = PtySessionEventExited;

  const factory PtySessionEvent.failed({required String workspaceId, required String error}) = PtySessionEventFailed;
}
