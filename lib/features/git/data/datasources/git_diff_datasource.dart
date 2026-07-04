import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

import '../../domain/entities/file_diff.dart';
import '../../domain/entities/git_diff_file.dart';
import 'git_worktree_datasource.dart' show GitException;

/// Runs `git` subprocesses to list changed files and read per-file unified
/// diffs. Pure output parsing lives in [parsePorcelain] / [parseNumstat] /
/// [parseUnifiedDiff] (static, unit-tested); everything else is a guarded
/// `Process.run`.
@lazySingleton
class GitDiffDataSource {
  GitDiffDataSource(this._talker);
  final Talker _talker;

  static const _timeout = Duration(seconds: 5);
  static const _peekBytes = 8192;

  /// Lists changed files by merging `git status --porcelain` (status +
  /// rename info) with `git diff --numstat HEAD` (added/deleted counts).
  /// Untracked files never appear in numstat, so their line count is derived
  /// by reading the file directly.
  Future<List<GitDiffFile>> listChangedFiles(String cwd) async {
    final porcelainOut = await _runCapture(cwd, ['status', '--porcelain']);
    final numstatOut = await _runCapture(cwd, ['diff', '--numstat', 'HEAD']);
    final numstat = parseNumstat(numstatOut);
    final entries = parsePorcelain(porcelainOut);

    final result = <GitDiffFile>[];
    for (final entry in entries) {
      if (entry.status == GitFileStatus.untracked) {
        final counted = await _countUntracked(cwd, entry.path);
        result.add(entry.copyWith(added: counted.added, isBinary: counted.isBinary));
        continue;
      }
      final stat = numstat[entry.path];
      if (stat == null) {
        result.add(entry);
        continue;
      }
      result.add(entry.copyWith(added: stat.added, deleted: stat.deleted, isBinary: stat.isBinary));
    }
    return result;
  }

  /// Reads the unified diff of a single [file]. Untracked files have no HEAD
  /// blob to diff against, so they go through `git diff --no-index` against
  /// `/dev/null` (exit code 1 on differences is expected, not an error).
  Future<FileDiff> readFileDiff(String cwd, GitDiffFile file) async {
    if (file.status == GitFileStatus.untracked) {
      final stdout = await _runNoIndexAgainstDevNull(cwd, file.path);
      return parseUnifiedDiff(stdout).copyWith(path: file.path);
    }
    final stdout = await _runCapture(cwd, ['diff', 'HEAD', '--', file.path]);
    return parseUnifiedDiff(stdout).copyWith(path: file.path);
  }

  Future<({int added, bool isBinary})> _countUntracked(String cwd, String relativePath) async {
    try {
      final file = File(p.join(cwd, relativePath));
      if (!await file.exists()) return (added: 0, isBinary: false);
      final raf = await file.open();
      try {
        final peek = await raf.read(_peekBytes);
        if (peek.contains(0)) return (added: 0, isBinary: true);
      } finally {
        await raf.close();
      }
      final content = await file.readAsString();
      final lineCount = content.isEmpty ? 0 : const LineSplitter().convert(content).length;
      return (added: lineCount, isBinary: false);
    } catch (e) {
      _talker.debug('GitDiffDataSource: failed to count untracked lines for $relativePath: $e');
      return (added: 0, isBinary: false);
    }
  }

  Future<String> _runNoIndexAgainstDevNull(String cwd, String relativePath) async {
    try {
      final result = await Process.run('git', [
        '-C',
        cwd,
        'diff',
        '--no-index',
        '--',
        '/dev/null',
        relativePath,
      ]).timeout(_timeout);
      // `--no-index` exits 1 when there are differences — that is the normal
      // case for an untracked file with content, not an error. Only >1 (spawn
      // issue, bad path, etc.) is a real failure.
      if (result.exitCode > 1) {
        throw GitException(_asString(result.stderr).trim());
      }
      return _asString(result.stdout);
    } on GitException {
      rethrow;
    } on TimeoutException {
      throw GitException('git diff --no-index timed out for $relativePath');
    } catch (e) {
      throw GitException('git diff --no-index failed for $relativePath: $e');
    }
  }

