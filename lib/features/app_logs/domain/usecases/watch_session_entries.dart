import 'package:injectable/injectable.dart';

import '../entities/app_log_entry.dart';
import '../repositories/app_logs_repository.dart';

@injectable
class WatchSessionEntries {
  WatchSessionEntries(this._repo);
  final AppLogsRepository _repo;

  Stream<List<AppLogEntry>> call({required int sessionId, Set<AppLogLevel> levels = const {}, String? search}) =>
      _repo.watchEntries(sessionId: sessionId, levels: levels, search: search);
}
