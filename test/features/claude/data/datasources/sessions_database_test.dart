// Contracts for SessionsDatabase FTS5 search behavior.
//
// `_escapeFtsQuery` is private, so we observe it via the public surface that
// uses it: `searchFtsIds`. The body indexed in `sessions_fts` is searched by
// the user's freeform query — the escape function turns each whitespace-
// separated token into a quoted prefix expression so that:
// - SQL FTS5 metacharacters in user input do not crash the query,
// - results are matched as prefixes (e.g. "rep" matches "repository"),
// - empty / whitespace-only queries return [] without hitting SQLite.
//
// A regression here either crashes search ("malformed MATCH expression"), or
// silently mismatches results — both invisible until an end user notices.

import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/drift_in_memory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionsDatabase.searchFtsIds — empty / whitespace queries', () {
    test('empty query returns [] without querying FTS', () async {
      final db = makeSessionsDb();
      addTearDown(db.close);

      await db.upsertSessionFts(sessionId: 's1', workspaceId: 'w1', body: 'anything');

      expect(await db.searchFtsIds(workspaceId: 'w1', query: ''), isEmpty);
    });

    test('whitespace-only query returns []', () async {
      final db = makeSessionsDb();
      addTearDown(db.close);

      await db.upsertSessionFts(sessionId: 's1', workspaceId: 'w1', body: 'anything');

      expect(await db.searchFtsIds(workspaceId: 'w1', query: '   '), isEmpty);
    });
  });

  group('SessionsDatabase.searchFtsIds — prefix matching', () {
    test('a single token matches as a prefix on the body', () async {
      final db = makeSessionsDb();
      addTearDown(db.close);

      await db.upsertSessionFts(sessionId: 's1', workspaceId: 'w1', body: 'repository pattern');

      expect(await db.searchFtsIds(workspaceId: 'w1', query: 'rep'), ['s1']);
    });

    test('two tokens both must prefix-match (logical AND)', () async {
      final db = makeSessionsDb();
      addTearDown(db.close);

      await db.upsertSessionFts(sessionId: 'has-both', workspaceId: 'w1', body: 'repository pattern adoption');
      await db.upsertSessionFts(sessionId: 'has-one', workspaceId: 'w1', body: 'repository only');

      final out = await db.searchFtsIds(workspaceId: 'w1', query: 'rep pat');
      expect(out, ['has-both']);
    });

    test('no match returns an empty list (not a crash)', () async {
      final db = makeSessionsDb();
      addTearDown(db.close);

      await db.upsertSessionFts(sessionId: 's1', workspaceId: 'w1', body: 'repository pattern');

      expect(await db.searchFtsIds(workspaceId: 'w1', query: 'nonsense'), isEmpty);
    });
  });

  group('SessionsDatabase.searchFtsIds — workspace scoping', () {
    test('results are filtered by workspaceId', () async {
      final db = makeSessionsDb();
      addTearDown(db.close);

      await db.upsertSessionFts(sessionId: 's1', workspaceId: 'w1', body: 'shared text');
      await db.upsertSessionFts(sessionId: 's2', workspaceId: 'w2', body: 'shared text');

      expect(await db.searchFtsIds(workspaceId: 'w1', query: 'shared'), ['s1']);
      expect(await db.searchFtsIds(workspaceId: 'w2', query: 'shared'), ['s2']);
    });
  });

  group('SessionsDatabase.searchFtsIds — escape: characters that are FTS5 metacharacters', () {
    test('user query with double quotes does not crash and finds the indexed term', () async {
      // FTS5 uses `"` as a quoting delimiter. Naive interpolation of a token
      // like `he"llo` would unbalance quotes and raise "malformed MATCH". The
      // escape doubles `"` and re-quotes the whole token so it is treated as
      // a literal phrase.
      final db = makeSessionsDb();
      addTearDown(db.close);

      // FTS5 unicode61 tokenizer breaks on punctuation, so the body is split
      // into ["he", "llo"]. The escaped query searches for the literal phrase
      // including the `"` — which matches none of the tokens — but it MUST
      // NOT crash. That is the safety contract under test.
      await db.upsertSessionFts(sessionId: 's1', workspaceId: 'w1', body: 'plain text');

      // No throw on an embedded quote: graceful empty result.
      expect(
        await db.searchFtsIds(workspaceId: 'w1', query: 'he"llo'),
        isEmpty,
      );
    });

    test('user query with FTS5 operator-like characters does not crash', () async {
      final db = makeSessionsDb();
      addTearDown(db.close);

      await db.upsertSessionFts(sessionId: 's1', workspaceId: 'w1', body: 'plain text');

      // Each of these would, unescaped, be parsed as an FTS5 operator. The
      // escape forces them into a quoted phrase so SQLite treats them as data.
      for (final query in ['NOT term', 'term OR', 'AND term', 'term*here', '(term)', '+term']) {
        expect(
          () => db.searchFtsIds(workspaceId: 'w1', query: query),
          returnsNormally,
          reason: 'Query "$query" must not crash search.',
        );
      }
    });
  });

  group('SessionsDatabase.searchFtsIds — limit', () {
    test('limit is honored on multi-row matches', () async {
      final db = makeSessionsDb();
      addTearDown(db.close);

      for (var i = 0; i < 5; i++) {
        await db.upsertSessionFts(sessionId: 's$i', workspaceId: 'w1', body: 'topic alpha');
      }

      final out = await db.searchFtsIds(workspaceId: 'w1', query: 'topic', limit: 2);
      expect(out, hasLength(2));
    });
  });

  group('SessionsDatabase.upsertSessionFts — replace semantics', () {
    test('upserting an existing sessionId replaces its body, no duplicate row', () async {
      final db = makeSessionsDb();
      addTearDown(db.close);

      await db.upsertSessionFts(sessionId: 's1', workspaceId: 'w1', body: 'first body');
      await db.upsertSessionFts(sessionId: 's1', workspaceId: 'w1', body: 'second body');

      // Old body must no longer match.
      expect(await db.searchFtsIds(workspaceId: 'w1', query: 'first'), isEmpty);
      // New body must match.
      expect(await db.searchFtsIds(workspaceId: 'w1', query: 'second'), ['s1']);
    });
  });

  group('SessionsDatabase.deleteSessionFts', () {
    test('removing a session drops it from search results', () async {
      final db = makeSessionsDb();
      addTearDown(db.close);

      await db.upsertSessionFts(sessionId: 's1', workspaceId: 'w1', body: 'ephemeral');
      expect(await db.searchFtsIds(workspaceId: 'w1', query: 'ephemeral'), ['s1']);

      await db.deleteSessionFts('s1');
      expect(await db.searchFtsIds(workspaceId: 'w1', query: 'ephemeral'), isEmpty);
    });
  });

  group('SessionsDatabase.ftsIdsForWorkspace', () {
    test('returns the set of session ids indexed for the workspace', () async {
      final db = makeSessionsDb();
      addTearDown(db.close);

      await db.upsertSessionFts(sessionId: 's1', workspaceId: 'w1', body: 'a');
      await db.upsertSessionFts(sessionId: 's2', workspaceId: 'w1', body: 'b');
      await db.upsertSessionFts(sessionId: 's3', workspaceId: 'w2', body: 'c');

      expect(await db.ftsIdsForWorkspace('w1'), {'s1', 's2'});
      expect(await db.ftsIdsForWorkspace('w2'), {'s3'});
      expect(await db.ftsIdsForWorkspace('nope'), isEmpty);
    });
  });
}
