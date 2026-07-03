import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/git_worktree.dart';
import '../repositories/git_repository.dart';

@injectable
class ListWorktrees {
  ListWorktrees(this._repository);
  final GitRepository _repository;

  Future<Either<Failure, List<GitWorktree>>> call({required String repoRoot}) =>
      _repository.listWorktrees(repoRoot: repoRoot);
}
