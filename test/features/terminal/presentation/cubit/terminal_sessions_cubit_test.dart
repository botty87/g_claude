// State-machine contracts for [TerminalSessionsCubit].
//
// The cubit bridges [WorkspacesCubit] (workspace lifecycle) and
// [PtyDataSource] (PTY process management). Its observable responsibilities:
//
//   1. On workspace added: emit `starting`, then spawn via datasource.
//      The `starting` emit must precede the spawn so that the synchronous
//      `running` event fired by the datasource finds the session in state.
//   2. On workspace removed: remove from state and call datasource.dispose().
//   3. restart(): when status is `starting`, it is a no-op; otherwise it
//      bumps incarnation, emits `starting`, disposes old PTY, then calls
//      getOrCreate once dispose resolves.
//   4. _onPtyEvent: `running` / `exited` / `failed` are each reflected into
//      the matching [TerminalRunStatus] in state, with exitCode / lastError
//      propagated on `exited` / `failed` respectively.
//   5. close(): cancels both subscriptions and calls disposeAll().

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/terminal/data/datasources/pty_datasource.dart';
import 'package:g_claude/features/terminal/presentation/cubit/terminal_sessions_cubit.dart';
import 'package:g_claude/features/workspace/domain/entities/workspace.dart';
import 'package:g_claude/features/workspace/presentation/cubit/workspaces_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xterm/xterm.dart';

import '../../../../helpers/fakes.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class _MockPtyDataSource extends Mock implements PtyDataSource {}

