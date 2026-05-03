import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../entities/chat_session_summary.dart';
import '../repositories/chat_history_repository.dart';

@injectable
class SearchSessions {
  SearchSessions(this._repo);

  final ChatHistoryRepository _repo;

  Future<Either<Failure, List<ChatSessionSummary>>> call(
    WorkspaceId workspaceId,
    String query,
  ) =>
      _repo.searchSessions(workspaceId, query);
}
