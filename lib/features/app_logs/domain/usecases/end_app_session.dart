import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/app_logs_repository.dart';

@injectable
class EndAppSession {
  EndAppSession(this._repo);
  final AppLogsRepository _repo;

  Future<Either<Failure, void>> call() => _repo.endSession();
}
