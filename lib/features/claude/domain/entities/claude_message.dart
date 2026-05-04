import 'package:freezed_annotation/freezed_annotation.dart';

import 'chat_attachment.dart';
import 'claude_event.dart';

part 'claude_message.freezed.dart';

enum ClaudeToolStatus { running, completed, error }

enum ClaudePermissionDecision { allowOnce, allowAlways, deny }

@freezed
sealed class ClaudeMessage with _$ClaudeMessage {
  const ClaudeMessage._();

  const factory ClaudeMessage.user({
    required String id,
    required String text,
    required DateTime createdAt,
    @Default(<String>[]) List<String> slashTriggers,
    @Default(<ChatAttachment>[]) List<ChatAttachment> attachments,
  }) = ClaudeMessageUser;

  const factory ClaudeMessage.assistant({
    required String id,
    required String text,
    @Default(false) bool isStreaming,
    required DateTime createdAt,
  }) = ClaudeMessageAssistant;

  const factory ClaudeMessage.tool({
    required String id,
    required String toolName,
    required ClaudeToolStatus status,
    required DateTime createdAt,
    String? toolUseId,
    Map<String, dynamic>? input,
    String? output,
    @Default(false) bool isError,
  }) = ClaudeMessageTool;

  const factory ClaudeMessage.system({
    required String id,
    required String text,
    required DateTime createdAt,
  }) = ClaudeMessageSystem;

  /// Inline interactive card that asks the user to answer one or more
  /// questions emitted by Claude via the `AskUserQuestion` tool. The card
  /// stays in the message stream after submission as a record of the choice.
  const factory ClaudeMessage.askUserQuestion({
    required String id,
    required String toolUseId,
    required List<AskUserQuestionItem> questions,
    required DateTime createdAt,
    @Default(<String, String>{}) Map<String, String> answers,
    @Default(false) bool answered,
  }) = ClaudeMessageAskUserQuestion;

  /// Inline card that asks the user to approve / deny a tool invocation
  /// surfaced by the `PreToolUse` permission hook.
  const factory ClaudeMessage.permissionRequest({
    required String id,
    required String requestId,
    required String toolName,
    required Map<String, dynamic> toolInput,
    required DateTime createdAt,
    ClaudePermissionDecision? decision,
    @Default(false) bool answered,
  }) = ClaudeMessagePermissionRequest;
}
