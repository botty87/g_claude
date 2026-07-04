// Contracts for `GitDiffRepositoryImpl` — maps datasource outcomes to Either.

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/features/git/data/datasources/git_diff_datasource.dart';
import 'package:g_claude/features/git/data/datasources/git_worktree_datasource.dart' show GitException;
import 'package:g_claude/features/git/data/repositories/git_diff_repository_impl.dart';
import 'package:g_claude/features/git/domain/entities/file_diff.dart';
import 'package:g_claude/features/git/domain/entities/git_diff_file.dart';
import 'package:mocktail/mocktail.dart';

class _MockDs extends Mock implements GitDiffDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(const GitDiffFile(path: 'x', status: GitFileStatus.modified));
  });

  late _MockDs ds;
  late GitDiffRepositoryImpl repo;

  setUp(() {
    ds = _MockDs();
    repo = GitDiffRepositoryImpl(ds);
  });

  group('listChangedFiles', () {
    test('Right(list) on success', () async {
      when(
        () => ds.listChangedFiles(any()),
      ).thenAnswer((_) async => const [GitDiffFile(path: 'a.dart', status: GitFileStatus.modified, added: 1)]);
      final out = await repo.listChangedFiles(cwd: '/repo');
      expect(out.right.single.path, 'a.dart');
    });

    test('GitException -> SubprocessFailure carrying the message', () async {
      when(() => ds.listChangedFiles(any())).thenThrow(const GitException('status failed'));
      final out = await repo.listChangedFiles(cwd: '/repo');
      expect(out.left, isA<SubprocessFailure>());
      expect((out.left as SubprocessFailure).message, 'status failed');
    });

    test('any other throw -> Left(UnexpectedFailure)', () async {
      when(() => ds.listChangedFiles(any())).thenThrow(Exception('boom'));
      final out = await repo.listChangedFiles(cwd: '/repo');
      expect(out.left, isA<UnexpectedFailure>());
    });
  });

  group('readFileDiff', () {
    const file = GitDiffFile(path: 'a.dart', status: GitFileStatus.modified);

    test('Right(diff) on success', () async {
      when(() => ds.readFileDiff(any(), any())).thenAnswer((_) async => const FileDiff(path: 'a.dart', added: 3));
      final out = await repo.readFileDiff(cwd: '/repo', file: file);
      expect(out.right.added, 3);
      verify(() => ds.readFileDiff('/repo', file)).called(1);
    });

    test('GitException -> SubprocessFailure', () async {
      when(() => ds.readFileDiff(any(), any())).thenThrow(const GitException('diff failed'));
      final out = await repo.readFileDiff(cwd: '/repo', file: file);
      expect(out.left, isA<SubprocessFailure>());
    });

    test('any other throw -> Left(UnexpectedFailure)', () async {
      when(() => ds.readFileDiff(any(), any())).thenThrow(Exception('boom'));
      final out = await repo.readFileDiff(cwd: '/repo', file: file);
      expect(out.left, isA<UnexpectedFailure>());
    });
  });
}
