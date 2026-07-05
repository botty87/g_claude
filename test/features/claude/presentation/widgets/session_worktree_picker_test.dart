// [SessionWorktreePicker] contracts: a breadcrumb "worktree · session" button
// that opens a dropdown. It's the only session-switching UI (tabs are gone).
// A plain-folder workspace (no repoRoot) never shows a WORKTREE section. A git
// worktree only shows it when the sidebar is collapsed (the sidebar tree
// switches worktrees otherwise); expanded shows a hint row instead.
//
// Deliberately NOT wrapped in `pumpAppWidget`/`EasyLocalization`: this widget
// uses `OverlayPortal` for the dropdown, and a `testWidgets` that shows an
// `OverlayPortal` overlay leaves the binding in a state where the *next*
// `testWidgets` in the same file — even one that never touches this widget —
// gets a fresh `EasyLocalization` that never resolves past its "locale not
// loaded yet" placeholder (confirmed with a minimal repro: an unrelated
// `OverlayPortal` widget in test 1, a bare `Text` in test 2, wrapped in
// `pumpAppWidget` — test 2's text never renders). Plain `pumpAppWidget` files
// without `OverlayPortal` (e.g. `pump_app_test.dart`) do not hit this.
// `easy_localization`'s `.tr()` degrades gracefully to the literal key without
// an `EasyLocalization` ancestor (logs a warning, doesn't throw), so a bare
// `MaterialApp` is enough here — every assertion below is key-based and none
// depend on translated text.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/claude/domain/entities/claude_effort.dart';
import 'package:g_claude/features/claude/domain/entities/claude_model.dart';
import 'package:g_claude/features/claude/domain/entities/claude_permission_mode.dart';
import 'package:g_claude/features/claude/domain/entities/claude_thinking_mode.dart';
import 'package:g_claude/features/claude/presentation/cubit/claude_sessions_cubit.dart';
import 'package:g_claude/core/l10n/l10n.dart';
import 'package:g_claude/features/claude/presentation/widgets/session_worktree_picker.dart';
import 'package:g_claude/features/git/domain/entities/git_worktree.dart';
import 'package:g_claude/features/shell/presentation/cubit/shell_cubit.dart';
import 'package:g_claude/features/workspace/domain/entities/workspace.dart';
import 'package:g_claude/features/workspace/presentation/cubit/workspaces_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockWorkspacesCubit extends MockCubit<WorkspacesState> implements WorkspacesCubit {}

class _MockSessionsCubit extends MockCubit<ClaudeSessionsState> implements ClaudeSessionsCubit {}

class _MockShellCubit extends MockCubit<ShellState> implements ShellCubit {}

Workspace _ws(String path, {String? repoRoot, String? branch}) => Workspace(
  id: path,
  path: path,
  name: path.split('/').last,
  openedAt: DateTime.utc(2026, 1, 1),
  repoRoot: repoRoot,
  branch: branch,
);

