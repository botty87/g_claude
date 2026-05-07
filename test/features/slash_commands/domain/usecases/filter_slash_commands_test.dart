// Contracts for FilterSlashCommands.
//
// The slash-command palette ranks suggestions in four tiers, in order:
//   1. post-colon prefix     (e.g. "/git:commit" matches query "co")
//   2. whole trigger prefix  (e.g. "/commit" matches query "co")
//   3. name contains         (e.g. "/precommit" matches query "co")
//   4. description contains  (matches query against the description text)
//
// The branches are mutually exclusive (else-if chain): a command lands in at
// most ONE bucket. This is the contract the UI relies on for ordering.
//
// Why this matters: a regression that flips ordering or doubles a command
// across tiers degrades discoverability silently — the test above the change
// must still pass for the same query producing the same ordered list.

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/slash_commands/domain/usecases/filter_slash_commands.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late FilterSlashCommands subject;

  setUp(() {
    subject = FilterSlashCommands();
  });

  group('FilterSlashCommands — empty / passthrough cases', () {
    test('empty filter returns the input list unchanged (same order, same length)', () {
      final all = [makeSlashCommand('/foo'), makeSlashCommand('/bar'), makeSlashCommand('/baz')];

      final out = subject(all, '');

      expect(out, all, reason: 'Empty query short-circuits before any tiering.');
    });

    test('filter consisting only of "/" is treated as empty and returns all', () {
      final all = [makeSlashCommand('/foo'), makeSlashCommand('/bar')];
      expect(subject(all, '/'), all);
    });

    test('filter consisting only of whitespace is treated as empty', () {
      final all = [makeSlashCommand('/foo'), makeSlashCommand('/bar')];
      expect(subject(all, '   '), all);
    });

    test('empty input list with non-empty query returns empty list', () {
      expect(subject(const [], 'foo'), isEmpty);
    });
  });

  group('FilterSlashCommands — ranking tiers', () {
    test('post-colon prefix wins over whole-trigger prefix for the same query', () {
      // "/git:commit" matches "co" via post-colon prefix.
      // "/commit"     matches "co" via whole-trigger prefix.
      // Post-colon must come first.
      final post = makeSlashCommand('/git:commit');
      final whole = makeSlashCommand('/commit');

      final out = subject([whole, post], 'co');

      expect(out, [post, whole]);
    });

    test('whole-trigger prefix wins over name-contains for the same query', () {
      final prefix = makeSlashCommand('/commit');
      final containsOnly = makeSlashCommand('/precommit');

      final out = subject([containsOnly, prefix], 'co');

      expect(out.first, prefix, reason: '"commit" starts with "co"; "precommit" only contains it.');
      expect(out, contains(containsOnly));
      expect(out.length, 2);
    });

    test('name-contains wins over description-contains for the same query', () {
      final nameMatch = makeSlashCommand('/precommit', description: 'something else');
      final descMatch = makeSlashCommand('/foo', description: 'commit related');

      final out = subject([descMatch, nameMatch], 'commit');

      expect(out.first, nameMatch);
      expect(out.last, descMatch);
    });

    test('a command lands in at most one tier (else-if exclusivity)', () {
      // "/commit" satisfies wholePrefix AND nameContains for query "co". The
      // contract is exclusive — it must appear exactly once in the output.
      final cmd = makeSlashCommand('/commit', description: 'co code');

      final out = subject([cmd], 'co');

      expect(out, [cmd]);
      expect(out.length, 1, reason: 'No double-bucketing.');
    });
  });

  group('FilterSlashCommands — query normalization', () {
    test('leading "/" in query is stripped before matching', () {
      final cmd = makeSlashCommand('/commit');
      expect(subject([cmd], '/com'), [cmd]);
    });

    test('only the FIRST leading "/" is stripped (replaceFirst)', () {
      // The implementation uses replaceFirst, so `//foo` becomes `/foo` and
      // will never prefix-match `foo`. Documented contract.
      final cmd = makeSlashCommand('/foo');
      expect(
        subject([cmd], '//foo'),
        isEmpty,
        reason: '"/foo" remaining after stripping one slash does not prefix-match "foo".',
      );
    });

    test('query is lowercased before matching trigger and description', () {
      final cmd = makeSlashCommand('/Commit', description: 'Commit changes');
      expect(subject([cmd], 'COM'), [cmd]);
    });

    test('trigger is lowercased before matching (case-insensitive trigger)', () {
      final cmd = makeSlashCommand('/COMMIT');
      expect(subject([cmd], 'com'), [cmd]);
    });

    test('description match is case-insensitive', () {
      final cmd = makeSlashCommand('/foo', description: 'COMMIT changes');
      expect(subject([cmd], 'commit'), [cmd]);
    });

    test('query is trimmed before matching', () {
      final cmd = makeSlashCommand('/commit');
      expect(subject([cmd], '  commit  '), [cmd]);
    });
  });

  group('FilterSlashCommands — non-matches', () {
    test('a command with no name or description match is dropped', () {
      final cmd = makeSlashCommand('/foo', description: 'bar');
      expect(subject([cmd], 'unrelated'), isEmpty);
    });
  });

  group('FilterSlashCommands — ordering across tiers', () {
    test('within a tier, the original input order is preserved', () {
      final a = makeSlashCommand('/commit-a');
      final b = makeSlashCommand('/commit-b');
      final c = makeSlashCommand('/commit-c');

      final out = subject([c, a, b], 'commit');

      expect(out, [c, a, b], reason: 'Same-tier members keep their input order — stable sort.');
    });
  });
}
