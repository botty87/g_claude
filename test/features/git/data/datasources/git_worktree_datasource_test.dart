// Contracts for `GitWorktreeDataSource.parseWorktreeList` — the pure parser of
// `git worktree list --porcelain`. Fixtures are real `git` output.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/git/data/datasources/git_worktree_datasource.dart';

import '../../../../helpers/fakes.dart';

String _fixture(String name) => File('test/fixtures/git/$name').readAsStringSync();

void main() {
  group('parseWorktreeList — real output', () {
    late final worktrees = GitWorktreeDataSource.parseWorktreeList(_fixture('worktree-list.txt'));

    test('parses one entry per worktree block', () {
      expect(worktrees.length, 3);
    });

    test('main worktree carries branch (refs/heads/ stripped) and head', () {
      final main = worktrees.first;
      expect(main.path, '/Users/marco.bottichio/Dev/g_claude');
      expect(main.branch, 'main');
      expect(main.head, '53ce176db1be6817873343407366947c2389855b');
      expect(main.isDetached, isFalse);
    });

    test('linked worktree keeps a slashed branch name', () {
      expect(worktrees[1].branch, 'feature/restyle');
    });

    test('detached HEAD → isDetached, branch null', () {
      final detached = worktrees[2];
      expect(detached.isDetached, isTrue);
      expect(detached.branch, isNull);
    });
  });

  group('parseWorktreeList — bare + edge cases', () {
    test('flags the bare entry and still parses the working worktree', () {
      final worktrees = GitWorktreeDataSource.parseWorktreeList(_fixture('worktree-list-bare.txt'));
      expect(worktrees.length, 2);
      expect(worktrees.first.isBare, isTrue);
      expect(worktrees.first.branch, isNull);
      expect(worktrees[1].isBare, isFalse);
      expect(worktrees[1].branch, 'main');
    });

    test('empty output → empty list', () {
      expect(GitWorktreeDataSource.parseWorktreeList(''), isEmpty);
    });

    test('removeWorktree on an already-gone path is an idempotent no-op (no git, no throw)', () async {
      // A retry after a partial failure (worktree removed, branch delete failed)
      // must not error on `git worktree remove <missing>`. The dir doesn't exist,
      // so the datasource returns before touching git.
      final ds = GitWorktreeDataSource(makeTestTalker());
      await expectLater(ds.removeWorktree('/repo', '/definitely/not/here/xyz-123'), completes);
    });

    test('trailing content without a blank line is still flushed', () {
      const out = 'worktree /x\nHEAD abc\nbranch refs/heads/dev';
      final parsed = GitWorktreeDataSource.parseWorktreeList(out);
      expect(parsed.single.branch, 'dev');
      expect(parsed.single.head, 'abc');
    });
  });
}
