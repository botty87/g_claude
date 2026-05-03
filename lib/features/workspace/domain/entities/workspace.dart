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
    required DateTime openedAt,
  }) = _Workspace;
}
