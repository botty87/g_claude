// Contracts for `defaultWorktreePath` — suggests `<repoRoot>/.worktrees/<branch>`.

import 'package:flutter_test/flutter_test.dart';
import 'package:g_claude/features/git/domain/worktree_path.dart';

void main() {
  group('defaultWorktreePath', () {
    test('nests the branch under the repo .worktrees folder', () {
      expect(
        defaultWorktreePath(repoRoot: '/Users/me/Dev/repo', branch: 'feature/bar'),
        '/Users/me/Dev/repo/.worktrees/feature/bar',
      );
    });

    test('single-segment branch', () {
      expect(defaultWorktreePath(repoRoot: '/root/repo', branch: 'hotfix'), '/root/repo/.worktrees/hotfix');
    });

    test('empty branch → the base .worktrees folder (for prefill before typing)', () {
      expect(defaultWorktreePath(repoRoot: '/root/repo', branch: ''), '/root/repo/.worktrees');
    });

    test('trailing slash in repoRoot is normalized away', () {
      expect(defaultWorktreePath(repoRoot: '/root/repo/', branch: 'dev'), '/root/repo/.worktrees/dev');
    });
  });
}