  /// Runs `git -C <cwd> <args>` and returns stdout, throwing [GitException]
  /// (carrying stderr) on non-zero exit, timeout, or spawn failure.
  Future<String> _runCapture(String cwd, List<String> args) async {
    try {
      final result = await Process.run('git', ['-C', cwd, ...args]).timeout(_timeout);
      if (result.exitCode != 0) {
        throw GitException(_asString(result.stderr).trim());
      }
      return _asString(result.stdout);
    } on GitException {
      rethrow;
    } on TimeoutException {
      throw GitException('git ${args.join(' ')} timed out');
    } catch (e) {
      throw GitException('git ${args.join(' ')} failed: $e');
    }
  }

  String _asString(dynamic data) => data is String ? data : utf8.decode(data as List<int>);

  static final RegExp _renameBraceRegex = RegExp(r'^(.*)\{(.*) => (.*)\}(.*)$');
  static final RegExp _hunkHeaderRegex = RegExp(r'^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@');

  /// Parses `git status --porcelain` (short format v1): each line is
  /// `XY<space>path`, X = staged status, Y = unstaged status.
  ///
  /// - `??` -> [GitFileStatus.untracked].
  /// - X or Y == `R` -> [GitFileStatus.renamed]; the path field is
  ///   `old -> new`, split accordingly.
  /// - Otherwise: if either column is `D` -> deleted; else the first
  ///   non-space column decides (`A`/`C` -> added, anything else -> modified).
  ///
  /// Quoted paths (git wraps paths containing special characters in `"..."`
  /// with backslash-escaped quotes) get a basic unquote.
  @visibleForTesting
  static List<GitDiffFile> parsePorcelain(String stdout) {
    final out = <GitDiffFile>[];
    for (final rawLine in const LineSplitter().convert(stdout)) {
      if (rawLine.length < 4) continue;
      final x = rawLine[0];
      final y = rawLine[1];
      final rest = rawLine.substring(3);

      if (x == '?' && y == '?') {
        out.add(GitDiffFile(path: _unquote(rest), status: GitFileStatus.untracked));
        continue;
      }

      if (x == 'R' || y == 'R') {
        final parts = rest.split(' -> ');
        final oldPath = _unquote(parts.first);
        final newPath = parts.length > 1 ? _unquote(parts[1]) : oldPath;
        out.add(GitDiffFile(path: newPath, status: GitFileStatus.renamed, oldPath: oldPath));
        continue;
      }

      final GitFileStatus status;
      if (x == 'D' || y == 'D') {
        status = GitFileStatus.deleted;
      } else {
        final code = x != ' ' ? x : y;
        status = switch (code) {
          'A' => GitFileStatus.added,
          'C' => GitFileStatus.added,
          _ => GitFileStatus.modified,
        };
      }
      out.add(GitDiffFile(path: _unquote(rest), status: status));
    }
    return out;
  }

  static String _unquote(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length >= 2 && trimmed.startsWith('"') && trimmed.endsWith('"')) {
      return trimmed.substring(1, trimmed.length - 1).replaceAll(r'\"', '"').replaceAll(r'\\', r'\');
    }
    return trimmed;
  }

  /// Parses `git diff --numstat`: lines are `added\tdeleted\tpath`. Binary
  /// files report `-\t-\tpath`. A renamed path is either `old => new` or, with
  /// a shared prefix/suffix, brace-quoted: `pre/{old => new}/post`. The map is
  /// keyed by the resolved *new* path.
  @visibleForTesting
  static Map<String, ({int added, int deleted, bool isBinary})> parseNumstat(String stdout) {
    final out = <String, ({int added, int deleted, bool isBinary})>{};
    for (final line in const LineSplitter().convert(stdout)) {
      if (line.trim().isEmpty) continue;
      final firstTab = line.indexOf('\t');
      final secondTab = firstTab < 0 ? -1 : line.indexOf('\t', firstTab + 1);
      if (firstTab < 0 || secondTab < 0) continue;

      final addedRaw = line.substring(0, firstTab);
      final deletedRaw = line.substring(firstTab + 1, secondTab);
      final pathRaw = line.substring(secondTab + 1);

      final isBinary = addedRaw == '-' || deletedRaw == '-';
      final added = isBinary ? 0 : int.tryParse(addedRaw) ?? 0;
      final deleted = isBinary ? 0 : int.tryParse(deletedRaw) ?? 0;
      out[_resolveNumstatPath(pathRaw)] = (added: added, deleted: deleted, isBinary: isBinary);
    }
    return out;
  }

