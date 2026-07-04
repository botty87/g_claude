// Contracts for `WorkspacesCubit`.
//
// The cubit owns the multi-workspace tab list, the activeId, and persistence
// of both. It is a `@lazySingleton` because it survives navigation; restore
// runs once at boot and feeds downstream cubits via stream subscription.
//
// Tests focus on observable state transitions for the user-facing actions:
// open / close / setActive / restore. Persistence is mocked so we can pin
// the debounce contract without burning real time on disk.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/core/utils/either.dart';
import 'package:g_claude/features/git/domain/usecases/add_worktree.dart';
import 'package:g_claude/features/git/domain/usecases/delete_branch.dart';
import 'package:g_claude/features/git/domain/usecases/inspect_folder.dart';
import 'package:g_claude/features/git/domain/usecases/list_branches.dart';
import 'package:g_claude/features/git/domain/usecases/list_worktrees.dart';
import 'package:g_claude/features/git/domain/usecases/remove_worktree.dart';
import 'package:g_claude/features/workspace/data/datasources/workspace_file_watcher.dart';
import 'package:g_claude/features/workspace/data/datasources/workspaces_persistence_datasource.dart';
import 'package:g_claude/features/workspace/domain/entities/workspace.dart';
import 'package:g_claude/features/workspace/domain/usecases/open_workspace.dart';
import 'package:g_claude/features/workspace/presentation/cubit/workspaces_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';

class _MockOpenWs extends Mock implements OpenWorkspace {}

class _MockListWorktrees extends Mock implements ListWorktrees {}

class _MockRemoveWorktree extends Mock implements RemoveWorktree {}

class _MockDeleteBranch extends Mock implements DeleteBranch {}

class _MockAddWorktree extends Mock implements AddWorktree {}

class _MockListBranches extends Mock implements ListBranches {}

class _MockInspectFolder extends Mock implements InspectFolder {}

class _MockPersistence extends Mock implements WorkspacesPersistenceDataSource {}

class _MockWatcher extends Mock implements WorkspaceFileWatcher {}

Workspace _ws(String path, {DateTime? openedAt}) {
  return Workspace(id: path, path: path, name: path.split('/').last, openedAt: openedAt ?? DateTime.utc(2026, 1, 1));
}

