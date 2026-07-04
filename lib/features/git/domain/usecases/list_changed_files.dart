import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/git_diff_file.dart';
import '../repositories/git_diff_repository.dart';

@injectable
class ListChangedFiles {
  ListChangedFiles(this._repository);
  final GitDiffRepository _repository;

  Future<Either<Failure, List<GitDiffFile>>> call({required String cwd}) => _repository.listChangedFiles(cwd: cwd);
}
