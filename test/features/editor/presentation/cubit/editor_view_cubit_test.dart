// State-machine contracts for [EditorViewCubit].
//
// Tracks, per workspace, which center surface is shown (chat / code / terminal),
// whether the peek overlay is open and the chat/peek split ratio. The open-files
// set lives elsewhere ([FileTabsCubit]); this cubit only models the view mode.
// It prunes per-workspace state when a workspace is closed.

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/editor/presentation/cubit/editor_view_cubit.dart';
import 'package:g_claude/features/workspace/domain/entities/workspace.dart';
import 'package:g_claude/features/workspace/presentation/cubit/workspaces_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockWorkspacesCubit extends Mock implements WorkspacesCubit {}

Workspace _ws(String id) => Workspace(id: id, path: id, name: id, openedAt: DateTime(2020));

void main() {
  const wsA = '/ws/a';
  const wsB = '/ws/b';

  late _MockWorkspacesCubit workspaces;
  late StreamController<WorkspacesState> wsController;

  setUp(() {
    workspaces = _MockWorkspacesCubit();
    wsController = StreamController<WorkspacesState>.broadcast();
    when(() => workspaces.stream).thenAnswer((_) => wsController.stream);
    when(() => workspaces.state).thenReturn(const WorkspacesState.initial());
  });

  tearDown(() => wsController.close());

  EditorViewCubit makeCubit() => EditorViewCubit(workspaces)..init();

  test('defaults to chat view, no peek, 0.56 split for an unknown workspace', () {
    final cubit = makeCubit();
    expect(cubit.state.dataFor(wsA), const EditorViewData());
    expect(cubit.state.dataFor(wsA).view, CenterView.chat);
    expect(cubit.state.dataFor(wsA).peekOpen, isFalse);
    expect(cubit.state.dataFor(wsA).peekFraction, 0.56);
    cubit.close();
  });

  blocTest<EditorViewCubit, EditorViewState>(
    'setView records the view and clears any peek',
    build: makeCubit,
    act: (c) => c
      ..openPeek(wsA)
      ..setView(wsA, CenterView.code),
    expect: () => [
      isA<EditorViewState>().having((s) => s.dataFor(wsA), 'A', const EditorViewData(peekOpen: true)),
      isA<EditorViewState>().having((s) => s.dataFor(wsA), 'A', const EditorViewData(view: CenterView.code)),
    ],
  );

  blocTest<EditorViewCubit, EditorViewState>(
    'promoteToFull -> code+no peek, demoteToPeek -> chat+peek',
    build: makeCubit,
    act: (c) => c
      ..promoteToFull(wsA)
      ..demoteToPeek(wsA),
    expect: () => [
      isA<EditorViewState>().having((s) => s.dataFor(wsA), 'A', const EditorViewData(view: CenterView.code)),
      isA<EditorViewState>().having((s) => s.dataFor(wsA), 'A', const EditorViewData(peekOpen: true)),
    ],
  );

  blocTest<EditorViewCubit, EditorViewState>(
    'closePeek clears the overlay without touching the view',
    build: makeCubit,
    seed: () => const EditorViewState(perWorkspace: {wsA: EditorViewData(view: CenterView.code, peekOpen: true)}),
    act: (c) => c.closePeek(wsA),
    expect: () => [
      isA<EditorViewState>().having((s) => s.dataFor(wsA), 'A', const EditorViewData(view: CenterView.code)),
    ],
  );

  blocTest<EditorViewCubit, EditorViewState>(
    'setPeekFraction updates the split ratio, preserving view/peek',
    build: makeCubit,
    seed: () => const EditorViewState(perWorkspace: {wsA: EditorViewData(peekOpen: true)}),
    act: (c) => c.setPeekFraction(wsA, 0.4),
    expect: () => [
      isA<EditorViewState>().having(
        (s) => s.dataFor(wsA),
        'A',
        const EditorViewData(peekOpen: true, peekFraction: 0.4),
      ),
    ],
  );

  blocTest<EditorViewCubit, EditorViewState>(
    'view mode is isolated per workspace',
    build: makeCubit,
    act: (c) => c.setView(wsA, CenterView.terminal),
    verify: (c) {
      expect(c.state.dataFor(wsA).view, CenterView.terminal);
      expect(c.state.dataFor(wsB).view, CenterView.chat);
    },
  );

  blocTest<EditorViewCubit, EditorViewState>(
    'no-op when the view is already the requested one',
    build: makeCubit,
    seed: () => const EditorViewState(perWorkspace: {wsA: EditorViewData(view: CenterView.code)}),
    act: (c) => c.setView(wsA, CenterView.code),
    expect: () => const <EditorViewState>[],
  );

  test('prunes view state when a workspace is closed', () async {
    final cubit = makeCubit();
    cubit
      ..setView(wsA, CenterView.code)
      ..setView(wsB, CenterView.terminal);
    expect(cubit.state.perWorkspace.keys, containsAll(<String>[wsA, wsB]));

    // wsA closed → only wsB remains alive.
    wsController.add(WorkspacesState.loaded(workspaces: [_ws(wsB)], activeId: wsB));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.perWorkspace.keys, [wsB]);
    await cubit.close();
  });
}