void main() {
  setUpAll(() {
    registerFallbackValue(PersistedWorkspaces(activeId: null, workspaces: const []));
  });

  late _MockOpenWs openWs;
  late _MockListWorktrees listWorktrees;
  late _MockRemoveWorktree removeWorktreeUsecase;
  late _MockDeleteBranch deleteBranchUsecase;
  late _MockAddWorktree addWorktreeUsecase;
  late _MockListBranches listBranchesUsecase;
  late _MockInspectFolder inspectFolderUsecase;
  late _MockPersistence persistence;
  late _MockWatcher watcher;

  setUp(() {
    openWs = _MockOpenWs();
    listWorktrees = _MockListWorktrees();
    removeWorktreeUsecase = _MockRemoveWorktree();
    deleteBranchUsecase = _MockDeleteBranch();
    addWorktreeUsecase = _MockAddWorktree();
    listBranchesUsecase = _MockListBranches();
    inspectFolderUsecase = _MockInspectFolder();
    persistence = _MockPersistence();
    watcher = _MockWatcher();
    // Default stubs.
    when(() => persistence.read()).thenAnswer((_) async => null);
    when(() => persistence.write(any())).thenAnswer((_) async {});
    when(() => watcher.dispose(any())).thenAnswer((_) async {});
  });

  WorkspacesCubit make() {
    final cubit = WorkspacesCubit(
      openWs,
      listWorktrees,
      removeWorktreeUsecase,
      deleteBranchUsecase,
      addWorktreeUsecase,
      listBranchesUsecase,
      inspectFolderUsecase,
      persistence,
      watcher,
      makeTestTalker(),
    );
    cubit.init();
    return cubit;
  }

  group('openPath — happy path', () {
    blocTest<WorkspacesCubit, WorkspacesState>(
      'opens a path: emits loaded with the new workspace + activeId == its id',
      build: () {
        when(() => openWs(path: any(named: 'path'))).thenAnswer((_) async => Right(_ws('/Users/me/proj')));
        return make();
      },
      act: (c) => c.openPath('/Users/me/proj'),
      expect: () => [
        isA<WorkspacesStateLoaded>()
            .having((s) => s.workspaces.length, 'count', 1)
            .having((s) => s.workspaces.first.id, 'id', '/Users/me/proj')
            .having((s) => s.activeId, 'activeId', '/Users/me/proj'),
      ],
    );
  });

  group('openPath — duplicate path activates existing tab without re-opening', () {
    blocTest<WorkspacesCubit, WorkspacesState>(
      'asking to open an already-open workspace switches activeId only',
      build: () {
        when(() => openWs(path: any(named: 'path'))).thenAnswer((_) async => Right(_ws('/x')));
        return make();
      },
      act: (c) async {
        // First open.
        await c.openPath('/x');
        // Open another and switch active off.
        when(() => openWs(path: any(named: 'path'))).thenAnswer((_) async => Right(_ws('/y')));
        await c.openPath('/y');
        // Now ask again for /x → must NOT call openWs, just activate.
        await c.openPath('/x');
      },
      verify: (c) {
        expect(c.state.workspacesOrEmpty.map((w) => w.id), ['/x', '/y']);
        expect(c.state.activeIdOrNull, '/x');
        // openWs called twice (for /x and /y), NOT three times.
        verify(() => openWs(path: any(named: 'path'))).called(2);
      },
    );
  });

  group('openPath — failure surfaces lastFailure but keeps the existing list', () {
    blocTest<WorkspacesCubit, WorkspacesState>(
      'invalid path emits a loaded state carrying lastFailure, list unchanged',
      build: () {
        when(() => openWs(path: any(named: 'path'))).thenAnswer((_) async => Right(_ws('/x')));
        return make();
      },
      act: (c) async {
        await c.openPath('/x');
        when(
          () => openWs(path: any(named: 'path')),
        ).thenAnswer((_) async => Left(NotFoundFailure('Directory does not exist: /missing')));
        await c.openPath('/missing');
      },
      verify: (c) {
        expect(c.state.workspacesOrEmpty.map((w) => w.id), ['/x']);
        expect((c.state as WorkspacesStateLoaded).lastFailure, isA<NotFoundFailure>());
      },
    );
  });

  group('closeWorkspace', () {
    blocTest<WorkspacesCubit, WorkspacesState>(
      'closing the active workspace shifts activeId to a sibling, list shrinks',
      build: () {
        when(() => openWs(path: '/x')).thenAnswer((_) async => Right(_ws('/x')));
        when(() => openWs(path: '/y')).thenAnswer((_) async => Right(_ws('/y')));
        when(() => openWs(path: '/z')).thenAnswer((_) async => Right(_ws('/z')));
        return make();
      },
      act: (c) async {
        await c.openPath('/x');
        await c.openPath('/y');
        await c.openPath('/z');
        // Now activeId == '/z'. Close it.
        c.closeWorkspace('/z');
      },
      verify: (c) {
        // Closing /z (last) → next active is /y (the previous neighbor).
        expect(c.state.workspacesOrEmpty.map((w) => w.id), ['/x', '/y']);
        expect(c.state.activeIdOrNull, '/y');
      },
    );

    blocTest<WorkspacesCubit, WorkspacesState>(
      'closing the only workspace empties the list and clears activeId',
      build: () {
        when(() => openWs(path: any(named: 'path'))).thenAnswer((_) async => Right(_ws('/x')));
        return make();
      },
      act: (c) async {
        await c.openPath('/x');
        c.closeWorkspace('/x');
      },
      verify: (c) {
        expect(c.state.workspacesOrEmpty, isEmpty);
        expect(c.state.activeIdOrNull, isNull);
      },
    );

    blocTest<WorkspacesCubit, WorkspacesState>(
      'closing a non-active workspace keeps activeId unchanged',
      build: () {
        when(() => openWs(path: '/x')).thenAnswer((_) async => Right(_ws('/x')));
        when(() => openWs(path: '/y')).thenAnswer((_) async => Right(_ws('/y')));
        return make();
      },
      act: (c) async {
        await c.openPath('/x');
        await c.openPath('/y');
        // activeId == '/y'. Close /x.
        c.closeWorkspace('/x');
      },
      verify: (c) {
        expect(c.state.workspacesOrEmpty.map((w) => w.id), ['/y']);
        expect(c.state.activeIdOrNull, '/y');
      },
    );

    blocTest<WorkspacesCubit, WorkspacesState>(
      'closing a non-existent id is a no-op (no emit, no exception)',
      build: () {
        when(() => openWs(path: any(named: 'path'))).thenAnswer((_) async => Right(_ws('/x')));
        return make();
      },
      seed: () => WorkspacesState.loaded(workspaces: [_ws('/x')], activeId: '/x'),
      act: (c) => c.closeWorkspace('/never-opened'),
      expect: () => const <WorkspacesState>[],
    );
  });

  group('removeWorktree', () {
    // Pure mocks: after moving the idempotent `Directory.exists()` guard into
    // GitWorktreeDataSource, the cubit does no filesystem I/O, so tests need no
    // real temp dirs.
    Workspace wt({String? branch}) =>
        makeWorkspace(id: '/repo/wt', path: '/repo/wt', repoRoot: '/repo', branch: branch);

    WorkspacesCubit loadedWith(Workspace ws) {
      final cubit = make();
      cubit.emit(WorkspacesState.loaded(workspaces: [ws], activeId: ws.id));
      return cubit;
    }

    test('success closes the workspace and shrinks the list', () async {
      when(
        () => removeWorktreeUsecase(
          repoRoot: any(named: 'repoRoot'),
          worktreePath: any(named: 'worktreePath'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final cubit = loadedWith(wt(branch: 'feature/x'));
      final result = await cubit.removeWorktree('/repo/wt');

      expect(result.isRight, isTrue);
      expect(cubit.state.workspacesOrEmpty, isEmpty);
      await cubit.close();
    });

    test('git failure on the worktree-remove step returns Left AND keeps the workspace open', () async {
      when(
        () => removeWorktreeUsecase(
          repoRoot: any(named: 'repoRoot'),
          worktreePath: any(named: 'worktreePath'),
        ),
      ).thenAnswer((_) async => const Left(SubprocessFailure(message: 'contains modified files')));

      final cubit = loadedWith(wt(branch: 'feature/x'));
      final result = await cubit.removeWorktree('/repo/wt');

      expect(result.isLeft, isTrue);
      expect(cubit.state.workspacesOrEmpty, hasLength(1));
      await cubit.close();
    });

    test('deleteBranch:true runs both git operations and closes on full success', () async {
      when(
        () => removeWorktreeUsecase(
          repoRoot: any(named: 'repoRoot'),
          worktreePath: any(named: 'worktreePath'),
        ),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => deleteBranchUsecase(
          repoRoot: any(named: 'repoRoot'),
          branch: any(named: 'branch'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final cubit = loadedWith(wt(branch: 'feature/x'));
      await cubit.removeWorktree('/repo/wt', deleteBranch: true);

      expect(cubit.state.workspacesOrEmpty, isEmpty);
      verify(
        () => removeWorktreeUsecase(
          repoRoot: any(named: 'repoRoot'),
          worktreePath: any(named: 'worktreePath'),
        ),
      ).called(1);
      verify(() => deleteBranchUsecase(repoRoot: '/repo', branch: 'feature/x')).called(1);
      await cubit.close();
    });

    test('branch-delete failure after a successful worktree removal returns Left and keeps the tab open', () async {
      when(
        () => removeWorktreeUsecase(
          repoRoot: any(named: 'repoRoot'),
          worktreePath: any(named: 'worktreePath'),
        ),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => deleteBranchUsecase(
          repoRoot: any(named: 'repoRoot'),
          branch: any(named: 'branch'),
        ),
      ).thenAnswer((_) async => const Left(SubprocessFailure(message: 'branch not fully merged')));

      final cubit = loadedWith(wt(branch: 'feature/x'));
      final result = await cubit.removeWorktree('/repo/wt', deleteBranch: true);

      expect(result.isLeft, isTrue, reason: 'the branch error is surfaced');
      expect(cubit.state.workspacesOrEmpty, hasLength(1), reason: 'partial failure keeps the tab open');
      await cubit.close();
    });

    test('[branch] argument overrides the workspace field so the deleted branch matches what the UI showed', () async {
      when(
        () => removeWorktreeUsecase(
          repoRoot: any(named: 'repoRoot'),
          worktreePath: any(named: 'worktreePath'),
        ),
      ).thenAnswer((_) async => const Right(null));
      when(
        () => deleteBranchUsecase(
          repoRoot: any(named: 'repoRoot'),
          branch: any(named: 'branch'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Workspace's own branch field is null (e.g. detect() resolved repoRoot
      // but the branch probe timed out); the dialog passes the live branch it
      // actually displayed.
      final cubit = loadedWith(wt());
      await cubit.removeWorktree('/repo/wt', deleteBranch: true, branch: 'feature/from-ui');

      verify(() => deleteBranchUsecase(repoRoot: '/repo', branch: 'feature/from-ui')).called(1);
      await cubit.close();
    });

    test('plain folder workspace (repoRoot == null) returns Left without touching git', () async {
      final cubit = loadedWith(makeWorkspace(id: '/plain/folder', path: '/plain/folder'));
      final result = await cubit.removeWorktree('/plain/folder');

      expect(result.isLeft, isTrue);
      expect(cubit.state.workspacesOrEmpty, hasLength(1));
      verifyNever(
        () => removeWorktreeUsecase(
          repoRoot: any(named: 'repoRoot'),
          worktreePath: any(named: 'worktreePath'),
        ),
      );
      verifyNever(
        () => deleteBranchUsecase(
          repoRoot: any(named: 'repoRoot'),
          branch: any(named: 'branch'),
        ),
      );
      await cubit.close();
    });
  });

  group('createWorktree', () {
    test('success creates the worktree then opens it as a workspace', () async {
      when(
        () => addWorktreeUsecase(
          repoRoot: any(named: 'repoRoot'),
          worktreePath: any(named: 'worktreePath'),
          newBranch: any(named: 'newBranch'),
          baseRef: any(named: 'baseRef'),
          checkoutBranch: any(named: 'checkoutBranch'),
        ),
      ).thenAnswer((_) async => const Right(null));
      when(() => openWs(path: any(named: 'path'))).thenAnswer((_) async => Right(_ws('/repo/feature/new')));

      final cubit = make();
      final result = await cubit.createWorktree(
        repoRoot: '/repo',
        targetPath: '/repo/feature/new',
        newBranch: 'feature/new',
      );

      expect(result.isRight, isTrue);
      verify(() => openWs(path: '/repo/feature/new')).called(1);
      expect(cubit.state.workspacesOrEmpty.map((w) => w.id), contains('/repo/feature/new'));
      await cubit.close();
    });

    test('openAfter:false creates the worktree without opening it, and bumps the worktree revision', () async {
      when(
        () => addWorktreeUsecase(
          repoRoot: any(named: 'repoRoot'),
          worktreePath: any(named: 'worktreePath'),
          newBranch: any(named: 'newBranch'),
          baseRef: any(named: 'baseRef'),
          checkoutBranch: any(named: 'checkoutBranch'),
        ),
      ).thenAnswer((_) async => const Right(null));

      final cubit = make();
      cubit.emit(const WorkspacesState.loaded());
      final before = cubit.state.worktreesRevisionOrZero;

      final result = await cubit.createWorktree(
        repoRoot: '/repo',
        targetPath: '/repo/.worktrees/x',
        newBranch: 'x',
        openAfter: false,
      );

      expect(result.isRight, isTrue);
      verifyNever(() => openWs(path: any(named: 'path')));
      expect(cubit.state.workspacesOrEmpty, isEmpty, reason: 'not opened');
      expect(cubit.state.worktreesRevisionOrZero, before + 1, reason: 'sidebar re-fetch trigger');
      await cubit.close();
    });

    test('git failure returns Left and does NOT open a workspace', () async {
      when(
        () => addWorktreeUsecase(
          repoRoot: any(named: 'repoRoot'),
          worktreePath: any(named: 'worktreePath'),
          newBranch: any(named: 'newBranch'),
          baseRef: any(named: 'baseRef'),
          checkoutBranch: any(named: 'checkoutBranch'),
        ),
      ).thenAnswer((_) async => const Left(SubprocessFailure(message: "fatal: '/repo/dup' already exists")));

      final cubit = make();
      final result = await cubit.createWorktree(repoRoot: '/repo', targetPath: '/repo/dup', newBranch: 'dup');

      expect(result.isLeft, isTrue);
      verifyNever(() => openWs(path: any(named: 'path')));
      expect(cubit.state.workspacesOrEmpty, isEmpty);
      await cubit.close();
    });
  });

  group('setActive', () {
    blocTest<WorkspacesCubit, WorkspacesState>(
      'switches activeId and emits a fresh loaded state',
      build: () {
        when(() => openWs(path: '/x')).thenAnswer((_) async => Right(_ws('/x')));
        when(() => openWs(path: '/y')).thenAnswer((_) async => Right(_ws('/y')));
        return make();
      },
      act: (c) async {
        await c.openPath('/x');
        await c.openPath('/y'); // active = /y
        c.setActive('/x'); // switch
      },
      verify: (c) => expect(c.state.activeIdOrNull, '/x'),
    );

    blocTest<WorkspacesCubit, WorkspacesState>(
      'setActive on the already-active id is a no-op (no emit)',
      build: () {
        when(() => openWs(path: any(named: 'path'))).thenAnswer((_) async => Right(_ws('/x')));
        return make();
      },
      seed: () => WorkspacesState.loaded(workspaces: [_ws('/x')], activeId: '/x'),
      act: (c) => c.setActive('/x'),
      expect: () => const <WorkspacesState>[],
    );

    blocTest<WorkspacesCubit, WorkspacesState>(
      'setActive on an unknown id is a no-op',
      build: () => make(),
      seed: () => WorkspacesState.loaded(workspaces: [_ws('/x')], activeId: '/x'),
      act: (c) => c.setActive('/never-opened'),
      expect: () => const <WorkspacesState>[],
    );
  });

  group('restore', () {
    blocTest<WorkspacesCubit, WorkspacesState>(
      'no persisted snapshot → emits an empty loaded state',
      build: () {
        when(() => persistence.read()).thenAnswer((_) async => null);
        return make();
      },
      act: (c) => c.restore(),
      expect: () => [
        isA<WorkspacesStateLoaded>()
            .having((s) => s.workspaces, 'workspaces', isEmpty)
            .having((s) => s.activeId, 'activeId', isNull),
      ],
    );

    blocTest<WorkspacesCubit, WorkspacesState>(
      'restores valid entries and skips entries whose openWorkspace fails',
      build: () {
        when(() => persistence.read()).thenAnswer(
          (_) async => PersistedWorkspaces(
            activeId: '/x',
            workspaces: [
              PersistedWorkspaceEntry(id: '/x', path: '/x', name: 'x', openedAt: DateTime.utc(2026, 1, 1)),
              PersistedWorkspaceEntry(
                id: '/missing',
                path: '/missing',
                name: 'missing',
                openedAt: DateTime.utc(2026, 1, 1),
              ),
            ],
          ),
        );
        when(() => openWs(path: '/x')).thenAnswer((_) async => Right(_ws('/x')));
        when(() => openWs(path: '/missing')).thenAnswer((_) async => Left(NotFoundFailure('/missing')));
        return make();
      },
      act: (c) => c.restore(),
      verify: (c) {
        expect(c.state.workspacesOrEmpty.map((w) => w.id), ['/x']);
        expect(c.state.activeIdOrNull, '/x');
      },
    );

    blocTest<WorkspacesCubit, WorkspacesState>(
      'falls back to first restored workspace when persisted activeId is missing',
      build: () {
        when(() => persistence.read()).thenAnswer(
          (_) async => PersistedWorkspaces(
            activeId: '/never-restored',
            workspaces: [PersistedWorkspaceEntry(id: '/x', path: '/x', name: 'x', openedAt: DateTime.utc(2026, 1, 1))],
          ),
        );
        when(() => openWs(path: '/x')).thenAnswer((_) async => Right(_ws('/x')));
        return make();
      },
      act: (c) => c.restore(),
      verify: (c) {
        expect(
          c.state.activeIdOrNull,
          '/x',
          reason: 'When persisted activeId is missing from restored list, fallback to first.',
        );
      },
    );
  });
}
