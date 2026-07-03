import 'package:freezed_annotation/freezed_annotation.dart';

part 'git_worktree.freezed.dart';

/// A single git worktree as reported by `git worktree list --porcelain`.
///
/// [path] is normalized (absolute) so it can be matched 1:1 against a
/// `WorkspaceId` (which is itself the normalized absolute path).
@freezed
abstract class GitWorktree with _$GitWorktree {
  const factory GitWorktree({
    required String path,
    required String head,
    String? branch,
    @Default(false) bool isBare,
    @Default(false) bool isDetached,
  }) = _GitWorktree;
}

/// Result of detecting whether a path lives inside a git repository.
///
/// [repoRoot] is the main worktree root (derived from the shared
/// `--git-common-dir`), stable across all worktrees of the same repo — it is
/// the grouping key. [branch] is the branch checked out at the probed path
/// (null when HEAD is detached).
@freezed
abstract class GitRepoInfo with _$GitRepoInfo {
  const factory GitRepoInfo({required String repoRoot, String? branch}) = _GitRepoInfo;
}
