import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

import '../../domain/entities/git_branch.dart';
import '../../domain/entities/git_folder_inspection.dart';
import '../../domain/entities/git_worktree.dart';

/// Runs `git` subprocesses to detect repositories and enumerate their
/// worktrees. Kept deliberately thin: pure output parsing is [parseWorktreeList]
/// (static, unit-tested); everything else is a guarded `Process.run`.
@lazySingleton
class GitWorktreeDataSource {
  GitWorktreeDataSource(this._talker);
  final Talker _talker;

  static const _timeout = Duration(seconds: 3);
  // `git worktree add` checks out the entire tree — on a large repo this takes
  // well over the default 3s, so it gets its own generous budget. NOTE: a
  // timeout only abandons the await, it does not kill the git process, so on the
  // (rare) blow-past-120s case git may still finish and leave a worktree the UI
  // reported as failed. Accepted: at 120s this only trips on a pathological
  // hang; the user can prune/remove it manually.
  static const _addTimeout = Duration(seconds: 120);

  String _normalize(String path) => p.normalize(p.absolute(path));

  /// Detects whether [path] is inside a git repo. Returns null when it is not
  /// (or when git is unavailable / times out — a broken git must never block
  /// opening a plain folder).
  Future<GitRepoInfo?> detect(String path) async {
    final commonDir = await _run(path, ['rev-parse', '--path-format=absolute', '--git-common-dir']);
    if (commonDir == null) return null;
    final trimmed = commonDir.trim();
    if (trimmed.isEmpty) return null;
    // `--git-common-dir` points at the shared `.git` (or `.bare`); its parent is
    // the main worktree root / repo container, stable across every worktree —
    // this is the grouping key.
    final repoRoot = _normalize(p.dirname(trimmed));

    // A bare repo container (e.g. `<repo>/.bare` with all branches as linked
    // worktrees) is NOT itself a working tree: `--is-inside-work-tree` is false
    // and HEAD merely points at the default branch, which is checked out
    // nowhere. Reporting that branch would paint a phantom "main" worktree, so
    // leave branch null — the row/chip then render it as the repo root, not a
    // branch. Only read the branch when inside a real work tree.
    final insideWorkTree = (await _run(path, ['rev-parse', '--is-inside-work-tree']))?.trim() == 'true';
    String? branch;
    if (insideWorkTree) {
      final head = await _run(path, ['rev-parse', '--abbrev-ref', 'HEAD']);
      final branchName = head?.trim();
      branch = (branchName == null || branchName.isEmpty || branchName == 'HEAD') ? null : branchName;
    }

    return GitRepoInfo(repoRoot: repoRoot, branch: branch);
  }

