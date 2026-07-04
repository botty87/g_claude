// [NewWorktreeDialog] contract: the "new branch" mode routes to
// WorkspacesCubit.createWorktree (default base = the repo's main branch, open-
// after ON) and surfaces a failed creation without closing; the "open existing"
// mode inspects the typed folder and, on confirm, opens it via openPath.
//
// One testWidgets: EasyLocalization only loads its JSON for the first pumped
// tree in a file, so we pump once and re-open the dialog per scenario.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/core/utils/either.dart';
import 'package:g_claude/features/git/domain/entities/git_branch.dart';
import 'package:g_claude/features/git/domain/entities/git_folder_inspection.dart';
import 'package:g_claude/features/git/domain/entities/git_worktree.dart';
import 'package:g_claude/features/shell/presentation/widgets/new_worktree_dialog.dart';
import 'package:g_claude/features/workspace/presentation/cubit/workspaces_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockWorkspacesCubit extends MockCubit<WorkspacesState> implements WorkspacesCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const repoRoot = '/repo';
  // The main worktree lives at repoRoot on branch 'main' → that's the default base.
  final worktrees = const [GitWorktree(path: '/repo', head: 'a', branch: 'main')];

  late _MockWorkspacesCubit cubit;

  setUp(() {
    cubit = _MockWorkspacesCubit();
    whenListen(cubit, const Stream<WorkspacesState>.empty(), initialState: const WorkspacesState.loaded());
    when(
      () => cubit.branchesFor(repoRoot),
    ).thenAnswer((_) async => const [GitBranch(name: 'main', worktreePath: '/repo'), GitBranch(name: 'dev')]);
    when(
      () => cubit.createWorktree(
        repoRoot: any(named: 'repoRoot'),
        targetPath: any(named: 'targetPath'),
        newBranch: any(named: 'newBranch'),
        baseRef: any(named: 'baseRef'),
        checkoutBranch: any(named: 'checkoutBranch'),
        openAfter: any(named: 'openAfter'),
      ),
    ).thenAnswer((_) async => const Right(null));
    when(() => cubit.inspectFolder(any())).thenAnswer(
      (_) async => const GitFolderInspection(
        isGit: true,
        repoRoot: '/other/repo',
        branch: 'hotfix/login',
        isWorktree: true,
        dirtyCount: 3,
      ),
    );
    when(() => cubit.openPath(any())).thenAnswer((_) async {});
  });

  testWidgets('new-branch creates via createWorktree; open-existing inspects + opens; failure keeps dialog open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppWidget(
      tester,
      Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => showNewWorktreeDialog(context, repoRoot: repoRoot, worktrees: worktrees),
            child: const Text('open'),
          ),
        ),
      ),
      appBuilder: (context, navigatorChild) =>
          BlocProvider<WorkspacesCubit>.value(value: cubit, child: navigatorChild!),
    );

    Future<void> openDialog() async {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    // 1) New branch: typing the name enables Create and routes to createWorktree
    //    with the repo's default base ('main') and open-after ON.
    await openDialog();
    await tester.enterText(find.byKey(const ValueKey('new_worktree_branch_name')), 'feature/new');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('new_worktree_confirm')));
    await tester.pumpAndSettle();
    verify(
      () => cubit.createWorktree(
        repoRoot: repoRoot,
        targetPath: any(named: 'targetPath'),
        newBranch: 'feature/new',
        baseRef: 'main',
        checkoutBranch: null,
        openAfter: true,
      ),
    ).called(1);
    clearInteractions(cubit);
    when(
      () => cubit.branchesFor(repoRoot),
    ).thenAnswer((_) async => const [GitBranch(name: 'main', worktreePath: '/repo'), GitBranch(name: 'dev')]);

    // 2) Open existing: switch mode, type a folder, the inspection card appears,
    //    and confirming opens the folder via openPath.
    await openDialog();
    await tester.tap(find.text('Open existing'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('new_worktree_existing_path')), '/other/repo');
    await tester.pump(const Duration(milliseconds: 400)); // debounce
    await tester.pumpAndSettle();
    expect(find.text('Git worktree detected'), findsOneWidget);
    expect(find.text('hotfix/login'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('new_worktree_confirm')));
    await tester.pumpAndSettle();
    verify(() => cubit.openPath('/other/repo')).called(1);
    verifyNever(
      () => cubit.createWorktree(
        repoRoot: any(named: 'repoRoot'),
        targetPath: any(named: 'targetPath'),
        newBranch: any(named: 'newBranch'),
        baseRef: any(named: 'baseRef'),
        checkoutBranch: any(named: 'checkoutBranch'),
        openAfter: any(named: 'openAfter'),
      ),
    );
    clearInteractions(cubit);

    // 3) New-branch failure keeps the dialog open with the git message.
    when(
      () => cubit.createWorktree(
        repoRoot: any(named: 'repoRoot'),
        targetPath: any(named: 'targetPath'),
        newBranch: any(named: 'newBranch'),
        baseRef: any(named: 'baseRef'),
        checkoutBranch: any(named: 'checkoutBranch'),
        openAfter: any(named: 'openAfter'),
      ),
    ).thenAnswer((_) async => const Left(SubprocessFailure(message: 'fatal: already exists')));
    await openDialog();
    await tester.enterText(find.byKey(const ValueKey('new_worktree_branch_name')), 'dup');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('new_worktree_confirm')));
    await tester.pumpAndSettle();
    expect(find.text('fatal: already exists'), findsOneWidget);
    expect(find.byKey(const ValueKey('new_worktree_confirm')), findsOneWidget);
  });
}
