import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/chat_history_repository.dart';

@injectable
class ExportChatSession {
  ExportChatSession(this._repo);

  final ChatHistoryRepository _repo;

  Future<Either<Failure, String>> call({
    required String encodedPath,
    required String sessionId,
    required String destinationPath,
  }) => _repo.exportSession(encodedPath: encodedPath, sessionId: sessionId, destinationPath: destinationPath);
}
