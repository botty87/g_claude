import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/git_repository.dart';

@injectable
class RemoveWorktree {
  RemoveWorktree(this._repository);
  final GitRepository _repository;

  Future<Either<Failure, void>> call({required String repoRoot, required String worktreePath, bool force = false}) =>
      _repository.removeWorktree(repoRoot: repoRoot, worktreePath: worktreePath, force: force);
}
