// [ClaudeSessionsCubit] event→state transitions for the sidecar protocol
// events (see backend/PROTOCOL.md). This file focuses purely on
// `_handleEvent` — how a decoded [ClaudeEvent] arriving on the `sendPrompt`
// stream mutates `ClaudeSessionData` for the currently-running workspace.
//
// Responsibilities under test:
//   1. sessionInit → runStatus becomes `running`.
//   2. planProposed → a `ClaudeMessagePlan` is appended to session messages.
//   3. permissionRequest → a `ClaudeMessagePermissionRequest` is appended.
//   4. taskComplete → runStatus returns to `idle`.
//   5. sessionDead(exitCode != 0) → runStatus becomes `sessionDead` and
//      `stderrTail` is copied onto the session.
//   6. answerPlan(approve: true) → session.permissionMode flips to `auto`
//      and `ClaudeRepository.respondPlan` is called with that mode.
//
// Coverage notes (what is deferred and why): the cubit constructor pulls in
// nine collaborators (SendPrompt, StopRun, ListMcpServers,
// AuthenticateMcpServer, LoadSessionMessages, ClaudeHistoryDataSource,
// WorkspacesCubit, ClaudeRepository, SharedPreferences, Talker). All of them
// are mocked below so the full constructor + `init()` runs for real;
// `WorkspacesCubit` is mocked exactly like the precedent in
// `terminal_sessions_cubit_test.dart` (`extends Mock implements
// WorkspacesCubit`). `SendPrompt.call` is stubbed to return a controllable
// stream so tests drive `_handleEvent` deterministically without touching
// any real process/network.
//
// The `sessionInit → mcpServers merged into the MCP cache` sub-contract is
// covered only indirectly: the cache itself is a private field, and the only
// public read path (`ensureMcpServers`) is TTL-gated by wall-clock time,
// which would make a direct assertion either flaky (real waits) or brittle
// (reaching into private state). We assert the directly observable part
// (runStatus → running) and leave the cache-merge internals to a future
// `@visibleForTesting` seam if that specific bug surface needs coverage.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/core/utils/either.dart';
import 'package:g_claude/features/claude/data/datasources/claude_history_datasource.dart';
import 'package:g_claude/features/claude/domain/entities/claude_event.dart';
import 'package:g_claude/features/claude/domain/entities/claude_message.dart';
import 'package:g_claude/features/claude/domain/entities/claude_permission_mode.dart';
import 'package:g_claude/features/claude/domain/entities/mcp_server.dart';
import 'package:g_claude/features/claude/domain/repositories/claude_repository.dart';
import 'package:g_claude/features/claude/domain/usecases/authenticate_mcp_server.dart';
import 'package:g_claude/features/claude/domain/usecases/list_mcp_servers.dart';
import 'package:g_claude/features/claude/domain/usecases/load_session_messages.dart';
import 'package:g_claude/features/claude/domain/usecases/send_prompt.dart';
import 'package:g_claude/features/claude/domain/usecases/stop_run.dart';
import 'package:g_claude/features/claude/presentation/cubit/claude_sessions_cubit.dart';
import 'package:g_claude/features/workspace/domain/entities/workspace.dart';
import 'package:g_claude/features/workspace/presentation/cubit/workspaces_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/fakes.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockSendPrompt extends Mock implements SendPrompt {}

class _MockStopRun extends Mock implements StopRun {}

class _MockListMcpServers extends Mock implements ListMcpServers {}

class _MockAuthenticateMcpServer extends Mock implements AuthenticateMcpServer {}

class _MockLoadSessionMessages extends Mock implements LoadSessionMessages {}

class _MockClaudeHistoryDataSource extends Mock implements ClaudeHistoryDataSource {}

class _MockWorkspacesCubit extends Mock implements WorkspacesCubit {}

class _MockClaudeRepository extends Mock implements ClaudeRepository {}

// ---------------------------------------------------------------------------
// Fixture
// ---------------------------------------------------------------------------

const _wid = '/proj';

class _Fixture {
  _Fixture({required this.cubit, required this.sendPrompt, required this.repo, required this.runController});

  final ClaudeSessionsCubit cubit;
  final _MockSendPrompt sendPrompt;
  final _MockClaudeRepository repo;
  final StreamController<Either<Failure, ClaudeEvent>> runController;
}

