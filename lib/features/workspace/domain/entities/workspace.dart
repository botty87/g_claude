import 'package:freezed_annotation/freezed_annotation.dart';

part 'workspace.freezed.dart';

typedef WorkspaceId = String;
typedef SessionId = String;

@freezed
abstract class Workspace with _$Workspace {
  const factory Workspace({
    required WorkspaceId id,
    required String path,
    required String name,
    String? claudeMd,
    @Default(<SessionId>[]) List<SessionId> sessionIds,
    SessionId? activeSessionId,
    required DateTime openedAt,
  }) = _Workspace;
}
