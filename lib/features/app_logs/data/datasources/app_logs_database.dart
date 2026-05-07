import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

part 'app_logs_database.g.dart';

@DataClassName('AppSessionRow')
class AppSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get appVersion => text().nullable()();
  TextColumn get platform => text()();
  IntColumn get errorCount => integer().withDefault(const Constant(0))();
  IntColumn get warningCount => integer().withDefault(const Constant(0))();
  IntColumn get totalCount => integer().withDefault(const Constant(0))();
}

@DataClassName('LogEntryRow')
class LogEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(AppSessions, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get time => dateTime()();
  TextColumn get level => text()();
  TextColumn get title => text().nullable()();
  TextColumn get message => text()();
  TextColumn get exception => text().nullable()();
  TextColumn get stackTrace => text().nullable()();
}

@DriftDatabase(tables: [AppSessions, LogEntries])
class AppLogsDatabase extends _$AppLogsDatabase {
  AppLogsDatabase(super.e);

  factory AppLogsDatabase.openInDirectory(Directory dir) {
    final file = File(p.join(dir.path, 'g_claude_app_logs.sqlite'));
    return AppLogsDatabase(NativeDatabase.createInBackground(file));
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // FK constraints are OFF by default in SQLite. Required for cascade
      // deletes on log_entries when a session is removed.
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onCreate: (m) async {
      await m.createAll();
      await customStatement('CREATE INDEX idx_log_entries_session_time ON log_entries(session_id, time)');
      await customStatement('CREATE INDEX idx_app_sessions_started ON app_sessions(started_at DESC)');
    },
  );
}
