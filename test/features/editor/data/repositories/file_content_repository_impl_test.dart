// Contracts for `FileContentRepositoryImpl`.
//
// The repository sits between the editor (which reads files frequently:
// open, refresh, prewarm) and the filesystem datasource. It provides:
//   - LRU cache (30 entries / 10MB) keyed by path
//   - mtime-based invalidation (every cache hit re-checks mtime)
//   - in-flight coalescing so concurrent reads of the same path → 1 disk hit
//   - exception → Failure mapping at the boundary
//
// The cache and coalesce logic are silent: a regression goes unnoticed in
// production until either edits-on-disk are not picked up (mtime bug) or the
// app spins up multiple parallel reads of the same file (coalesce bug).

import 'dart:io' show OSError, PathNotFoundException;

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/exceptions.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/features/editor/data/datasources/file_content_datasource.dart';
import 'package:g_claude/features/editor/data/repositories/file_content_repository_impl.dart';
import 'package:g_claude/features/editor/domain/entities/file_content.dart';
import 'package:mocktail/mocktail.dart';

class _MockDs extends Mock implements FileContentDataSource {}

ReadFileResult _result(String path, String content, DateTime mtime,
    {int? bytes}) {
  return (
    content: FileContent(
      path: path,
      content: content,
      sizeBytes: bytes ?? content.length,
    ),
    modified: mtime,
  );
}

