import 'package:path/path.dart' as p;

/// What a folder turns out to be when inspected before opening it: a plain
/// folder, a git repository (main checkout), or a linked git worktree — plus
/// the branch and how many uncommitted changes it has. Used by the "open
/// existing" flow to preview a folder before attaching it as a workspace.
class GitFolderInspection {
  const GitFolderInspection({
    this.isGit = false,
    this.repoRoot,
    this.branch,
    this.isWorktree = false,
    this.dirtyCount = 0,
  });

  final bool isGit;
  final String? repoRoot;
  final String? branch;

  /// True when the folder is a *linked* worktree (not the main checkout).
  final bool isWorktree;

  /// Number of uncommitted changes (`git status --porcelain` lines).
  final int dirtyCount;

  String? get repoName => repoRoot == null ? null : p.basename(repoRoot!);
}