  /// Inspects [path] before opening it: is it git? a linked worktree or the
  /// main checkout? which branch, how many uncommitted changes? A non-git path
  /// (or broken git) yields `isGit: false` so the caller opens it as a plain
  /// workspace.
  Future<GitFolderInspection> inspect(String path) async {
    final info = await detect(path);
    if (info == null) return const GitFolderInspection();
    // A linked worktree's `--git-dir` (its private dir under `worktrees/<name>`)
    // differs from the shared `--git-common-dir`; the main checkout's are equal.
    // Comparing the two is precise (a mere `/worktrees/` substring match would
    // false-positive on repos whose path happens to contain that segment).
    final gitDir = (await _run(path, ['rev-parse', '--path-format=absolute', '--git-dir']))?.trim();
    final commonDir = (await _run(path, ['rev-parse', '--path-format=absolute', '--git-common-dir']))?.trim();
    final isWorktree =
        gitDir != null && commonDir != null && gitDir.isNotEmpty && p.normalize(gitDir) != p.normalize(commonDir);
    final status = await _run(path, ['status', '--porcelain']) ?? '';
    final dirty = const LineSplitter().convert(status).where((l) => l.trim().isNotEmpty).length;
    return GitFolderInspection(
      isGit: true,
      repoRoot: info.repoRoot,
      branch: info.branch,
      isWorktree: isWorktree,
      dirtyCount: dirty,
    );
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

  Future<void> removeWorktree(String repoRoot, String worktreePath, {bool force = false}) async {
    // Idempotent: if the worktree dir is already gone (e.g. a retry after a
    // partial failure where the removal succeeded but branch deletion didn't),
    // treat it as done instead of erroring on `git worktree remove <missing>`.
    // Keeping this I/O in the datasource keeps the cubit free of filesystem
    // access (Clean Arch) and mockable.
    if (!await Directory(worktreePath).exists()) return;
    await _runOrThrow(repoRoot, ['worktree', 'remove', if (force) '--force', worktreePath]);
  }

  Future<void> deleteBranch(String repoRoot, String branch, {bool force = false}) async {
    await _runOrThrow(repoRoot, ['branch', force ? '-D' : '-d', branch]);
  }

  /// Creates a new worktree at [worktreePath]. Either creates a new branch
  /// ([newBranch] set, optionally starting at [baseRef]) or checks out an
  /// existing branch ([checkoutBranch]). Throws [GitException] carrying git's
  /// stderr on any failure (dir already exists, branch already exists, branch
  /// already checked out elsewhere) — callers surface it to the user rather
  /// than pre-validating.
  Future<void> addWorktree(
    String repoRoot,
    String worktreePath, {
    String? newBranch,
    String? baseRef,
    String? checkoutBranch,
  }) async {
    final args = <String>['worktree', 'add'];
    if (newBranch != null) {
      args.addAll(['-b', newBranch, worktreePath]);
      if (baseRef != null && baseRef.isNotEmpty) args.add(baseRef);
    } else {
      args.add(worktreePath);
      if (checkoutBranch != null && checkoutBranch.isNotEmpty) args.add(checkoutBranch);
    }
    await _runOrThrow(repoRoot, args, timeout: _addTimeout);
  }

  /// Lists local branches with the worktree (if any) that has each checked out.
  Future<List<GitBranch>> listBranches(String repoRoot) async {
    final out = await _run(repoRoot, ['branch', '--list', '--format=%(refname:short)%09%(worktreepath)']);
    if (out == null) {
      throw const GitException('git branch --list failed');
    }
    return parseBranchList(out);
  }

  /// Parses `git branch --list --format='%(refname:short)\t%(worktreepath)'`:
  /// one branch per line, name and (possibly empty) worktree path split by a
  /// TAB. An empty worktree path means the branch is not checked out anywhere.
  @visibleForTesting
  static List<GitBranch> parseBranchList(String stdout) {
    final out = <GitBranch>[];
    for (final line in const LineSplitter().convert(stdout)) {
      if (line.trim().isEmpty) continue;
      final tab = line.indexOf('\t');
      final name = (tab < 0 ? line : line.substring(0, tab)).trim();
      if (name.isEmpty) continue;
      final wt = tab < 0 ? '' : line.substring(tab + 1).trim();
      out.add(GitBranch(name: name, worktreePath: wt.isEmpty ? null : p.normalize(p.absolute(wt))));
    }
    return out;
  }

  /// Like [_run] but throws [GitException] (carrying stderr) on non-zero exit,
  /// timeout, or spawn failure — callers that must know *why* an operation
  /// failed (not just that it silently no-op'd) use this instead of [_run].
  Future<void> _runOrThrow(String cwd, List<String> args, {Duration? timeout}) async {
    try {
      final result = await Process.run('git', ['-C', cwd, ...args]).timeout(timeout ?? _timeout);
      if (result.exitCode != 0) {
        throw GitException(_asString(result.stderr).trim());
      }
    } on GitException {
      rethrow;
    } on TimeoutException {
      throw GitException('git ${args.join(' ')} timed out');
    } catch (e) {
      throw GitException('git ${args.join(' ')} failed: $e');
    }
  }

  String _asString(dynamic data) => data is String ? data : utf8.decode(data as List<int>);

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
