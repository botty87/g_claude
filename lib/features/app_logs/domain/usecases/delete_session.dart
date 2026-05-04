import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/app_logs_repository.dart';

@injectable
class DeleteSession {
  DeleteSession(this._repo);
  final AppLogsRepository _repo;

  Future<Either<Failure, void>> call({required int sessionId}) =>
      _repo.deleteSession(sessionId);
}
