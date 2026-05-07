import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/claude/presentation/widgets/clickable_code_resolver.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;
  late String cwd;
  late String absFile;
  late String nestedFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('clickable_code_');
    cwd = tempDir.path;
    final lib = Directory(p.join(cwd, 'lib'))..createSync();
    absFile = p.join(lib.path, 'main.dart');
    File(absFile).writeAsStringSync('// main');
    nestedFile = p.join(lib.path, 'feature', 'foo_cubit.dart');
    Directory(p.dirname(nestedFile)).createSync(recursive: true);
    File(nestedFile).writeAsStringSync('// foo');
  });

  tearDown(() async {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('resolveCodePath', () {
    test('absolute existing path resolves', () {
      final got = resolveCodePath(content: absFile, cwd: cwd, basenameIndex: const {});
      expect(got, p.normalize(absFile));
    });

    test('absolute missing path returns null', () {
      final got = resolveCodePath(content: '/no/such/file.dart', cwd: cwd, basenameIndex: const {});
      expect(got, isNull);
    });

    test('relative to cwd resolves', () {
      final got = resolveCodePath(content: 'lib/main.dart', cwd: cwd, basenameIndex: const {});
      expect(got, p.normalize(absFile));
    });

    test('basename hits index when no slash in content', () {
      final got = resolveCodePath(
        content: 'foo_cubit.dart',
        cwd: cwd,
        basenameIndex: {
          'foo_cubit.dart': [nestedFile],
        },
      );
      expect(got, nestedFile);
    });

    test('basename ignored when content has slash', () {
      final got = resolveCodePath(
        content: 'wrong/foo_cubit.dart',
        cwd: cwd,
        basenameIndex: {
          'foo_cubit.dart': [nestedFile],
        },
      );
      expect(got, isNull);
    });

    test('reserved literals return null', () {
      for (final s in ['null', 'true', 'false', 'undefined']) {
        expect(
          resolveCodePath(content: s, cwd: cwd, basenameIndex: const {}),
          isNull,
          reason: s,
        );
      }
    });

    test('cli flags return null', () {
      expect(resolveCodePath(content: '--no-verify', cwd: cwd, basenameIndex: const {}), isNull);
    });

    test('numbers return null', () {
      for (final s in ['42', '3.14', '-7']) {
        expect(
          resolveCodePath(content: s, cwd: cwd, basenameIndex: const {}),
          isNull,
          reason: s,
        );
      }
    });

    test('plain identifier without dot or slash returns null', () {
      expect(resolveCodePath(content: 'useState', cwd: cwd, basenameIndex: const {}), isNull);
    });

    test('content with whitespace returns null', () {
      expect(resolveCodePath(content: 'lib/ main.dart', cwd: cwd, basenameIndex: const {}), isNull);
    });

    test('too short returns null', () {
      expect(resolveCodePath(content: 'a', cwd: cwd, basenameIndex: const {}), isNull);
    });

    test('directory path is not resolved as file', () {
      final got = resolveCodePath(content: 'lib', cwd: cwd, basenameIndex: const {});
      expect(got, isNull);
    });
  });
}