/// Builds a [ClaudeSessionsCubit] wired to mocked collaborators, with a
/// single workspace already present in [WorkspacesCubit]'s state (so a
/// [ClaudeSessionData] entry exists in `state.sessionFor(_wid)` before the
/// test starts driving `sendPrompt`/events).
_Fixture _makeFixture() {
  final sendPrompt = _MockSendPrompt();
  final stopRun = _MockStopRun();
  final listMcpServers = _MockListMcpServers();
  final authenticateMcpServer = _MockAuthenticateMcpServer();
  final loadSessionMessages = _MockLoadSessionMessages();
  final historyDs = _MockClaudeHistoryDataSource();
  final wsCubit = _MockWorkspacesCubit();
  final repo = _MockClaudeRepository();

  final runController = StreamController<Either<Failure, ClaudeEvent>>();

  final ws = Workspace(id: _wid, path: _wid, name: 'proj', openedAt: DateTime.utc(2026, 1, 1));
  when(() => wsCubit.state).thenReturn(WorkspacesState.loaded(workspaces: [ws], activeId: ws.id));
  when(() => wsCubit.stream).thenAnswer((_) => const Stream.empty());

  when(() => sendPrompt.call(any())).thenAnswer((_) => runController.stream);
  when(() => stopRun.call(sid: any(named: 'sid'))).thenAnswer((_) async {});
  when(() => listMcpServers.call()).thenAnswer((_) async => const Right(<McpServer>[]));
  when(
    () => repo.setMode(
      sid: any(named: 'sid'),
      mode: any(named: 'mode'),
    ),
  ).thenReturn(null);
  when(
    () => repo.respondPlan(
      sid: any(named: 'sid'),
      toolUseId: any(named: 'toolUseId'),
      approve: any(named: 'approve'),
      mode: any(named: 'mode'),
    ),
  ).thenReturn(null);
  when(
    () => repo.respondPermission(
      sid: any(named: 'sid'),
      toolUseId: any(named: 'toolUseId'),
      decision: any(named: 'decision'),
    ),
  ).thenReturn(null);

  final cubit = ClaudeSessionsCubit(
    sendPrompt,
    stopRun,
    listMcpServers,
    authenticateMcpServer,
    loadSessionMessages,
    historyDs,
    wsCubit,
    repo,
    _sharedPrefs,
    makeTestTalker(),
  );
  cubit.init();

  return _Fixture(cubit: cubit, sendPrompt: sendPrompt, repo: repo, runController: runController);
}

late SharedPreferences _sharedPrefs;

Future<void> _drain() => Future<void>.delayed(Duration.zero);

/// Drives `sendPrompt(...)` to put the cubit into a running state wired to
/// [fixture.runController], then drains the microtask queue so the
/// `_runSub.listen` in the cubit is attached before the test pushes events.
Future<void> _startRun(_Fixture fixture) async {
  await fixture.cubit.sendPrompt(_wid, 'hello');
  await _drain();
}