  static String _resolveNumstatPath(String raw) {
    final brace = _renameBraceRegex.firstMatch(raw);
    if (brace != null) {
      return '${brace.group(1)}${brace.group(3)}${brace.group(4)}';
    }
    if (raw.contains(' => ')) {
      return raw.split(' => ').last;
    }
    return raw;
  }

  /// Parses a unified diff for a single file. Skips everything before the
  /// first hunk header (`diff --git`, `index`, `---`, `+++`, mode lines,
  /// etc.). Each `@@ -a,b +c,d @@` opens a [DiffHunk] whose `header` is the
  /// full header line; `+`/`-`/` ` prefixed lines become addition/deletion/
  /// context [DiffLine]s carrying the running old/new line numbers, starting
  /// at the hunk header's `a`/`c` offsets. A "Binary files ... differ" line
  /// short-circuits to `FileDiff(isBinary: true)` with no hunks.
  ///
  /// [path] on the returned [FileDiff] is best-effort (from the `+++`/`---`
  /// header); callers that already know the path should override it via
  /// `copyWith`.
  @visibleForTesting
  static FileDiff parseUnifiedDiff(String diffText) {
    final lines = const LineSplitter().convert(diffText);
    if (lines.any((l) => l.startsWith('Binary files') && l.endsWith('differ'))) {
      return FileDiff(path: _extractPath(lines), isBinary: true);
    }

    final hunks = <DiffHunk>[];
    String? currentHeader;
    List<DiffLine>? currentLines;
    var oldNo = 0;
    var newNo = 0;
    var added = 0;
    var deleted = 0;

    void flushHunk() {
      final header = currentHeader;
      final hunkLines = currentLines;
      if (header != null && hunkLines != null) {
        hunks.add(DiffHunk(header: header, lines: hunkLines));
      }
      currentHeader = null;
      currentLines = null;
    }

    for (final line in lines) {
      final match = _hunkHeaderRegex.firstMatch(line);
      if (match != null) {
        flushHunk();
        oldNo = int.parse(match.group(1)!);
        newNo = int.parse(match.group(3)!);
        currentHeader = line;
        currentLines = <DiffLine>[];
        continue;
      }

      final hunkLines = currentLines;
      if (hunkLines == null) continue; // header lines before the first hunk
      if (line.startsWith(r'\ No newline at end of file')) continue;
      if (line.isEmpty) continue;

      final prefix = line[0];
      final content = line.substring(1);
      switch (prefix) {
        case '+':
          hunkLines.add(DiffLine(type: DiffLineType.addition, content: content, newLineNo: newNo));
          newNo++;
          added++;
        case '-':
          hunkLines.add(DiffLine(type: DiffLineType.deletion, content: content, oldLineNo: oldNo));
          oldNo++;
          deleted++;
        case ' ':
          hunkLines.add(DiffLine(type: DiffLineType.context, content: content, oldLineNo: oldNo, newLineNo: newNo));
          oldNo++;
          newNo++;
        default:
          break; // unexpected content line outside +/-/space; ignore
      }
    }
    flushHunk();

    return FileDiff(path: _extractPath(lines), hunks: hunks, added: added, deleted: deleted);
  }

  static String _extractPath(List<String> lines) {
    for (final line in lines) {
      if (line.startsWith('+++ b/')) return line.substring('+++ b/'.length);
    }
    for (final line in lines) {
      if (line.startsWith('--- a/')) return line.substring('--- a/'.length);
    }
    for (final line in lines) {
      if (line.startsWith('+++ ') && !line.endsWith('/dev/null')) return line.substring('+++ '.length);
      if (line.startsWith('--- ') && !line.endsWith('/dev/null')) return line.substring('--- '.length);
    }
    return '';
  }
}
