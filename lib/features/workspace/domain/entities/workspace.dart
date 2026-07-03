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
    // Git worktree metadata, populated at open time (never persisted — re-derived
    // on restore). `repoRoot` is the shared main-worktree root and is the key
    // that groups all worktrees of the same repo. Null for a plain folder.
    String? repoRoot,
    String? branch,
  }) = _Workspace;
}
