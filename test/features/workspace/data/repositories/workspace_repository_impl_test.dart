// Contracts for `WorkspaceRepositoryImpl`.
//
// The repository normalizes a user-supplied path, asks the datasource to
// validate it as a directory, and reads CLAUDE.md if present. Any datasource
// exception is mapped to a Failure — no exception ever reaches the cubit.

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/exceptions.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/core/utils/either.dart';
import 'package:g_claude/features/git/domain/entities/git_worktree.dart';
import 'package:g_claude/features/git/domain/repositories/git_repository.dart';
import 'package:g_claude/features/workspace/data/datasources/workspace_local_datasource.dart';
import 'package:g_claude/features/workspace/data/repositories/workspace_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockDs extends Mock implements WorkspaceLocalDataSource {}

class _MockGit extends Mock implements GitRepository {}

void main() {
  late _MockDs ds;
  late _MockGit git;
  late WorkspaceRepositoryImpl repo;

  setUp(() {
    ds = _MockDs();
    git = _MockGit();
    // Default: not a git repo (plain folder).
    when(() => git.detect(path: any(named: 'path'))).thenAnswer((_) async => const Right(null));
    repo = WorkspaceRepositoryImpl(ds, git);
  });

  group('openWorkspace — happy path', () {
    test('returns a Workspace whose path/id are normalized (absolute) and name is the basename', () async {
      when(() => ds.ensureDirectoryExists(any())).thenAnswer((_) async {});
      when(() => ds.readClaudeMd(any())).thenAnswer((_) async => '# proj');

      final out = await repo.openWorkspace(path: '/Users/me/proj');

      expect(out.isRight, isTrue);
      expect(out.right.path, '/Users/me/proj');
      expect(out.right.id, '/Users/me/proj');
      expect(out.right.name, 'proj');
      expect(out.right.claudeMd, '# proj');
    });

    test('claudeMd is null when readClaudeMd returns null', () async {
      when(() => ds.ensureDirectoryExists(any())).thenAnswer((_) async {});
      when(() => ds.readClaudeMd(any())).thenAnswer((_) async => null);

      final out = await repo.openWorkspace(path: '/x/y');
      expect(out.right.claudeMd, isNull);
    });

    test('git detection annotates repoRoot/branch without touching id/path', () async {
      when(() => ds.ensureDirectoryExists(any())).thenAnswer((_) async {});
      when(() => ds.readClaudeMd(any())).thenAnswer((_) async => null);
      when(
        () => git.detect(path: any(named: 'path')),
      ).thenAnswer((_) async => const Right(GitRepoInfo(repoRoot: '/repo', branch: 'feature/x')));

      final out = await repo.openWorkspace(path: '/repo/wt');
      expect(out.right.id, '/repo/wt');
      expect(out.right.path, '/repo/wt');
      expect(out.right.repoRoot, '/repo');
      expect(out.right.branch, 'feature/x');
    });

    test('plain folder leaves repoRoot/branch null', () async {
      when(() => ds.ensureDirectoryExists(any())).thenAnswer((_) async {});
      when(() => ds.readClaudeMd(any())).thenAnswer((_) async => null);

      final out = await repo.openWorkspace(path: '/home/me');
      expect(out.right.repoRoot, isNull);
      expect(out.right.branch, isNull);
    });

    test('git detection failure degrades to a plain folder (never blocks open)', () async {
      when(() => ds.ensureDirectoryExists(any())).thenAnswer((_) async {});
      when(() => ds.readClaudeMd(any())).thenAnswer((_) async => null);
      when(
        () => git.detect(path: any(named: 'path')),
      ).thenAnswer((_) async => const Left(UnexpectedFailure('git broken')));

      final out = await repo.openWorkspace(path: '/x/y');
      expect(out.isRight, isTrue);
      expect(out.right.repoRoot, isNull);
    });
  });

  group('openWorkspace — exception → Failure mapping', () {
    test('WorkspaceNotFoundException → NotFoundFailure with path in message', () async {
      when(() => ds.ensureDirectoryExists(any())).thenThrow(const WorkspaceNotFoundException('/missing'));

      final out = await repo.openWorkspace(path: '/missing');
      expect(out.isLeft, isTrue);
      final failure = out.left;
      expect(failure, isA<NotFoundFailure>());
      expect((failure as NotFoundFailure).message, contains('/missing'));
    });

    test('WorkspaceNotADirectoryException → ValidationFailure', () async {
      when(() => ds.ensureDirectoryExists(any())).thenThrow(const WorkspaceNotADirectoryException('/not-a-dir'));

      final out = await repo.openWorkspace(path: '/not-a-dir');
      expect(out.left, isA<ValidationFailure>());
    });

    test('Generic exception from datasource → UnexpectedFailure', () async {
      when(() => ds.ensureDirectoryExists(any())).thenThrow(Exception('disk full'));

      final out = await repo.openWorkspace(path: '/x/y');
      expect(out.left, isA<UnexpectedFailure>());
    });

    test('exception thrown by readClaudeMd (after directory check) → UnexpectedFailure', () async {
      when(() => ds.ensureDirectoryExists(any())).thenAnswer((_) async {});
      when(() => ds.readClaudeMd(any())).thenThrow(Exception('IO'));

      final out = await repo.openWorkspace(path: '/x/y');
      expect(out.left, isA<UnexpectedFailure>());
    });
  });

  group('loadClaudeMd', () {
    test('returns Right with content when readClaudeMd succeeds', () async {
      when(() => ds.readClaudeMd(any())).thenAnswer((_) async => '# md');
      final out = await repo.loadClaudeMd(path: '/x/y');
      expect(out.right, '# md');
    });

    test('returns Right(null) when there is no CLAUDE.md', () async {
      when(() => ds.readClaudeMd(any())).thenAnswer((_) async => null);
      final out = await repo.loadClaudeMd(path: '/x/y');
      expect(out.right, isNull);
    });

    test('any exception from readClaudeMd → Left(UnexpectedFailure)', () async {
      when(() => ds.readClaudeMd(any())).thenThrow(Exception('boom'));
      final out = await repo.loadClaudeMd(path: '/x/y');
      expect(out.left, isA<UnexpectedFailure>());
    });
  });
}
