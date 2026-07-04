import 'package:freezed_annotation/freezed_annotation.dart';

part 'git_diff_file.freezed.dart';

enum GitFileStatus { modified, added, deleted, renamed, untracked }

/// A single changed file as reported by `git status --porcelain` merged with
/// `git diff --numstat HEAD` line counts.
///
/// [path] is repo-relative; for a [GitFileStatus.renamed] entry it is the
/// *new* path and [oldPath] carries the previous one.
@freezed
abstract class GitDiffFile with _$GitDiffFile {
  const factory GitDiffFile({
    required String path,
    required GitFileStatus status,
    @Default(0) int added,
    @Default(0) int deleted,
    @Default(false) bool isBinary,
    String? oldPath,
  }) = _GitDiffFile;
}
