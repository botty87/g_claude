import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_diff.freezed.dart';

enum DiffLineType { context, addition, deletion, hunkHeader }

/// One line inside a [DiffHunk], stripped of its leading `+`/`-`/` ` marker.
@freezed
abstract class DiffLine with _$DiffLine {
  const factory DiffLine({required DiffLineType type, required String content, int? oldLineNo, int? newLineNo}) =
      _DiffLine;
}

/// One `@@ -a,b +c,d @@ ...` block of a unified diff.
@freezed
abstract class DiffHunk with _$DiffHunk {
  const factory DiffHunk({required String header, required List<DiffLine> lines}) = _DiffHunk;
}

/// Parsed unified diff for a single file.
@freezed
abstract class FileDiff with _$FileDiff {
  const factory FileDiff({
    required String path,
    @Default(<DiffHunk>[]) List<DiffHunk> hunks,
    @Default(false) bool isBinary,
    @Default(0) int added,
    @Default(0) int deleted,
  }) = _FileDiff;
}
