import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/either.dart';
import '../../domain/entities/app_log_entry.dart';
import '../../domain/entities/app_log_session.dart';
import '../../domain/repositories/app_logs_repository.dart';
import '../datasources/app_logs_database.dart';

@LazySingleton(as: AppLogsRepository)
class AppLogsRepositoryImpl implements AppLogsRepository {
  AppLogsRepositoryImpl(this._db);
  final AppLogsDatabase _db;

  int? _currentSessionId;

  @override
  int? get currentSessionId => _currentSessionId;

  @override
  Future<Either<Failure, AppLogSession>> startSession({
    String? appVersion,
    required String platform,
  }) async {
    try {
      final id = await _db.into(_db.appSessions).insert(
            AppSessionsCompanion.insert(
              startedAt: DateTime.now(),
              platform: platform,
              appVersion: Value(appVersion),
            ),
          );
      _currentSessionId = id;
      final row = await (_db.select(_db.appSessions)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      return Right(_toSession(row));
    } catch (e) {
      return Left(UnexpectedFailure('startSession: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> endSession() async {
    final id = _currentSessionId;
    if (id == null) return const Right(null);
    try {
      await (_db.update(_db.appSessions)..where((t) => t.id.equals(id)))
          .write(AppSessionsCompanion(endedAt: Value(DateTime.now())));
      _currentSessionId = null;
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure('endSession: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> appendEntries(
    List<AppLogEntryDraft> drafts,
  ) async {
    final sessionId = _currentSessionId;
    if (sessionId == null || drafts.isEmpty) return const Right(null);
    try {
      var errors = 0;
      var warnings = 0;
      await _db.transaction(() async {
        await _db.batch((b) {
          b.insertAll(
            _db.logEntries,
            drafts.map((d) {
              if (d.level == AppLogLevel.error ||
                  d.level == AppLogLevel.critical) {
                errors++;
              }
              if (d.level == AppLogLevel.warning) {
                warnings++;
              }
              return LogEntriesCompanion.insert(
                sessionId: sessionId,
                time: d.time,
                level: appLogLevelToString(d.level),
                title: Value(d.title),
                message: d.message,
                exception: Value(d.exception),
                stackTrace: Value(d.stackTrace),
              );
            }).toList(),
          );
        });
        // Use customUpdate so drift notifies stream watchers on appSessions.
        await _db.customUpdate(
          'UPDATE app_sessions SET total_count = total_count + ?, '
          'error_count = error_count + ?, warning_count = warning_count + ? '
          'WHERE id = ?',
          variables: [
            Variable.withInt(drafts.length),
            Variable.withInt(errors),
            Variable.withInt(warnings),
            Variable.withInt(sessionId),
          ],
          updates: {_db.appSessions},
        );
      });
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure('appendEntries: $e'));
    }
  }

  @override
  Stream<List<AppLogSession>> watchSessions() {
    final q = _db.select(_db.appSessions)
      ..orderBy([
        (t) => OrderingTerm(
              expression: t.startedAt,
              mode: OrderingMode.desc,
            ),
      ]);
    return q.watch().map((rows) => rows.map(_toSession).toList());
  }

  @override
  Stream<List<AppLogEntry>> watchEntries({
    required int sessionId,
    Set<AppLogLevel> levels = const {},
    String? search,
  }) {
    final q = _db.select(_db.logEntries)
      ..where((t) => t.sessionId.equals(sessionId));
    if (levels.isNotEmpty) {
      final names = levels.map(appLogLevelToString).toList();
      q.where((t) => t.level.isIn(names));
    }
    final s = search?.trim();
    if (s != null && s.isNotEmpty) {
      final pattern = '%$s%';
      q.where((t) => t.message.like(pattern) | t.title.like(pattern));
    }
    q.orderBy([
      (t) => OrderingTerm(expression: t.time, mode: OrderingMode.asc),
    ]);
    return q.watch().map((rows) => rows.map(_toEntry).toList());
  }

  @override
  Future<Either<Failure, void>> deleteSession(int sessionId) async {
    try {
      await (_db.delete(_db.appSessions)
            ..where((t) => t.id.equals(sessionId)))
          .go();
      if (_currentSessionId == sessionId) _currentSessionId = null;
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure('deleteSession: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAll() async {
    try {
      await _db.delete(_db.appSessions).go();
      _currentSessionId = null;
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure('deleteAll: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> pruneOlderThan(Duration maxAge) async {
    try {
      final cutoff = DateTime.now().subtract(maxAge);
      final keepCurrent = _currentSessionId;
      final q = _db.delete(_db.appSessions)
        ..where((t) {
          var cond = t.startedAt.isSmallerThanValue(cutoff);
          if (keepCurrent != null) {
            cond = cond & t.id.equals(keepCurrent).not();
          }
          return cond;
        });
      final n = await q.go();
      return Right(n);
    } catch (e) {
      return Left(UnexpectedFailure('pruneOlderThan: $e'));
    }
  }

  AppLogSession _toSession(AppSessionRow r) => AppLogSession(
        id: r.id,
        startedAt: r.startedAt,
        endedAt: r.endedAt,
        appVersion: r.appVersion,
        platform: r.platform,
        errorCount: r.errorCount,
        warningCount: r.warningCount,
        totalCount: r.totalCount,
      );

  AppLogEntry _toEntry(LogEntryRow r) => AppLogEntry(
        id: r.id,
        sessionId: r.sessionId,
        time: r.time,
        level: parseAppLogLevel(r.level),
        title: r.title,
        message: r.message,
        exception: r.exception,
        stackTrace: r.stackTrace,
      );
}