void main() {
  late _MockDs ds;
  late FileContentRepositoryImpl repo;

  setUp(() {
    ds = _MockDs();
    repo = FileContentRepositoryImpl(ds);
  });

  group('readFile — cache miss flow', () {
    test('first read calls the datasource exactly once and returns the content',
        () async {
      when(() => ds.readFile(path: '/p/a.dart')).thenAnswer((_) async =>
          _result('/p/a.dart', 'foo', DateTime.utc(2026, 1, 1)));

      final out = await repo.readFile(path: '/p/a.dart');

      expect(out.isRight, isTrue);
      expect(out.right.content, 'foo');
      verify(() => ds.readFile(path: '/p/a.dart')).called(1);
    });

    test('a second read of the same path is served from cache (no datasource read)',
        () async {
      when(() => ds.readFile(path: '/p/a.dart')).thenAnswer((_) async =>
          _result('/p/a.dart', 'foo', DateTime.utc(2026, 1, 1)));
      // After the first hit lands, the cache validates via mtimeOf instead of
      // re-reading. Configure mtimeOf to return the same mtime → cache hit.
      when(() => ds.mtimeOf(path: '/p/a.dart'))
          .thenAnswer((_) async => DateTime.utc(2026, 1, 1));

      await repo.readFile(path: '/p/a.dart');
      final second = await repo.readFile(path: '/p/a.dart');

      expect(second.right.content, 'foo');
      // datasource.readFile was called once. mtimeOf was called for the second
      // read (cache validation) but readFile must NOT have been called twice.
      verify(() => ds.readFile(path: '/p/a.dart')).called(1);
      verify(() => ds.mtimeOf(path: '/p/a.dart')).called(1);
    });
  });

  group('readFile — mtime invalidation', () {
    test('a cached entry whose mtime changed is invalidated and re-read', () async {
      when(() => ds.readFile(path: '/p/a.dart')).thenAnswer((invocation) async {
        return _result('/p/a.dart', 'first', DateTime.utc(2026, 1, 1));
      });
      await repo.readFile(path: '/p/a.dart');

      // Now switch the datasource so mtimeOf reports a NEW mtime, and a new
      // readFile returns updated content.
      when(() => ds.mtimeOf(path: '/p/a.dart'))
          .thenAnswer((_) async => DateTime.utc(2026, 1, 2));
      when(() => ds.readFile(path: '/p/a.dart')).thenAnswer((_) async =>
          _result('/p/a.dart', 'second', DateTime.utc(2026, 1, 2)));

      final out = await repo.readFile(path: '/p/a.dart');

      expect(out.right.content, 'second');
      verify(() => ds.readFile(path: '/p/a.dart')).called(2);
    });

    test('mtimeOf returning null evicts the cache and surfaces NotFoundFailure',
        () async {
      when(() => ds.readFile(path: '/p/a.dart')).thenAnswer((_) async =>
          _result('/p/a.dart', 'foo', DateTime.utc(2026, 1, 1)));
      await repo.readFile(path: '/p/a.dart');

      when(() => ds.mtimeOf(path: '/p/a.dart')).thenAnswer((_) async => null);

      final out = await repo.readFile(path: '/p/a.dart');
      expect(out.isLeft, isTrue);
      expect(out.left, isA<NotFoundFailure>());
    });
  });

  group('readFile — exception → Failure mapping', () {
    test('PathNotFoundException → NotFoundFailure', () async {
      // dart:io's PathNotFoundException requires (path, OSError, [message]).
      // Construct one with a canned OSError to drive the catch arm in
      // _readUncached.
      when(() => ds.readFile(path: any(named: 'path'))).thenThrow(
        const PathNotFoundException('/p/missing', OSError('ENOENT', 2)),
      );

      final out = await repo.readFile(path: '/p/missing');
      expect(out.left, isA<NotFoundFailure>());
    });

    test('FileTooLargeException → ValidationFailure with size in message',
        () async {
      when(() => ds.readFile(path: any(named: 'path')))
          .thenThrow(FileTooLargeException(99999));

      final out = await repo.readFile(path: '/p/big');
      final failure = out.left;
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).message, contains('99999'));
    });

    test('BinaryFileException → ValidationFailure', () async {
      when(() => ds.readFile(path: any(named: 'path')))
          .thenThrow(const BinaryFileException());

      final out = await repo.readFile(path: '/p/binary');
      expect(out.left, isA<ValidationFailure>());
    });

    test('Generic exception → UnexpectedFailure (no exception bubbles past)',
        () async {
      when(() => ds.readFile(path: any(named: 'path')))
          .thenThrow(Exception('something else'));

      final out = await repo.readFile(path: '/p/x');
      expect(out.left, isA<UnexpectedFailure>(),
          reason: 'No exception must reach the presentation layer.');
    });
  });

  group('readFile — in-flight coalesce', () {
    test('two concurrent reads of the same path produce one datasource call',
        () async {
      var calls = 0;
      // Slow datasource so we can fire the second call while the first is
      // still pending.
      when(() => ds.readFile(path: '/p/a.dart')).thenAnswer((_) async {
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 30));
        return _result('/p/a.dart', 'foo', DateTime.utc(2026, 1, 1));
      });

      final f1 = repo.readFile(path: '/p/a.dart');
      final f2 = repo.readFile(path: '/p/a.dart');
      await Future.wait([f1, f2]);

      expect(calls, 1, reason: 'Coalesce must avoid duplicate disk reads.');
    });
  });

  group('readFile — LRU eviction by entry count', () {
    test('beyond 30 distinct entries, the LRU is evicted (first read no longer cached)',
        () async {
      // Stage 31 distinct paths. After the 31st insert, the first one must
      // have been evicted: a second read of it goes back to the datasource.
      for (var i = 0; i < 31; i++) {
        final path = '/p/$i.dart';
        when(() => ds.readFile(path: path)).thenAnswer((_) async =>
            _result(path, 'x', DateTime.utc(2026, 1, 1)));
      }
      for (var i = 0; i < 31; i++) {
        await repo.readFile(path: '/p/$i.dart');
      }
      // Now read /p/0 again. It should NOT be in cache anymore — second
      // datasource hit expected.
      when(() => ds.mtimeOf(path: '/p/0.dart'))
          .thenAnswer((_) async => DateTime.utc(2026, 1, 1));
      await repo.readFile(path: '/p/0.dart');

      verify(() => ds.readFile(path: '/p/0.dart')).called(2);
    });
  });

  group('readFile — LRU eviction by total bytes (10MB cap)', () {
    test('a cumulative size > 10MB evicts the oldest entry', () async {
      // Eviction is driven by sizeBytes (the FileContent field), not by
      // content.length — passing `bytes` is sufficient and avoids holding
      // 12MB of strings live during the test run.
      const sixMb = 6 * 1024 * 1024;
      when(() => ds.readFile(path: '/p/big1.bin')).thenAnswer((_) async =>
          _result('/p/big1.bin', 'x', DateTime.utc(2026, 1, 1), bytes: sixMb));
      when(() => ds.readFile(path: '/p/big2.bin')).thenAnswer((_) async =>
          _result('/p/big2.bin', 'x', DateTime.utc(2026, 1, 1), bytes: sixMb));

      await repo.readFile(path: '/p/big1.bin');
      await repo.readFile(path: '/p/big2.bin');

      // Now /p/big1.bin must have been evicted: a re-read goes to datasource.
      when(() => ds.mtimeOf(path: '/p/big1.bin'))
          .thenAnswer((_) async => DateTime.utc(2026, 1, 1));
      await repo.readFile(path: '/p/big1.bin');
      verify(() => ds.readFile(path: '/p/big1.bin')).called(2);
    });
  });
}
