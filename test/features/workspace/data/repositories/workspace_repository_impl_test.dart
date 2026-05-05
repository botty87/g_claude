// Contracts for `WorkspaceRepositoryImpl`.
//
// The repository normalizes a user-supplied path, asks the datasource to
// validate it as a directory, and reads CLAUDE.md if present. Any datasource
// exception is mapped to a Failure — no exception ever reaches the cubit.

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/exceptions.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/features/workspace/data/datasources/workspace_local_datasource.dart';
import 'package:g_claude/features/workspace/data/repositories/workspace_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockDs extends Mock implements WorkspaceLocalDataSource {}

void main() {
  late _MockDs ds;
  late WorkspaceRepositoryImpl repo;

  setUp(() {
    ds = _MockDs();
    repo = WorkspaceRepositoryImpl(ds);
  });

  group('openWorkspace — happy path', () {
    test('returns a Workspace whose path/id are normalized (absolute) and name is the basename',
        () async {
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
  });

  group('openWorkspace — exception → Failure mapping', () {
    test('WorkspaceNotFoundException → NotFoundFailure with path in message',
        () async {
      when(() => ds.ensureDirectoryExists(any())).thenThrow(
        const WorkspaceNotFoundException('/missing'),
      );

      final out = await repo.openWorkspace(path: '/missing');
      expect(out.isLeft, isTrue);
      final failure = out.left;
      expect(failure, isA<NotFoundFailure>());
      expect((failure as NotFoundFailure).message, contains('/missing'));
    });

    test('WorkspaceNotADirectoryException → ValidationFailure', () async {
      when(() => ds.ensureDirectoryExists(any())).thenThrow(
        const WorkspaceNotADirectoryException('/not-a-dir'),
      );

      final out = await repo.openWorkspace(path: '/not-a-dir');
      expect(out.left, isA<ValidationFailure>());
    });

    test('Generic exception from datasource → UnexpectedFailure', () async {
      when(() => ds.ensureDirectoryExists(any()))
          .thenThrow(Exception('disk full'));

      final out = await repo.openWorkspace(path: '/x/y');
      expect(out.left, isA<UnexpectedFailure>());
    });

    test('exception thrown by readClaudeMd (after directory check) → UnexpectedFailure',
        () async {
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
