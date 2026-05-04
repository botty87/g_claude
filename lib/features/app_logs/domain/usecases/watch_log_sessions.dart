import 'package:injectable/injectable.dart';

import '../entities/app_log_session.dart';
import '../repositories/app_logs_repository.dart';

@injectable
class WatchLogSessions {
  WatchLogSessions(this._repo);
  final AppLogsRepository _repo;

  Stream<List<AppLogSession>> call() => _repo.watchSessions();
}
