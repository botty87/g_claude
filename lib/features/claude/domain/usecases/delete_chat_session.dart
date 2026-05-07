import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/chat_history_repository.dart';

@injectable
class DeleteChatSession {
  DeleteChatSession(this._repo);

  final ChatHistoryRepository _repo;

  Future<Either<Failure, void>> call({required String sessionId, required String encodedPath}) =>
      _repo.deleteSession(sessionId: sessionId, encodedPath: encodedPath);
}
