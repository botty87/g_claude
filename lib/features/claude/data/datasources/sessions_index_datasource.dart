import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'claude_history_datasource.dart';
import 'sessions_database.dart';

abstract interface class SessionsIndexDataSource {
  Future<List<SessionRow>> listForWorkspace(String workspaceId);
  Future<List<SessionRow>> getByIds(List<String> ids, String workspaceId);
  Future<void> refreshIndex({required String workspaceId, required String workspaceCwd});
  Future<void> deleteRow(String sessionId);
  Future<List<String>> searchIds(String workspaceId, String query, {int limit});
}

@LazySingleton(as: SessionsIndexDataSource)
class SessionsIndexDataSourceImpl implements SessionsIndexDataSource {
  SessionsIndexDataSourceImpl(this._db, this._history);

  final SessionsDatabase _db;
  final ClaudeHistoryDataSource _history;

  @override
  Future<List<SessionRow>> listForWorkspace(String workspaceId) {
    return (_db.select(_db.sessions)
          ..where((s) => s.workspaceId.equals(workspaceId))
          ..orderBy([(s) => OrderingTerm.desc(s.lastMessageAt)]))
        .get();
  }

  @override
  Future<List<SessionRow>> getByIds(List<String> ids, String workspaceId) async {
    if (ids.isEmpty) return [];
    final rows = await (_db.select(
      _db.sessions,
    )..where((s) => s.workspaceId.equals(workspaceId) & s.id.isIn(ids))).get();
    final byId = {for (final r in rows) r.id: r};
    return [
      for (final id in ids)
        if (byId.containsKey(id)) byId[id]!,
    ];
  }

  @override
  Future<void> refreshIndex({required String workspaceId, required String workspaceCwd}) async {
    final metas = await _history.scanWorkspace(workspaceCwd);

    final ftsIds = await _db.ftsIdsForWorkspace(workspaceId);

    await _db.transaction(() async {
      final existing = await (_db.select(_db.sessions)..where((s) => s.workspaceId.equals(workspaceId))).get();

      final existingById = {for (final row in existing) row.id: row};
      final metaIds = {for (final m in metas) m.id};

      for (final meta in metas) {
        final row = existingById[meta.id];
        final mtimeChanged = row == null || row.fileMtime != meta.fileMtime;
        final sizeChanged = row == null || row.fileSize != meta.fileSize;
        final ftsAbsent = !ftsIds.contains(meta.id);

        if (row == null || mtimeChanged || sizeChanged) {
          await _db
              .into(_db.sessions)
              .insertOnConflictUpdate(
                SessionsCompanion.insert(
                  id: meta.id,
                  workspaceId: workspaceId,
                  encodedPath: meta.encodedPath,
                  title: Value(meta.title),
                  firstMessageAt: meta.firstMessageAt,
                  lastMessageAt: meta.lastMessageAt,
                  messageCount: Value(meta.messageCount),
                  fileSize: meta.fileSize,
                  fileMtime: meta.fileMtime,
                ),
              );
          final body = await _history.readFullText(encodedPath: meta.encodedPath, sessionId: meta.id);
          await _db.upsertSessionFts(sessionId: meta.id, workspaceId: workspaceId, body: body);
        } else if (ftsAbsent) {
          final body = await _history.readFullText(encodedPath: meta.encodedPath, sessionId: meta.id);
          await _db.upsertSessionFts(sessionId: meta.id, workspaceId: workspaceId, body: body);
        }
      }

      for (final row in existing) {
        if (!metaIds.contains(row.id)) {
          await (_db.delete(_db.sessions)..where((s) => s.id.equals(row.id))).go();
          await _db.deleteSessionFts(row.id);
        }
      }
    });
  }

  @override
  Future<void> deleteRow(String sessionId) async {
    await (_db.delete(_db.sessions)..where((s) => s.id.equals(sessionId))).go();
    await _db.deleteSessionFts(sessionId);
  }

  @override
  Future<List<String>> searchIds(String workspaceId, String query, {int limit = 200}) {
    return _db.searchFtsIds(workspaceId: workspaceId, query: query, limit: limit);
  }
}
