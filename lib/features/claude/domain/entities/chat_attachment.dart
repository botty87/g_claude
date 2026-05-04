import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_attachment.freezed.dart';

enum ChatAttachmentKind { file, directory, fileRange }

@freezed
abstract class ChatAttachment with _$ChatAttachment {
  const factory ChatAttachment({
    required String path,
    required String displayName,
    required ChatAttachmentKind kind,
    int? startLine,
    int? endLine,
    String? snippet,
  }) = _ChatAttachment;
}
