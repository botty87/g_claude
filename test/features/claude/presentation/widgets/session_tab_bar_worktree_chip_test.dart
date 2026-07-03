// [SessionTabBar] worktree chip contracts: when the active workspace is a git
// worktree, the chip shows the current branch and its menu lists the repo's
// worktrees; picking one routes to [WorkspacesCubit.openPath] (activate if
// open, register lazily otherwise). Reads live from the cubits — no local mirror.

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
import 'package:g_claude/features/workspace/domain/entities/workspace.dart';
import 'package:g_claude/features/workspace/presentation/cubit/workspaces_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockWorkspacesCubit extends MockCubit<WorkspacesState> implements WorkspacesCubit {}

class _MockSessionsCubit extends MockCubit<ClaudeSessionsState> implements ClaudeSessionsCubit {}

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

  final worktrees = const [
    GitWorktree(path: '/repo/main', head: 'a', branch: 'main'),
    GitWorktree(path: '/repo/feat', head: 'b', branch: 'feature/x'),
  ];

  late _MockWorkspacesCubit ws;
  late _MockSessionsCubit sessions;

  setUp(() {
    ws = _MockWorkspacesCubit();
    whenListen(
      ws,
      const Stream<WorkspacesState>.empty(),
      initialState: WorkspacesState.loaded(workspaces: [active], activeId: activePath),
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
  });

  Future<void> pump(WidgetTester tester) async {
    await pumpAppWidget(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<WorkspacesCubit>.value(value: ws),
          BlocProvider<ClaudeSessionsCubit>.value(value: sessions),
        ],
        child: const SessionTabBar(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('chip shows the active branch, lists worktrees, and picking one calls openPath', (tester) async {
    await pump(tester);

    // Chip is present and shows the active branch.
    expect(find.byKey(const ValueKey('worktree_chip')), findsOneWidget);
    expect(find.text('main'), findsWidgets);

    // Open the menu: both worktrees appear (the not-opened one too).
    await tester.tap(find.byKey(const ValueKey('worktree_chip')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('worktree_menu_/repo/feat')), findsOneWidget);

    // Picking the not-opened worktree routes to openPath.
    await tester.tap(find.byKey(const ValueKey('worktree_menu_/repo/feat')));
    await tester.pumpAndSettle();
    verify(() => ws.openPath('/repo/feat')).called(1);
  });
}
