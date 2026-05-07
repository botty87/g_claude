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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX idx_sessions_workspace_lastmsg ON sessions(workspace_id, last_message_at DESC)',
      );
      await customStatement(
        "CREATE VIRTUAL TABLE sessions_fts USING fts5("
        "session_id UNINDEXED, "
        "workspace_id UNINDEXED, "
        "body, "
        "tokenize = 'unicode61 remove_diacritics 2'"
        ")",
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await customStatement(
          "CREATE VIRTUAL TABLE sessions_fts USING fts5("
          "session_id UNINDEXED, "
          "workspace_id UNINDEXED, "
          "body, "
          "tokenize = 'unicode61 remove_diacritics 2'"
          ")",
        );
      }
    },
  );

  Future<void> upsertSessionFts({required String sessionId, required String workspaceId, required String body}) async {
    await customStatement('DELETE FROM sessions_fts WHERE session_id = ?', [sessionId]);
    await customStatement('INSERT INTO sessions_fts(session_id, workspace_id, body) VALUES (?, ?, ?)', [
      sessionId,
      workspaceId,
      body,
    ]);
  }

  Future<void> deleteSessionFts(String sessionId) async {
    await customStatement('DELETE FROM sessions_fts WHERE session_id = ?', [sessionId]);
  }

  Future<List<String>> searchFtsIds({required String workspaceId, required String query, int limit = 200}) async {
    final escaped = _escapeFtsQuery(query);
    if (escaped.isEmpty) return [];
    final rows = await customSelect(
      'SELECT session_id FROM sessions_fts '
      'WHERE workspace_id = ? AND sessions_fts MATCH ? '
      'ORDER BY rank LIMIT ?',
      variables: [Variable<String>(workspaceId), Variable<String>(escaped), Variable<int>(limit)],
      readsFrom: {},
    ).get();
    return rows.map((r) => r.read<String>('session_id')).toList();
  }

  Future<Set<String>> ftsIdsForWorkspace(String workspaceId) async {
    final rows = await customSelect(
      'SELECT session_id FROM sessions_fts WHERE workspace_id = ?',
      variables: [Variable<String>(workspaceId)],
      readsFrom: {},
    ).get();
    return rows.map((r) => r.read<String>('session_id')).toSet();
  }

  static String _escapeFtsQuery(String raw) {
    final cleaned = raw.trim();
    if (cleaned.isEmpty) return '';
    final tokens = cleaned.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    return tokens
        .map((t) {
          final safe = t.replaceAll('"', '""');
          return '"$safe"*';
        })
        .join(' ');
  }
}
