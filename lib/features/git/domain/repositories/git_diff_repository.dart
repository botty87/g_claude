import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/file_diff.dart';
import '../entities/git_diff_file.dart';

abstract interface class GitDiffRepository {
  Future<Either<Failure, List<GitDiffFile>>> listChangedFiles({required String cwd});

  Future<Either<Failure, FileDiff>> readFileDiff({required String cwd, required GitDiffFile file});
}
