import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:g_claude/features/app_logs/data/datasources/app_logs_database.dart';
import 'package:g_claude/features/claude/data/datasources/sessions_database.dart';

/// Returns an [AppLogsDatabase] backed by an in-memory SQLite, ready for tests.
///
/// Foreign keys are enabled by the app's migration `beforeOpen`, so cascade
/// deletes mirror production behavior. Always wrap usage with `addTearDown`
/// so the executor is closed and the test isolate stays clean:
///
/// ```dart
/// final db = makeAppLogsDb();
/// addTearDown(db.close);
/// ```
AppLogsDatabase makeAppLogsDb() {
  return AppLogsDatabase(NativeDatabase.memory());
}

/// Returns a [SessionsDatabase] backed by an in-memory SQLite. Required for
/// any test exercising FTS5 search or sessions index queries.
SessionsDatabase makeSessionsDb() {
  return SessionsDatabase(NativeDatabase.memory());
}

/// Helper: drains a stream into a list, useful when testing watch* methods.
Future<List<T>> collect<T>(Stream<T> stream, {int take = 1}) async {
  return await stream.take(take).toList();
}

/// Re-exported for tests that need to build raw queries against drift.
typedef DriftDatabase = GeneratedDatabase;
