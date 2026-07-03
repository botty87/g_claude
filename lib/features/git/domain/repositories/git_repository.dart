import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/git_worktree.dart';

abstract interface class GitRepository {
  /// Returns repo info when [path] is inside a git repo, `Right(null)` when it
  /// is a plain folder.
  Future<Either<Failure, GitRepoInfo?>> detect({required String path});

  Future<Either<Failure, List<GitWorktree>>> listWorktrees({required String repoRoot});
}
