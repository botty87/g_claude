// Contracts for [FileTabsCubit]'s diff-tab surface.
//
// [FileTabsCubit] owns, per workspace, both the persisted file-tab strip
// (openPaths/activePath/previewPath) and an ephemeral diff-tab strip
// (openDiffs/activeDiffId) that lives beside it in the same "Code" area.
// Diff tabs are keyed by `DiffTabRef.path` and are never persisted.
//
// Responsibilities under test:
// - openDiff/setActiveDiff/closeDiff manage the diff-tab list and its active
//   selection.
// - Activating/opening a *file* tab always wins over an active diff tab
//   (`activeDiffId` resets to null), including the edge case where the file
//   is already `activePath` but a diff is currently shown.
// - closeAllFiles clears only the file-tab fields, preserving diff tabs.
// - Diff tabs never leak into the persisted snapshot (tabs.v1 / DTO has no
//   diff fields at all).

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/editor/data/datasources/file_tabs_persistence_datasource.dart';
import 'package:g_claude/features/editor/presentation/cubit/file_tabs_cubit.dart';
import 'package:g_claude/features/git/domain/entities/git_diff_file.dart';
import 'package:g_claude/features/workspace/data/datasources/workspace_file_watcher.dart';
import 'package:g_claude/features/workspace/domain/entities/workspace.dart';
import 'package:g_claude/features/workspace/presentation/cubit/workspaces_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';

class _MockWorkspacesCubit extends Mock implements WorkspacesCubit {}

class _MockPersistence extends Mock implements FileTabsPersistenceDataSource {}

class _MockFileWatcher extends Mock implements WorkspaceFileWatcher {}

