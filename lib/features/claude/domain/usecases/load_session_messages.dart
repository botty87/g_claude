import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/claude_message.dart';
import '../repositories/chat_history_repository.dart';

@injectable
class LoadSessionMessages {
  LoadSessionMessages(this._repo);

  final ChatHistoryRepository _repo;

  Future<Either<Failure, List<ClaudeMessage>>> call({
    required String encodedPath,
    required String sessionId,
  }) =>
      _repo.loadMessages(encodedPath: encodedPath, sessionId: sessionId);
}
