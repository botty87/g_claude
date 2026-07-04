import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/git_branch.dart';
import '../repositories/git_repository.dart';

@injectable
class ListBranches {
  ListBranches(this._repository);
  final GitRepository _repository;

  Future<Either<Failure, List<GitBranch>>> call({required String repoRoot}) =>
      _repository.listBranches(repoRoot: repoRoot);
}
