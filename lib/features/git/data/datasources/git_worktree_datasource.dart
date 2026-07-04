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
  // well over the default 3s, so it gets its own generous budget. On timeout git
  // is killed (SIGTERM → SIGKILL) and any partial worktree is cleaned up — see
  // [_runAddOrThrow] — so a pathological hang no longer orphans a worktree.
  static const _addTimeout = Duration(seconds: 120);
  // Grace between SIGTERM and SIGKILL when a timed-out `git worktree add` refuses
  // to die on TERM (a checkout mid-flight may ignore it).
  static const _killGrace = Duration(seconds: 3);

  /// Detects whether [path] is inside a git repo. Returns null when it is not
  /// (or when git is unavailable / times out — a broken git must never block
  /// opening a plain folder).
  Future<GitRepoInfo?> detect(String path) async {
    final commonDir = await _run(path, ['rev-parse', '--path-format=absolute', '--git-common-dir']);
    if (commonDir == null) return null;
    // Only read the branch when inside a real work tree: a bare repo/container's
    // HEAD points at a default branch checked out nowhere, so reporting it would
    // paint a phantom worktree.
    final insideWorkTree = (await _run(path, ['rev-parse', '--is-inside-work-tree']))?.trim() == 'true';
    final head = insideWorkTree ? await _run(path, ['rev-parse', '--abbrev-ref', 'HEAD']) : null;
    return resolveRepoInfo(commonDir: commonDir, insideWorkTree: insideWorkTree, head: head);
  }

  /// Pure mapping of `git rev-parse` outputs to [GitRepoInfo] — extracted from
  /// [detect] so the repoRoot/branch derivation is unit-testable without
  /// spawning git (fixtures are real `rev-parse` output). Returns null when
  /// [commonDir] is empty (the path is not a git repo).
  ///
  /// [repoRoot] is the grouping key stable across a repo's worktrees, derived
  /// from `--git-common-dir`:
  ///  - normal repo → `<root>/.git` → parent `<root>`
  ///  - `.bare` container layout → `<container>/.bare` → parent `<container>`
  ///  - classic bare (`git init --bare foo.git`) → `foo.git` *is* the repo → itself
  ///
  /// A leading-dot basename (`.git`, `.bare`, any hidden nested git dir) means
  /// the common dir lives *inside* the project root, so the root is its parent;
  /// otherwise the common dir *is* the root. This is the only signal that works:
  /// classic-bare-worktree, normal-worktree and `.bare`-worktree all report
  /// `(is-inside-work-tree=true, is-bare-repository=false)` yet need different
  /// roots, so no rev-parse boolean can substitute for the basename check.
  /// Accepted misfire (pathological, documented): `--separate-git-dir` targets
  /// and a classic bare living at a dot-prefixed path (e.g. `~/.myrepo`).
  @visibleForTesting
  static GitRepoInfo? resolveRepoInfo({
    required String? commonDir,
    required bool insideWorkTree,
    required String? head,
  }) {
    final trimmed = commonDir?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final normalized = p.normalize(p.absolute(trimmed));
    final repoRoot = p.basename(normalized).startsWith('.') ? p.dirname(normalized) : normalized;
    String? branch;
    if (insideWorkTree) {
      final name = head?.trim();
      branch = (name == null || name.isEmpty || name == 'HEAD') ? null : name;
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
    await _runAddOrThrow(repoRoot, args, worktreePath);
  }

  /// Lists local branches AND remote-tracking branches (`origin/*`) so the "new
  /// worktree" dialog can base a new branch on a remote. `git for-each-ref` over
  /// both ref namespaces in one call — its `%(worktreepath)` gives the checkout
  /// (local only), and `%(symref)` lets us drop the `origin/HEAD` alias.
  ///
  /// NOTE: remotes are only valid as a *base* (`worktree add -b … origin/x`).
  /// A caller that checks out or deletes a branch must filter `isRemote` first
  /// (checking out `origin/x` detaches HEAD; `branch -d origin/x` is nonsense).
  Future<List<GitBranch>> listBranches(String repoRoot) async {
    final out = await _run(repoRoot, [
      'for-each-ref',
      '--format=%(refname)%09%(refname:short)%09%(worktreepath)%09%(symref)',
      'refs/heads',
      'refs/remotes',
    ]);
    if (out == null) {
      throw const GitException('git for-each-ref failed');
    }
    return parseBranchList(out);
  }

  /// Parses `git for-each-ref --format='%(refname)\t%(refname:short)\t%(worktreepath)\t%(symref)'`
  /// over `refs/heads` and `refs/remotes`. TAB-separated fields per line:
  ///  0. full refname — classifies local (`refs/heads/…`) vs remote (`refs/remotes/…`)
  ///  1. short name — `main`, `origin/main`; the display value and base ref
  ///  2. worktree path — local branches only; empty ⇒ not checked out anywhere
  ///  3. symref target — non-empty ⇒ a symbolic ref (`origin/HEAD`), skipped
  @visibleForTesting
  static List<GitBranch> parseBranchList(String stdout) {
    final out = <GitBranch>[];
    for (final line in const LineSplitter().convert(stdout)) {
      if (line.trim().isEmpty) continue;
      final f = line.split('\t');
      final refname = f.isNotEmpty ? f[0].trim() : '';
      final name = f.length > 1 ? f[1].trim() : refname;
      final wt = f.length > 2 ? f[2].trim() : '';
      final symref = f.length > 3 ? f[3].trim() : '';
      if (name.isEmpty) continue;
      if (symref.isNotEmpty) continue; // e.g. refs/remotes/origin/HEAD → origin/main
      out.add(
        GitBranch(
          name: name,
          worktreePath: wt.isEmpty ? null : p.normalize(p.absolute(wt)),
          isRemote: refname.startsWith('refs/remotes/'),
        ),
      );
    }
    return out;
  }

  /// Like [_run] but throws [GitException] (carrying stderr) on non-zero exit,
  /// timeout, or spawn failure — callers that must know *why* an operation
  /// failed (not just that it silently no-op'd) use this instead of [_run].
  Future<void> _runOrThrow(String cwd, List<String> args) async {
    try {
      final result = await Process.run('git', ['-C', cwd, ...args]).timeout(_timeout);
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

  /// Runs `git worktree add` under a hard timeout that actually KILLS git — a
  /// plain `Process.run().timeout` only abandons the await, leaving git to
  /// finish and orphan a worktree the UI already reported as failed. On timeout:
  /// SIGTERM, then SIGKILL after [_killGrace], then best-effort cleanup (remove
  /// the partial target dir + `git worktree prune` the dangling admin entry).
  /// Uses [Process.start] so we hold the handle needed to signal the child.
  Future<void> _runAddOrThrow(String cwd, List<String> args, String worktreePath) async {
    final Process proc;
    try {
      proc = await Process.start('git', ['-C', cwd, ...args]);
    } catch (e) {
      throw GitException('git ${args.join(' ')} failed to start: $e');
    }
    // Drain both pipes eagerly so git never blocks on a full stdout/stderr
    // buffer; stderr is what we surface on failure. `allowMalformed` so a
    // SIGKILL mid-write (truncated multibyte) can't turn the drain into an
    // unhandled `FormatException`.
    const decoder = Utf8Decoder(allowMalformed: true);
    final stdoutDrain = proc.stdout.transform(decoder).join();
    final stderrOut = proc.stderr.transform(decoder).join();

    final int exitCode;
    try {
      exitCode = await proc.exitCode.timeout(_addTimeout);
    } on TimeoutException {
      proc.kill(ProcessSignal.sigterm);
      try {
        await proc.exitCode.timeout(_killGrace);
      } on TimeoutException {
        proc.kill(ProcessSignal.sigkill);
      }
      stdoutDrain.ignore();
      stderrOut.ignore();
      await _cleanupPartialWorktree(cwd, worktreePath);
      throw GitException(
        'git ${args.join(' ')} timed out after ${_addTimeout.inSeconds}s (killed; cleaned up partial worktree)',
      );
    }

    stdoutDrain.ignore();
    if (exitCode != 0) {
      final err = (await stderrOut).trim();
      throw GitException(err.isEmpty ? 'git ${args.join(' ')} failed (exit $exitCode)' : err);
    }
    stderrOut.ignore();
  }

  /// Best-effort removal of the debris a killed `git worktree add` may leave:
  /// the partially-created target dir and the dangling worktree admin entry.
  /// Never throws — cleanup failure must not mask the original timeout error.
  Future<void> _cleanupPartialWorktree(String repoRoot, String worktreePath) async {
    try {
      final dir = Directory(worktreePath);
      if (await dir.exists()) {
        // Negligible-but-destructive race guard: if git actually finished a
        // VALID worktree right as the timeout fired, it has a `.git` gitfile —
        // never delete that (and `git worktree prune` leaves it alone too).
        final gitEntry = await FileSystemEntity.type(p.join(worktreePath, '.git'));
        if (gitEntry == FileSystemEntityType.notFound) await dir.delete(recursive: true);
      }
    } catch (e) {
      _talker.warning('worktree cleanup: could not remove partial dir $worktreePath: $e');
    }
    // `worktree prune` only touches metadata (never a checkout) and is fast, so
    // a plain `.timeout` here can't hang the way `worktree add` could.
    try {
      await Process.run('git', ['-C', repoRoot, 'worktree', 'prune']).timeout(_timeout);
    } catch (e) {
      _talker.warning('worktree cleanup: git worktree prune failed in $repoRoot: $e');
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
