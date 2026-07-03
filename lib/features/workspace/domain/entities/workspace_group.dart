import 'package:path/path.dart' as p;

import 'workspace.dart';

/// A repo grouping: the opened worktrees that share the same [repoRoot].
class WorkspaceGroup {
  const WorkspaceGroup({required this.repoRoot, required this.name, required this.worktrees});

  final String repoRoot;
  final String name;
  final List<Workspace> worktrees;
}

/// The workspace list split into repo groups (repoRoot != null) and flat
/// folders (repoRoot == null).
class GroupedWorkspaces {
  const GroupedWorkspaces({required this.repos, required this.folders});

  final List<WorkspaceGroup> repos;
  final List<Workspace> folders;
}

/// Pure grouping of open workspaces. First-seen order is preserved for both
/// repos and folders, and worktrees keep their order within a group.
GroupedWorkspaces groupWorkspaces(List<Workspace> workspaces) {
  final order = <String>[];
  final byRepo = <String, List<Workspace>>{};
  final folders = <Workspace>[];

  for (final w in workspaces) {
    final root = w.repoRoot;
    if (root == null) {
      folders.add(w);
      continue;
    }
    if (!byRepo.containsKey(root)) {
      byRepo[root] = [];
      order.add(root);
    }
    byRepo[root]!.add(w);
  }

  final repos = order
      .map((root) => WorkspaceGroup(repoRoot: root, name: p.basename(root), worktrees: byRepo[root]!))
      .toList(growable: false);

  return GroupedWorkspaces(repos: repos, folders: folders);
}