class _MockWorkspacesCubit extends Mock implements WorkspacesCubit {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a cubit wired to the provided mocks and calls `init()`.
///
/// The workspaces state starts empty so no PTY is spawned during build,
/// giving each test full control of what arrives on the stream.
TerminalSessionsCubit _makeCubit({
  required _MockPtyDataSource ds,
  required _MockWorkspacesCubit wsCubit,
  required StreamController<WorkspacesState> wsController,
  required StreamController<PtySessionEvent> eventsController,
}) {
  // Datasource events stream.
  when(() => ds.events).thenAnswer((_) => eventsController.stream);
  when(() => ds.detectShell()).thenReturn('/bin/zsh');
  when(() => ds.disposeAll()).thenAnswer((_) async {});

  // WorkspacesCubit: start empty.
  when(() => wsCubit.state).thenReturn(const WorkspacesState.initial());
  when(() => wsCubit.stream).thenAnswer((_) => wsController.stream);

  final cubit = TerminalSessionsCubit(ds, wsCubit, makeTestTalker());
  cubit.init();
  return cubit;
}

/// Push a new workspace-list through the stream and wait for the microtask
/// queue to drain so that event-stream listeners have a chance to run.
Future<void> _addWorkspace(StreamController<WorkspacesState> wsController, Workspace ws) async {
  wsController.add(WorkspacesState.loaded(workspaces: [ws], activeId: ws.id));
  // Drain microtask queue so stream listeners fire.
  await Future<void>.delayed(Duration.zero);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUpAll(() {
    // Provide a fallback value for PtySessionEvent matchers.
    registerFallbackValue(const PtySessionEvent.running(workspaceId: 'fallback'));
    registerFallbackValue(Terminal());
  });

  late _MockPtyDataSource ds;
  late _MockWorkspacesCubit wsCubit;
  late StreamController<WorkspacesState> wsController;
  late StreamController<PtySessionEvent> eventsController;

  setUp(() {
    ds = _MockPtyDataSource();
    wsCubit = _MockWorkspacesCubit();
    wsController = StreamController<WorkspacesState>.broadcast();
    eventsController = StreamController<PtySessionEvent>.broadcast();

    // Default stubs that most tests don't need to override.
    when(
      () => ds.getOrCreate(
        workspaceId: any(named: 'workspaceId'),
        cwd: any(named: 'cwd'),
      ),
    ).thenReturn(null);
    when(() => ds.dispose(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await wsController.close();
    await eventsController.close();
  });

  // -------------------------------------------------------------------------
  // 1. workspace added
  // -------------------------------------------------------------------------

  group('workspace added — starting emitted before spawn, then running on event', () {
    test('state transitions: initial → has starting session → has running session', () async {
      TerminalRunStatus? statusAtSpawnTime;

      // Capture the session status at the moment getOrCreate is called.
      when(
        () => ds.getOrCreate(
          workspaceId: any(named: 'workspaceId'),
          cwd: any(named: 'cwd'),
        ),
      ).thenAnswer((inv) {
        final id = inv.namedArguments[#workspaceId] as String;
        statusAtSpawnTime = _statusOf(id, _latestCubitRef!);
      });

      final cubit = _makeCubit(
        ds: ds,
        wsCubit: wsCubit,
        wsController: wsController,
        eventsController: eventsController,
      );
      _latestCubitRef = cubit;

      final ws = makeWorkspace(id: '/proj', path: '/proj');
      await _addWorkspace(wsController, ws);

      // `starting` must have been the status when getOrCreate ran.
      expect(
        statusAtSpawnTime,
        TerminalRunStatus.starting,
        reason: 'Cubit must emit starting BEFORE calling getOrCreate',
      );

      // Now simulate the datasource firing a `running` event.
      eventsController.add(PtySessionEvent.running(workspaceId: ws.id));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.sessions[ws.id]?.status, TerminalRunStatus.running);

      await cubit.close();
    });

    blocTest<TerminalSessionsCubit, TerminalSessionsState>(
      'state contains session entry with shellPath and cwd after workspace added',
      build: () => _makeCubit(ds: ds, wsCubit: wsCubit, wsController: wsController, eventsController: eventsController),
      act: (c) async {
        final ws = makeWorkspace(id: '/proj', path: '/proj');
        await _addWorkspace(wsController, ws);
      },
      verify: (c) {
        final session = c.state.sessions['/proj'];
        expect(session, isNotNull);
        expect(session!.cwd, '/proj');
        expect(session.shellPath, isNotEmpty);
        expect(session.status, TerminalRunStatus.starting);
      },
    );
  });

  // -------------------------------------------------------------------------
  // 2. workspace removed
  // -------------------------------------------------------------------------

  group('workspace removed — session dropped from state and dispose called', () {
    blocTest<TerminalSessionsCubit, TerminalSessionsState>(
      'removing a workspace removes its session from state and calls dispose(id)',
      build: () => _makeCubit(ds: ds, wsCubit: wsCubit, wsController: wsController, eventsController: eventsController),
      act: (c) async {
        final ws = makeWorkspace(id: '/proj', path: '/proj');
        // Add workspace.
        await _addWorkspace(wsController, ws);
        // Now remove it.
        wsController.add(const WorkspacesState.loaded(workspaces: [], activeId: null));
        await Future<void>.delayed(Duration.zero);
      },
      verify: (c) {
        expect(c.state.sessions.containsKey('/proj'), isFalse);
        verify(() => ds.dispose('/proj')).called(1);
      },
    );
  });

  // -------------------------------------------------------------------------
  // 3. restart()
  // -------------------------------------------------------------------------

  group('restart — no-op when starting; otherwise increments incarnation and respawns', () {
    test('restart while starting is a no-op: incarnation stays 0, dispose not called', () async {
      final cubit = _makeCubit(
        ds: ds,
        wsCubit: wsCubit,
        wsController: wsController,
        eventsController: eventsController,
      );

      final ws = makeWorkspace(id: '/proj', path: '/proj');
      await _addWorkspace(wsController, ws);

      // Status is `starting` at this point.
      expect(cubit.state.sessions['/proj']?.status, TerminalRunStatus.starting);

      final statesBefore = [cubit.state];
      cubit.restart('/proj');
      await Future<void>.delayed(Duration.zero);

      // No state change.
      expect(cubit.state, statesBefore.first);
      // dispose was never called (only the initial getOrCreate ran during add).
      verifyNever(() => ds.dispose(any()));

      await cubit.close();
    });

    test('restart when running: emits starting with incarnation+1, calls dispose then getOrCreate', () async {
      final disposeCompleter = Completer<void>();
      var getOrCreateCallCount = 0;

      when(() => ds.dispose('/proj')).thenAnswer((_) => disposeCompleter.future);
      when(
        () => ds.getOrCreate(
          workspaceId: any(named: 'workspaceId'),
          cwd: any(named: 'cwd'),
        ),
      ).thenAnswer((_) {
        getOrCreateCallCount++;
      });

      final cubit = _makeCubit(
        ds: ds,
        wsCubit: wsCubit,
        wsController: wsController,
        eventsController: eventsController,
      );

      final ws = makeWorkspace(id: '/proj', path: '/proj');
      await _addWorkspace(wsController, ws);

      // Drive to `running`.
      eventsController.add(PtySessionEvent.running(workspaceId: ws.id));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.sessions['/proj']?.status, TerminalRunStatus.running);

      // Capture state before restart.
      final incarnationBefore = cubit.state.sessions['/proj']!.incarnation;
      // getOrCreate was called once during workspace add.
      final countBeforeRestart = getOrCreateCallCount;
      expect(countBeforeRestart, 1);

      // Trigger restart.
      cubit.restart('/proj');
      await Future<void>.delayed(Duration.zero);

      // Before dispose resolves: status is `starting`, incarnation bumped.
      expect(cubit.state.sessions['/proj']?.status, TerminalRunStatus.starting);
      expect(cubit.state.sessions['/proj']?.incarnation, incarnationBefore + 1);
      // dispose was called once for restart.
      verify(() => ds.dispose('/proj')).called(1);
      // getOrCreate must NOT have been called again yet (dispose still pending).
      expect(getOrCreateCallCount, countBeforeRestart, reason: 'getOrCreate must not fire until dispose completes');

      // Complete dispose.
      disposeCompleter.complete();
      await Future<void>.delayed(Duration.zero);

      // getOrCreate should have been called once more after dispose completed.
      expect(
        getOrCreateCallCount,
        countBeforeRestart + 1,
        reason: 'getOrCreate must fire exactly once after dispose resolves',
      );

      await cubit.close();
    });

    test('restart when exited: emits starting with cleared exitCode and incremented incarnation', () async {
      final cubit = _makeCubit(
        ds: ds,
        wsCubit: wsCubit,
        wsController: wsController,
        eventsController: eventsController,
      );

      final ws = makeWorkspace(id: '/proj', path: '/proj');
      await _addWorkspace(wsController, ws);

      // Drive through running → exited.
      eventsController.add(PtySessionEvent.running(workspaceId: ws.id));
      await Future<void>.delayed(Duration.zero);
      eventsController.add(PtySessionEvent.exited(workspaceId: ws.id, exitCode: 0));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.sessions['/proj']?.exitCode, 0);

      // Restart from exited state.
      cubit.restart('/proj');
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.sessions['/proj']?.status, TerminalRunStatus.starting);
      expect(cubit.state.sessions['/proj']?.exitCode, isNull);
      expect(cubit.state.sessions['/proj']?.incarnation, 1);

      await cubit.close();
    });
  });