void main() {
  const wsId = '/ws/a';
  final workspace = Workspace(id: wsId, path: wsId, name: 'a', openedAt: DateTime.utc(2026, 1, 1));

  late _MockWorkspacesCubit workspaces;
  late _MockPersistence persistence;
  late _MockFileWatcher watcher;
  late StreamController<WorkspacesState> wsController;

  setUpAll(() {
    registerFallbackValue(const PersistedFileTabs(perWorkspace: {}));
  });

  setUp(() {
    workspaces = _MockWorkspacesCubit();
    wsController = StreamController<WorkspacesState>.broadcast();
    when(() => workspaces.stream).thenAnswer((_) => wsController.stream);
    when(() => workspaces.state).thenReturn(WorkspacesState.loaded(workspaces: [workspace], activeId: wsId));

    persistence = _MockPersistence();
    when(() => persistence.write(any())).thenAnswer((_) async {});
    when(() => persistence.read()).thenAnswer((_) async => null);

    watcher = _MockFileWatcher();
    when(() => watcher.watch(any())).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() => wsController.close());

  FileTabsCubit makeCubit() => FileTabsCubit(workspaces, persistence, watcher, makeTestTalker())..init();

  DiffTabRef ref(String path, {GitFileStatus status = GitFileStatus.modified, int added = 0, int deleted = 0}) =>
      DiffTabRef(path: path, status: status, added: added, deleted: deleted);

  group('openDiff', () {
    blocTest<FileTabsCubit, FileTabsState>(
      'adds the ref to openDiffs, activates it and marks it as the preview',
      build: makeCubit,
      act: (c) => c.openDiff(wsId, ref('a.dart')),
      verify: (c) {
        final files = c.state.filesFor(wsId)!;
        expect(files.openDiffs.map((d) => d.path), ['a.dart']);
        expect(files.activeDiffId, 'a.dart');
        expect(files.previewDiffId, 'a.dart');
      },
    );

    blocTest<FileTabsCubit, FileTabsState>(
      'a single-click diff is a preview that the next single-click diff replaces in place',
      build: makeCubit,
      act: (c) => c
        ..openDiff(wsId, ref('a.dart'))
        ..openDiff(wsId, ref('b.dart')),
      verify: (c) {
        final files = c.state.filesFor(wsId)!;
        // b replaces a's preview slot — only one preview diff at a time.
        expect(files.openDiffs.map((d) => d.path), ['b.dart']);
        expect(files.previewDiffId, 'b.dart');
        expect(files.activeDiffId, 'b.dart');
      },
    );

    blocTest<FileTabsCubit, FileTabsState>(
      'pinDiff keeps the diff so the next single-click appends beside it',
      build: makeCubit,
      act: (c) => c
        ..openDiff(wsId, ref('a.dart'))
        ..pinDiff(wsId, 'a.dart')
        ..openDiff(wsId, ref('b.dart')),
      verify: (c) {
        final files = c.state.filesFor(wsId)!;
        expect(files.openDiffs.map((d) => d.path), ['a.dart', 'b.dart']);
        expect(files.previewDiffId, 'b.dart', reason: 'b is the new preview');
      },
    );

    blocTest<FileTabsCubit, FileTabsState>(
      're-opening an already-open diff updates it in place (no duplicate) and keeps position',
      build: makeCubit,
      act: (c) => c
        ..openDiff(wsId, ref('a.dart', added: 1))
        ..pinDiff(wsId, 'a.dart')
        ..openDiff(wsId, ref('b.dart'))
        ..openDiff(wsId, ref('a.dart', added: 9, deleted: 2)),
      verify: (c) {
        final files = c.state.filesFor(wsId)!;
        expect(files.openDiffs.map((d) => d.path), ['a.dart', 'b.dart']);
        final a = files.openDiffs.firstWhere((d) => d.path == 'a.dart');
        expect(a.added, 9);
        expect(a.deleted, 2);
        expect(files.activeDiffId, 'a.dart');
      },
    );
  });

  group('setActiveDiff', () {
    blocTest<FileTabsCubit, FileTabsState>(
      'activates a path already present in openDiffs',
      build: makeCubit,
      act: (c) => c
        ..openDiff(wsId, ref('a.dart'))
        ..pinDiff(wsId, 'a.dart')
        ..openDiff(wsId, ref('b.dart'))
        ..setActiveDiff(wsId, 'a.dart'),
      verify: (c) => expect(c.state.filesFor(wsId)!.activeDiffId, 'a.dart'),
    );

    blocTest<FileTabsCubit, FileTabsState>(
      'no-op (no new emission) when the path is not an open diff',
      build: makeCubit,
      seed: () => FileTabsState(
        perWorkspace: {
          wsId: WorkspaceFiles(openDiffs: [ref('a.dart')], activeDiffId: 'a.dart'),
        },
      ),
      act: (c) => c.setActiveDiff(wsId, 'missing.dart'),
      expect: () => <FileTabsState>[],
    );

    blocTest<FileTabsCubit, FileTabsState>(
      'no-op when the path is already the active diff',
      build: makeCubit,
      seed: () => FileTabsState(
        perWorkspace: {
          wsId: WorkspaceFiles(openDiffs: [ref('a.dart')], activeDiffId: 'a.dart'),
        },
      ),
      act: (c) => c.setActiveDiff(wsId, 'a.dart'),
      expect: () => <FileTabsState>[],
    );
  });

  group('closeDiff', () {
    blocTest<FileTabsCubit, FileTabsState>(
      'removes the diff from the list',
      build: makeCubit,
      seed: () => FileTabsState(
        perWorkspace: {
          wsId: WorkspaceFiles(openDiffs: [ref('a.dart'), ref('b.dart')], activeDiffId: 'b.dart'),
        },
      ),
      act: (c) => c.closeDiff(wsId, 'a.dart'),
      verify: (c) {
        final files = c.state.filesFor(wsId)!;
        expect(files.openDiffs.map((d) => d.path), ['b.dart']);
        expect(files.activeDiffId, 'b.dart', reason: 'closing a non-active diff must not disturb activeDiffId');
      },
    );

    blocTest<FileTabsCubit, FileTabsState>(
      'closing the active diff falls back to an adjacent diff',
      build: makeCubit,
      seed: () => FileTabsState(
        perWorkspace: {
          wsId: WorkspaceFiles(openDiffs: [ref('a.dart'), ref('b.dart'), ref('c.dart')], activeDiffId: 'b.dart'),
        },
      ),
      act: (c) => c.closeDiff(wsId, 'b.dart'),
      verify: (c) {
        final files = c.state.filesFor(wsId)!;
        expect(files.openDiffs.map((d) => d.path), ['a.dart', 'c.dart']);
        expect(files.activeDiffId, isNotNull);
        expect(['a.dart', 'c.dart'], contains(files.activeDiffId));
      },
    );

    blocTest<FileTabsCubit, FileTabsState>(
      'closing the last remaining active diff clears activeDiffId to null',
      build: makeCubit,
      seed: () => FileTabsState(
        perWorkspace: {
          wsId: WorkspaceFiles(openDiffs: [ref('a.dart')], activeDiffId: 'a.dart'),
        },
      ),
      act: (c) => c.closeDiff(wsId, 'a.dart'),
      verify: (c) {
        final files = c.state.filesFor(wsId)!;
        expect(files.openDiffs, isEmpty);
        expect(files.activeDiffId, isNull);
      },
    );
  });

  group('file activation overrides an active diff tab (invariant)', () {
    blocTest<FileTabsCubit, FileTabsState>(
      'openFile clears activeDiffId even though it does not touch the diff list',
      build: makeCubit,
      seed: () => FileTabsState(
        perWorkspace: {
          wsId: WorkspaceFiles(openDiffs: [ref('a.dart')], activeDiffId: 'a.dart'),
        },
      ),
      act: (c) => c.openFile(wsId, 'main.dart'),
      verify: (c) {
        final files = c.state.filesFor(wsId)!;
        expect(files.activeDiffId, isNull);
        expect(files.activePath, 'main.dart');
        expect(files.openDiffs.map((d) => d.path), ['a.dart'], reason: 'the diff tab itself must survive');
      },
    );

    blocTest<FileTabsCubit, FileTabsState>(
      'setActiveFile clears activeDiffId for a path not yet active',
      build: makeCubit,
      seed: () => FileTabsState(
        perWorkspace: {
          wsId: WorkspaceFiles(
            openPaths: ['main.dart', 'other.dart'],
            activePath: 'other.dart',
            openDiffs: [ref('a.dart')],
            activeDiffId: 'a.dart',
          ),
        },
      ),
      act: (c) => c.setActiveFile(wsId, 'main.dart'),
      verify: (c) {
        final files = c.state.filesFor(wsId)!;
        expect(files.activePath, 'main.dart');
        expect(files.activeDiffId, isNull);
      },
    );

    blocTest<FileTabsCubit, FileTabsState>(
      'edge case: setActiveFile(path) where path is ALREADY activePath is NOT a no-op '
      'while a diff is active — it must still clear activeDiffId so the file view wins',
      build: makeCubit,
      seed: () => FileTabsState(
        perWorkspace: {
          wsId: WorkspaceFiles(
            openPaths: ['main.dart'],
            activePath: 'main.dart',
            openDiffs: [ref('a.dart')],
            activeDiffId: 'a.dart',
          ),
        },
      ),
      act: (c) => c.setActiveFile(wsId, 'main.dart'),
      expect: () => [isA<FileTabsState>().having((s) => s.filesFor(wsId)!.activeDiffId, 'activeDiffId', isNull)],
      verify: (c) {
        final files = c.state.filesFor(wsId)!;
        expect(files.activePath, 'main.dart');
        expect(files.activeDiffId, isNull);
      },
    );

    blocTest<FileTabsCubit, FileTabsState>(
      'true no-op: setActiveFile(path) already active AND no diff active emits nothing',
      build: makeCubit,
      seed: () => FileTabsState(
        perWorkspace: {
          wsId: WorkspaceFiles(openPaths: ['main.dart'], activePath: 'main.dart'),
        },
      ),
      act: (c) => c.setActiveFile(wsId, 'main.dart'),
      expect: () => <FileTabsState>[],
    );
  });

  group('closeAllFiles', () {
    blocTest<FileTabsCubit, FileTabsState>(
      'clears the file-tab fields but preserves openDiffs/activeDiffId',
      build: makeCubit,
      seed: () => FileTabsState(
        perWorkspace: {
          wsId: WorkspaceFiles(
            openPaths: ['a.dart', 'b.dart'],
            activePath: 'a.dart',
            previewPath: 'b.dart',
            openDiffs: [ref('diff.dart')],
            activeDiffId: 'diff.dart',
          ),
        },
      ),
      act: (c) => c.closeAllFiles(wsId),
      verify: (c) {
        final files = c.state.filesFor(wsId)!;
        expect(files.openPaths, isEmpty);
        expect(files.activePath, isNull);
        expect(files.previewPath, isNull);
        expect(files.openDiffs.map((d) => d.path), ['diff.dart']);
        expect(files.activeDiffId, 'diff.dart');
      },
    );

    blocTest<FileTabsCubit, FileTabsState>(
      'surfaces a remaining diff tab (no active diff) so the center is not left empty',
      build: makeCubit,
      seed: () => FileTabsState(
        perWorkspace: {
          // A file is shown (activeDiffId null) while a diff tab sits inactive.
          wsId: WorkspaceFiles(openPaths: ['a.dart'], activePath: 'a.dart', openDiffs: [ref('diff.dart')]),
        },
      ),
      act: (c) => c.closeAllFiles(wsId),
      verify: (c) {
        final files = c.state.filesFor(wsId)!;
        expect(files.openPaths, isEmpty);
        expect(files.activeDiffId, 'diff.dart', reason: 'the remaining diff is activated');
      },
    );
  });

  group('closeAllTabs', () {
    blocTest<FileTabsCubit, FileTabsState>(
      'clears both file tabs and diff tabs (backs Cmd+Shift+W)',
      build: makeCubit,
      seed: () => FileTabsState(
        perWorkspace: {
          wsId: WorkspaceFiles(
            openPaths: ['a.dart'],
            activePath: 'a.dart',
            openDiffs: [ref('diff.dart')],
            activeDiffId: 'diff.dart',
          ),
        },
      ),
      act: (c) => c.closeAllTabs(wsId),
      verify: (c) {
        final files = c.state.filesFor(wsId)!;
        expect(files.openPaths, isEmpty);
        expect(files.activePath, isNull);
        expect(files.openDiffs, isEmpty);
        expect(files.activeDiffId, isNull);
      },
    );

    blocTest<FileTabsCubit, FileTabsState>(
      'closes all when only diff tabs are open (no file tabs)',
      build: makeCubit,
      seed: () => FileTabsState(
        perWorkspace: {
          wsId: WorkspaceFiles(openDiffs: [ref('diff.dart')], activeDiffId: 'diff.dart'),
        },
      ),
      act: (c) => c.closeAllTabs(wsId),
      verify: (c) => expect(c.state.filesFor(wsId)!.openDiffs, isEmpty),
    );
  });

  group('persistence', () {
    test('diff tabs are never included in the persisted snapshot', () async {
      final cubit = makeCubit();
      cubit
        ..openFile(wsId, 'main.dart')
        ..openDiff(wsId, ref('a.dart'));

      // _persist() runs 250ms after the last emission, debounced.
      await Future<void>.delayed(const Duration(milliseconds: 400));

      final captured = verify(() => persistence.write(captureAny())).captured;
      final snapshot = captured.last as PersistedFileTabs;
      final persisted = snapshot.perWorkspace[wsId]!;
      // The DTO type itself has no diff-related field; this asserts the only
      // fields it *does* carry reflect the file tab, not the diff tab.
      expect(persisted.openPaths, ['main.dart']);
      expect(persisted.activePath, 'main.dart');

      await cubit.close();
    });
  });
}
