// State-machine contracts for [EditorViewCubit].
//
// Tracks, per workspace, which center surface is shown (chat / code / terminal)
// and whether the peek overlay is open. The open-files set lives elsewhere
// ([FileTabsCubit]); this cubit only models the view mode.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/editor/presentation/cubit/editor_view_cubit.dart';

void main() {
  const wsA = '/ws/a';
  const wsB = '/ws/b';

  test('defaults to chat view with no peek for an unknown workspace', () {
    final cubit = EditorViewCubit();
    expect(cubit.state.dataFor(wsA), const EditorViewData());
    expect(cubit.state.dataFor(wsA).view, CenterView.chat);
    expect(cubit.state.dataFor(wsA).peekOpen, isFalse);
    expect(cubit.state.dataFor(null), const EditorViewData());
    cubit.close();
  });

  blocTest<EditorViewCubit, EditorViewState>(
    'setView records the view and clears any peek',
    build: EditorViewCubit.new,
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
    build: EditorViewCubit.new,
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
    build: EditorViewCubit.new,
    seed: () => const EditorViewState(perWorkspace: {wsA: EditorViewData(view: CenterView.code, peekOpen: true)}),
    act: (c) => c.closePeek(wsA),
    expect: () => [
      isA<EditorViewState>().having((s) => s.dataFor(wsA), 'A', const EditorViewData(view: CenterView.code)),
    ],
  );

  blocTest<EditorViewCubit, EditorViewState>(
    'view mode is isolated per workspace',
    build: EditorViewCubit.new,
    act: (c) => c.setView(wsA, CenterView.terminal),
    verify: (c) {
      expect(c.state.dataFor(wsA).view, CenterView.terminal);
      expect(c.state.dataFor(wsB).view, CenterView.chat);
    },
  );

  blocTest<EditorViewCubit, EditorViewState>(
    'no-op when the view is already the requested one',
    build: EditorViewCubit.new,
    seed: () => const EditorViewState(perWorkspace: {wsA: EditorViewData(view: CenterView.code)}),
    act: (c) => c.setView(wsA, CenterView.code),
    expect: () => const <EditorViewState>[],
  );
}