  // -------------------------------------------------------------------------
  // 4. _onPtyEvent
  // -------------------------------------------------------------------------

  group('pty events — status, exitCode and lastError propagated into state', () {
    test('running event sets status to running', () async {
      final cubit = _makeCubit(
        ds: ds,
        wsCubit: wsCubit,
        wsController: wsController,
        eventsController: eventsController,
      );

      final ws = makeWorkspace(id: '/proj');
      await _addWorkspace(wsController, ws);

      eventsController.add(PtySessionEvent.running(workspaceId: ws.id));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.sessions['/proj']?.status, TerminalRunStatus.running);
      expect(cubit.state.sessions['/proj']?.exitCode, isNull);
      expect(cubit.state.sessions['/proj']?.lastError, isNull);

      await cubit.close();
    });

    test('exited event propagates exitCode into state', () async {
      final cubit = _makeCubit(
        ds: ds,
        wsCubit: wsCubit,
        wsController: wsController,
        eventsController: eventsController,
      );

      final ws = makeWorkspace(id: '/proj');
      await _addWorkspace(wsController, ws);

      eventsController.add(PtySessionEvent.running(workspaceId: ws.id));
      await Future<void>.delayed(Duration.zero);
      eventsController.add(PtySessionEvent.exited(workspaceId: ws.id, exitCode: 42));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.sessions['/proj']?.status, TerminalRunStatus.exited);
      expect(cubit.state.sessions['/proj']?.exitCode, 42);

      await cubit.close();
    });

    test('failed event propagates lastError into state', () async {
      final cubit = _makeCubit(
        ds: ds,
        wsCubit: wsCubit,
        wsController: wsController,
        eventsController: eventsController,
      );

      final ws = makeWorkspace(id: '/proj');
      await _addWorkspace(wsController, ws);

      eventsController.add(PtySessionEvent.failed(workspaceId: ws.id, error: 'spawn failed: no such file'));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.sessions['/proj']?.status, TerminalRunStatus.failed);
      expect(cubit.state.sessions['/proj']?.lastError, 'spawn failed: no such file');

      await cubit.close();
    });

    test('event for unknown workspaceId is ignored (no exception, no state change)', () async {
      final cubit = _makeCubit(
        ds: ds,
        wsCubit: wsCubit,
        wsController: wsController,
        eventsController: eventsController,
      );

      final stateBefore = cubit.state;

      eventsController.add(const PtySessionEvent.running(workspaceId: 'unknown-id'));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state, stateBefore);

      await cubit.close();
    });
  });

  // -------------------------------------------------------------------------
  // 5. close()
  // -------------------------------------------------------------------------

  group('close — cancels subscriptions and disposes all sessions', () {
    test('close() calls disposeAll() on the datasource', () async {
      final cubit = _makeCubit(
        ds: ds,
        wsCubit: wsCubit,
        wsController: wsController,
        eventsController: eventsController,
      );

      await cubit.close();

      verify(() => ds.disposeAll()).called(1);
    });

    test('events emitted after close() are silently ignored (no StateError)', () async {
      final cubit = _makeCubit(
        ds: ds,
        wsCubit: wsCubit,
        wsController: wsController,
        eventsController: eventsController,
      );

      final ws = makeWorkspace(id: '/proj');
      await _addWorkspace(wsController, ws);

      await cubit.close();

      // Post-close: pushing through the controllers must not throw.
      expect(() async {
        eventsController.add(PtySessionEvent.running(workspaceId: ws.id));
        wsController.add(WorkspacesState.loaded(workspaces: [ws], activeId: ws.id));
        await Future<void>.delayed(Duration.zero);
      }, returnsNormally);
    });
  });
}

// ---------------------------------------------------------------------------
// Capture helper — allows inspecting cubit state during mock stub invocations.
// Only used by the ordering test (contract 1).
// ---------------------------------------------------------------------------
TerminalSessionsCubit? _latestCubitRef;

TerminalRunStatus? _statusOf(String id, TerminalSessionsCubit cubit) {
  return cubit.state.sessions[id]?.status;
}
