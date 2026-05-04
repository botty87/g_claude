import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/app_logs_repository.dart';

@injectable
class PruneOldSessions {
  PruneOldSessions(this._repo);
  final AppLogsRepository _repo;

  Future<Either<Failure, int>> call({required Duration maxAge}) =>
      _repo.pruneOlderThan(maxAge);
}
