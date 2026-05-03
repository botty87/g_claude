import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../repositories/chat_history_repository.dart';

@injectable
class RefreshSessionsIndex {
  RefreshSessionsIndex(this._repo);

  final ChatHistoryRepository _repo;

  Future<Either<Failure, void>> call({
    required WorkspaceId workspaceId,
    required String workspaceCwd,
  }) =>
      _repo.refreshIndex(workspaceId: workspaceId, workspaceCwd: workspaceCwd);
}
