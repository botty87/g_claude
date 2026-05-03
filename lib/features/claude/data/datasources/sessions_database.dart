import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

part 'sessions_database.g.dart';

@DataClassName('SessionRow')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get encodedPath => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  DateTimeColumn get firstMessageAt => dateTime()();
  DateTimeColumn get lastMessageAt => dateTime()();
  IntColumn get messageCount => integer().withDefault(const Constant(0))();
  IntColumn get fileSize => integer()();
  DateTimeColumn get fileMtime => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Sessions])
class SessionsDatabase extends _$SessionsDatabase {
  SessionsDatabase(super.e);

  factory SessionsDatabase.openInDirectory(Directory dir) {
    final file = File(p.join(dir.path, 'g_claude_sessions.sqlite'));
    return SessionsDatabase(NativeDatabase.createInBackground(file));
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
            'CREATE INDEX idx_sessions_workspace_lastmsg ON sessions(workspace_id, last_message_at DESC)',
          );
        },
      );
}
