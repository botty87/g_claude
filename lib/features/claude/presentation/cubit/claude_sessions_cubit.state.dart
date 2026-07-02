part of 'claude_sessions_cubit.dart';

enum ClaudeRunStatus { idle, connecting, running, compacting, error, sessionDead }

@freezed
abstract class ClaudeSessionData with _$ClaudeSessionData {
  const factory ClaudeSessionData({
    @Default('') String tabId,
    @Default(<ClaudeMessage>[]) List<ClaudeMessage> messages,
    @Default(ClaudeRunStatus.idle) ClaudeRunStatus runStatus,
    required ClaudeModel model,
    required ClaudePermissionMode permissionMode,
    required ClaudeEffort effort,
    required ClaudeThinkingMode thinkingMode,
    String? claudeSessionId,
    Failure? lastError,
    @Default(<String>[]) List<String> stderrTail,
    @Default(<String>[]) List<String> availableSkills,
    @Default(<String>{}) Set<String> disabledMcpServers,
    @Default(ChatInputDraft.empty) ChatInputDraft inputDraft,
    @Default(false) bool allowAlwaysActive,
    QueuedPrompt? queuedPrompt,
    SessionUsage? usage,
  }) = _ClaudeSessionData;
}

@freezed
abstract class WorkspaceSessions with _$WorkspaceSessions {
  const WorkspaceSessions._();
  const factory WorkspaceSessions({
    @Default(<ClaudeSessionData>[]) List<ClaudeSessionData> tabs,
    @Default('') String activeTabId,
  }) = _WorkspaceSessions;

  ClaudeSessionData? get activeTab {
    for (final t in tabs) {
      if (t.tabId == activeTabId) return t;
    }
    return tabs.isEmpty ? null : tabs.first;
  }

  ClaudeSessionData? tabById(String tabId) {
    for (final t in tabs) {
      if (t.tabId == tabId) return t;
    }
    return null;
  }
}

@freezed
abstract class ClaudeSessionsState with _$ClaudeSessionsState {
  const ClaudeSessionsState._();

  const factory ClaudeSessionsState({
    @Default(<String, WorkspaceSessions>{}) Map<String, WorkspaceSessions> workspaces,
  }) = _ClaudeSessionsState;

  ClaudeSessionData? sessionFor(String? workspaceId) {
    if (workspaceId == null) return null;
    return workspaces[workspaceId]?.activeTab;
  }

  WorkspaceSessions? tabsFor(String? id) => id == null ? null : workspaces[id];

  List<ClaudeSessionData> tabsList(String? id) => id == null ? const [] : (workspaces[id]?.tabs ?? const []);
}
