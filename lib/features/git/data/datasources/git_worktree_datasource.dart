import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

import '../../domain/entities/git_worktree.dart';

/// Runs `git` subprocesses to detect repositories and enumerate their
/// worktrees. Kept deliberately thin: pure output parsing is [parseWorktreeList]
/// (static, unit-tested); everything else is a guarded `Process.run`.
@lazySingleton
class GitWorktreeDataSource {
  GitWorktreeDataSource(this._talker);
  final Talker _talker;

  static const _timeout = Duration(seconds: 3);

  String _normalize(String path) => p.normalize(p.absolute(path));

  /// Detects whether [path] is inside a git repo. Returns null when it is not
  /// (or when git is unavailable / times out — a broken git must never block
  /// opening a plain folder).
  Future<GitRepoInfo?> detect(String path) async {
    final commonDir = await _run(path, ['rev-parse', '--path-format=absolute', '--git-common-dir']);
    if (commonDir == null) return null;
    final trimmed = commonDir.trim();
    if (trimmed.isEmpty) return null;
    // `--git-common-dir` points at the shared `.git`; its parent is the main
    // worktree root, which is stable across every linked worktree.
    final repoRoot = _normalize(p.dirname(trimmed));

    final head = await _run(path, ['rev-parse', '--abbrev-ref', 'HEAD']);
    final branchName = head?.trim();
    final branch = (branchName == null || branchName.isEmpty || branchName == 'HEAD') ? null : branchName;

    return GitRepoInfo(repoRoot: repoRoot, branch: branch);
  }

  /// Lists all worktrees of the repo rooted at [repoRoot].
  Future<List<GitWorktree>> listWorktrees(String repoRoot) async {
    final out = await _run(repoRoot, ['worktree', 'list', '--porcelain']);
    if (out == null) {
      throw const GitException('git worktree list failed');
    }
    final worktrees = parseWorktreeList(out);
    _talker.verbose('git worktree list parsed: ${worktrees.length} worktree(s) for $repoRoot');
    return worktrees;
  }

  /// Runs `git -C <cwd> <args>` and returns stdout, or null on non-zero exit,
  /// spawn failure, or timeout.
  Future<String?> _run(String cwd, List<String> args) async {
    try {
      final result = await Process.run('git', ['-C', cwd, ...args]).timeout(_timeout);
      if (result.exitCode != 0) return null;
      return result.stdout is String ? result.stdout as String : utf8.decode(result.stdout as List<int>);
    } on TimeoutException {
      _talker.warning('git ${args.join(' ')} timed out in $cwd');
      return null;
    } catch (e) {
      _talker.debug('git ${args.join(' ')} failed in $cwd: $e');
      return null;
    }
  }

  /// Parses `git worktree list --porcelain` output. Blocks are separated by
  /// blank lines; each block starts with `worktree <path>` followed by
  /// attribute lines (`HEAD <sha>`, `branch refs/heads/<name>`, `detached`,
  /// `bare`).
  @visibleForTesting
  static List<GitWorktree> parseWorktreeList(String stdout) {
    final out = <GitWorktree>[];
    String? path;
    String head = '';
    String? branch;
    var isBare = false;
    var isDetached = false;

    void flush() {
      if (path != null) {
        out.add(
          GitWorktree(
            path: p.normalize(p.absolute(path!)),
            head: head,
            branch: branch,
            isBare: isBare,
            isDetached: isDetached,
          ),
        );
      }
      path = null;
      head = '';
      branch = null;
      isBare = false;
      isDetached = false;
    }

    for (final line in const LineSplitter().convert(stdout)) {
      if (line.trim().isEmpty) {
        flush();
        continue;
      }
      if (line.startsWith('worktree ')) {
        flush();
        path = line.substring('worktree '.length).trim();
      } else if (line.startsWith('HEAD ')) {
        head = line.substring('HEAD '.length).trim();
      } else if (line.startsWith('branch ')) {
        final ref = line.substring('branch '.length).trim();
        const prefix = 'refs/heads/';
        branch = ref.startsWith(prefix) ? ref.substring(prefix.length) : ref;
      } else if (line.trim() == 'detached') {
        isDetached = true;
      } else if (line.trim() == 'bare') {
        isBare = true;
      }
    }
    flush();
    return out;
  }
}

class GitException implements Exception {
  const GitException(this.message);
  final String message;

  @override
  String toString() => 'GitException: $message';
}
