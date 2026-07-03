// Contracts for `GitRepositoryImpl` — maps datasource outcomes to Either.

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/features/git/data/datasources/git_worktree_datasource.dart';
import 'package:g_claude/features/git/data/repositories/git_repository_impl.dart';
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
}
