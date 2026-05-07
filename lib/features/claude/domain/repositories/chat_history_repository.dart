import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../entities/chat_session_summary.dart';
import '../entities/claude_message.dart';

abstract interface class ChatHistoryRepository {
  Future<Either<Failure, List<ChatSessionSummary>>> listSessions(WorkspaceId workspaceId);

  Future<Either<Failure, List<ClaudeMessage>>> loadMessages({required String encodedPath, required String sessionId});

  Future<Either<Failure, void>> refreshIndex({required WorkspaceId workspaceId, required String workspaceCwd});

  Future<Either<Failure, void>> deleteSession({required String sessionId, required String encodedPath});

  Future<Either<Failure, String>> exportSession({
    required String encodedPath,
    required String sessionId,
    required String destinationPath,
  });

  Future<Either<Failure, List<ChatSessionSummary>>> searchSessions(WorkspaceId workspaceId, String query);
}
