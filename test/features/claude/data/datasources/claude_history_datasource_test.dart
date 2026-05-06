// Contracts for `ClaudeHistoryDataSourceImpl` (lib/features/claude/data/
// datasources/claude_history_datasource.dart).
//
// All fixtures live under test/fixtures/jsonl/synthetic/. They are SYNTHETIC
// because the harness sandbox blocks copying real files from
// ~/.claude/projects/. Their shapes were verified against real production
// JSONL via `jq` inspection (see synthetic/README.md). The test for each
// contract uses one fixture-per-concept so failures localize cleanly.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/claude/data/datasources/claude_history_datasource.dart';
import 'package:g_claude/features/claude/domain/entities/claude_message.dart';
import 'package:path/path.dart' as p;

import '../../../../helpers/fakes.dart';

const _fixturesRoot = 'test/fixtures/jsonl/synthetic';
const _testCwd = '/test/workspace';

/// Builds a `~/.claude/projects/`-shaped tmp directory containing the named
/// fixtures, each placed under `{encodedPath}/{sessionId}.jsonl`.
///
/// `encodedPath` is derived live via `encodeCwd` so a regex change in the
/// production encoder cannot silently desync the test fixture layout.
Future<({Directory projectsDir, String encodedPath, String sessionId})>
    _stageFixtures(
  Map<String, String> fixtureToSessionId, {
  String cwd = _testCwd,
}) async {
  final encodedPath = ClaudeHistoryDataSourceImpl(makeTestTalker()).encodeCwd(cwd);
  final tmp = await Directory.systemTemp.createTemp('g_claude_history_');
  final wsDir = Directory(p.join(tmp.path, encodedPath))..createSync(recursive: true);

  String? firstSessionId;
  for (final entry in fixtureToSessionId.entries) {
    final src = File(p.join(_fixturesRoot, entry.key));
    final dst = File(p.join(wsDir.path, '${entry.value}.jsonl'));
    await dst.writeAsString(await src.readAsString());
    firstSessionId ??= entry.value;
  }

  return (
    projectsDir: tmp,
    encodedPath: encodedPath,
    sessionId: firstSessionId ?? '',
  );
}

