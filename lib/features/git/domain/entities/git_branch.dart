import 'package:freezed_annotation/freezed_annotation.dart';

part 'git_branch.freezed.dart';

/// A local git branch as reported by
/// `git branch --list --format='%(refname:short)\t%(worktreepath)'`.
///
/// [worktreePath] is the absolute path of the worktree that has this branch
/// checked out, or null when no worktree holds it. This matters for creating a
/// new worktree: `git worktree add <path> <branch>` refuses a branch already
/// checked out elsewhere, so only branches with [hasWorktree] == false are
/// valid checkout candidates.
@freezed
abstract class GitBranch with _$GitBranch {
  const factory GitBranch({required String name, String? worktreePath}) = _GitBranch;

  const GitBranch._();

  bool get hasWorktree => worktreePath != null && worktreePath!.isNotEmpty;
}