ClaudeSessionData _session(String tabId) => ClaudeSessionData(
  tabId: tabId,
  model: ClaudeModel.sonnet,
  permissionMode: ClaudePermissionMode.auto,
  effort: ClaudeEffort.high,
  thinkingMode: ClaudeThinkingMode.on,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repoRoot = '/repo';
  const activePath = '/repo/main';
  final active = _ws(activePath, repoRoot: repoRoot, branch: 'main');
  final feat = _ws('/repo/feat', repoRoot: repoRoot, branch: 'feature/x');
  final plain = _ws('/plain/folder');

  late _MockWorkspacesCubit ws;
  late _MockSessionsCubit sessions;
  late _MockShellCubit shell;

  setUp(() {
    ws = _MockWorkspacesCubit();
    when(() => ws.openPath(any())).thenAnswer((_) async {});
    when(() => ws.ensureWorktrees(any())).thenAnswer((_) async => const <GitWorktree>[]);
    when(() => ws.cachedWorktrees(any())).thenReturn(null);

    sessions = _MockSessionsCubit();
    when(() => sessions.switchTab(any(), any())).thenReturn(null);
    when(() => sessions.closeTab(any(), any())).thenReturn(null);
    when(() => sessions.openNewSession(any())).thenReturn(null);

    shell = _MockShellCubit();
  });

  void stubWorkspaces({required List<Workspace> workspaces, required String activeId}) {
    whenListen(
      ws,
      const Stream<WorkspacesState>.empty(),
      initialState: WorkspacesState.loaded(workspaces: workspaces, activeId: activeId),
    );
  }

  void stubSessions({required String workspaceId, required List<ClaudeSessionData> tabs, required String activeTab}) {
    whenListen(
      sessions,
      const Stream<ClaudeSessionsState>.empty(),
      initialState: ClaudeSessionsState(
        workspaces: {workspaceId: WorkspaceSessions(tabs: tabs, activeTabId: activeTab)},
      ),
    );
  }

  Future<void> pump(WidgetTester tester, {required String workspaceId, required bool sidebarCollapsed}) async {
    whenListen(
      shell,
      const Stream<ShellState>.empty(),
      initialState: ShellState(selectedActivity: ActivityId.sessions, sidebarCollapsed: sidebarCollapsed),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<WorkspacesCubit>.value(value: ws),
              BlocProvider<ClaudeSessionsCubit>.value(value: sessions),
              BlocProvider<ShellCubit>.value(value: shell),
            ],
            child: SessionWorktreePicker(workspaceId: workspaceId),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openDropdown(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('session_worktree_picker')));
    await tester.pumpAndSettle();
  }

  testWidgets('plain-folder workspace (sidebar collapsed) shows the folder name and no WORKTREE section', (
    tester,
  ) async {
    stubWorkspaces(workspaces: [plain], activeId: plain.id);
    stubSessions(workspaceId: plain.id, tabs: [_session('t')], activeTab: 't');

    await pump(tester, workspaceId: plain.id, sidebarCollapsed: true);
    expect(find.byKey(const ValueKey('session_worktree_picker')), findsOneWidget);
    expect(find.text('folder'), findsOneWidget);

    await openDropdown(tester);
    expect(find.byKey(const ValueKey('worktree_picker_worktree_header')), findsNothing);
    expect(find.byKey(ValueKey('worktree_picker_worktree_${plain.path}')), findsNothing);
  });

  testWidgets('detached-HEAD worktree labels the breadcrumb "Detached", not the folder name', (tester) async {
    const detachedPath = '/repo/wt';
    final detachedWs = _ws(detachedPath, repoRoot: repoRoot); // branch: null
    const detachedList = [GitWorktree(path: detachedPath, head: 'abc123', isDetached: true)];
    when(() => ws.ensureWorktrees(repoRoot)).thenAnswer((_) async => detachedList);
    when(() => ws.cachedWorktrees(repoRoot)).thenReturn(detachedList);
    stubWorkspaces(workspaces: [detachedWs], activeId: detachedPath);
    stubSessions(workspaceId: detachedPath, tabs: [_session('t')], activeTab: 't');

    await pump(tester, workspaceId: detachedPath, sidebarCollapsed: false);
    expect(find.text(Locales.Claude.Terminal.WorktreeChip.detached), findsOneWidget);
    expect(find.text('wt'), findsNothing);
  });

  testWidgets('plain-folder workspace (sidebar expanded) still shows no WORKTREE section', (tester) async {
    stubWorkspaces(workspaces: [plain], activeId: plain.id);
    stubSessions(workspaceId: plain.id, tabs: [_session('t')], activeTab: 't');

    await pump(tester, workspaceId: plain.id, sidebarCollapsed: false);
    await openDropdown(tester);
    expect(find.byKey(const ValueKey('worktree_picker_worktree_header')), findsNothing);
  });

  testWidgets(
    'git worktree with sidebar collapsed shows the WORKTREE section listing open worktrees, and no hint row',
    (tester) async {
      stubWorkspaces(workspaces: [active, feat], activeId: activePath);
      stubSessions(workspaceId: activePath, tabs: [_session('t')], activeTab: 't');

      await pump(tester, workspaceId: activePath, sidebarCollapsed: true);
      await openDropdown(tester);

      expect(find.byKey(const ValueKey('worktree_picker_worktree_/repo/main')), findsOneWidget);
      expect(find.byKey(const ValueKey('worktree_picker_worktree_/repo/feat')), findsOneWidget);
      expect(find.byKey(const ValueKey('worktree_picker_worktree_header')), findsOneWidget);
      expect(find.byKey(const ValueKey('worktree_picker_change_hint')), findsNothing);
    },
  );

  testWidgets(
    'git worktree with sidebar expanded hides the WORKTREE section and shows the change-worktree hint instead',
    (tester) async {
      stubWorkspaces(workspaces: [active, feat], activeId: activePath);
      stubSessions(workspaceId: activePath, tabs: [_session('t')], activeTab: 't');

      await pump(tester, workspaceId: activePath, sidebarCollapsed: false);
      await openDropdown(tester);

      expect(find.byKey(const ValueKey('worktree_picker_worktree_/repo/main')), findsNothing);
      expect(find.byKey(const ValueKey('worktree_picker_worktree_/repo/feat')), findsNothing);
      expect(find.byKey(const ValueKey('worktree_picker_worktree_header')), findsNothing);
      expect(find.byKey(const ValueKey('worktree_picker_change_hint')), findsOneWidget);
    },
  );

  testWidgets('tapping a worktree row calls openPath and closes the dropdown', (tester) async {
    stubWorkspaces(workspaces: [active, feat], activeId: activePath);
    stubSessions(workspaceId: activePath, tabs: [_session('t')], activeTab: 't');

    await pump(tester, workspaceId: activePath, sidebarCollapsed: true);
    await openDropdown(tester);

    await tester.tap(find.byKey(const ValueKey('worktree_picker_worktree_/repo/feat')));
    await tester.pumpAndSettle();

    verify(() => ws.openPath('/repo/feat')).called(1);
    expect(find.byKey(const ValueKey('worktree_picker_worktree_/repo/feat')), findsNothing);
  });

  testWidgets('dropdown lists sessions; tapping one switches tab and closes the dropdown', (tester) async {
    stubWorkspaces(workspaces: [active], activeId: activePath);
    stubSessions(workspaceId: activePath, tabs: [_session('t1'), _session('t2')], activeTab: 't1');

    await pump(tester, workspaceId: activePath, sidebarCollapsed: false);
    await openDropdown(tester);

    expect(find.byKey(const ValueKey('worktree_picker_session_t1')), findsOneWidget);
    expect(find.byKey(const ValueKey('worktree_picker_session_t2')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('worktree_picker_session_t2')));
    await tester.pumpAndSettle();

    verify(() => sessions.switchTab(activePath, 't2')).called(1);
    expect(find.byKey(const ValueKey('worktree_picker_session_t2')), findsNothing);
  });

  testWidgets('tapping + New session calls openNewSession and closes the dropdown', (tester) async {
    stubWorkspaces(workspaces: [active], activeId: activePath);
    stubSessions(workspaceId: activePath, tabs: [_session('t1')], activeTab: 't1');

    await pump(tester, workspaceId: activePath, sidebarCollapsed: false);
    await openDropdown(tester);

    await tester.tap(find.byKey(const ValueKey('worktree_picker_new_session')));
    await tester.pumpAndSettle();

    verify(() => sessions.openNewSession(activePath)).called(1);
    expect(find.byKey(const ValueKey('worktree_picker_new_session')), findsNothing);
  });
}
