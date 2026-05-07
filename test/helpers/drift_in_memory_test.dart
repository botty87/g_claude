// Smoke test for the drift in-memory helper.
//
// Verifies the helper instantiates a usable database and that schema creation
// runs (we can write and read a row). If this fails, every B2-onward test
// that exercises FTS5 search or app-logs persistence will fail too — so this
// gate is intentionally cheap and frontline.

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/app_logs/data/datasources/app_logs_database.dart';

import 'drift_in_memory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('makeAppLogsDb', () {
    test('returns a working AppLogsDatabase: insert + select round-trips', () async {
      final db = makeAppLogsDb();
      addTearDown(db.close);

      final id = await db
          .into(db.appSessions)
          .insert(AppSessionsCompanion.insert(startedAt: DateTime.utc(2026, 1, 1), platform: 'test'));

      final row = await (db.select(db.appSessions)..where((s) => s.id.equals(id))).getSingle();
      expect(row.platform, 'test');
      // Drift serializes DateTime as epoch microseconds and reconstructs as
      // local time on read. Same instant, but the UTC flag is lost — assert on
      // instant equality, not `==` (which compares both moment and isUtc).
      expect(
        row.startedAt.isAtSameMomentAs(DateTime.utc(2026, 1, 1)),
        isTrue,
        reason: 'Persisted instant must round-trip even though the UTC flag is dropped.',
      );
    });

    test('cascade-deletes log entries when a session is removed', () async {
      final db = makeAppLogsDb();
      addTearDown(db.close);

      final sessionId = await db
          .into(db.appSessions)
          .insert(AppSessionsCompanion.insert(startedAt: DateTime.utc(2026, 1, 1), platform: 'test'));
      await db
          .into(db.logEntries)
          .insert(
            LogEntriesCompanion.insert(
              sessionId: sessionId,
              time: DateTime.utc(2026, 1, 1),
              level: 'info',
              message: 'hello',
            ),
          );

      await (db.delete(db.appSessions)..where((s) => s.id.equals(sessionId))).go();

      final remaining = await db.select(db.logEntries).get();
      expect(
        remaining,
        isEmpty,
        reason: 'FK cascade must remove orphan log_entries when the parent session is deleted.',
      );
    });
  });

  group('makeSessionsDb', () {
    test('returns a working SessionsDatabase with sessions_fts virtual table', () async {
      final db = makeSessionsDb();
      addTearDown(db.close);

      // The migration creates the FTS5 virtual table at onCreate. If the helper
      // skipped migrations, this raw query would fail with "no such table".
      final result = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type='table' AND name='sessions_fts'")
          .get();
      expect(result, hasLength(1));
    });
  });
}
