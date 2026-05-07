// Contracts for `ClaudeSettingsWriter`.
//
// The writer creates the temporary settings.json that wires Claude's
// PreToolUse hook to our local PermissionServer via curl. A regression here
// either produces a settings file that Claude rejects, or wires the hook to
// the wrong port — both invisible until Claude crashes mid-run.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/claude/data/datasources/claude_settings_writer.dart';

import '../../../../helpers/fakes.dart';

void main() {
  group('ClaudeSettingsWriter.ensure', () {
    test('writes a real file at the returned path on first call', () async {
      final w = ClaudeSettingsWriter(makeTestTalker());

      final path = await w.ensure(12345);

      expect(File(path).existsSync(), isTrue);
      addTearDown(() => File(path).parent.deleteSync(recursive: true));
    });

    test('the file is valid JSON with a PreToolUse hook bound to the port', () async {
      final w = ClaudeSettingsWriter(makeTestTalker());
      final path = await w.ensure(12345);
      addTearDown(() => File(path).parent.deleteSync(recursive: true));

      final body = File(path).readAsStringSync();
      // Must parse — Claude rejects malformed settings.
      final json = jsonDecode(body) as Map<String, dynamic>;

      final hooks = json['hooks'] as Map<String, dynamic>;
      final preToolUse = hooks['PreToolUse'] as List<dynamic>;
      expect(preToolUse, hasLength(1));

      final entry = preToolUse.single as Map<String, dynamic>;
      expect(entry['matcher'], '*', reason: 'matcher * routes every tool through the permission server.');

      final inner = (entry['hooks'] as List).single as Map<String, dynamic>;
      expect(inner['type'], 'command');
      expect(inner['command'], contains('http://127.0.0.1:12345/permission'));
      expect(inner['command'], contains('curl'));
      expect(
        inner['command'],
        contains('--max-time 120'),
        reason: 'curl timeout must be set so a frozen UI does not stall the subprocess forever.',
      );
    });

    test('a second call with the same port reuses the cached path (no rewrite)', () async {
      final w = ClaudeSettingsWriter(makeTestTalker());

      final p1 = await w.ensure(12345);
      addTearDown(() => File(p1).parent.deleteSync(recursive: true));

      final mtime1 = File(p1).lastModifiedSync();
      // Second call. Path returned should be IDENTICAL.
      final p2 = await w.ensure(12345);

      expect(p2, p1);
      // File mtime must not have changed (no rewrite).
      expect(File(p2).lastModifiedSync(), mtime1);
    });

    test('a second call with a different port writes a NEW file at a new path', () async {
      final w = ClaudeSettingsWriter(makeTestTalker());

      final p1 = await w.ensure(12345);
      addTearDown(() => File(p1).parent.deleteSync(recursive: true));

      final p2 = await w.ensure(54321);
      addTearDown(() {
        // p2 may live in a different temp dir — clean it too.
        if (File(p2).existsSync()) {
          File(p2).parent.deleteSync(recursive: true);
        }
      });

      expect(p2, isNot(p1), reason: 'A different port must yield a different settings file.');
      // The new file must reference the new port.
      final body2 = File(p2).readAsStringSync();
      expect(body2, contains('http://127.0.0.1:54321/permission'));
      expect(body2, isNot(contains('http://127.0.0.1:12345/permission')));
    });

    test('the written JSON has a single top-level "hooks" key with no extras', () async {
      final w = ClaudeSettingsWriter(makeTestTalker());
      final path = await w.ensure(12345);
      addTearDown(() => File(path).parent.deleteSync(recursive: true));

      final body = File(path).readAsStringSync();
      final json = jsonDecode(body) as Map<String, dynamic>;
      // Pin the shape so a future change that bundles extra config (e.g.
      // `permissions`, `model`) does it intentionally — the test must be
      // updated together with the code.
      expect(json.keys.toSet(), {'hooks'});
    });
  });
}
