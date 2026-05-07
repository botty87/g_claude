import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/app_log_entry.dart';
import '../entities/app_log_session.dart';

abstract class AppLogsRepository {
  Future<Either<Failure, AppLogSession>> startSession({String? appVersion, required String platform});
  Future<Either<Failure, void>> endSession();
  Future<Either<Failure, void>> appendEntries(List<AppLogEntryDraft> drafts);
  Stream<List<AppLogSession>> watchSessions();
  Stream<List<AppLogEntry>> watchEntries({required int sessionId, Set<AppLogLevel> levels = const {}, String? search});
  Future<Either<Failure, void>> deleteSession(int sessionId);
  Future<Either<Failure, void>> deleteAll();
  Future<Either<Failure, int>> pruneOlderThan(Duration maxAge);
  int? get currentSessionId;
}
