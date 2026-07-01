// [SidecarClientDataSource] is the Dart-side client of the sidecar NDJSON
// protocol (see backend/PROTOCOL.md). Responsibilities:
//
//   1. `startRun` — sends a `start` REQ (sid = cwd) via [SidecarTransport],
//      then filters the transport's shared `events` stream down to events
//      matching this run's `sid`, mapping each raw protocol map to a typed
//      [ClaudeEvent]. The stream completes when `sessionDead` arrives.
//   2. `stop` / `respondPermission` / `answerQuestion` / `answerPlan` /
//      `setMode` — each sends a specific REQ shape back through the
//      transport.
//   3. `answerQuestion` must replay the exact `questions` payload that was
//      cached from a previously-seen `askUserQuestion` event for the same
//      `toolUseID` (the sidecar protocol requires the round trip).
//
// These tests use a hand-written fake [SidecarTransport] so no real process
// or network I/O is involved — fully deterministic and fast.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/claude/data/datasources/sidecar_client_datasource.dart';
import 'package:g_claude/features/claude/data/datasources/sidecar_transport.dart';
import 'package:g_claude/features/claude/domain/entities/claude_effort.dart';
import 'package:g_claude/features/claude/domain/entities/claude_event.dart';
import 'package:g_claude/features/claude/domain/entities/claude_model.dart';
import 'package:g_claude/features/claude/domain/entities/claude_permission_mode.dart';
import 'package:g_claude/features/claude/domain/entities/mcp_server.dart';

import '../../../../helpers/fakes.dart';

// ---------------------------------------------------------------------------
// Fake transport
// ---------------------------------------------------------------------------

/// In-memory [SidecarTransport]: `events` is driven by a broadcast
/// controller the test pushes raw protocol maps into; every `send` call is
/// recorded verbatim so REQ payloads can be asserted on.
class _FakeSidecarTransport implements SidecarTransport {
  final StreamController<Map<String, dynamic>> _controller = StreamController<Map<String, dynamic>>.broadcast();
  final List<Map<String, dynamic>> sent = [];
  bool started = false;

  @override
  Stream<Map<String, dynamic>> get events => _controller.stream;

  @override
  Future<void> start() async {
    started = true;
  }