void main() {
  setUpAll(() {
    registerFallbackValue(ClaudePermissionMode.defaultMode);
    registerFallbackValue(ClaudePermissionDecision.allowOnce);
    registerFallbackValue(const SendPromptParams(cwd: '/fallback', prompt: '', mode: ClaudePermissionMode.defaultMode));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _sharedPrefs = await SharedPreferences.getInstance();
  });

  // ---------------------------------------------------------------------------
  // 1. sessionInit
  // ---------------------------------------------------------------------------

  group('sessionInit — runStatus becomes running', () {
    test('runStatus transitions connecting → running on sessionInit', () async {
      final fixture = _makeFixture();
      await _startRun(fixture);

      expect(fixture.cubit.state.sessionFor(_wid)?.runStatus, ClaudeRunStatus.connecting);

      fixture.runController.add(const Right(ClaudeEvent.sessionInit(sessionId: 'sess-1', model: 'claude-opus')));
      await _drain();

      expect(fixture.cubit.state.sessionFor(_wid)?.runStatus, ClaudeRunStatus.running);
      expect(fixture.cubit.state.sessionFor(_wid)?.claudeSessionId, 'sess-1');

      await fixture.cubit.close();
    });
  });

  // ---------------------------------------------------------------------------
  // 2. planProposed
  // ---------------------------------------------------------------------------

  group('planProposed — appends a ClaudeMessagePlan to session messages', () {
    test('a planProposed event appends a plan card carrying toolUseId/plan/planFilePath', () async {
      final fixture = _makeFixture();
      await _startRun(fixture);

      fixture.runController.add(
        const Right(ClaudeEvent.planProposed(toolUseId: 'pl1', plan: '1. Do the thing', planFilePath: '/tmp/plan.md')),
      );
      await _drain();

      final messages = fixture.cubit.state.sessionFor(_wid)!.messages;
      final planMessage = messages.whereType<ClaudeMessagePlan>().single;
      expect(planMessage.toolUseId, 'pl1');
      expect(planMessage.plan, '1. Do the thing');
      expect(planMessage.planFilePath, '/tmp/plan.md');
      expect(planMessage.answered, isFalse);

      await fixture.cubit.close();
    });
  });

  // ---------------------------------------------------------------------------
  // 3. permissionRequest
  // ---------------------------------------------------------------------------

  group('permissionRequest — appends a ClaudeMessagePermissionRequest to session messages', () {
    test('a permissionRequest event appends a permission card carrying requestId/toolName/toolInput', () async {
      final fixture = _makeFixture();
      await _startRun(fixture);

      fixture.runController.add(
        const Right(ClaudeEvent.permissionRequest(requestId: 'req-1', toolName: 'Bash', toolInput: {'command': 'ls'})),
      );
      await _drain();

      final messages = fixture.cubit.state.sessionFor(_wid)!.messages;
      final permissionMessage = messages.whereType<ClaudeMessagePermissionRequest>().single;
      expect(permissionMessage.requestId, 'req-1');
      expect(permissionMessage.toolName, 'Bash');
      expect(permissionMessage.toolInput, {'command': 'ls'});
      expect(permissionMessage.answered, isFalse);

      await fixture.cubit.close();
    });
  });

  // ---------------------------------------------------------------------------
  // 4. taskComplete
  // ---------------------------------------------------------------------------

  group('taskComplete — runStatus returns to idle', () {
    test('taskComplete flips runStatus back to idle', () async {
      final fixture = _makeFixture();
      await _startRun(fixture);

      fixture.runController.add(const Right(ClaudeEvent.sessionInit(sessionId: 'sess-1', model: 'claude-opus')));
      await _drain();
      expect(fixture.cubit.state.sessionFor(_wid)?.runStatus, ClaudeRunStatus.running);

      fixture.runController.add(const Right(ClaudeEvent.taskComplete(result: 'done')));
      await _drain();

      expect(fixture.cubit.state.sessionFor(_wid)?.runStatus, ClaudeRunStatus.idle);

      await fixture.cubit.close();
    });
  });

  // ---------------------------------------------------------------------------
  // 5. sessionDead
  // ---------------------------------------------------------------------------

  group('sessionDead — exitCode != 0 sets runStatus sessionDead and stores stderrTail', () {
    test('exitCode 1 sets runStatus to sessionDead and copies stderrTail onto the session', () async {
      final fixture = _makeFixture();
      await _startRun(fixture);

      fixture.runController.add(
        const Right(ClaudeEvent.sessionDead(exitCode: 1, stderrTail: ['fatal: boom', 'stack trace...'])),
      );
      await _drain();

      final session = fixture.cubit.state.sessionFor(_wid)!;
      expect(session.runStatus, ClaudeRunStatus.sessionDead);
      expect(session.stderrTail, ['fatal: boom', 'stack trace...']);
      expect(session.lastError, isA<SubprocessFailure>());

      await fixture.cubit.close();
    });

    test('exitCode 0 is treated as a clean exit: runStatus idle, no failure recorded', () async {
      final fixture = _makeFixture();
      await _startRun(fixture);

      fixture.runController.add(const Right(ClaudeEvent.sessionDead(exitCode: 0, stderrTail: [])));
      await _drain();

      final session = fixture.cubit.state.sessionFor(_wid)!;
      expect(session.runStatus, ClaudeRunStatus.idle);
      expect(session.lastError, isNull);

      await fixture.cubit.close();
    });
  });

  // ---------------------------------------------------------------------------
  // 6. answerPlan(approve: true)
  // ---------------------------------------------------------------------------

  group('answerPlan(approve: true) — switches permissionMode to auto and forwards to the repository', () {
    test('approving a plan sets session.permissionMode to auto and calls respondPlan with mode auto', () async {
      final fixture = _makeFixture();
      await _startRun(fixture);

      fixture.runController.add(const Right(ClaudeEvent.planProposed(toolUseId: 'pl1', plan: 'plan text')));
      await _drain();

      final planMessage = fixture.cubit.state.sessionFor(_wid)!.messages.whereType<ClaudeMessagePlan>().single;

      fixture.cubit.answerPlan(_wid, planMessage.id, true);
      await _drain();

      expect(fixture.cubit.state.sessionFor(_wid)?.permissionMode, ClaudePermissionMode.auto);
      final updatedPlan = fixture.cubit.state.sessionFor(_wid)!.messages.whereType<ClaudeMessagePlan>().single;
      expect(updatedPlan.answered, isTrue);
      expect(updatedPlan.approved, isTrue);

      verify(
        () => fixture.repo.respondPlan(sid: _wid, toolUseId: 'pl1', approve: true, mode: ClaudePermissionMode.auto),
      ).called(1);

      await fixture.cubit.close();
    });

    test(
      'rejecting a plan leaves permissionMode unchanged and calls respondPlan with approve:false, mode:null',
      () async {
        final fixture = _makeFixture();
        await _startRun(fixture);

        fixture.runController.add(const Right(ClaudeEvent.planProposed(toolUseId: 'pl2', plan: 'plan text')));
        await _drain();

        final before = fixture.cubit.state.sessionFor(_wid)!.permissionMode;
        final planMessage = fixture.cubit.state.sessionFor(_wid)!.messages.whereType<ClaudeMessagePlan>().single;

        fixture.cubit.answerPlan(_wid, planMessage.id, false);
        await _drain();

        expect(fixture.cubit.state.sessionFor(_wid)?.permissionMode, before, reason: 'rejecting must not change mode');

        verify(() => fixture.repo.respondPlan(sid: _wid, toolUseId: 'pl2', approve: false, mode: null)).called(1);

        await fixture.cubit.close();
      },
    );
  });
}
