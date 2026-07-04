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
    // Account-wide MCP server list (from `claude mcp list` + sessionInit merge).
    // Global, not per-workspace; kept in state so the "N active" count is reactive.
    @Default(<McpServer>[]) List<McpServer> mcpServers,
  }) = _ClaudeSessionsState;

  ClaudeSessionData? sessionFor(String? workspaceId) {
    if (workspaceId == null) return null;
    return workspaces[workspaceId]?.activeTab;
  }

  WorkspaceSessions? tabsFor(String? id) => id == null ? null : workspaces[id];

  List<ClaudeSessionData> tabsList(String? id) => id == null ? const [] : (workspaces[id]?.tabs ?? const []);

  /// True when any tab of [workspaceId] has an agent run in flight — drives the
  /// per-worktree status dot in the sidebar / worktree chip.
  bool isWorkspaceRunning(String workspaceId) {
    final ws = workspaces[workspaceId];
    if (ws == null) return false;
    return ws.tabs.any(
      (t) =>
          t.runStatus == ClaudeRunStatus.running ||
          t.runStatus == ClaudeRunStatus.connecting ||
          t.runStatus == ClaudeRunStatus.compacting,
    );
  }
}
