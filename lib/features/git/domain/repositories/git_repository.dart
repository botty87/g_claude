import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/git_branch.dart';
import '../entities/git_folder_inspection.dart';
import '../entities/git_worktree.dart';

abstract interface class GitRepository {
  /// Returns repo info when [path] is inside a git repo, `Right(null)` when it
  /// is a plain folder.
  Future<Either<Failure, GitRepoInfo?>> detect({required String path});

  /// Inspects [path] (git kind, branch, uncommitted changes) for a preview
  /// before opening it as a workspace.
  Future<Either<Failure, GitFolderInspection>> inspect({required String path});

  Future<Either<Failure, List<GitWorktree>>> listWorktrees({required String repoRoot});

  Future<Either<Failure, void>> removeWorktree({
    required String repoRoot,
    required String worktreePath,
    bool force = false,
  });

  Future<Either<Failure, void>> deleteBranch({required String repoRoot, required String branch, bool force = false});

  /// Creates a new worktree: either a new branch ([newBranch], optionally from
  /// [baseRef]) or an existing branch ([checkoutBranch]).
  Future<Either<Failure, void>> addWorktree({
    required String repoRoot,
    required String worktreePath,
    String? newBranch,
    String? baseRef,
    String? checkoutBranch,
  });

  Future<Either<Failure, List<GitBranch>>> listBranches({required String repoRoot});
}
