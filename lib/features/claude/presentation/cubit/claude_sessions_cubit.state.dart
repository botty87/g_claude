part of 'claude_sessions_cubit.dart';

enum ClaudeRunStatus { idle, connecting, running, error, sessionDead }

@freezed
abstract class ClaudeSessionData with _$ClaudeSessionData {
  const factory ClaudeSessionData({
    @Default(<ClaudeMessage>[]) List<ClaudeMessage> messages,
    @Default(ClaudeRunStatus.idle) ClaudeRunStatus runStatus,
    required ClaudeModel model,
    required ClaudePermissionMode permissionMode,
    String? claudeSessionId,
    Failure? lastError,
    @Default(<String>[]) List<String> stderrTail,
  }) = _ClaudeSessionData;
}

@freezed
abstract class ClaudeSessionsState with _$ClaudeSessionsState {
  const ClaudeSessionsState._();

  const factory ClaudeSessionsState({
    @Default(<String, ClaudeSessionData>{}) Map<String, ClaudeSessionData> sessions,
  }) = _ClaudeSessionsState;

  ClaudeSessionData? sessionFor(String? workspaceId) {
    if (workspaceId == null) return null;
    return sessions[workspaceId];
  }
}
