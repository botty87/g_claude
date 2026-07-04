// Contracts for the diff panel (`lib/features/shell/presentation/widgets/diff_panel_view.dart`):
//
// - `buildDiffTreeRows` is a pure function that groups a flat list of
//   [GitDiffFile] into a depth-annotated, dir-then-file sorted row list for
//   the tree view, honoring `collapsedDirs`.
// - `DiffPanelView` renders the flat/tree list backed by [GitDiffCubit],
//   opens a diff tab via [FileTabsCubit.openDiff] on row tap (promoting to
//   peek when the center isn't already showing code), and falls back to a
//   "not a repo" / "empty" message per workspace state.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/core/l10n/l10n.dart';
import 'package:g_claude/features/editor/presentation/cubit/editor_view_cubit.dart';
import 'package:g_claude/features/editor/presentation/cubit/file_tabs_cubit.dart';
import 'package:g_claude/features/git/domain/entities/git_diff_file.dart';
import 'package:g_claude/features/git/presentation/cubit/git_diff_cubit.dart';
import 'package:g_claude/features/shell/presentation/widgets/diff_panel_view.dart';
import 'package:g_claude/features/workspace/presentation/cubit/workspaces_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';
import '../../../../helpers/pump_app.dart';

class _MockWorkspacesCubit extends MockCubit<WorkspacesState> implements WorkspacesCubit {}

class _MockGitDiffCubit extends MockCubit<GitDiffState> implements GitDiffCubit {}

class _MockFileTabsCubit extends MockCubit<FileTabsState> implements FileTabsCubit {}

class _MockEditorViewCubit extends MockCubit<EditorViewState> implements EditorViewCubit {}

