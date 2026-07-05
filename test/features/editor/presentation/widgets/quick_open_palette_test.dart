// [showQuickOpen] palette contract: it lists the workspace's currently *open*
// files (no disk scan), the text field filters them by basename/path, and
// picking a row sets the active file + switches to the Code view, then closes.
//
// showDialog pushes a route as a sibling of the home route in the Navigator's
// overlay; wrapping the providers via MaterialApp.builder (appBuilder) puts
// them above the Navigator so the dialog route can see them — see
// test/helpers/pump_app.dart.
//
// All flows live in ONE testWidgets: EasyLocalization only loads its JSON for
// the FIRST pumped tree in a file (a second `pumpAppWidget` renders the
// loading placeholder forever under fake test time), so we pump once and
// re-open the dialog per scenario — see close_worktree_dialog_test.dart.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/editor/presentation/cubit/editor_view_cubit.dart';
import 'package:g_claude/features/editor/presentation/cubit/file_tabs_cubit.dart';
import 'package:g_claude/features/editor/presentation/widgets/quick_open_palette.dart';
import 'package:g_claude/features/git/domain/entities/git_diff_file.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockFileTabsCubit extends MockCubit<FileTabsState> implements FileTabsCubit {}

class _MockEditorViewCubit extends MockCubit<EditorViewState> implements EditorViewCubit {}

const _workspaceId = '/ws/a';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => registerFallbackValue(CenterView.chat));

  late _MockFileTabsCubit fileTabs;
  late _MockEditorViewCubit editorView;

  setUp(() {
    fileTabs = _MockFileTabsCubit();
    when(() => fileTabs.state).thenReturn(
      const FileTabsState(
        perWorkspace: {
          _workspaceId: WorkspaceFiles(
            openPaths: ['/ws/a/lib/main.dart', '/ws/a/lib/foo_widget.dart', '/ws/a/README.md'],
            activePath: '/ws/a/lib/main.dart',
            openDiffs: [DiffTabRef(path: '/ws/a/lib/protocol.ts', status: GitFileStatus.modified)],
          ),
        },
      ),
    );
    when(() => fileTabs.setActiveFile(any(), any())).thenReturn(null);
    when(() => fileTabs.setActiveDiff(any(), any())).thenReturn(null);

    editorView = _MockEditorViewCubit();
    when(() => editorView.setView(any(), any())).thenReturn(null);
  });

  testWidgets('filters by typing, selecting a row acts + closes, empty state shows the placeholder', (tester) async {
    await pumpAppWidget(
      tester,
      Builder(
        builder: (context) => Center(
          child: ElevatedButton(onPressed: () => showQuickOpen(context, _workspaceId), child: const Text('open')),
        ),
      ),
      appBuilder: (context, navigatorChild) => MultiBlocProvider(
        providers: [
          BlocProvider<FileTabsCubit>.value(value: fileTabs),
          BlocProvider<EditorViewCubit>.value(value: editorView),
        ],
        child: navigatorChild!,
      ),
    );

    Future<void> open() async {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    // 1) Lists every open file; typing filters by basename/path.
    await open();
    expect(find.text('main.dart'), findsOneWidget);
    expect(find.text('foo_widget.dart'), findsOneWidget);
    expect(find.text('README.md'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('quick_open_search_field')), 'foo');
    await tester.pumpAndSettle();
    expect(find.text('foo_widget.dart'), findsOneWidget);
    expect(find.text('main.dart'), findsNothing);
    expect(find.text('README.md'), findsNothing);

    // Reset for the next scenario: close via Escape.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('quick_open_search_field')), findsNothing);

    // 2) Tapping a row sets the active file, switches to Code view, closes.
    await open();
    await tester.tap(find.text('foo_widget.dart'));
    await tester.pumpAndSettle();

    verify(() => fileTabs.setActiveFile(_workspaceId, '/ws/a/lib/foo_widget.dart')).called(1);
    verify(() => editorView.setView(_workspaceId, CenterView.code)).called(1);
    expect(find.byKey(const ValueKey('quick_open_search_field')), findsNothing);
    clearInteractions(fileTabs);
    clearInteractions(editorView);

    // 2b) Keyboard nav: arrow-down moves selection off row 0 (main.dart) onto
    // row 1 (foo_widget.dart), enter opens the selected row — not the first one.
    await open();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    verify(() => fileTabs.setActiveFile(_workspaceId, '/ws/a/lib/foo_widget.dart')).called(1);
    verify(() => editorView.setView(_workspaceId, CenterView.code)).called(1);
    expect(find.byKey(const ValueKey('quick_open_search_field')), findsNothing);

    // 3) A diff tab is listed too (with a DIFF badge); picking it activates the
    // diff, not a file.
    clearInteractions(fileTabs);
    clearInteractions(editorView);
    await open();
    expect(find.text('protocol.ts'), findsOneWidget);
    expect(find.text('DIFF'), findsWidgets);
    await tester.tap(find.text('protocol.ts'));
    await tester.pumpAndSettle();
    verify(() => fileTabs.setActiveDiff(_workspaceId, '/ws/a/lib/protocol.ts')).called(1);
    verify(() => editorView.setView(_workspaceId, CenterView.code)).called(1);
    verifyNever(() => fileTabs.setActiveFile(any(), any()));

    // 3b) Regression: filtering is on the file NAME only, not the path. A
    // directory segment shared by every file ('lib') must match nothing.
    clearInteractions(fileTabs);
    clearInteractions(editorView);
    await open();
    await tester.enterText(find.byKey(const ValueKey('quick_open_search_field')), 'lib');
    await tester.pumpAndSettle();
    expect(find.text('main.dart'), findsNothing);
    expect(find.text('foo_widget.dart'), findsNothing);
    expect(find.text('protocol.ts'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    // 4) No open files or diffs: the empty placeholder shows instead of a list.
    when(() => fileTabs.state).thenReturn(const FileTabsState());
    await open();
    expect(find.text('No open files'), findsOneWidget);
  });
}
