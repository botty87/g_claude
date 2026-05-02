import 'package:freezed_annotation/freezed_annotation.dart';

part 'claude_message.freezed.dart';

enum ClaudeToolStatus { running, completed, error }

@freezed
sealed class ClaudeMessage with _$ClaudeMessage {
  const ClaudeMessage._();

  const factory ClaudeMessage.user({
    required String id,
    required String text,
    required DateTime createdAt,
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
}
