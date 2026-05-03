import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../slash_commands/domain/entities/slash_command.dart';
import 'chat_attachment.dart';

part 'chat_input_draft.freezed.dart';

@freezed
abstract class ChatInputDraft with _$ChatInputDraft {
  const factory ChatInputDraft({
    @Default('') String text,
    @Default(<SlashCommand>[]) List<SlashCommand> selectedCommands,
    @Default(<ChatAttachment>[]) List<ChatAttachment> attachments,
  }) = _ChatInputDraft;

  static const empty = ChatInputDraft();
}
