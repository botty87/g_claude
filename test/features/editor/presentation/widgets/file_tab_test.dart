// Contracts for [FileTab] when rendering a *diff* tab (`isDiff: true`):
// a diff tab shows a distinct icon + "DIFF" badge, is not draggable, and
// routes taps to the diff-specific cubit methods (`setActiveDiff`/`closeDiff`)
// instead of the regular file ones (`setActiveFile`/`closeFile`).

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:g_claude/core/l10n/l10n.dart';
import 'package:g_claude/features/editor/presentation/cubit/file_tabs_cubit.dart';
import 'package:g_claude/features/editor/presentation/widgets/file_tab.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockFileTabsCubit extends MockCubit<FileTabsState> implements FileTabsCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const wsId = '/ws/a';
  const path = 'a.dart';

  late _MockFileTabsCubit fileTabs;

  setUp(() {
    fileTabs = _MockFileTabsCubit();
    whenListen(fileTabs, const Stream<FileTabsState>.empty(), initialState: const FileTabsState());
    when(() => fileTabs.setActiveDiff(any(), any())).thenReturn(null);
    when(() => fileTabs.closeDiff(any(), any())).thenReturn(null);
    when(() => fileTabs.setActiveFile(any(), any())).thenReturn(null);
    when(() => fileTabs.closeFile(any(), any())).thenReturn(null);
  });

  Future<void> pump(WidgetTester tester, {bool isActive = false, bool isPreview = false}) async {
    await pumpAppWidget(
      tester,
      BlocProvider<FileTabsCubit>.value(
        value: fileTabs,
        child: FileTab(workspaceId: wsId, path: path, isActive: isActive, isPreview: isPreview, isDiff: true),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the difference icon and the DIFF badge', (tester) async {
    await pump(tester);

    expect(find.byIcon(Symbols.difference), findsOneWidget);
    expect(find.byIcon(Symbols.description), findsNothing, reason: 'the plain-file icon must not show on a diff tab');
    expect(find.text(Locales.Editor.Diff.badge), findsOneWidget);
  });

  testWidgets('tapping the tab body activates the diff via setActiveDiff', (tester) async {
    await pump(tester);

    await tester.tap(find.text(path));
    await tester.pumpAndSettle();

    verify(() => fileTabs.setActiveDiff(wsId, path)).called(1);
    verifyNever(() => fileTabs.setActiveFile(any(), any()));
  });

  testWidgets('tapping the close icon closes the diff via closeDiff', (tester) async {
    await pump(tester);

    await tester.tap(find.byIcon(Symbols.close));
    await tester.pumpAndSettle();

    verify(() => fileTabs.closeDiff(wsId, path)).called(1);
    verifyNever(() => fileTabs.closeFile(any(), any()));
  });

  testWidgets('is not wrapped in a Draggable (diff tabs are not reorderable)', (tester) async {
    await pump(tester);

    expect(find.byType(Draggable<String>), findsNothing);
  });
}
