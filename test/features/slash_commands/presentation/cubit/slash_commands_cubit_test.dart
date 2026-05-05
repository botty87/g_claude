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
import 'package:g_claude/features/slash_commands/domain/entities/slash_command.dart';
import 'package:g_claude/features/slash_commands/domain/entities/slash_command_source.dart';
import 'package:g_claude/features/slash_commands/domain/usecases/filter_slash_commands.dart';
import 'package:g_claude/features/slash_commands/domain/usecases/load_slash_commands.dart';
import 'package:g_claude/features/slash_commands/presentation/cubit/slash_commands_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:talker_flutter/talker_flutter.dart';

class _MockLoad extends Mock implements LoadSlashCommands {}

SlashCommand _cmd(String trigger, {String description = ''}) {
  return SlashCommand(
    name: trigger.replaceFirst('/', ''),
    trigger: trigger,
    description: description,
    source: SlashCommandSource.user,
  );
}

void main() {
  late _MockLoad load;
  late FilterSlashCommands filter;

  setUp(() {
    load = _MockLoad();
    filter = FilterSlashCommands(); // pure logic — use the real one.
  });

  SlashCommandsCubit make() => SlashCommandsCubit(load, filter, Talker());

  group('loadFor', () {
    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'success populates `all` and stays in idle',
      build: () {
        when(() => load.call(workspaceCwd: any(named: 'workspaceCwd')))
            .thenAnswer((_) async => Right([
                  _cmd('/foo', description: 'first'),
                  _cmd('/bar', description: 'second'),
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
      seed: () => SlashCommandsState.idle(all: [_cmd('/commit'), _cmd('/feature')]),
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
        all: [_cmd('/foo')],
        filtered: [_cmd('/foo')],
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
      seed: () => SlashCommandsState.idle(all: [_cmd('/feature')]),
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
        all: [_cmd('/c1'), _cmd('/c2'), _cmd('/c3')],
        filtered: [_cmd('/c1'), _cmd('/c2'), _cmd('/c3')],
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
      seed: () => SlashCommandsState.idle(all: [_cmd('/foo')]),
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
        all: [_cmd('/a'), _cmd('/b'), _cmd('/c')],
        filtered: [_cmd('/a'), _cmd('/b'), _cmd('/c')],
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
        all: [_cmd('/a'), _cmd('/b')],
        filtered: [_cmd('/a'), _cmd('/b')],
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
        all: [_cmd('/a')],
        filtered: [_cmd('/a')],
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
    test('returns the currently highlighted command in suggesting state', () {
      final c = make();
      c.emit(SlashCommandsState.suggesting(
        all: [_cmd('/a'), _cmd('/b')],
        filtered: [_cmd('/a'), _cmd('/b')],
        selectedIndex: 1,
        filter: '/',
      ));
      expect(c.accept()?.trigger, '/b');
    });

    test('returns null when state is idle', () {
      final c = make();
      expect(c.accept(), isNull);
    });

    test('returns null when filtered is empty', () {
      final c = make();
      c.emit(SlashCommandsState.suggesting(
        all: const [],
        filtered: const [],
        selectedIndex: 0,
        filter: '/zzz',
      ));
      expect(c.accept(), isNull);
    });
  });

  group('updateSkills', () {
    blocTest<SlashCommandsCubit, SlashCommandsState>(
      'merges new skills (no duplicate triggers) into idle state',
      build: () => make(),
      seed: () => SlashCommandsState.idle(all: [_cmd('/preexisting')]),
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
        all: [_cmd('/foo')],
        filtered: [_cmd('/foo')],
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
        all: [_cmd('/a')],
        filtered: [_cmd('/a')],
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
