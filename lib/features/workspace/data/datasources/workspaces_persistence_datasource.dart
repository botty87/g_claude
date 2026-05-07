import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/persistence/key_value_store.dart';

class PersistedWorkspaceEntry {
  const PersistedWorkspaceEntry({required this.id, required this.path, required this.name, required this.openedAt});

  final String id;
  final String path;
  final String name;
  final DateTime openedAt;
}

class PersistedWorkspaces {
  const PersistedWorkspaces({required this.workspaces, this.activeId});

  final List<PersistedWorkspaceEntry> workspaces;
  final String? activeId;
}

abstract interface class WorkspacesPersistenceDataSource {
  Future<PersistedWorkspaces?> read();
  Future<void> write(PersistedWorkspaces snapshot);
  Future<void> clear();
}

@LazySingleton(as: WorkspacesPersistenceDataSource)
class WorkspacesPersistenceDataSourceImpl implements WorkspacesPersistenceDataSource {
  WorkspacesPersistenceDataSourceImpl(this._store, this._talker);

  final KeyValueStore _store;
  final Talker _talker;

  static const _key = 'persistence.workspaces.v1';
  static const _schemaVersion = 1;

  @override
  Future<PersistedWorkspaces?> read() async {
    final raw = await _store.readString(_key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final v = json['schemaVersion'] as int?;
      if (v != _schemaVersion) {
        _talker.warning('Workspaces persistence: schema mismatch (got $v, expected $_schemaVersion). Discarding.');
        return null;
      }
      final list = (json['workspaces'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_parseEntry)
          .whereType<PersistedWorkspaceEntry>()
          .toList(growable: false);
      return PersistedWorkspaces(workspaces: list, activeId: json['activeId'] as String?);
    } catch (e, st) {
      _talker.error('Workspaces persistence: failed to parse, discarding', e, st);
      return null;
    }
  }

  @override
  Future<void> write(PersistedWorkspaces snapshot) async {
    final json = <String, dynamic>{
      'schemaVersion': _schemaVersion,
      'activeId': snapshot.activeId,
      'workspaces': snapshot.workspaces
          .map(
            (w) => <String, dynamic>{
              'id': w.id,
              'path': w.path,
              'name': w.name,
              'openedAt': w.openedAt.toIso8601String(),
            },
          )
          .toList(),
    };
    await _store.writeString(_key, jsonEncode(json));
  }

  @override
  Future<void> clear() => _store.remove(_key);

  PersistedWorkspaceEntry? _parseEntry(Map<String, dynamic> j) {
    final id = j['id'] as String?;
    final path = j['path'] as String?;
    final name = j['name'] as String?;
    final openedAtStr = j['openedAt'] as String?;
    if (id == null || path == null || name == null || openedAtStr == null) {
      return null;
    }
    final openedAt = DateTime.tryParse(openedAtStr);
    if (openedAt == null) return null;
    return PersistedWorkspaceEntry(id: id, path: path, name: name, openedAt: openedAt);
  }
}
