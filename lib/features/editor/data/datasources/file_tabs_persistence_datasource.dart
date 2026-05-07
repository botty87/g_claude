import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/persistence/key_value_store.dart';

class PersistedWorkspaceFiles {
  const PersistedWorkspaceFiles({required this.openPaths, this.activePath, this.previewPath});

  final List<String> openPaths;
  final String? activePath;
  final String? previewPath;
}

class PersistedFileTabs {
  const PersistedFileTabs({required this.perWorkspace});

  final Map<String, PersistedWorkspaceFiles> perWorkspace;
}

abstract interface class FileTabsPersistenceDataSource {
  Future<PersistedFileTabs?> read();
  Future<void> write(PersistedFileTabs snapshot);
  Future<void> clear();
}

@LazySingleton(as: FileTabsPersistenceDataSource)
class FileTabsPersistenceDataSourceImpl implements FileTabsPersistenceDataSource {
  FileTabsPersistenceDataSourceImpl(this._store, this._talker);

  final KeyValueStore _store;
  final Talker _talker;

  static const _key = 'persistence.file_tabs.v1';
  static const _schemaVersion = 1;

  @override
  Future<PersistedFileTabs?> read() async {
    final raw = await _store.readString(_key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final v = json['schemaVersion'] as int?;
      if (v != _schemaVersion) {
        _talker.warning('FileTabs persistence: schema mismatch (got $v, expected $_schemaVersion). Discarding.');
        return null;
      }
      final perWs = <String, PersistedWorkspaceFiles>{};
      final raw2 = json['perWorkspace'] as Map<String, dynamic>? ?? const {};
      raw2.forEach((id, value) {
        if (value is! Map<String, dynamic>) return;
        final files = _parseFiles(value);
        if (files != null) perWs[id] = files;
      });
      return PersistedFileTabs(perWorkspace: perWs);
    } catch (e, st) {
      _talker.error('FileTabs persistence: failed to parse, discarding', e, st);
      return null;
    }
  }

  @override
  Future<void> write(PersistedFileTabs snapshot) async {
    final json = <String, dynamic>{
      'schemaVersion': _schemaVersion,
      'perWorkspace': snapshot.perWorkspace.map(
        (id, files) => MapEntry(id, <String, dynamic>{
          'openPaths': files.openPaths,
          'activePath': files.activePath,
          'previewPath': files.previewPath,
        }),
      ),
    };
    await _store.writeString(_key, jsonEncode(json));
  }

  @override
  Future<void> clear() => _store.remove(_key);

  PersistedWorkspaceFiles? _parseFiles(Map<String, dynamic> j) {
    final paths = (j['openPaths'] as List<dynamic>? ?? const []).whereType<String>().toList(growable: false);
    return PersistedWorkspaceFiles(
      openPaths: paths,
      activePath: j['activePath'] as String?,
      previewPath: j['previewPath'] as String?,
    );
  }
}
