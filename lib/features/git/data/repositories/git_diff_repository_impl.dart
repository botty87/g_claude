import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/file_diff.dart';
import '../../domain/entities/git_diff_file.dart';
import '../../domain/repositories/git_diff_repository.dart';
import '../datasources/git_diff_datasource.dart';
import '../datasources/git_worktree_datasource.dart' show GitException;

@LazySingleton(as: GitDiffRepository)
class GitDiffRepositoryImpl implements GitDiffRepository {
  GitDiffRepositoryImpl(this._ds);
  final GitDiffDataSource _ds;

  @override
  Future<Either<Failure, List<GitDiffFile>>> listChangedFiles({required String cwd}) async {
    try {
      return Right(await _ds.listChangedFiles(cwd));
    } on GitException catch (e) {
      return Left(SubprocessFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure('git diff list changed files failed: $e'));
    }
  }

  @override
  Future<Either<Failure, FileDiff>> readFileDiff({required String cwd, required GitDiffFile file}) async {
    try {
      return Right(await _ds.readFileDiff(cwd, file));
    } on GitException catch (e) {
      return Left(SubprocessFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure('git diff read file diff failed: $e'));
    }
  }
}
