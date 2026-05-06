// Contracts for `SlashCommandsCubit`.
//
// The cubit drives the slash-command palette inside the input bar. It is
// `@injectable` (factory): a fresh instance per route. Tests focus on the
// observable transitions: load → idle, onInputChanged → suggesting / idle,
// moveSelection / selectAt clamping, accept returning the highlighted
// command, dismiss → idle.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/core/utils/either.dart';
import 'package:g_claude/features/slash_commands/domain/usecases/filter_slash_commands.dart';
import 'package:g_claude/features/slash_commands/domain/usecases/load_slash_commands.dart';
import 'package:g_claude/features/slash_commands/presentation/cubit/slash_commands_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';

class _MockLoad extends Mock implements LoadSlashCommands {}

void main() {
  late _MockLoad load;
  late FilterSlashCommands filter;

  setUp(() {
    load = _MockLoad();
    filter = FilterSlashCommands(); // pure logic — use the real one.
  });

  SlashCommandsCubit make() => SlashCommandsCubit(load, filter, makeTestTalker());

  group('loadFor', () {
    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'success populates `all` and stays in idle',
      build: () {
        when(() => load.call(workspaceCwd: any(named: 'workspaceCwd')))
            .thenAnswer((_) async => Right([
                  makeSlashCommand('/foo', description: 'first'),
                  makeSlashCommand('/bar', description: 'second'),
                ]));
        return make();
      },
      act: (c) => c.loadFor('/some/cwd'),
      expect: () => [
        isA<SlashCommandsStateIdle>().having((s) => s.all.length, 'count', 2),
      ],
    );

    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'failure emits an empty idle state and does not throw',
      build: () {
        when(() => load.call(workspaceCwd: any(named: 'workspaceCwd')))
            .thenAnswer((_) async => Left(NotFoundFailure('cwd missing')));
        return make();
      },
      act: (c) => c.loadFor('/missing'),
      expect: () => [isA<SlashCommandsStateIdle>().having((s) => s.all, 'all', isEmpty)],
    );
  });

  group('onInputChanged — entering / leaving suggesting state', () {
    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'a leading slash transitions to suggesting with filtered results',
      build: () => make(),
      seed: () => SlashCommandsState.idle(all: [makeSlashCommand('/commit'), makeSlashCommand('/feature')]),
      act: (c) => c.onInputChanged('/co'),
      expect: () => [
        isA<SlashCommandsStateSuggesting>()
            .having((s) => s.filter, 'filter', '/co')
            .having((s) => s.filtered.length, 'filtered count', 1)
            .having((s) => s.filtered.first.trigger, 'top match', '/commit'),
      ],
    );

    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'text without a leading slash dismisses to idle (with current `all` preserved)',
      build: () => make(),
      seed: () => SlashCommandsState.suggesting(
        all: [makeSlashCommand('/foo')],
        filtered: [makeSlashCommand('/foo')],
        selectedIndex: 0,
        filter: '/f',
      ),
      act: (c) => c.onInputChanged('hello world'),
      expect: () => [
        isA<SlashCommandsStateIdle>().having((s) => s.all.length, 'all preserved', 1),
      ],
    );

    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'multi-line input considers only the LAST line for slash detection',
      build: () => make(),
      seed: () => SlashCommandsState.idle(all: [makeSlashCommand('/feature')]),
      act: (c) => c.onInputChanged('first line\nthen\n/fea'),
      expect: () => [
        isA<SlashCommandsStateSuggesting>()
            .having((s) => s.filter, 'filter', '/fea'),
      ],
    );

    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'previous selectedIndex is preserved (clamped) when filtering changes the list',
      build: () => make(),
      seed: () => SlashCommandsState.suggesting(
        all: [makeSlashCommand('/c1'), makeSlashCommand('/c2'), makeSlashCommand('/c3')],
        filtered: [makeSlashCommand('/c1'), makeSlashCommand('/c2'), makeSlashCommand('/c3')],
        selectedIndex: 2,
        filter: '/c',
      ),
      // Filter '/c1' narrows filtered to just 1 element, prev index 2 must clamp to 0.
      act: (c) => c.onInputChanged('/c1'),
      expect: () => [
        isA<SlashCommandsStateSuggesting>()
            .having((s) => s.filtered.length, 'filtered', 1)
            .having((s) => s.selectedIndex, 'index', 0),
      ],
    );

    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'no matches still emits suggesting with empty filtered + selectedIndex 0',
      build: () => make(),
      seed: () => SlashCommandsState.idle(all: [makeSlashCommand('/foo')]),
      act: (c) => c.onInputChanged('/zzzzz'),
      expect: () => [
        isA<SlashCommandsStateSuggesting>()
            .having((s) => s.filtered, 'filtered', isEmpty)
            .having((s) => s.selectedIndex, 'index', 0),
      ],
    );
  });

  group('moveSelection', () {
    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'moveSelection wraps within bounds (clamp to last index)',
      build: () => make(),
      seed: () => SlashCommandsState.suggesting(
        all: [makeSlashCommand('/a'), makeSlashCommand('/b'), makeSlashCommand('/c')],
        filtered: [makeSlashCommand('/a'), makeSlashCommand('/b'), makeSlashCommand('/c')],
        selectedIndex: 1,
        filter: '/',
      ),
      act: (c) => c.moveSelection(10),
      expect: () => [
        isA<SlashCommandsStateSuggesting>().having((s) => s.selectedIndex, 'idx', 2),
      ],
    );

    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'moveSelection on idle is a no-op',
      build: () => make(),
      seed: () => const SlashCommandsState.idle(),
      act: (c) => c.moveSelection(1),
      expect: () => const <SlashCommandsState>[],
    );

    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'moveSelection on empty filtered is a no-op',
      build: () => make(),
      seed: () => SlashCommandsState.suggesting(
        all: const [],
        filtered: const [],
        selectedIndex: 0,
        filter: '/zzz',
      ),
      act: (c) => c.moveSelection(1),
      expect: () => const <SlashCommandsState>[],
    );
  });

  group('selectAt', () {
    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'selectAt within bounds updates selectedIndex',
      build: () => make(),
      seed: () => SlashCommandsState.suggesting(
        all: [makeSlashCommand('/a'), makeSlashCommand('/b')],
        filtered: [makeSlashCommand('/a'), makeSlashCommand('/b')],
        selectedIndex: 0,
        filter: '/',
      ),
      act: (c) => c.selectAt(1),
      expect: () => [
        isA<SlashCommandsStateSuggesting>().having((s) => s.selectedIndex, 'idx', 1),
      ],
    );

    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'selectAt out-of-bounds is a no-op',
      build: () => make(),
      seed: () => SlashCommandsState.suggesting(
        all: [makeSlashCommand('/a')],
        filtered: [makeSlashCommand('/a')],
        selectedIndex: 0,
        filter: '/',
      ),
      act: (c) {
        c.selectAt(99);
        c.selectAt(-1);
      },
      expect: () => const <SlashCommandsState>[],
    );
  });

  group('accept', () {
    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'returns the currently highlighted command in suggesting state',
      build: () => make(),
      seed: () => SlashCommandsState.suggesting(
        all: [makeSlashCommand('/a'), makeSlashCommand('/b')],
        filtered: [makeSlashCommand('/a'), makeSlashCommand('/b')],
        selectedIndex: 1,
        filter: '/',
      ),
      verify: (c) => expect(c.accept()?.trigger, '/b'),
    );

    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'returns null when state is idle',
      build: () => make(),
      verify: (c) => expect(c.accept(), isNull),
    );

    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'returns null when filtered is empty',
      build: () => make(),
      seed: () => const SlashCommandsState.suggesting(
        all: [],
        filtered: [],
        selectedIndex: 0,
        filter: '/zzz',
      ),
      verify: (c) => expect(c.accept(), isNull),
    );
  });

  group('updateSkills', () {
    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'merges new skills (no duplicate triggers) into idle state',
      build: () => make(),
      seed: () => SlashCommandsState.idle(all: [makeSlashCommand('/preexisting')]),
      act: (c) => c.updateSkills(['skill_a', 'skill_b', 'preexisting']),
      verify: (c) {
        final all = (c.state as SlashCommandsStateIdle).all;
        // /preexisting was already in the list — must NOT be duplicated.
        final triggers = all.map((c) => c.trigger).toList();
        expect(triggers, ['/preexisting', '/skill_a', '/skill_b']);
      },
    );

    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'when in suggesting state, re-applies the active filter against the merged list',
      build: () => make(),
      seed: () => SlashCommandsState.suggesting(
        all: [makeSlashCommand('/foo')],
        filtered: [makeSlashCommand('/foo')],
        selectedIndex: 0,
        filter: '/sk',
      ),
      act: (c) => c.updateSkills(['skill_a']),
      verify: (c) {
        final s = c.state as SlashCommandsStateSuggesting;
        expect(s.all.map((x) => x.trigger), contains('/skill_a'));
        expect(s.filtered.map((x) => x.trigger), contains('/skill_a'));
      },
    );
  });

  group('dismiss', () {
    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'transitions to idle and preserves `all`',
      build: () => make(),
      seed: () => SlashCommandsState.suggesting(
        all: [makeSlashCommand('/a')],
        filtered: [makeSlashCommand('/a')],
        selectedIndex: 0,
        filter: '/',
      ),
      act: (c) => c.dismiss(),
      expect: () => [
        isA<SlashCommandsStateIdle>().having((s) => s.all.length, 'all', 1),
      ],
    );
  });
}
