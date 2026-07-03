// [WorkspaceSidebar] repo-group contracts: a git repo renders as an expandable
// group whose opened worktrees show by default; the "show all" toggle reveals
// worktrees present on disk but not yet opened, and clicking one routes to
// [WorkspacesCubit.openPath] (lazy register). Reads live from the cubits.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:g_claude/features/claude/presentation/cubit/claude_sessions_cubit.dart';
import 'package:g_claude/features/git/domain/entities/git_worktree.dart';
import 'package:g_claude/features/shell/presentation/cubit/shell_cubit.dart';
import 'package:g_claude/features/shell/presentation/widgets/workspace_sidebar.dart';
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
  final mainWt = _ws('/repo/main', repoRoot: repoRoot, branch: 'main');
  final worktrees = const [
    GitWorktree(path: '/repo/main', head: 'a', branch: 'main'),
    GitWorktree(path: '/repo/feat', head: 'b', branch: 'feature/x'),
  ];

  late _MockWorkspacesCubit ws;
  late _MockSessionsCubit sessions;
  late _MockShellCubit shell;

  setUp(() {
    ws = _MockWorkspacesCubit();
    whenListen(
      ws,
      const Stream<WorkspacesState>.empty(),
      initialState: WorkspacesState.loaded(workspaces: [mainWt], activeId: '/repo/main'),
    );
    when(() => ws.cachedWorktrees(repoRoot)).thenReturn(worktrees);
    when(() => ws.ensureWorktrees(repoRoot)).thenAnswer((_) async => worktrees);
    when(() => ws.openPath(any())).thenAnswer((_) async {});

    sessions = _MockSessionsCubit();
    whenListen(sessions, const Stream<ClaudeSessionsState>.empty(), initialState: const ClaudeSessionsState());

    shell = _MockShellCubit();
    whenListen(
      shell,
      const Stream<ShellState>.empty(),
      initialState: const ShellState(selectedActivity: ActivityId.sessions),
    );
  });

  Future<void> pump(WidgetTester tester) async {
    await pumpAppWidget(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<WorkspacesCubit>.value(value: ws),
          BlocProvider<ClaudeSessionsCubit>.value(value: sessions),
          BlocProvider<ShellCubit>.value(value: shell),
        ],
        child: const SizedBox(width: 262, height: 600, child: WorkspaceSidebar()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('repo group shows opened worktree; "show all" reveals not-opened and opens on tap', (tester) async {
    await pump(tester);

    // The repo group header renders; the opened worktree row is present.
    expect(find.byKey(const ValueKey('repo_group_repo')), findsOneWidget);
    expect(find.byKey(const ValueKey('worktree_row_/repo/main')), findsOneWidget);
    // Not-opened worktree is hidden until "show all".
    expect(find.byKey(const ValueKey('worktree_row_/repo/feat')), findsNothing);

    // Toggle "show all": the not-opened worktree appears.
    await tester.tap(find.byIcon(Symbols.visibility_off));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('worktree_row_/repo/feat')), findsOneWidget);

    // Clicking the not-opened worktree routes to openPath.
    await tester.tap(find.byKey(const ValueKey('worktree_row_/repo/feat')));
    await tester.pumpAndSettle();
    verify(() => ws.openPath('/repo/feat')).called(1);
  });
}
