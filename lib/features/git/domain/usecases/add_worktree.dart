import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/git_repository.dart';

@injectable
class AddWorktree {
  AddWorktree(this._repository);
  final GitRepository _repository;

  Future<Either<Failure, void>> call({
    required String repoRoot,
    required String worktreePath,
    String? newBranch,
    String? baseRef,
    String? checkoutBranch,
  }) => _repository.addWorktree(
    repoRoot: repoRoot,
    worktreePath: worktreePath,
    newBranch: newBranch,
    baseRef: baseRef,
    checkoutBranch: checkoutBranch,
  );
}
