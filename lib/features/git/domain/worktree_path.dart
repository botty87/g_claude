import 'package:path/path.dart' as p;

/// Suggests where a new worktree for [branch] should live: inside the repo, in a
/// dedicated `.worktrees/` folder, mirroring the branch name.
///
/// e.g. repoRoot `~/Dev/g_claude` + branch `feature/bar`
///   → `~/Dev/g_claude/.worktrees/feature/bar`
///
/// `.worktrees/` should be added to the repo's `.gitignore`. When [branch] is
/// empty the base folder itself is returned, so the field can be prefilled
/// before the user types a name. The result is always editable before creation.
String defaultWorktreePath({required String repoRoot, required String branch}) {
  final base = p.join(p.normalize(repoRoot), '.worktrees');
  final b = branch.trim();
  return p.normalize(b.isEmpty ? base : p.join(base, b));
}
