// [CloseWorktreeDialog] contract: each choice routes to the right
// WorkspacesCubit action, the main checkout can only be closed, and a failed
// removal keeps the dialog open showing the error. Reads/acts through the cubit.
//
// All flows live in ONE testWidgets: EasyLocalization only loads its JSON for
// the FIRST pumped tree in a file (a second `pumpAppWidget` renders the loading
// placeholder forever under fake test time), so we pump once and re-open the
// dialog per scenario, clearing cubit interactions between them.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/core/utils/either.dart';
import 'package:g_claude/features/shell/presentation/widgets/close_worktree_dialog.dart';
import 'package:g_claude/features/workspace/presentation/cubit/workspaces_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockWorkspacesCubit extends MockCubit<WorkspacesState> implements WorkspacesCubit {}

const _closeOnly = ValueKey('close_worktree_option_closeOnly');
const _removeWt = ValueKey('close_worktree_option_removeWorktree');
const _removeWtBranch = ValueKey('close_worktree_option_removeWorktreeAndBranch');
const _confirm = ValueKey('close_worktree_confirm');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockWorkspacesCubit cubit;

  setUp(() {
    cubit = _MockWorkspacesCubit();
    whenListen(cubit, const Stream<WorkspacesState>.empty(), initialState: const WorkspacesState.loaded());
    when(() => cubit.closeWorkspace(any())).thenReturn(null);
    when(
      () => cubit.removeWorktree(
        any(),
        deleteBranch: any(named: 'deleteBranch'),
        force: any(named: 'force'),
        forceBranch: any(named: 'forceBranch'),
        branch: any(named: 'branch'),
      ),
    ).thenAnswer((_) async => const Right(null));
  });

  testWidgets('each choice routes to the right action; main can only close; failure keeps the dialog open', (
    tester,
  ) async {
    // The dialog is sized for the app's real window; the default 800x600 test
    // surface is too short for the three options + error row (overflow).
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpAppWidget(
      tester,
      Builder(
        builder: (context) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => showCloseWorktreeDialog(
                  context,
                  workspaceId: '/repo/wt',
                  name: 'wt',
                  branch: 'feature/x',
                  isMain: false,
                ),
                child: const Text('open'),
              ),
              ElevatedButton(
                onPressed: () => showCloseWorktreeDialog(context, workspaceId: '/repo/wt', name: 'wt', isMain: true),
                child: const Text('openMain'),
              ),
            ],
          ),
        ),
      ),
      // showDialog pushes a route as a sibling of the home route in the
      // Navigator's overlay; wrapping the provider via MaterialApp.builder puts
      // it above the Navigator so the dialog route can see it.
      appBuilder: (context, navigatorChild) =>
          BlocProvider<WorkspacesCubit>.value(value: cubit, child: navigatorChild!),
    );

    Future<void> openLinked() async {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    // 1) "Remove worktree" → removeWorktree(deleteBranch:false). Also asserts the
    // three options render for a linked worktree.
    await openLinked();
    expect(find.byKey(_closeOnly), findsOneWidget);
    expect(find.byKey(_removeWt), findsOneWidget);
    expect(find.byKey(_removeWtBranch), findsOneWidget);
    await tester.tap(find.byKey(_removeWt));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_confirm));
    await tester.pumpAndSettle();
    verify(
      () =>
          cubit.removeWorktree('/repo/wt', deleteBranch: false, force: false, forceBranch: false, branch: 'feature/x'),
    ).called(1);
    clearInteractions(cubit);

    // 2) "Remove worktree and branch" → removeWorktree(deleteBranch:true).
    await openLinked();
    await tester.tap(find.byKey(_removeWtBranch));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_confirm));
    await tester.pumpAndSettle();
    verify(
      () => cubit.removeWorktree('/repo/wt', deleteBranch: true, force: false, forceBranch: false, branch: 'feature/x'),
    ).called(1);
    clearInteractions(cubit);

    // 3) "Close only" → closeWorkspace, no removeWorktree.
    await openLinked();
    await tester.tap(find.byKey(_closeOnly));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_confirm));
    await tester.pumpAndSettle();
    verify(() => cubit.closeWorkspace('/repo/wt')).called(1);
    verifyNever(
      () => cubit.removeWorktree(
        any(),
        deleteBranch: any(named: 'deleteBranch'),
        force: any(named: 'force'),
        forceBranch: any(named: 'forceBranch'),
        branch: any(named: 'branch'),
      ),
    );
    clearInteractions(cubit);

    // 4) main checkout: no radio options, confirm just closes.
    await tester.tap(find.text('openMain'));
    await tester.pumpAndSettle();
    expect(find.byKey(_closeOnly), findsNothing);
    expect(find.byKey(_removeWt), findsNothing);
    await tester.tap(find.byKey(_confirm));
    await tester.pumpAndSettle();
    verify(() => cubit.closeWorkspace('/repo/wt')).called(1);
    clearInteractions(cubit);

    // 5) failure → dialog stays open with the error message.
    when(
      () => cubit.removeWorktree(
        any(),
        deleteBranch: any(named: 'deleteBranch'),
        force: any(named: 'force'),
        forceBranch: any(named: 'forceBranch'),
        branch: any(named: 'branch'),
      ),
    ).thenAnswer((_) async => const Left(SubprocessFailure(message: 'dirty working tree')));
    await openLinked();
    await tester.tap(find.byKey(_removeWt));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_confirm));
    await tester.pumpAndSettle();
    expect(find.text('dirty working tree'), findsOneWidget);
    expect(find.byKey(_confirm), findsOneWidget);
  });
}
