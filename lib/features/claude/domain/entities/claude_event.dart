import 'package:freezed_annotation/freezed_annotation.dart';

part 'claude_event.freezed.dart';

/// Normalized stream events emitted by the `claude -p` subprocess.
///
/// Mirrors the canonical event types used by clui-cc, adapted to Dart sealed
/// unions. The data layer parses raw NDJSON into [ClaudeEvent] before exposing
/// it to the domain.
@freezed
abstract class ClaudePluginInfo with _$ClaudePluginInfo {
  const factory ClaudePluginInfo({
    required String name,
    required String path,
    String? source,
  }) = _ClaudePluginInfo;
}

@freezed
abstract class AskUserQuestionOption with _$AskUserQuestionOption {
  const factory AskUserQuestionOption({
    required String label,
    @Default('') String description,
  }) = _AskUserQuestionOption;
}

@freezed
abstract class AskUserQuestionItem with _$AskUserQuestionItem {
  const factory AskUserQuestionItem({
    required String question,
    @Default('') String header,
    @Default(false) bool multiSelect,
    @Default(<AskUserQuestionOption>[]) List<AskUserQuestionOption> options,
  }) = _AskUserQuestionItem;
}

@freezed
sealed class ClaudeEvent with _$ClaudeEvent {
  /// `system/init` — emitted at session start. Carries the `session_id`
  /// (needed for `--resume`) and the model actually selected by the CLI.
  const factory ClaudeEvent.sessionInit({
    required String sessionId,
    required String model,
    @Default(<String>[]) List<String> tools,
    @Default(<String>[]) List<String> skills,
    @Default(<String>[]) List<String> slashCommands,
    @Default(<ClaudePluginInfo>[]) List<ClaudePluginInfo> plugins,
  }) = ClaudeEventSessionInit;

  /// Streaming text delta for the current assistant message.
  const factory ClaudeEvent.textChunk({
    required String text,
  }) = ClaudeEventTextChunk;

  /// A tool invocation has started.
  const factory ClaudeEvent.toolCall({
    required String toolName,
    required String toolId,
    required int index,
  }) = ClaudeEventToolCall;

  /// Partial JSON input being streamed for a tool call.
  const factory ClaudeEvent.toolCallUpdate({
    required String toolId,
    required String partialInput,
  }) = ClaudeEventToolCallUpdate;

  /// A tool invocation finished receiving its full input.
  const factory ClaudeEvent.toolCallComplete({
    required int index,
    String? toolId,
    Map<String, dynamic>? input,
  }) = ClaudeEventToolCallComplete;

  /// Tool execution finished — output / error from the tool itself.
  const factory ClaudeEvent.toolResult({
    required String toolUseId,
    required String content,
    @Default(false) bool isError,
  }) = ClaudeEventToolResult;

  /// Full assistant message after a content block has been assembled.
  const factory ClaudeEvent.assistantMessage({
    required String text,
  }) = ClaudeEventAssistantMessage;

  /// Run finished successfully.
  const factory ClaudeEvent.taskComplete({
    String? result,
    double? costUsd,
    int? durationMs,
    int? numTurns,
  }) = ClaudeEventTaskComplete;

  /// Subprocess emitted an error result.
  const factory ClaudeEvent.errorEvent({
    required String message,
  }) = ClaudeEventErrorEvent;

  /// Subprocess hit a rate limit.
  const factory ClaudeEvent.rateLimit({
    required String status,
    int? resetsAt,
  }) = ClaudeEventRateLimit;

  /// The subprocess exited (clean or unexpected).
  const factory ClaudeEvent.sessionDead({
    int? exitCode,
    @Default(<String>[]) List<String> stderrTail,
  }) = ClaudeEventSessionDead;

  /// Claude emitted the `AskUserQuestion` tool — needs an interactive answer
  /// from the user that we'll send back as a `tool_result`.
  const factory ClaudeEvent.askUserQuestion({
    required String toolUseId,
    required List<AskUserQuestionItem> questions,
  }) = ClaudeEventAskUserQuestion;

  /// PreToolUse hook is asking the user to approve a tool invocation. The
  /// permission server is holding the HTTP response open until the user
  /// answers via [respondPermission].
  const factory ClaudeEvent.permissionRequest({
    required String requestId,
    required String toolName,
    required Map<String, dynamic> toolInput,
  }) = ClaudeEventPermissionRequest;
}
