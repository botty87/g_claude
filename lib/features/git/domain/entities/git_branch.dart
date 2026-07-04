import 'package:freezed_annotation/freezed_annotation.dart';

part 'git_branch.freezed.dart';

/// A git branch — local or remote-tracking — as reported by
/// `git for-each-ref` over `refs/heads` and `refs/remotes` (see [isRemote]).
///
/// [worktreePath] is the absolute path of the worktree that has this branch
/// checked out, or null when no worktree holds it. This matters for creating a
/// new worktree: `git worktree add <path> <branch>` refuses a branch already
/// checked out elsewhere, so only branches with [hasWorktree] == false are
/// valid checkout candidates.
///
/// [isRemote] flags a remote-tracking branch (`origin/main`, from
/// `refs/remotes/*`): it is never checked out ([hasWorktree] is always false)
/// but is valid as the *base* of a new local branch
/// (`git worktree add -b <local> <path> <origin/remote>`).
@freezed
abstract class GitBranch with _$GitBranch {
  const factory GitBranch({required String name, String? worktreePath, @Default(false) bool isRemote}) = _GitBranch;

  const GitBranch._();

  bool get hasWorktree => worktreePath != null && worktreePath!.isNotEmpty;
}
