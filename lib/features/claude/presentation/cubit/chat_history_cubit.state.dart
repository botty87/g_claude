part of 'chat_history_cubit.dart';

enum HistoryStatus { idle, loading, error }

@freezed
abstract class WorkspaceHistory with _$WorkspaceHistory {
  const factory WorkspaceHistory({
    @Default(<ChatSessionSummary>[]) List<ChatSessionSummary> sessions,
    @Default(HistoryStatus.idle) HistoryStatus status,
    String? selectedId,
    @Default(<ClaudeMessage>[]) List<ClaudeMessage> previewMessages,
    @Default(false) bool previewLoading,
    @Default('') String query,
    Failure? lastError,
  }) = _WorkspaceHistory;
}

@freezed
abstract class ChatHistoryState with _$ChatHistoryState {
  const ChatHistoryState._();

  const factory ChatHistoryState({
    @Default(<String, WorkspaceHistory>{}) Map<String, WorkspaceHistory> byWorkspace,
  }) = _ChatHistoryState;

  WorkspaceHistory? historyFor(String? workspaceId) {
    if (workspaceId == null) return null;
    return byWorkspace[workspaceId];
  }
}
