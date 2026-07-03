import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/git_worktree.dart';
import '../repositories/git_repository.dart';

@injectable
class DetectGitRepo {
  DetectGitRepo(this._repository);
  final GitRepository _repository;

  Future<Either<Failure, GitRepoInfo?>> call({required String path}) => _repository.detect(path: path);
}
