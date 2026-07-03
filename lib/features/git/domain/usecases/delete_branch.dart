import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/git_repository.dart';

@injectable
class DeleteBranch {
  DeleteBranch(this._repository);
  final GitRepository _repository;

  Future<Either<Failure, void>> call({required String repoRoot, required String branch, bool force = false}) =>
      _repository.deleteBranch(repoRoot: repoRoot, branch: branch, force: force);
}
