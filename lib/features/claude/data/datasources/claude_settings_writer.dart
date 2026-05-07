import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

import '../../../../core/utils/pretty_json.dart';

/// Writes a temporary `settings.json` consumed by `claude -p --settings <path>`
/// that wires every `PreToolUse` event to the local PermissionServer via curl.
@lazySingleton
class ClaudeSettingsWriter {
  ClaudeSettingsWriter(this._talker);

  final Talker _talker;
  String? _path;
  int? _writtenForPort;

  Future<String> ensure(int port) async {
    if (_path != null && _writtenForPort == port) return _path!;
    final dir = Directory.systemTemp.createTempSync('g_claude_settings_');
    final file = File(p.join(dir.path, 'settings.json'));
    final content = {
      'hooks': {
        'PreToolUse': [
          {
            'matcher': '*',
            'hooks': [
              {
                'type': 'command',
                'command':
                    'curl -sf --max-time 120 '
                    '-H "Content-Type: application/json" '
                    '--data-binary @- '
                    'http://127.0.0.1:$port/permission',
              },
            ],
          },
        ],
      },
    };
    await file.writeAsString(prettyJson.convert(content));
    _path = file.path;
    _writtenForPort = port;
    _talker.info('Claude settings written: $_path (hook port=$port)');
    return _path!;
  }
}
