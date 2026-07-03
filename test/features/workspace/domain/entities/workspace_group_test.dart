// Contracts for the pure `groupWorkspaces` grouping used by the sidebar.

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/workspace/domain/entities/workspace.dart';
import 'package:g_claude/features/workspace/domain/entities/workspace_group.dart';

Workspace _ws(String path, {String? repoRoot, String? branch}) => Workspace(
  id: path,
  path: path,
  name: path.split('/').last,
  openedAt: DateTime.utc(2026, 1, 1),
  repoRoot: repoRoot,
  branch: branch,
);

void main() {
  test('splits repo worktrees from plain folders', () {
    final grouped = groupWorkspaces([
      _ws('/home/me'),
      _ws('/repo/main', repoRoot: '/repo', branch: 'main'),
      _ws('/repo/feat', repoRoot: '/repo', branch: 'feature/x'),
    ]);

    expect(grouped.folders.map((w) => w.path), ['/home/me']);
    expect(grouped.repos.length, 1);
    expect(grouped.repos.single.repoRoot, '/repo');
    expect(grouped.repos.single.name, 'repo');
    expect(grouped.repos.single.worktrees.map((w) => w.branch), ['main', 'feature/x']);
  });

  test('separate repoRoots become separate groups, first-seen order preserved', () {
    final grouped = groupWorkspaces([_ws('/b/wt', repoRoot: '/b'), _ws('/a/wt', repoRoot: '/a')]);
    expect(grouped.repos.map((g) => g.repoRoot), ['/b', '/a']);
  });

  test('no repos → empty repo list, only folders', () {
    final grouped = groupWorkspaces([_ws('/x'), _ws('/y')]);
    expect(grouped.repos, isEmpty);
    expect(grouped.folders.length, 2);
  });
}