ClaudeHistoryDataSourceImpl _makeDs(Directory projectsDir) {
  return ClaudeHistoryDataSourceImpl.withProjectsDir(makeTestTalker(), projectsDir);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('encodeCwd', () {
    test('replaces every non-alphanumeric character with a single dash', () {
      final ds = ClaudeHistoryDataSourceImpl(makeTestTalker());
      expect(ds.encodeCwd('/Users/foo/bar'), '-Users-foo-bar');
      expect(ds.encodeCwd('/tmp/wd'), '-tmp-wd');
    });

    test('preserves alphanumerics including digits', () {
      final ds = ClaudeHistoryDataSourceImpl(makeTestTalker());
      expect(ds.encodeCwd('/Dev/proj-2/src'), '-Dev-proj-2-src');
    });

    test('whitespace and dots are encoded as dashes (one per char)', () {
      final ds = ClaudeHistoryDataSourceImpl(makeTestTalker());
      expect(ds.encodeCwd('/path with spaces/foo.dart'),
          '-path-with-spaces-foo-dart');
    });
  });

  group('scanWorkspace', () {
    test('returns [] when the workspace directory does not exist', () async {
      final tmp = await Directory.systemTemp.createTemp('g_claude_history_');
      addTearDown(() => tmp.delete(recursive: true));

      final ds = _makeDs(tmp);
      // Use a cwd whose encoded form is missing on disk.
      final out = await ds.scanWorkspace('/never/existed');
      expect(out, isEmpty);
    });

    test('returns [] when the workspace directory is empty', () async {
      final tmp = await Directory.systemTemp.createTemp('g_claude_history_');
      addTearDown(() => tmp.delete(recursive: true));
      Directory(p.join(tmp.path, '-test')).createSync();

      final ds = _makeDs(tmp);
      // Pass a cwd that encodes to "-test".
      expect(await ds.scanWorkspace('/test'), isEmpty);
    });

    test('skips non-.jsonl files in the workspace directory', () async {
      final tmp = await Directory.systemTemp.createTemp('g_claude_history_');
      addTearDown(() => tmp.delete(recursive: true));
      final wsDir = Directory(p.join(tmp.path, '-test'))..createSync();
      File(p.join(wsDir.path, 'README.md')).writeAsStringSync('not a session');

      final ds = _makeDs(tmp);
      expect(await ds.scanWorkspace('/test'), isEmpty);
    });

    test('extracts title from the first user message of a text-only session',
        () async {
      final staged = await _stageFixtures({
        'text_only_session.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final metas = await ds.scanWorkspace('/test/workspace');
      expect(metas, hasLength(1));
      expect(metas.single.id, 'sess-1');
      expect(metas.single.title, 'What is 2+2?');
    });

    test('counts only user/assistant entries, not system/queue/snapshot/permission',
        () async {
      final staged = await _stageFixtures({
        'noise_filter.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final metas = await ds.scanWorkspace('/test/workspace');
      expect(metas.single.messageCount, 2,
          reason: '1 user + 1 assistant; the 4 noise entries must not count.');
    });

    test('extracts title via slash-command rule: drops "/cmd" prefix and keeps args',
        () async {
      final staged = await _stageFixtures({
        'slash_command_title.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final metas = await ds.scanWorkspace('/test/workspace');
      // _extractUserText: starts with '/', has a space → return args after space.
      expect(metas.single.title, 'build a cli tool for csv parsing');
    });

    test('falls back to summary entry text when no user message produces a title',
        () async {
      final staged = await _stageFixtures({
        'summary_fallback.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final metas = await ds.scanWorkspace('/test/workspace');
      expect(metas.single.title, 'Discussion about quantum entanglement');
    });

    test('isSidechain and isMeta entries are filtered from messageCount and title',
        () async {
      final staged = await _stageFixtures({
        'sidechain_meta_filter.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final metas = await ds.scanWorkspace('/test/workspace');
      // Only the non-sidechain, non-meta user/assistant entries count.
      expect(metas.single.messageCount, 2);
      // Title comes from the first NON-sidechain user message — the sidechain
      // ones must not contribute.
      expect(metas.single.title, 'Real user question');
    });

    test('sorts results by lastMessageAt descending', () async {
      final staged = await _stageFixtures({
        'text_only_session.jsonl': 'sess-2026-04-01',
        'tool_flow.jsonl': 'sess-2026-04-01b',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final metas = await ds.scanWorkspace('/test/workspace');
      expect(metas, hasLength(2));
      // Both fixtures have explicit timestamps in the same day; the contract
      // is that they come out sorted descending by lastMessageAt — assert
      // monotonic decrease across the list.
      for (var i = 1; i < metas.length; i++) {
        expect(
          metas[i - 1].lastMessageAt.isAfter(metas[i].lastMessageAt) ||
              metas[i - 1].lastMessageAt
                  .isAtSameMomentAs(metas[i].lastMessageAt),
          isTrue,
        );
      }
    });

    test('falls back to file mtime when the session has no parseable timestamps',
        () async {
      final tmp = await Directory.systemTemp.createTemp('g_claude_history_');
      addTearDown(() => tmp.delete(recursive: true));
      final wsDir = Directory(p.join(tmp.path, '-test'))..createSync();
      // Single entry, no timestamp. messageCount must still increment, but
      // firstMessageAt/lastMessageAt fall back to fileMtime.
      File(p.join(wsDir.path, 'sess-x.jsonl')).writeAsStringSync(
        '{"type":"user","uuid":"u-1","message":{"role":"user","content":"hi"}}\n',
      );

      final ds = _makeDs(tmp);
      final metas = await ds.scanWorkspace('/test');
      expect(metas, hasLength(1));
      expect(metas.single.firstMessageAt, metas.single.fileMtime);
      expect(metas.single.lastMessageAt, metas.single.fileMtime);
    });
  });

  group('readSession', () {
    test('emits user (text) → assistant (text) for a text-only session',
        () async {
      final staged = await _stageFixtures({
        'text_only_session.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final messages = await ds
          .readSession(encodedPath: staged.encodedPath, sessionId: 'sess-1')
          .toList();

      expect(messages, hasLength(4));
      expect(messages[0], isA<ClaudeMessageUser>());
      expect((messages[0] as ClaudeMessageUser).text, 'What is 2+2?');
      expect(messages[1], isA<ClaudeMessageAssistant>());
      expect((messages[1] as ClaudeMessageAssistant).text, '2 + 2 = 4.');
    });

    test('handles message.content as raw String (legacy shape)', () async {
      final staged = await _stageFixtures({
        'string_content_user.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final messages = await ds
          .readSession(encodedPath: staged.encodedPath, sessionId: 'sess-1')
          .toList();

      final firstUser = messages.first as ClaudeMessageUser;
      expect(firstUser.text, 'Plain string content, not a list.');
    });

    test('correlates tool_result to its tool_use by tool_use_id and marks completed',
        () async {
      final staged = await _stageFixtures({
        'tool_flow.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final messages = await ds
          .readSession(encodedPath: staged.encodedPath, sessionId: 'sess-1')
          .toList();

      final tools = messages.whereType<ClaudeMessageTool>().toList();
      // Real contract: the parser yields TWO tool messages with the same id:
      // first the running snapshot when tool_use is read, then the completed
      // snapshot when the matching tool_result arrives later. Consumers
      // collapse them by id (same id == same logical tool, latest wins).
      expect(tools, hasLength(2));
      expect(tools[0].id, tools[1].id);
      expect(tools[0].status, ClaudeToolStatus.running);
      expect(tools[0].output, isNull);
      final completed = tools[1];
      expect(completed.status, ClaudeToolStatus.completed);
      expect(completed.output, 'hello world');
      expect(completed.isError, isFalse);
    });

    test('emits a tool_result with isError=true when content carries is_error',
        () async {
      // Using mixed_tool_result (single tool, JSON-encoded list content) but
      // turning is_error true via inline. We stage and overwrite the file
      // with a single-line variant for this contract.
      final tmp = await Directory.systemTemp.createTemp('g_claude_history_');
      addTearDown(() => tmp.delete(recursive: true));
      final wsDir = Directory(p.join(tmp.path, '-test'))..createSync();
      File(p.join(wsDir.path, 'sess.jsonl')).writeAsStringSync(
        '${'{"type":"assistant","timestamp":"2026-04-01T10:00:00.000Z","uuid":"a-1","message":{"id":"m-1","role":"assistant","content":[{"type":"tool_use","id":"t-1","name":"X","input":{}}]}}'}\n'
        '${'{"type":"user","timestamp":"2026-04-01T10:00:01.000Z","uuid":"u-1","message":{"role":"user","content":[{"type":"tool_result","tool_use_id":"t-1","content":"oops","is_error":true}]}}'}\n',
      );
      final ds = _makeDs(tmp);
      final out = await ds
          .readSession(encodedPath: '-test', sessionId: 'sess')
          .toList();
      final tool = out.whereType<ClaudeMessageTool>()
          .firstWhere((t) => t.status == ClaudeToolStatus.error);
      expect(tool.isError, isTrue);
      expect(tool.output, 'oops');
    });

    test('JSON-encodes tool_result content when it arrives as a List of blocks',
        () async {
      final staged = await _stageFixtures({
        'mixed_tool_result.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final messages = await ds
          .readSession(encodedPath: staged.encodedPath, sessionId: 'sess-1')
          .toList();

      final completed = messages
          .whereType<ClaudeMessageTool>()
          .firstWhere((t) => t.status == ClaudeToolStatus.completed);
      // Current impl: `output = jsonEncode(rawContent)` when content is a List.
      expect(completed.output, contains('"text":"first"'));
      expect(completed.output, contains('"text":"second"'));
    });

    test('orphan tool_use without a matching tool_result is emitted as error at end',
        () async {
      final staged = await _stageFixtures({
        'orphan_tool.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final messages = await ds
          .readSession(encodedPath: staged.encodedPath, sessionId: 'sess-1')
          .toList();

      // The orphan is yielded twice: once running (live), once as the final
      // error snapshot at end of stream (the loop on pendingTools).
      final tools = messages.whereType<ClaudeMessageTool>().toList();
      expect(tools.last.status, ClaudeToolStatus.error);
      expect(tools.last.isError, isTrue);
      expect(tools.last.toolUseId, 'tool_orphan');
    });

    test('isSidechain and isMeta messages are filtered from the stream',
        () async {
      final staged = await _stageFixtures({
        'sidechain_meta_filter.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final messages = await ds
          .readSession(encodedPath: staged.encodedPath, sessionId: 'sess-1')
          .toList();

      // Only the non-sidechain, non-meta turn pair survives.
      expect(messages, hasLength(2));
      expect((messages[0] as ClaudeMessageUser).text, 'Real user question');
      expect((messages[1] as ClaudeMessageAssistant).text, 'Real reply');
    });

    test('non-message types (system, queue-operation, summary, snapshot) emit nothing',
        () async {
      final staged = await _stageFixtures({
        'noise_filter.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final messages = await ds
          .readSession(encodedPath: staged.encodedPath, sessionId: 'sess-1')
          .toList();

      expect(messages, hasLength(2));
      expect(messages[0], isA<ClaudeMessageUser>());
      expect(messages[1], isA<ClaudeMessageAssistant>());
    });

    test('a malformed JSON line is logged and skipped, not crash the stream',
        () async {
      final tmp = await Directory.systemTemp.createTemp('g_claude_history_');
      addTearDown(() => tmp.delete(recursive: true));
      final wsDir = Directory(p.join(tmp.path, '-test'))..createSync();
      File(p.join(wsDir.path, 'sess.jsonl')).writeAsStringSync(
        '${'{"type":"user","timestamp":"2026-04-01T10:00:00.000Z","uuid":"u-1","message":{"role":"user","content":"first"}}'}\n'
        'this line is not valid JSON\n'
        '${'{"type":"user","timestamp":"2026-04-01T10:00:01.000Z","uuid":"u-2","message":{"role":"user","content":"second"}}'}\n',
      );

      final ds = _makeDs(tmp);
      final messages = await ds
          .readSession(encodedPath: '-test', sessionId: 'sess')
          .toList();
      expect(messages, hasLength(2));
      expect((messages[0] as ClaudeMessageUser).text, 'first');
      expect((messages[1] as ClaudeMessageUser).text, 'second');
    });
  });

  group('readFullText', () {
    test('concatenates user and assistant text with newline separators', () async {
      final staged = await _stageFixtures({
        'text_only_session.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final text = await ds.readFullText(
        encodedPath: staged.encodedPath,
        sessionId: 'sess-1',
      );

      // 4 messages → 4 text blocks joined by \n in order.
      expect(text, contains('What is 2+2?'));
      expect(text, contains('2 + 2 = 4.'));
      expect(text, contains('Thanks.'));
      expect(text, contains("You're welcome."));
      // Order check: first user before first assistant.
      expect(text.indexOf('What is 2+2?'), lessThan(text.indexOf('2 + 2 = 4.')));
    });

    test('truncates output at the 200KB cutoff', () async {
      final tmp = await Directory.systemTemp.createTemp('g_claude_history_');
      addTearDown(() => tmp.delete(recursive: true));
      final wsDir = Directory(p.join(tmp.path, '-test'))..createSync();

      // Write enough bytes to comfortably exceed 200KB. Each line carries a
      // user message with ~5KB of payload; we write 60 lines (~300KB total).
      final payload = 'lorem ipsum dolor sit amet ' * 200; // ~5KB
      final buf = StringBuffer();
      for (var i = 0; i < 60; i++) {
        buf.write(
          '{"type":"user","timestamp":"2026-04-01T10:00:00.000Z","uuid":"u-$i","message":{"role":"user","content":${'"$payload"'}}}\n',
        );
      }
      File(p.join(wsDir.path, 'sess.jsonl')).writeAsStringSync(buf.toString());

      final ds = _makeDs(tmp);
      final text = await ds.readFullText(
        encodedPath: '-test',
        sessionId: 'sess',
      );

      // The cutoff check is at the START of every iteration: once the buffer
      // is >= 200KB, the loop breaks. So output is at least 200KB-ish but
      // bounded above by 200KB + (one extra payload) — assert it is bounded.
      expect(text.length, greaterThan(200 * 1024 - 1));
      expect(text.length, lessThan(220 * 1024),
          reason: 'After cutoff one trailing block may still be appended; '
              'a 20KB safety margin is generous.');
    });

    test('skips noise entries and excludes tool_use / tool_result content',
        () async {
      // tool_flow has tool_use + tool_result text but readFullText only takes
      // text blocks from user/assistant. The tool result "hello world" must
      // NOT appear in the concatenated output.
      final staged = await _stageFixtures({
        'tool_flow.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final ds = _makeDs(staged.projectsDir);
      final text = await ds.readFullText(
        encodedPath: staged.encodedPath,
        sessionId: 'sess-1',
      );

      expect(text, contains('Read hello.txt'));
      expect(text, contains("I'll read it now."));
      expect(text, contains("The file contains 'hello world'."));
      // The `hello world` from tool_result content is NOT included in
      // readFullText — only assistant/user text blocks.
      expect(text.contains('"hello world"'), isFalse);
    });
  });

  group('deleteSession', () {
    test('removes the session file when present', () async {
      final staged = await _stageFixtures({
        'text_only_session.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));

      final file = File(p.join(staged.projectsDir.path, staged.encodedPath, 'sess-1.jsonl'));
      expect(file.existsSync(), isTrue);

      final ds = _makeDs(staged.projectsDir);
      await ds.deleteSession(encodedPath: staged.encodedPath, sessionId: 'sess-1');
      expect(file.existsSync(), isFalse);
    });

    test('throws FileSystemException when the session file is missing', () async {
      final tmp = await Directory.systemTemp.createTemp('g_claude_history_');
      addTearDown(() => tmp.delete(recursive: true));
      Directory(p.join(tmp.path, '-test')).createSync();

      final ds = _makeDs(tmp);
      expect(
        () => ds.deleteSession(encodedPath: '-test', sessionId: 'absent'),
        throwsA(isA<FileSystemException>()),
      );
    });
  });

  group('exportSessionMarkdown', () {
    test('writes a markdown file containing user/assistant turns', () async {
      final staged = await _stageFixtures({
        'text_only_session.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));
      final dest = p.join(staged.projectsDir.path, 'export.md');

      final ds = _makeDs(staged.projectsDir);
      final returned = await ds.exportSessionMarkdown(
        encodedPath: staged.encodedPath,
        sessionId: 'sess-1',
        destinationPath: dest,
      );

      expect(returned, dest);
      final body = await File(dest).readAsString();
      expect(body, contains('# Session sess-1'));
      expect(body, contains('## User'));
      expect(body, contains('## Assistant'));
      expect(body, contains('What is 2+2?'));
      expect(body, contains('2 + 2 = 4.'));
    });

    test('includes a Tool section with input JSON and output blocks', () async {
      final staged = await _stageFixtures({
        'tool_flow.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));
      final dest = p.join(staged.projectsDir.path, 'export.md');

      final ds = _makeDs(staged.projectsDir);
      await ds.exportSessionMarkdown(
        encodedPath: staged.encodedPath,
        sessionId: 'sess-1',
        destinationPath: dest,
      );

      final body = await File(dest).readAsString();
      expect(body, contains('### Tool: Read'));
      expect(body, contains('"file_path": "/tmp/wd/hello.txt"'));
      expect(body, contains('hello world'));
    });

    test('creates intermediate directories under the destination path', () async {
      final staged = await _stageFixtures({
        'text_only_session.jsonl': 'sess-1',
      });
      addTearDown(() => staged.projectsDir.delete(recursive: true));
      final dest = p.join(staged.projectsDir.path, 'nested', 'sub', 'out.md');

      final ds = _makeDs(staged.projectsDir);
      await ds.exportSessionMarkdown(
        encodedPath: staged.encodedPath,
        sessionId: 'sess-1',
        destinationPath: dest,
      );

      expect(File(dest).existsSync(), isTrue);
    });
  });
}
