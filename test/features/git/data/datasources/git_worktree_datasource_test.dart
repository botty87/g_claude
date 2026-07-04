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

  group('parseBranchList — for-each-ref refs/heads + refs/remotes', () {
    // Real `git for-each-ref --format='%(refname)\t%(refname:short)\t%(worktreepath)\t%(symref)'`:
    // local branches (one checked out), a remote-tracking branch, and the
    // `origin/HEAD` symbolic alias git always emits under refs/remotes.
    const out =
        'refs/heads/main\tmain\t/Users/me/repo\t\n'
        'refs/heads/feature/x\tfeature/x\t\t\n'
        'refs/remotes/origin/main\torigin/main\t\t\n'
        'refs/remotes/origin/HEAD\torigin\t\trefs/remotes/origin/main';

    test('local branch with a worktree path is local + hasWorktree', () {
      final b = GitWorktreeDataSource.parseBranchList(out).firstWhere((b) => b.name == 'main');
      expect(b.isRemote, isFalse);
      expect(b.hasWorktree, isTrue);
    });

    test('local branch without a worktree path is not hasWorktree', () {
      final b = GitWorktreeDataSource.parseBranchList(out).firstWhere((b) => b.name == 'feature/x');
      expect(b.isRemote, isFalse);
      expect(b.hasWorktree, isFalse);
    });

    test('remote-tracking branch is flagged isRemote and never hasWorktree', () {
      final b = GitWorktreeDataSource.parseBranchList(out).firstWhere((b) => b.name == 'origin/main');
      expect(b.isRemote, isTrue);
      expect(b.hasWorktree, isFalse);
    });

    test('the origin/HEAD symbolic ref (symref set) is skipped', () {
      final names = GitWorktreeDataSource.parseBranchList(out).map((b) => b.name);
      expect(names, ['main', 'feature/x', 'origin/main']);
      expect(names, isNot(contains('origin')));
    });

    test('blank lines are skipped', () {
      expect(GitWorktreeDataSource.parseBranchList('\n\n'), isEmpty);
    });
  });

  group('resolveRepoInfo — repoRoot/branch from real rev-parse output', () {
    // Values captured from real `git rev-parse` across four repo layouts (normal,
    // classic bare `git init --bare foo.git`, and the `<repo>/.bare` container
    // convention, each probed at its root and at a linked worktree).

    test('normal repo: repoRoot = parent of .git, branch read', () {
      final info = GitWorktreeDataSource.resolveRepoInfo(
        commonDir: '/x/normal/.git',
        insideWorkTree: true,
        head: 'main',
      );
      expect(info!.repoRoot, '/x/normal');
      expect(info.branch, 'main');
    });

    test('classic bare dir: repoRoot IS the bare dir (not its parent), branch null', () {
      // The regression M2 fixed: dirname would give /x → wrong grouping key.
      final info = GitWorktreeDataSource.resolveRepoInfo(
        commonDir: '/x/classic.git',
        insideWorkTree: false,
        head: 'main', // ignored: not inside a work tree
      );
      expect(info!.repoRoot, '/x/classic.git');
      expect(info.branch, isNull, reason: 'bare dir is checked out nowhere → no phantom branch');
    });

    test('classic bare worktree: same repoRoot as the bare dir, branch read', () {
      final info = GitWorktreeDataSource.resolveRepoInfo(
        commonDir: '/x/classic.git',
        insideWorkTree: true,
        head: 'wtbranch',
      );
      expect(info!.repoRoot, '/x/classic.git', reason: 'must match the bare dir so worktrees group together');
      expect(info.branch, 'wtbranch');
    });

    test('.bare container: repoRoot = container (parent of .bare), branch null at root', () {
      final info = GitWorktreeDataSource.resolveRepoInfo(
        commonDir: '/x/container/.bare',
        insideWorkTree: false,
        head: 'main',
      );
      expect(info!.repoRoot, '/x/container');
      expect(info.branch, isNull);
    });

    test('.bare container worktree: same repoRoot, branch read', () {
      final info = GitWorktreeDataSource.resolveRepoInfo(
        commonDir: '/x/container/.bare',
        insideWorkTree: true,
        head: 'main',
      );
      expect(info!.repoRoot, '/x/container');
      expect(info.branch, 'main');
    });

    test('detached HEAD in a work tree → branch null', () {
      final info = GitWorktreeDataSource.resolveRepoInfo(
        commonDir: '/x/normal/.git',
        insideWorkTree: true,
        head: 'HEAD',
      );
      expect(info!.branch, isNull);
    });

    test('empty common dir (not a git repo) → null', () {
      expect(GitWorktreeDataSource.resolveRepoInfo(commonDir: '', insideWorkTree: false, head: null), isNull);
      expect(GitWorktreeDataSource.resolveRepoInfo(commonDir: null, insideWorkTree: false, head: null), isNull);
    });
  });
}
