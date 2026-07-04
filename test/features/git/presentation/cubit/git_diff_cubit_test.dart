// Contracts for `GitDiffCubit`: load success/failure, viewMode persistence,
// and restore repopulating per-workspace viewMode from the key-value store.

import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/core/error/failures.dart';
import 'package:g_claude/core/persistence/key_value_store.dart';
import 'package:g_claude/core/utils/either.dart';
import 'package:g_claude/features/git/domain/entities/git_diff_file.dart';
import 'package:g_claude/features/git/domain/usecases/list_changed_files.dart';
import 'package:g_claude/features/git/domain/usecases/read_file_diff.dart';
import 'package:g_claude/features/git/presentation/cubit/git_diff_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';

class _MockListChangedFiles extends Mock implements ListChangedFiles {}

class _MockReadFileDiff extends Mock implements ReadFileDiff {}

class _MockKeyValueStore extends Mock implements KeyValueStore {}

void main() {
  late _MockListChangedFiles listChangedFiles;
  late _MockReadFileDiff readFileDiff;
  late _MockKeyValueStore store;

  const workspaceId = '/repo';

  setUp(() {
    listChangedFiles = _MockListChangedFiles();
    readFileDiff = _MockReadFileDiff();
    store = _MockKeyValueStore();
    when(() => store.readString(any())).thenAnswer((_) async => null);
    when(() => store.writeString(any(), any())).thenAnswer((_) async {});
  });

  GitDiffCubit make() => GitDiffCubit(listChangedFiles, readFileDiff, store, makeTestTalker());

  group('load', () {
    blocTest<GitDiffCubit, GitDiffState>(
      'success: sets loading true then false, populates files, clears failure',
      build: () {
        when(
          () => listChangedFiles(cwd: any(named: 'cwd')),
        ).thenAnswer((_) async => const Right([GitDiffFile(path: 'a.dart', status: GitFileStatus.modified)]));
        return make();
      },
      act: (cubit) => cubit.load(workspaceId: workspaceId, path: '/repo'),
      expect: () => [
        predicate<GitDiffState>((s) => s.diffFor(workspaceId).loading == true),
        predicate<GitDiffState>(
          (s) =>
              s.diffFor(workspaceId).loading == false &&
              s.diffFor(workspaceId).files.single.path == 'a.dart' &&
              s.diffFor(workspaceId).failure == null,
        ),
      ],
    );

    blocTest<GitDiffCubit, GitDiffState>(
      'failure: sets loading false, failure populated, files cleared',
      build: () {
        when(
          () => listChangedFiles(cwd: any(named: 'cwd')),
        ).thenAnswer((_) async => const Left(UnexpectedFailure('boom')));
        return make();
      },
      act: (cubit) => cubit.load(workspaceId: workspaceId, path: '/repo'),
      expect: () => [
        predicate<GitDiffState>((s) => s.diffFor(workspaceId).loading == true),
        predicate<GitDiffState>(
          (s) =>
              s.diffFor(workspaceId).loading == false &&
              s.diffFor(workspaceId).files.isEmpty &&
              s.diffFor(workspaceId).failure is UnexpectedFailure,
        ),
      ],
    );

    blocTest<GitDiffCubit, GitDiffState>(
      'preserves the existing viewMode while (re)loading',
      build: () {
        when(() => listChangedFiles(cwd: any(named: 'cwd'))).thenAnswer((_) async => const Right(<GitDiffFile>[]));
        return make();
      },
      seed: () => GitDiffState(perWorkspace: {workspaceId: const WorkspaceDiff(viewMode: DiffViewMode.tree)}),
      act: (cubit) => cubit.load(workspaceId: workspaceId, path: '/repo'),
      verify: (cubit) {
        expect(cubit.state.diffFor(workspaceId).viewMode, DiffViewMode.tree);
      },
    );
  });

  group('setViewMode', () {
    blocTest<GitDiffCubit, GitDiffState>(
      'updates viewMode and persists it to the key-value store',
      build: make,
      act: (cubit) => cubit.setViewMode(workspaceId, DiffViewMode.tree),
      expect: () => [predicate<GitDiffState>((s) => s.diffFor(workspaceId).viewMode == DiffViewMode.tree)],
      verify: (_) {
        final captured = verify(() => store.writeString('persistence.git_diff.v1', captureAny())).captured;
        final json = jsonDecode(captured.single as String) as Map<String, dynamic>;
        expect((json['perWorkspace'] as Map)[workspaceId], 'tree');
      },
    );

    blocTest<GitDiffCubit, GitDiffState>(
      'no-op when setting the already-active viewMode (no emission)',
      build: make,
      act: (cubit) => cubit.setViewMode(workspaceId, DiffViewMode.flat),
      expect: () => <GitDiffState>[],
    );
  });

  group('toggleDir', () {
    blocTest<GitDiffCubit, GitDiffState>(
      'collapses a directory not yet in collapsedDirs, then expands it back',
      build: make,
      act: (cubit) {
        cubit.toggleDir(workspaceId, 'src/lib');
        cubit.toggleDir(workspaceId, 'src/lib');
      },
      expect: () => [
        predicate<GitDiffState>((s) => s.diffFor(workspaceId).collapsedDirs.contains('src/lib')),
        predicate<GitDiffState>((s) => !s.diffFor(workspaceId).collapsedDirs.contains('src/lib')),
      ],
    );
  });

  group('restore', () {
    test('repopulates per-workspace viewMode from persisted JSON, files stay empty', () async {
      when(() => store.readString('persistence.git_diff.v1')).thenAnswer(
        (_) async => jsonEncode({
          'perWorkspace': {workspaceId: 'tree'},
        }),
      );
      final cubit = make();
      await cubit.restore();
      final diff = cubit.state.diffFor(workspaceId);
      expect(diff.viewMode, DiffViewMode.tree);
      expect(diff.files, isEmpty);
      expect(diff.loading, isFalse);
    });

    test('missing key -> no state change', () async {
      final cubit = make();
      await cubit.restore();
      expect(cubit.state.perWorkspace, isEmpty);
    });

    test('malformed JSON -> no throw, no state change', () async {
      when(() => store.readString('persistence.git_diff.v1')).thenAnswer((_) async => 'not json');
      final cubit = make();
      await expectLater(cubit.restore(), completes);
      expect(cubit.state.perWorkspace, isEmpty);
    });
  });
}
