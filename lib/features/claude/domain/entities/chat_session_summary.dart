import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../workspace/domain/entities/workspace.dart';

part 'chat_session_summary.freezed.dart';

@freezed
abstract class ChatSessionSummary with _$ChatSessionSummary {
  const factory ChatSessionSummary({
    required String id,
    required WorkspaceId workspaceId,
    required String encodedPath,
    required String title,
    required DateTime firstMessageAt,
    required DateTime lastMessageAt,
    required int messageCount,
  }) = _ChatSessionSummary;
}