GitDiffFile _file(String path, {GitFileStatus status = GitFileStatus.modified, int added = 0, int deleted = 0}) =>
    GitDiffFile(path: path, status: status, added: added, deleted: deleted);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('buildDiffTreeRows', () {
    test('a root file (no slash in path) becomes a single depth-0 file entry, no dirs', () {
      final rows = buildDiffTreeRows([_file('README.md')], const {});

      expect(rows, hasLength(1));
      expect(rows.single.isDir, isFalse);
      expect(rows.single.depth, 0);
      expect(rows.single.file!.path, 'README.md');
    });

    test('a nested file produces one dir entry per path segment, then the file entry', () {
      final rows = buildDiffTreeRows([_file('lib/features/git/x.dart')], const {});

      expect(rows, hasLength(4));
      expect(rows[0].isDir, isTrue);
      expect(rows[0].name, 'lib');
      expect(rows[0].fullPath, 'lib');
      expect(rows[0].depth, 0);

      expect(rows[1].isDir, isTrue);
      expect(rows[1].name, 'features');
      expect(rows[1].fullPath, 'lib/features');
      expect(rows[1].depth, 1);

      expect(rows[2].isDir, isTrue);
      expect(rows[2].name, 'git');
      expect(rows[2].fullPath, 'lib/features/git');
      expect(rows[2].depth, 2);

      expect(rows[3].isDir, isFalse);
      expect(rows[3].file!.path, 'lib/features/git/x.dart');
      expect(rows[3].depth, 3);
    });

    test('fileCount of a dir aggregates all descendant files recursively', () {
      final rows = buildDiffTreeRows([_file('lib/a/f1.dart'), _file('lib/b/f2.dart')], const {});

      final libRow = rows.firstWhere((r) => r.isDir && r.fullPath == 'lib');
      expect(libRow.fileCount, 2);

      final aRow = rows.firstWhere((r) => r.isDir && r.fullPath == 'lib/a');
      expect(aRow.fileCount, 1);
      final bRow = rows.firstWhere((r) => r.isDir && r.fullPath == 'lib/b');
      expect(bRow.fileCount, 1);
    });

    test('collapsedDirs hides descendants of the matched dir but keeps the dir row itself', () {
      final rows = buildDiffTreeRows(
        [_file('lib/features/git/x.dart'), _file('lib/other.dart')],
        const {'lib/features'},
      );

      // lib, lib/features stay; lib/features/git and x.dart are hidden;
      // lib/other.dart (a direct child of lib) stays.
      expect(rows.map((r) => r.isDir ? r.fullPath : r.file!.path), ['lib', 'lib/features', 'lib/other.dart']);
    });

    test('siblings sort: dirs alphabetically (fully expanded) before this level\'s own files, '
        'files alphabetically by basename', () {
      final rows = buildDiffTreeRows([
        _file('b_file.txt'),
        _file('a_dir/x.dart'),
        _file('a_dir/y.dart'),
        _file('z_dir/w.dart'),
      ], const {});

      expect(rows.map((r) => r.isDir ? r.fullPath : r.file!.path), [
        'a_dir',
        'a_dir/x.dart',
        'a_dir/y.dart',
        'z_dir',
        'z_dir/w.dart',
        'b_file.txt',
      ]);
    });

    test('empty input produces no rows', () {
      expect(buildDiffTreeRows(const [], const {}), isEmpty);
    });
  });

  group('DiffPanelView', () {
    const wsId = '/repo';
    final workspace = makeWorkspace(id: wsId, path: wsId, repoRoot: wsId);

    late _MockWorkspacesCubit workspaces;
    late _MockGitDiffCubit gitDiff;
    late _MockFileTabsCubit fileTabs;
    late _MockEditorViewCubit editorView;

    setUpAll(() {
      registerFallbackValue(const DiffTabRef(path: '', status: GitFileStatus.modified));
      registerFallbackValue(DiffViewMode.flat);
    });

    setUp(() {
      workspaces = _MockWorkspacesCubit();
      whenListen(
        workspaces,
        Stream<WorkspacesState>.empty(),
        initialState: WorkspacesState.loaded(workspaces: [workspace], activeId: wsId),
      );

      gitDiff = _MockGitDiffCubit();
      whenListen(gitDiff, Stream<GitDiffState>.empty(), initialState: const GitDiffState());
      when(
        () => gitDiff.load(
          workspaceId: any(named: 'workspaceId'),
          path: any(named: 'path'),
        ),
      ).thenAnswer((_) async {});

      fileTabs = _MockFileTabsCubit();
      whenListen(fileTabs, Stream<FileTabsState>.empty(), initialState: const FileTabsState());

      editorView = _MockEditorViewCubit();
      whenListen(editorView, Stream<EditorViewState>.empty(), initialState: const EditorViewState());
    });

    // Re-stub only the state getter (the stream is already wired in setUp);
    // calling whenListen a second time does not refresh the state getter.
    void seedDiff(WorkspaceDiff diff) {
      when(() => gitDiff.state).thenReturn(GitDiffState(perWorkspace: {wsId: diff}));
    }

    Future<void> pump(WidgetTester tester) async {
      await pumpAppWidget(
        tester,
        MultiBlocProvider(
          providers: [
            BlocProvider<WorkspacesCubit>.value(value: workspaces),
            BlocProvider<GitDiffCubit>.value(value: gitDiff),
            BlocProvider<FileTabsCubit>.value(value: fileTabs),
            BlocProvider<EditorViewCubit>.value(value: editorView),
          ],
          child: const SizedBox(width: 320, height: 600, child: DiffPanelView()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('no active repo workspace -> shows the "not a repo" message', (tester) async {
      whenListen(
        workspaces,
        Stream<WorkspacesState>.empty(),
        initialState: WorkspacesState.loaded(
          workspaces: [makeWorkspace(id: wsId, path: wsId)],
          activeId: wsId,
        ),
      );

      await pump(tester);

      expect(find.text(Locales.Shell.DiffPanel.notRepo), findsOneWidget);
    });

    testWidgets('flat view: renders one row per file with status badge, path and +/- counters', (tester) async {
      seedDiff(
        WorkspaceDiff(
          files: [
            _file('a.dart', status: GitFileStatus.modified, added: 3, deleted: 1),
            _file('b/c.dart', status: GitFileStatus.added, added: 5),
          ],
        ),
      );

      await pump(tester);

      expect(find.byKey(const ValueKey('diff_file_a.dart')), findsOneWidget);
      expect(find.byKey(const ValueKey('diff_file_b/c.dart')), findsOneWidget);
      // Flat view shows the full repo-relative path, not just the basename.
      expect(find.text('a.dart'), findsOneWidget);
      expect(find.text('b/c.dart'), findsOneWidget);
      expect(find.text('+3'), findsOneWidget);
      expect(find.text('−1'), findsOneWidget);
      expect(find.text('+5'), findsOneWidget);
      // Status-letter badges: 'M' for modified, 'A' for added.
      expect(find.text('M'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('empty file list -> shows the empty-state message', (tester) async {
      seedDiff(const WorkspaceDiff(files: []));

      await pump(tester);

      expect(find.text(Locales.Shell.DiffPanel.empty), findsOneWidget);
    });

    testWidgets('load failure -> shows the load-error message instead of the list', (tester) async {
      seedDiff(WorkspaceDiff(files: const [], failure: const UnexpectedFailure('boom')));

      await pump(tester);

      expect(find.text(Locales.Shell.DiffPanel.loadError), findsOneWidget);
      expect(find.text(Locales.Shell.DiffPanel.empty), findsNothing);
    });

    testWidgets('tree view: nested files render dir + file rows; tapping a dir toggles it via the cubit', (
      tester,
    ) async {
      seedDiff(WorkspaceDiff(files: [_file('lib/a.dart')], viewMode: DiffViewMode.tree));
      when(() => gitDiff.toggleDir(any(), any())).thenReturn(null);

      await pump(tester);

      expect(find.text('lib'), findsOneWidget);
      expect(find.byKey(const ValueKey('diff_file_lib/a.dart')), findsOneWidget);

      await tester.tap(find.text('lib'));
      await tester.pumpAndSettle();

      verify(() => gitDiff.toggleDir(wsId, 'lib')).called(1);
    });

    testWidgets('tapping a file row opens a diff tab with the file path and promotes to peek when not on code view', (
      tester,
    ) async {
      seedDiff(WorkspaceDiff(files: [_file('a.dart', status: GitFileStatus.added, added: 2)]));
      when(() => fileTabs.openDiff(any(), any())).thenReturn(null);
      when(() => editorView.openPeek(any())).thenReturn(null);
      // Center is showing chat (default), not code -> expect a peek promotion.
      whenListen(
        editorView,
        Stream<EditorViewState>.empty(),
        initialState: const EditorViewState(perWorkspace: {wsId: EditorViewData(view: CenterView.chat)}),
      );

      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('diff_file_a.dart')));
      await tester.pumpAndSettle();

      final captured = verify(() => fileTabs.openDiff(wsId, captureAny())).captured;
      final ref = captured.single as DiffTabRef;
      expect(ref.path, 'a.dart');
      expect(ref.status, GitFileStatus.added);
      expect(ref.added, 2);
      verify(() => editorView.openPeek(wsId)).called(1);
    });

    testWidgets('tapping a file row while the code view is already shown does not open a peek', (tester) async {
      seedDiff(WorkspaceDiff(files: [_file('a.dart')]));
      when(() => fileTabs.openDiff(any(), any())).thenReturn(null);
      whenListen(
        editorView,
        Stream<EditorViewState>.empty(),
        initialState: const EditorViewState(perWorkspace: {wsId: EditorViewData(view: CenterView.code)}),
      );

      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('diff_file_a.dart')));
      await tester.pumpAndSettle();

      verify(() => fileTabs.openDiff(wsId, any())).called(1);
      verifyNever(() => editorView.openPeek(any()));
    });

    testWidgets('flat/tree view toggle chips switch the cubit view mode', (tester) async {
      seedDiff(WorkspaceDiff(files: [_file('a.dart')]));
      when(() => gitDiff.setViewMode(any(), any())).thenReturn(null);

      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('diff_view_tree')));
      await tester.pumpAndSettle();

      verify(() => gitDiff.setViewMode(wsId, DiffViewMode.tree)).called(1);
    });
  });
}
