// Contracts for `GitRepositoryImpl` — maps datasource outcomes to Either.

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/features/git/data/datasources/git_worktree_datasource.dart';
import 'package:g_claude/features/git/data/repositories/git_repository_impl.dart';
import 'package:g_claude/features/git/domain/entities/git_branch.dart';
import 'package:g_claude/features/git/domain/entities/git_folder_inspection.dart';
import 'package:g_claude/features/git/domain/entities/git_worktree.dart';
import 'package:mocktail/mocktail.dart';

class _MockDs extends Mock implements GitWorktreeDataSource {}

void main() {
  late _MockDs ds;
  late GitRepositoryImpl repo;

  setUp(() {
    ds = _MockDs();
    repo = GitRepositoryImpl(ds);
  });

  group('detect', () {
    test('Right(info) when inside a repo', () async {
      when(() => ds.detect(any())).thenAnswer((_) async => const GitRepoInfo(repoRoot: '/repo', branch: 'main'));
      final out = await repo.detect(path: '/repo/wt');
      expect(out.right?.repoRoot, '/repo');
    });

    test('Right(null) when not a repo', () async {
      when(() => ds.detect(any())).thenAnswer((_) async => null);
      final out = await repo.detect(path: '/home');
      expect(out.isRight, isTrue);
      expect(out.right, isNull);
    });

    test('any throw → Left(UnexpectedFailure)', () async {
      when(() => ds.detect(any())).thenThrow(Exception('boom'));
      final out = await repo.detect(path: '/x');
      expect(out.left, isA<UnexpectedFailure>());
    });
  });

  group('listWorktrees', () {
    test('GitException → SubprocessFailure', () async {
      when(() => ds.listWorktrees(any())).thenThrow(const GitException('list failed'));
      final out = await repo.listWorktrees(repoRoot: '/repo');
      expect(out.left, isA<SubprocessFailure>());
    });

    test('Right(list) on success', () async {
      when(
        () => ds.listWorktrees(any()),
      ).thenAnswer((_) async => const [GitWorktree(path: '/repo', head: 'abc', branch: 'main')]);
      final out = await repo.listWorktrees(repoRoot: '/repo');
      expect(out.right.single.branch, 'main');
    });
  });

  group('removeWorktree', () {
    test('Right(null) on success, forwards force flag', () async {
      when(() => ds.removeWorktree(any(), any(), force: any(named: 'force'))).thenAnswer((_) async {});
      final out = await repo.removeWorktree(repoRoot: '/repo', worktreePath: '/repo/wt', force: true);
      expect(out.isRight, isTrue);
      verify(() => ds.removeWorktree('/repo', '/repo/wt', force: true)).called(1);
    });

    test('GitException (e.g. dirty worktree) → SubprocessFailure carrying the message', () async {
      when(
        () => ds.removeWorktree(any(), any(), force: any(named: 'force')),
      ).thenThrow(const GitException('contains modified or untracked files'));
      final out = await repo.removeWorktree(repoRoot: '/repo', worktreePath: '/repo/wt');
      expect(out.left, isA<SubprocessFailure>());
      expect((out.left as SubprocessFailure).message, contains('modified or untracked'));
    });
  });

  group('deleteBranch', () {
    test('Right(null) on success, forwards force flag', () async {
      when(() => ds.deleteBranch(any(), any(), force: any(named: 'force'))).thenAnswer((_) async {});
      final out = await repo.deleteBranch(repoRoot: '/repo', branch: 'feature/x', force: true);
      expect(out.isRight, isTrue);
      verify(() => ds.deleteBranch('/repo', 'feature/x', force: true)).called(1);
    });

    test('GitException (branch not merged) → SubprocessFailure', () async {
      when(
        () => ds.deleteBranch(any(), any(), force: any(named: 'force')),
      ).thenThrow(const GitException('not fully merged'));
      final out = await repo.deleteBranch(repoRoot: '/repo', branch: 'feature/x');
      expect(out.left, isA<SubprocessFailure>());
    });
  });

  group('addWorktree', () {
    test('Right(null) on success, forwards the new-branch args', () async {
      when(
        () => ds.addWorktree(
          any(),
          any(),
          newBranch: any(named: 'newBranch'),
          baseRef: any(named: 'baseRef'),
          checkoutBranch: any(named: 'checkoutBranch'),
        ),
      ).thenAnswer((_) async {});
      final out = await repo.addWorktree(
        repoRoot: '/repo',
        worktreePath: '/repo/feat',
        newBranch: 'feature/x',
        baseRef: 'main',
      );
      expect(out.isRight, isTrue);
      verify(
        () => ds.addWorktree('/repo', '/repo/feat', newBranch: 'feature/x', baseRef: 'main', checkoutBranch: null),
      ).called(1);
    });

    test('GitException (path exists / branch taken) → SubprocessFailure carrying the message', () async {
      when(
        () => ds.addWorktree(
          any(),
          any(),
          newBranch: any(named: 'newBranch'),
          baseRef: any(named: 'baseRef'),
          checkoutBranch: any(named: 'checkoutBranch'),
        ),
      ).thenThrow(const GitException("'/repo/feat' already exists"));
      final out = await repo.addWorktree(repoRoot: '/repo', worktreePath: '/repo/feat', newBranch: 'x');
      expect(out.left, isA<SubprocessFailure>());
      expect((out.left as SubprocessFailure).message, contains('already exists'));
    });
  });

  group('inspect', () {
    test('Right(inspection) on success', () async {
      when(() => ds.inspect(any())).thenAnswer(
        (_) async => const GitFolderInspection(isGit: true, repoRoot: '/repo', branch: 'main', dirtyCount: 2),
      );
      final out = await repo.inspect(path: '/repo/wt');
      expect(out.right.isGit, isTrue);
      expect(out.right.dirtyCount, 2);
    });

    test('any throw → Left(UnexpectedFailure)', () async {
      when(() => ds.inspect(any())).thenThrow(Exception('boom'));
      final out = await repo.inspect(path: '/x');
      expect(out.left, isA<UnexpectedFailure>());
    });
  });

  group('listBranches', () {
    test('Right(list) on success', () async {
      when(
        () => ds.listBranches(any()),
      ).thenAnswer((_) async => const [GitBranch(name: 'main', worktreePath: '/repo'), GitBranch(name: 'dev')]);
      final out = await repo.listBranches(repoRoot: '/repo');
      expect(out.right.map((b) => b.name), ['main', 'dev']);
      expect(out.right.last.hasWorktree, isFalse);
    });

    test('GitException → SubprocessFailure', () async {
      when(() => ds.listBranches(any())).thenThrow(const GitException('branch list failed'));
      final out = await repo.listBranches(repoRoot: '/repo');
      expect(out.left, isA<SubprocessFailure>());
    });
  });
}
