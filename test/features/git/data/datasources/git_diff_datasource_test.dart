// Contracts for the pure parsers on `GitDiffDataSource` — `parsePorcelain`,
// `parseNumstat`, `parseUnifiedDiff`. Fixtures are real `git` output captured
// from a throwaway repo (see test/fixtures/git_diff/), except the single
// documented edge case (simple `old => new` numstat rename with no shared
// prefix/suffix) which the sample repo didn't happen to produce.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/git/data/datasources/git_diff_datasource.dart';
import 'package:g_claude/features/git/domain/entities/file_diff.dart';
import 'package:g_claude/features/git/domain/entities/git_diff_file.dart';

String _fixture(String name) => File('test/fixtures/git_diff/$name').readAsStringSync();

void main() {
  group('parsePorcelain — real `git status --porcelain` output', () {
    late final files = GitDiffDataSource.parsePorcelain(_fixture('porcelain-mixed.txt'));

    test('parses one entry per line', () {
      expect(files.length, 7);
    });

    test('modified file (staged, column X) maps to modified', () {
      final f = files.firstWhere((f) => f.path == 'src/lib/foo.dart');
      expect(f.status, GitFileStatus.modified);
    });

    test('deleted file maps to deleted', () {
      final f = files.firstWhere((f) => f.path == 'src/lib/gone.dart');
      expect(f.status, GitFileStatus.deleted);
    });

    test('binary-modified file (image) still maps to modified from porcelain alone', () {
      final f = files.firstWhere((f) => f.path == 'src/lib/image.png');
      expect(f.status, GitFileStatus.modified);
    });

    test('rename splits `old -> new` into path (new) and oldPath', () {
      final f = files.firstWhere((f) => f.status == GitFileStatus.renamed);
      expect(f.path, 'src/lib/new_name.dart');
      expect(f.oldPath, 'src/lib/old_name.dart');
    });

    test('untracked (`??`) maps to untracked', () {
      final untracked = files.where((f) => f.status == GitFileStatus.untracked).map((f) => f.path);
      expect(untracked, contains('src/lib/untracked.dart'));
      expect(untracked, contains('src/lib/untracked.png'));
    });

    test('a quoted path (git-escaped special characters) is unquoted', () {
      final f = files.firstWhere((f) => f.status == GitFileStatus.untracked && f.path.contains('weird'));
      expect(f.path, 'src/lib/weird "quoted" name.dart');
    });

    test('added file (`A `) maps to added', () {
      const out = 'A  src/lib/brand_new.dart';
      final parsed = GitDiffDataSource.parsePorcelain(out);
      expect(parsed.single.status, GitFileStatus.added);
    });

    test('copy (`C `) maps to added', () {
      const out = 'C  src/lib/copied.dart';
      final parsed = GitDiffDataSource.parsePorcelain(out);
      expect(parsed.single.status, GitFileStatus.added);
    });

    test('blank/malformed lines are skipped', () {
      expect(GitDiffDataSource.parsePorcelain('\n \nAB'), isEmpty);
    });
  });

  group('parseNumstat — real `git diff --numstat HEAD` output', () {
    late final stats = GitDiffDataSource.parseNumstat(_fixture('numstat-mixed.txt'));

    test('parses added/deleted counts for a modified file', () {
      expect(stats['src/lib/foo.dart'], (added: 2, deleted: 1, isBinary: false));
    });

    test('a deleted file reports 0 added', () {
      expect(stats['src/lib/gone.dart'], (added: 0, deleted: 1, isBinary: false));
    });

    test('binary file (`-\\t-`) maps to isBinary with zeroed counts', () {
      expect(stats['src/lib/image.png'], (added: 0, deleted: 0, isBinary: true));
    });

    test('brace-form rename `pre/{old => new}/post` resolves to the new path', () {
      expect(stats.containsKey('src/lib/new_name.dart'), isTrue);
      expect(stats.containsKey('src/lib/old_name.dart'), isFalse);
      expect(stats['src/lib/new_name.dart'], (added: 1, deleted: 1, isBinary: false));
    });

    test('simple `old => new` rename (no shared prefix/suffix) resolves to the new path', () {
      final simple = GitDiffDataSource.parseNumstat(_fixture('numstat-rename-arrow.txt'));
      expect(simple.containsKey('src/lib/new_full_name.dart'), isTrue);
      expect(simple['src/lib/new_full_name.dart'], (added: 3, deleted: 0, isBinary: false));
    });

    test('blank lines are skipped', () {
      expect(GitDiffDataSource.parseNumstat('\n\n'), isEmpty);
    });
  });

  group('parseUnifiedDiff — modified file', () {
    late final diff = GitDiffDataSource.parseUnifiedDiff(_fixture('diff-modified.txt'));

    test('single hunk with the raw @@ header', () {
      expect(diff.hunks, hasLength(1));
      expect(diff.hunks.single.header, '@@ -1,5 +1,6 @@');
    });

    test('context/addition/deletion lines carry the right running line numbers', () {
      final lines = diff.hunks.single.lines;
      expect(lines[0], const DiffLine(type: DiffLineType.context, content: 'line1', oldLineNo: 1, newLineNo: 1));
      expect(lines[1], const DiffLine(type: DiffLineType.deletion, content: 'line2', oldLineNo: 2));
      expect(lines[2], const DiffLine(type: DiffLineType.addition, content: 'line2 CHANGED', newLineNo: 2));
      expect(lines.last, const DiffLine(type: DiffLineType.addition, content: 'line6 NEW', newLineNo: 6));
    });

    test('totals added/deleted across the file', () {
      expect(diff.added, 2);
      expect(diff.deleted, 1);
      expect(diff.isBinary, isFalse);
    });
  });

  group('parseUnifiedDiff — deleted file', () {
    test('all-deletion hunk, no additions', () {
      final diff = GitDiffDataSource.parseUnifiedDiff(_fixture('diff-deleted.txt'));
      expect(diff.hunks.single.lines.single.type, DiffLineType.deletion);
      expect(diff.added, 0);
      expect(diff.deleted, 1);
    });
  });

  group('parseUnifiedDiff — renamed file diffed against HEAD by new path', () {
    test('git shows it as a brand-new file (all additions) since the pathspec has no history at that path', () {
      final diff = GitDiffDataSource.parseUnifiedDiff(_fixture('diff-renamed-as-added.txt'));
      expect(diff.hunks.single.lines, everyElement(predicate<DiffLine>((l) => l.type == DiffLineType.addition)));
      expect(diff.added, 3);
      expect(diff.deleted, 0);
    });
  });

  group('parseUnifiedDiff — untracked file via `git diff --no-index`', () {
    test('parses like a normal new-file diff', () {
      final diff = GitDiffDataSource.parseUnifiedDiff(_fixture('diff-untracked-text.txt'));
      expect(diff.added, 2);
      expect(diff.hunks.single.header, '@@ -0,0 +1,2 @@');
    });
  });

  group('parseUnifiedDiff — binary files', () {
    test('tracked binary diff -> isBinary, no hunks', () {
      final diff = GitDiffDataSource.parseUnifiedDiff(_fixture('diff-binary-tracked.txt'));
      expect(diff.isBinary, isTrue);
      expect(diff.hunks, isEmpty);
    });

    test('untracked binary diff (--no-index against /dev/null) -> isBinary, no hunks', () {
      final diff = GitDiffDataSource.parseUnifiedDiff(_fixture('diff-binary-untracked.txt'));
      expect(diff.isBinary, isTrue);
      expect(diff.hunks, isEmpty);
    });
  });

  group('parseUnifiedDiff — edge cases', () {
    test('empty input -> empty FileDiff, not binary', () {
      final diff = GitDiffDataSource.parseUnifiedDiff('');
      expect(diff.hunks, isEmpty);
      expect(diff.isBinary, isFalse);
      expect(diff.added, 0);
      expect(diff.deleted, 0);
    });

    test('"\\ No newline at end of file" marker line is ignored, not counted as content', () {
      const diffText =
          'diff --git a/f b/f\n'
          '--- a/f\n'
          '+++ b/f\n'
          '@@ -1 +1 @@\n'
          '-old\n'
          '\\ No newline at end of file\n'
          '+new\n'
          '\\ No newline at end of file\n';
      final diff = GitDiffDataSource.parseUnifiedDiff(diffText);
      expect(diff.hunks.single.lines, hasLength(2));
      expect(diff.added, 1);
      expect(diff.deleted, 1);
    });
  });
}