  @override
  void send(Map<String, dynamic> req) {
    sent.add(req);
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  void push(Map<String, dynamic> raw) => _controller.add(raw);
}

void main() {
  late _FakeSidecarTransport transport;
  late SidecarClientDataSource ds;

  setUp(() {
    transport = _FakeSidecarTransport();
    ds = SidecarClientDataSource(transport, makeTestTalker());
  });

  tearDown(() async {
    await transport.dispose();
  });

  // ---------------------------------------------------------------------------
  // 1. startRun REQ payload
  // ---------------------------------------------------------------------------

  group('startRun — sends a `start` REQ built from the call params', () {
    test('sid/cwd/prompt/mode always present; optional fields included only when non-null/non-empty', () async {
      final sub = ds
          .startRun(
            cwd: '/w',
            prompt: 'p',
            mode: ClaudePermissionMode.plan,
            model: ClaudeModel.opus,
            effort: ClaudeEffort.high,
            resumeSessionId: 'r',
            imagePaths: const ['/a.png'],
            disabledMcp: const {'context7'},
          )
          .listen((_) {});
      addTearDown(sub.cancel);
      await Future<void>.delayed(Duration.zero);

      expect(transport.started, isTrue);
      expect(transport.sent, hasLength(1));
      final req = transport.sent.single;
      expect(req['t'], 'start');
      expect(req['sid'], '/w');
      expect(req['cwd'], '/w');
      expect(req['prompt'], 'p');
      expect(req['mode'], 'plan');
      expect(req['model'], 'opus');
      expect(req['effort'], 'high');
      expect(req['thinking'], isTrue, reason: 'thinking defaults to true');
      expect(req['resume'], 'r');
      expect(req['images'], ['/a.png']);
      expect(req['disabledMcp'], ['context7']);
    });

    test('omits model/effort/resume/images/disabledMcp when null/empty', () async {
      final sub = ds.startRun(cwd: '/w2', prompt: 'p2', mode: ClaudePermissionMode.defaultMode).listen((_) {});
      addTearDown(sub.cancel);
      await Future<void>.delayed(Duration.zero);

      final req = transport.sent.single;
      expect(req.containsKey('model'), isFalse);
      expect(req.containsKey('effort'), isFalse);
      expect(req.containsKey('resume'), isFalse);
      expect(req.containsKey('images'), isFalse);
      expect(req.containsKey('disabledMcp'), isFalse);
      expect(req['thinking'], isTrue);
      expect(req['mode'], 'default');
    });

    test('thinking:false is sent explicitly when the caller passes thinking:false', () async {
      final sub = ds
          .startRun(cwd: '/w3', prompt: 'p3', mode: ClaudePermissionMode.acceptEdits, thinking: false)
          .listen((_) {});
      addTearDown(sub.cancel);
      await Future<void>.delayed(Duration.zero);

      expect(transport.sent.single['thinking'], isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // 2. sid filtering
  // ---------------------------------------------------------------------------

  group('startRun — events are filtered by sid (sid == cwd of this run)', () {
    test('an event with a different sid is not emitted on this run stream', () async {
      final seen = <ClaudeEvent>[];
      final sub = ds.startRun(cwd: '/mine', prompt: 'p', mode: ClaudePermissionMode.defaultMode).listen(seen.add);
      addTearDown(sub.cancel);
      await Future<void>.delayed(Duration.zero);

      transport.push({'t': 'textChunk', 'sid': '/someone-else', 'text': 'nope'});
      await Future<void>.delayed(Duration.zero);

      expect(seen, isEmpty);

      // Sanity: an event with the matching sid IS emitted.
      transport.push({'t': 'textChunk', 'sid': '/mine', 'text': 'yes'});
      await Future<void>.delayed(Duration.zero);
      expect(seen, [const ClaudeEvent.textChunk(text: 'yes')]);
    });
  });

  // ---------------------------------------------------------------------------
  // 3. stream completion
  // ---------------------------------------------------------------------------

  group('startRun — stream completes after sessionDead', () {
    test('sessionDead closes the run stream (emits the event then emitsDone)', () async {
      final stream = ds.startRun(cwd: '/w', prompt: 'p', mode: ClaudePermissionMode.defaultMode);

      final expectation = expectLater(
        stream,
        emitsInOrder([isA<ClaudeEventTextChunk>(), isA<ClaudeEventSessionDead>(), emitsDone]),
      );

      await Future<void>.delayed(Duration.zero);
      transport.push({'t': 'textChunk', 'sid': '/w', 'text': 'hi'});
      await Future<void>.delayed(Duration.zero);
      transport.push({'t': 'sessionDead', 'sid': '/w', 'exitCode': 0, 'stderrTail': <String>[]});

      await expectation;
    });
  });

  // ---------------------------------------------------------------------------
  // 4. event mapping — one contract per protocol event type
  // ---------------------------------------------------------------------------

  group('startRun — maps each protocol event to the matching ClaudeEvent variant', () {
    Future<ClaudeEvent> firstEventFor(Map<String, dynamic> raw, {String sid = '/w'}) async {
      final events = <ClaudeEvent>[];
      final sub = ds.startRun(cwd: sid, prompt: 'p', mode: ClaudePermissionMode.defaultMode).listen(events.add);
      addTearDown(sub.cancel);
      await Future<void>.delayed(Duration.zero);
      transport.push(raw);
      await Future<void>.delayed(Duration.zero);
      expect(events, hasLength(1), reason: 'expected exactly one mapped event for $raw');
      return events.single;
    }

    test('sessionInit maps sessionId/model/tools/skills/slashCommands/plugins', () async {
      final event = await firstEventFor({
        't': 'sessionInit',
        'sid': '/w',
        'sessionId': 'sess-1',
        'model': 'claude-opus',
        'tools': ['Bash', 'Read'],
        'skills': ['skill-a'],
        'slashCommands': ['/compact'],
        'plugins': [
          {'name': 'p1', 'path': '/plugins/p1', 'source': 'local'},
        ],
        'mcpServers': <Map<String, dynamic>>[],
      });

      final e = event as ClaudeEventSessionInit;
      expect(e.sessionId, 'sess-1');
      expect(e.model, 'claude-opus');
      expect(e.tools, ['Bash', 'Read']);
      expect(e.skills, ['skill-a']);
      expect(e.slashCommands, ['/compact']);
      expect(e.plugins, [const ClaudePluginInfo(name: 'p1', path: '/plugins/p1', source: 'local')]);
      expect(e.mcpServers, isEmpty);
    });

    test('sessionInit mcpServers: status mapping connected/failed/needs-auth/pending→unknown', () async {
      final event = await firstEventFor({
        't': 'sessionInit',
        'sid': '/w',
        'sessionId': 's',
        'model': 'm',
        'mcpServers': [
          {'name': 'srvA', 'status': 'connected'},
          {'name': 'srvB', 'status': 'failed'},
          {'name': 'srvC', 'status': 'needs-auth'},
          {'name': 'srvD', 'status': 'pending'},
        ],
      });

      final servers = (event as ClaudeEventSessionInit).mcpServers;
      expect(servers, hasLength(4));
      expect(servers[0].status, McpServerStatus.connected);
      expect(servers[1].status, McpServerStatus.failed);
      expect(servers[2].status, McpServerStatus.needsAuth);
      expect(servers[3].status, McpServerStatus.unknown, reason: '"pending" and any other value maps to unknown');
    });

    test('sessionInit mcpServers: displayName strips a leading "claude.ai " prefix', () async {
      final event = await firstEventFor({
        't': 'sessionInit',
        'sid': '/w',
        'sessionId': 's',
        'model': 'm',
        'mcpServers': [
          {'name': 'claude.ai Notion', 'status': 'connected'},
          {'name': 'context7', 'status': 'connected'},
        ],
      });

      final servers = (event as ClaudeEventSessionInit).mcpServers;
      expect(servers[0].name, 'claude.ai Notion', reason: 'raw name is preserved unmodified');
      expect(servers[0].displayName, 'Notion', reason: 'prefix stripped only from displayName');
      expect(servers[1].name, 'context7');
      expect(servers[1].displayName, 'context7', reason: 'no prefix to strip → displayName == name');
    });

    test('textChunk maps text', () async {
      final event = await firstEventFor({'t': 'textChunk', 'sid': '/w', 'text': 'hello'});
      expect(event, const ClaudeEvent.textChunk(text: 'hello'));
    });

    test('toolCall maps toolName/toolId/index', () async {
      final event = await firstEventFor({'t': 'toolCall', 'sid': '/w', 'toolName': 'Bash', 'toolId': 'tid-1', 'index': 2});
      expect(event, const ClaudeEvent.toolCall(toolName: 'Bash', toolId: 'tid-1', index: 2));
    });

    test('toolCallUpdate maps toolId/partialInput', () async {
      final event = await firstEventFor({'t': 'toolCallUpdate', 'sid': '/w', 'toolId': 'tid-1', 'partialInput': '{"comm'});
      expect(event, const ClaudeEvent.toolCallUpdate(toolId: 'tid-1', partialInput: '{"comm'));
    });

    test('toolCallComplete maps index/toolId/input (input already a map)', () async {
      final event = await firstEventFor({
        't': 'toolCallComplete',
        'sid': '/w',
        'index': 0,
        'toolId': 'tid-1',
        'input': {'command': 'ls'},
      });
      final e = event as ClaudeEventToolCallComplete;
      expect(e.index, 0);
      expect(e.toolId, 'tid-1');
      expect(e.input, {'command': 'ls'});
    });

    test('toolCallComplete decodes input when it arrives as a JSON string', () async {
      final event = await firstEventFor({
        't': 'toolCallComplete',
        'sid': '/w',
        'index': 0,
        'toolId': 'tid-1',
        'input': '{"command":"ls"}',
      });
      final e = event as ClaudeEventToolCallComplete;
      expect(e.input, {'command': 'ls'});
    });

    test('toolResult maps toolUseId/content/isError', () async {
      final event = await firstEventFor({
        't': 'toolResult',
        'sid': '/w',
        'toolUseId': 'tid-1',
        'content': 'boom',
        'isError': true,
      });
      expect(event, const ClaudeEvent.toolResult(toolUseId: 'tid-1', content: 'boom', isError: true));
    });

    test('toolResult isError defaults to false when absent', () async {
      final event = await firstEventFor({'t': 'toolResult', 'sid': '/w', 'toolUseId': 'tid-1', 'content': 'ok'});
      expect(event, const ClaudeEvent.toolResult(toolUseId: 'tid-1', content: 'ok', isError: false));
    });

    test('assistantMessage maps text', () async {
      final event = await firstEventFor({'t': 'assistantMessage', 'sid': '/w', 'text': 'final answer'});
      expect(event, const ClaudeEvent.assistantMessage(text: 'final answer'));
    });

    test('usageUpdate maps token counters', () async {
      final event = await firstEventFor({
        't': 'usageUpdate',
        'sid': '/w',
        'inputTokens': 10,
        'cacheReadTokens': 20,
        'cacheCreationTokens': 30,
        'outputTokens': 40,
      });
      expect(
        event,
        const ClaudeEvent.usageUpdate(inputTokens: 10, cacheReadTokens: 20, cacheCreationTokens: 30, outputTokens: 40),
      );
    });

    test('taskComplete maps result/costUsd/durationMs/numTurns', () async {
      final event = await firstEventFor({
        't': 'taskComplete',
        'sid': '/w',
        'result': 'done',
        'costUsd': 0.5,
        'durationMs': 1200,
        'numTurns': 3,
      });
      expect(event, const ClaudeEvent.taskComplete(result: 'done', costUsd: 0.5, durationMs: 1200, numTurns: 3));
    });

    test('errorEvent maps message, defaulting to "unknown" when absent', () async {
      final event = await firstEventFor({'t': 'errorEvent', 'sid': '/w', 'message': 'kaboom'});
      expect(event, const ClaudeEvent.errorEvent(message: 'kaboom'));

      final fallback = await firstEventFor({'t': 'errorEvent', 'sid': '/w2'}, sid: '/w2');
      expect(fallback, const ClaudeEvent.errorEvent(message: 'unknown'));
    });

    test('rateLimit maps status/resetsAt', () async {
      final event = await firstEventFor({'t': 'rateLimit', 'sid': '/w', 'status': 'exceeded', 'resetsAt': 1234567});
      expect(event, const ClaudeEvent.rateLimit(status: 'exceeded', resetsAt: 1234567));
    });

    test('permissionRequest maps toolUseID into requestId, plus toolName/toolInput', () async {
      final event = await firstEventFor({
        't': 'permissionRequest',
        'sid': '/w',
        'toolUseID': 'req-1',
        'toolName': 'Bash',
        'toolInput': {'command': 'rm -rf /'},
      });
      final e = event as ClaudeEventPermissionRequest;
      expect(e.requestId, 'req-1');
      expect(e.toolName, 'Bash');
      expect(e.toolInput, {'command': 'rm -rf /'});
    });

    test('askUserQuestion maps toolUseId and parses questions into AskUserQuestionItem', () async {
      final event = await firstEventFor({
        't': 'askUserQuestion',
        'sid': '/w',
        'toolUseID': 'q1',
        'questions': [
          {
            'question': 'Which framework?',
            'header': 'Framework',
            'multiSelect': false,
            'options': [
              {'label': 'Flutter', 'description': 'Cross-platform'},
              {'label': 'React Native'},
            ],
          },
        ],
      });
      final e = event as ClaudeEventAskUserQuestion;
      expect(e.toolUseId, 'q1');
      expect(e.questions, hasLength(1));
      expect(e.questions.single.question, 'Which framework?');
      expect(e.questions.single.header, 'Framework');
      expect(e.questions.single.multiSelect, isFalse);
      expect(e.questions.single.options, [
        const AskUserQuestionOption(label: 'Flutter', description: 'Cross-platform'),
        const AskUserQuestionOption(label: 'React Native'),
      ]);
    });

    test('planProposed maps toolUseId/plan/planFilePath', () async {
      final event = await firstEventFor({
        't': 'planProposed',
        'sid': '/w',
        'toolUseID': 'pl1',
        'plan': '1. Do a thing',
        'planFilePath': '/tmp/plan.md',
      });
      expect(
        event,
        const ClaudeEvent.planProposed(toolUseId: 'pl1', plan: '1. Do a thing', planFilePath: '/tmp/plan.md'),
      );
    });

    test('an unrecognized event type is dropped (no ClaudeEvent emitted)', () async {
      final events = <ClaudeEvent>[];
      final sub = ds.startRun(cwd: '/w', prompt: 'p', mode: ClaudePermissionMode.defaultMode).listen(events.add);
      addTearDown(sub.cancel);
      await Future<void>.delayed(Duration.zero);

      transport.push({'t': 'someFutureEventType', 'sid': '/w'});
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // 5. answerQuestion replays cached questions
  // ---------------------------------------------------------------------------

  group('answerQuestion — replays the questions cached from askUserQuestion', () {
    test('sends the original questions payload round-tripped, plus the answers map', () async {
      final rawQuestions = [
        {
          'question': 'Which framework?',
          'header': 'Framework',
          'multiSelect': false,
          'options': [
            {'label': 'Flutter', 'description': 'Cross-platform'},
          ],
        },
      ];

      final sub = ds.startRun(cwd: '/w', prompt: 'p', mode: ClaudePermissionMode.defaultMode).listen((_) {});
      addTearDown(sub.cancel);
      await Future<void>.delayed(Duration.zero);

      transport.push({'t': 'askUserQuestion', 'sid': '/w', 'toolUseID': 'q1', 'questions': rawQuestions});
      await Future<void>.delayed(Duration.zero);

      ds.answerQuestion(sid: '/w', toolUseID: 'q1', answers: {'Framework': 'Flutter'});

      final req = transport.sent.last;
      expect(req['t'], 'answerQuestion');
      expect(req['sid'], '/w');
      expect(req['toolUseID'], 'q1');
      expect(req['questions'], rawQuestions, reason: 'must replay the exact cached raw questions payload');
      expect(req['answers'], {'Framework': 'Flutter'});
    });

    test('when no questions were cached for the toolUseID, nothing is sent', () async {
      final sentBefore = transport.sent.length;
      ds.answerQuestion(sid: '/w', toolUseID: 'unknown-tool-use-id', answers: {'x': 'y'});
      expect(transport.sent.length, sentBefore, reason: 'no REQ should be sent without cached questions');
    });
  });

  // ---------------------------------------------------------------------------
  // 6. respondPermission / answerPlan / setMode / stop
  // ---------------------------------------------------------------------------

  group('respondPermission — sends `permission` REQ with the decision', () {
    test('allow:true sends decision:"allow"', () {
      ds.respondPermission(sid: '/w', toolUseID: 'req-1', allow: true);
      expect(transport.sent.single, {'t': 'permission', 'sid': '/w', 'toolUseID': 'req-1', 'decision': 'allow'});
    });

    test('allow:false sends decision:"deny"', () {
      ds.respondPermission(sid: '/w', toolUseID: 'req-1', allow: false);
      expect(transport.sent.single, {'t': 'permission', 'sid': '/w', 'toolUseID': 'req-1', 'decision': 'deny'});
    });

    test('remember:true adds remember:true to the payload', () {
      ds.respondPermission(sid: '/w', toolUseID: 'req-1', allow: true, remember: true);
      expect(transport.sent.single, {
        't': 'permission',
        'sid': '/w',
        'toolUseID': 'req-1',
        'decision': 'allow',
        'remember': true,
      });
    });

    test('remember:false (default) omits the remember key', () {
      ds.respondPermission(sid: '/w', toolUseID: 'req-1', allow: true);
      expect(transport.sent.single.containsKey('remember'), isFalse);
    });
  });

  group('answerPlan — sends `plan` REQ with decision + optional mode', () {
    test('approve:true sends decision:"approve"', () {
      ds.answerPlan(sid: '/w', toolUseID: 'pl1', approve: true);
      expect(transport.sent.single, {'t': 'plan', 'sid': '/w', 'toolUseID': 'pl1', 'decision': 'approve'});
    });

    test('approve:false sends decision:"reject"', () {
      ds.answerPlan(sid: '/w', toolUseID: 'pl1', approve: false);
      expect(transport.sent.single, {'t': 'plan', 'sid': '/w', 'toolUseID': 'pl1', 'decision': 'reject'});
    });

    test('mode is included as its cliFlag when provided', () {
      ds.answerPlan(sid: '/w', toolUseID: 'pl1', approve: true, mode: ClaudePermissionMode.acceptEdits);
      expect(transport.sent.single, {
        't': 'plan',
        'sid': '/w',
        'toolUseID': 'pl1',
        'decision': 'approve',
        'mode': 'acceptEdits',
      });
    });

    test('mode is omitted when not provided', () {
      ds.answerPlan(sid: '/w', toolUseID: 'pl1', approve: true);
      expect(transport.sent.single.containsKey('mode'), isFalse);
    });
  });

  group('setMode — sends `setMode` REQ with the mode cliFlag', () {
    test('sends sid + mode.cliFlag', () {
      ds.setMode(sid: '/w', mode: ClaudePermissionMode.bypassPermissions);
      expect(transport.sent.single, {'t': 'setMode', 'sid': '/w', 'mode': 'bypassPermissions'});
    });
  });

  group('stop — sends `stop` REQ for the given sid', () {
    test('sends t:"stop" + sid', () async {
      await ds.stop(sid: '/w');
      expect(transport.sent.single, {'t': 'stop', 'sid': '/w'});
    });
  });
}
