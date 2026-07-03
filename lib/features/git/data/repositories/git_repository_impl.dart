import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/git_worktree.dart';
import '../../domain/repositories/git_repository.dart';
import '../datasources/git_worktree_datasource.dart';

@LazySingleton(as: GitRepository)
class GitRepositoryImpl implements GitRepository {
  GitRepositoryImpl(this._ds);
  final GitWorktreeDataSource _ds;

  @override
  Future<Either<Failure, GitRepoInfo?>> detect({required String path}) async {
    try {
      return Right(await _ds.detect(path));
    } catch (e) {
      return Left(UnexpectedFailure('git detect failed: $e'));
    }
  }

  @override
  Future<Either<Failure, List<GitWorktree>>> listWorktrees({required String repoRoot}) async {
    try {
      return Right(await _ds.listWorktrees(repoRoot));
    } on GitException catch (e) {
      return Left(SubprocessFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure('git worktree list failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeWorktree({
    required String repoRoot,
    required String worktreePath,
    bool force = false,
  }) async {
    try {
      await _ds.removeWorktree(repoRoot, worktreePath, force: force);
      return const Right(null);
    } on GitException catch (e) {
      return Left(SubprocessFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure('git worktree remove failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBranch({
    required String repoRoot,
    required String branch,
    bool force = false,
  }) async {
    try {
      await _ds.deleteBranch(repoRoot, branch, force: force);
      return const Right(null);
    } on GitException catch (e) {
      return Left(SubprocessFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure('git branch delete failed: $e'));
    }
  }
}
