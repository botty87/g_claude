import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/file_diff.dart';
import '../entities/git_diff_file.dart';
import '../repositories/git_diff_repository.dart';

@injectable
class ReadFileDiff {
  ReadFileDiff(this._repository);
  final GitDiffRepository _repository;

  Future<Either<Failure, FileDiff>> call({required String cwd, required GitDiffFile file}) =>
      _repository.readFileDiff(cwd: cwd, file: file);
}
