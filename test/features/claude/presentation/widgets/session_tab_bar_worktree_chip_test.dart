// [SessionTabBar] worktree chip contracts: the chip is a *quick* switcher shown
// only when the sidebar is collapsed. It lists only the repo's *opened*
// worktrees (staying consistent with the sidebar's default "open only" view);
// picking one routes to [WorkspacesCubit.openPath]. Reads live from the cubits.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/claude/domain/entities/claude_effort.dart';
import 'package:g_claude/features/claude/domain/entities/claude_model.dart';
import 'package:g_claude/features/claude/domain/entities/claude_permission_mode.dart';
import 'package:g_claude/features/claude/domain/entities/claude_thinking_mode.dart';
import 'package:g_claude/features/claude/presentation/cubit/claude_sessions_cubit.dart';
import 'package:g_claude/features/claude/presentation/widgets/session_tab_bar.dart';
import 'package:g_claude/features/git/domain/entities/git_worktree.dart';
import 'package:g_claude/features/shell/presentation/cubit/shell_cubit.dart';
import 'package:g_claude/features/workspace/domain/entities/workspace.dart';
import 'package:g_claude/features/workspace/presentation/cubit/workspaces_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repoRoot = '/repo';
  const activePath = '/repo/main';
  final active = _ws(activePath, repoRoot: repoRoot, branch: 'main');
  final feat = _ws('/repo/feat', repoRoot: repoRoot, branch: 'feature/x');

  // The live git list carries a branch (`/repo/ghost`) that has NO open
  // workspace — the chip must not offer it.
  final worktrees = const [
    GitWorktree(path: '/repo/main', head: 'a', branch: 'main'),
    GitWorktree(path: '/repo/feat', head: 'b', branch: 'feature/x'),
    GitWorktree(path: '/repo/ghost', head: 'c', branch: 'feature/ghost'),
  ];

  late _MockWorkspacesCubit ws;
  late _MockSessionsCubit sessions;
  late _MockShellCubit shell;

  setUp(() {
    ws = _MockWorkspacesCubit();
    whenListen(
      ws,
      const Stream<WorkspacesState>.empty(),
      initialState: WorkspacesState.loaded(workspaces: [active, feat], activeId: activePath),
    );
    when(() => ws.cachedWorktrees(repoRoot)).thenReturn(worktrees);
    when(() => ws.ensureWorktrees(repoRoot)).thenAnswer((_) async => worktrees);
    when(() => ws.openPath(any())).thenAnswer((_) async {});

    sessions = _MockSessionsCubit();
    final data = ClaudeSessionData(
      tabId: 't',
      model: ClaudeModel.sonnet,
      permissionMode: ClaudePermissionMode.auto,
      effort: ClaudeEffort.high,
      thinkingMode: ClaudeThinkingMode.on,
    );
    whenListen(
      sessions,
      const Stream<ClaudeSessionsState>.empty(),
      initialState: ClaudeSessionsState(
        workspaces: {
          activePath: WorkspaceSessions(tabs: [data], activeTabId: 't'),
        },
      ),
    );

    shell = _MockShellCubit();
  });

  Future<void> pump(WidgetTester tester, {required bool sidebarCollapsed}) async {
    whenListen(
      shell,
      const Stream<ShellState>.empty(),
      initialState: ShellState(selectedActivity: ActivityId.sessions, sidebarCollapsed: sidebarCollapsed),
    );
    await pumpAppWidget(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<WorkspacesCubit>.value(value: ws),
          BlocProvider<ClaudeSessionsCubit>.value(value: sessions),
          BlocProvider<ShellCubit>.value(value: shell),
        ],
        child: const SessionTabBar(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('sidebar collapsed: chip shows active branch, lists only opened worktrees, picking calls openPath', (
    tester,
  ) async {
    await pump(tester, sidebarCollapsed: true);

    expect(find.byKey(const ValueKey('worktree_chip')), findsOneWidget);
    expect(find.text('main'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('worktree_chip')));
    await tester.pumpAndSettle();

    // Opened worktrees appear; the branch without an open worktree does not.
    expect(find.byKey(const ValueKey('worktree_menu_/repo/main')), findsOneWidget);
    expect(find.byKey(const ValueKey('worktree_menu_/repo/feat')), findsOneWidget);
    expect(find.byKey(const ValueKey('worktree_menu_/repo/ghost')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('worktree_menu_/repo/feat')));
    await tester.pumpAndSettle();
    verify(() => ws.openPath('/repo/feat')).called(1);
  });

  testWidgets('sidebar expanded: chip is not shown (the tree switches worktrees instead)', (tester) async {
    await pump(tester, sidebarCollapsed: false);
    expect(find.byKey(const ValueKey('worktree_chip')), findsNothing);
  });
}
