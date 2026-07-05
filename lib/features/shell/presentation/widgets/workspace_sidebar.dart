import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../claude/presentation/cubit/claude_sessions_cubit.dart';
import '../../../git/domain/entities/git_worktree.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/domain/entities/workspace_group.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../cubit/shell_cubit.dart';
import 'activity_mini_rail.dart';
import 'close_worktree_dialog.dart';
import 'new_worktree_dialog.dart';

const double kSidebarExpandedWidth = 262;
const double kSidebarCollapsedWidth = 52;
const Duration kSidebarAnimDuration = Duration(milliseconds: 220);
const Curve kSidebarAnimCurve = Curves.easeOutCubic;

const _tints = [AppColors.brandIndigo, AppColors.secondary, AppColors.tertiary, AppColors.primary];

Color _tintFor(int seed) => _tints[seed.abs() % _tints.length];

String _initialFor(String name) => name.isEmpty ? '?' : name.characters.first.toUpperCase();

/// Left navigation region: workspace switcher + activity mini-rail.
/// Replaces the old vertical [ActivityBar] and the top-right workspace dropdown.
class WorkspaceSidebar extends StatelessWidget {
  const WorkspaceSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final collapsed = context.select<ShellCubit, bool>((c) => c.state.sidebarCollapsed);
    return AnimatedContainer(
      duration: kSidebarAnimDuration,
      curve: kSidebarAnimCurve,
      width: collapsed ? kSidebarCollapsedWidth : kSidebarExpandedWidth,
      decoration: BoxDecoration(
        color: collapsed ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
        border: const Border(right: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      // Clip so the two fixed-width contents never paint past the animating
      // width. Each content is pinned to its own target width via [OverflowBox]
      // (left-aligned) so it lays out at 262/52 regardless of the intermediate
      // constraint, and [AnimatedSwitcher] crossfades between them.
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: kSidebarAnimDuration,
          switchInCurve: kSidebarAnimCurve,
          switchOutCurve: kSidebarAnimCurve,
          child: collapsed
              ? const _PinnedWidth(
                  key: ValueKey('sidebar_collapsed'),
                  width: kSidebarCollapsedWidth,
                  child: _CollapsedRail(),
                )
              : const _PinnedWidth(
                  key: ValueKey('sidebar_expanded'),
                  width: kSidebarExpandedWidth,
                  child: _ExpandedSidebar(),
                ),
        ),
      ),
    );
  }
}

/// Forces [child] to lay out at a fixed [width] regardless of the (animating)
/// constraint from the parent, left-aligned. Overflow is expected — the parent
/// [ClipRect] trims it — so the content keeps its real width while the sidebar
/// width tweens, instead of reflowing every frame.
class _PinnedWidth extends StatelessWidget {
  const _PinnedWidth({super.key, required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      alignment: Alignment.centerLeft,
      minWidth: width,
      maxWidth: width,
      child: SizedBox(width: width, child: child),
    );
  }
}

class _ExpandedSidebar extends StatelessWidget {
  const _ExpandedSidebar();

  @override
  Widget build(BuildContext context) {
    final workspaces = context.select<WorkspacesCubit, List<Workspace>>((c) => c.state.workspacesOrEmpty);
    final activeId = context.select<WorkspacesCubit, WorkspaceId?>((c) => c.state.activeIdOrNull);
    final grouped = groupWorkspaces(workspaces);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
          child: Row(
            children: [
              Text(Locales.Shell.Sidebar.header, style: AppTypography.sidebarLabel.copyWith(color: AppColors.outline)),
              const Spacer(),
              _IconButton(
                icon: Symbols.chevron_left,
                tooltip: Locales.Shell.Sidebar.collapse,
                onTap: () => context.read<ShellCubit>().toggleSidebar(),
                keyName: 'sidebar_collapse',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
          child: Hoverable(
            onTap: () => context.read<WorkspacesCubit>().openFromPicker(),
            builder: (context, hover) => Container(
              key: const ValueKey('sidebar_new_workspace'),
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: hover ? AppColors.glassHover : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid),
              ),
              child: Row(
                children: [
                  const Icon(Symbols.add, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    Locales.Shell.Sidebar.newWorkspace,
                    style: AppTypography.navTab.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            children: [
              for (final group in grouped.repos) _RepoGroup(group: group, activeId: activeId),
              for (final folder in grouped.folders)
                _WorkspaceRow(workspace: folder, tint: _tintFor(folder.id.hashCode), isActive: folder.id == activeId),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
          child: ActivityMiniRail(axis: Axis.horizontal),
        ),
      ],
    );
  }
}

/// A single row rendered for a plain folder workspace (no worktrees).
class _WorkspaceRow extends StatelessWidget {
  const _WorkspaceRow({required this.workspace, required this.tint, required this.isActive});

  final Workspace workspace;
  final Color tint;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: () => context.read<WorkspacesCubit>().setActive(workspace.id),
      builder: (context, hover) => Container(
        height: 34,
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.brandIndigo.withValues(alpha: 0.14)
              : (hover ? AppColors.glassHover : Colors.transparent),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border(left: BorderSide(color: isActive ? AppColors.brandIndigo : Colors.transparent, width: 2)),
        ),
        child: Row(
          children: [
            _Avatar(initial: _initialFor(workspace.name), tint: tint),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                workspace.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.navTab.copyWith(
                  color: isActive ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (hover) ...[
              const SizedBox(width: AppSpacing.xs),
              _CloseAffordance(
                keyName: 'close_workspace_${workspace.id}',
                onTap: () => context.read<WorkspacesCubit>().closeWorkspace(workspace.id),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// An expandable repo group: a header + nested worktree rows read live from
/// `git worktree list`. Expand + "show all" are ephemeral UI state (not domain).
class _RepoGroup extends HookWidget {
  const _RepoGroup({required this.group, required this.activeId});

  final WorkspaceGroup group;
  final WorkspaceId? activeId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkspacesCubit>();
    final expanded = useState(true);
    final showAll = useState(false);
    final tint = _tintFor(group.repoRoot.hashCode);

    final openedPaths = group.worktrees.map((w) => w.path).toList(growable: false);
    // Re-fetch when the repo, expand state, opened set, OR the worktree
    // revision changes — the last covers creating a worktree without opening it
    // (no opened-set change, so it would otherwise stay invisible).
    final revision = context.select<WorkspacesCubit, int>((c) => c.state.worktreesRevisionOrZero);
    // Fetch live worktrees only while expanded; seed with the warm cache to
    // avoid a loading flicker.
    final future = useMemoized(
      () => expanded.value
          ? cubit.ensureWorktrees(group.repoRoot)
          : Future.value(cubit.cachedWorktrees(group.repoRoot) ?? const <GitWorktree>[]),
      [group.repoRoot, expanded.value, openedPaths.length, revision],
    );
    final snap = useFuture(future, initialData: cubit.cachedWorktrees(group.repoRoot));
    final gitWorktrees = snap.data ?? const <GitWorktree>[];

    final openedSet = openedPaths.toSet();
    final gitByPath = {for (final g in gitWorktrees) g.path: g};
    final rows = <_WtRowData>[
      for (final w in group.worktrees)
        _WtRowData(
          path: w.path,
          name: w.name,
          branch: w.branch ?? gitByPath[w.path]?.branch,
          opened: true,
          detached: gitByPath[w.path]?.isDetached ?? false,
          isMain: w.path == group.repoRoot,
        ),
      if (showAll.value)
        for (final g in gitWorktrees)
          if (!g.isBare && !openedSet.contains(g.path))
            _WtRowData(
              path: g.path,
              name: p.basename(g.path),
              branch: g.branch,
              opened: false,
              detached: g.isDetached,
              isMain: g.path == group.repoRoot,
            ),
    ];

    final hasHidden = gitWorktrees.where((g) => !g.isBare).any((g) => !openedSet.contains(g.path));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RepoHeader(
          name: group.name,
          tint: tint,
          openedCount: group.worktrees.length,
          expanded: expanded.value,
          showAll: showAll.value,
          hasHidden: hasHidden,
          onToggleExpand: () => expanded.value = !expanded.value,
          onToggleShowAll: () => showAll.value = !showAll.value,
          onAddWorktree: () => showNewWorktreeDialog(context, repoRoot: group.repoRoot, worktrees: gitWorktrees),
        ),
        if (expanded.value)
          for (final row in rows)
            _WorktreeRow(
              row: row,
              repoRoot: group.repoRoot,
              tint: tint,
              isActive: row.path == activeId,
              onTap: () => cubit.openPath(row.path),
            ),
      ],
    );
  }
}

class _RepoHeader extends StatelessWidget {
  const _RepoHeader({
    required this.name,
    required this.tint,
    required this.openedCount,
    required this.expanded,
    required this.showAll,
    required this.hasHidden,
    required this.onToggleExpand,
    required this.onToggleShowAll,
    required this.onAddWorktree,
  });

  final String name;
  final Color tint;
  final int openedCount;
  final bool expanded;
  final bool showAll;
  final bool hasHidden;
  final VoidCallback onToggleExpand;
  final VoidCallback onToggleShowAll;
  final VoidCallback onAddWorktree;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: onToggleExpand,
      builder: (context, hover) => Container(
        key: ValueKey('repo_group_$name'),
        height: 34,
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: hover ? AppColors.glassHover : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            AnimatedRotation(
              turns: expanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 150),
              child: const Icon(Symbols.chevron_right, size: 16, color: AppColors.outline),
            ),
            const SizedBox(width: AppSpacing.xs),
            _Avatar(initial: _initialFor(name), tint: tint),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.navTab.copyWith(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              Locales.Shell.Sidebar.Worktrees.openedCount(count: '$openedCount'),
              style: AppTypography.navTab.copyWith(color: AppColors.outline, fontSize: 11),
            ),
            if (hasHidden || showAll) ...[
              const SizedBox(width: AppSpacing.xs),
              Hoverable(
                onTap: onToggleShowAll,
                builder: (context, h) => Tooltip(
                  message: showAll
                      ? Locales.Shell.Sidebar.Worktrees.showOpenOnly
                      : Locales.Shell.Sidebar.Worktrees.showAll,
                  child: Icon(
                    showAll ? Symbols.visibility : Symbols.visibility_off,
                    size: 15,
                    color: showAll ? AppColors.primary : AppColors.outline,
                  ),
                ),
              ),
            ],
            const SizedBox(width: AppSpacing.xs),
            Hoverable(
              onTap: onAddWorktree,
              builder: (context, h) => Tooltip(
                message: Locales.Shell.Sidebar.Worktrees.addTooltip,
                child: Icon(
                  Symbols.add,
                  key: ValueKey('add_worktree_$name'),
                  size: 16,
                  color: h ? AppColors.primary : AppColors.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Local, non-persisted view model for a worktree row.
class _WtRowData {
  const _WtRowData({
    required this.path,
    required this.name,
    required this.opened,
    required this.isMain,
    this.branch,
    this.detached = false,
  });

  final String path;
  final String name;
  final String? branch;
  final bool opened;
  final bool detached;
  final bool isMain;
}

class _WorktreeRow extends StatelessWidget {
  const _WorktreeRow({
    required this.row,
    required this.repoRoot,
    required this.tint,
    required this.isActive,
    required this.onTap,
  });

  final _WtRowData row;
  final String repoRoot;
  final Color tint;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final running = row.opened
        ? context.select<ClaudeSessionsCubit, bool>((c) => c.state.isWorkspaceRunning(row.path))
        : false;
    // A bare repo container (opened root, isMain, no branch) is not a branch
    // and not detached — label it "root", never a phantom branch.
    final branchLabel = row.detached
        ? Locales.Claude.Terminal.WorktreeChip.detached
        : row.branch ?? (row.isMain ? Locales.Claude.Terminal.WorktreeChip.root : '');

    return Hoverable(
      onTap: onTap,
      builder: (context, hover) => Container(
        key: ValueKey('worktree_row_${row.path}'),
        height: 32,
        margin: const EdgeInsets.only(left: 18, top: 1, bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.brandIndigo.withValues(alpha: 0.14)
              : (hover ? AppColors.glassHover : Colors.transparent),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border(left: BorderSide(color: isActive ? AppColors.brandIndigo : Colors.transparent, width: 2)),
        ),
        child: Row(
          children: [
            _StatusDot(running: running, opened: row.opened),
            const SizedBox(width: AppSpacing.sm),
            // Two columns: worktree name left-aligned (fills, so the branch is
            // pushed right), branch right-aligned in a capped column. The
            // trailing × still lands at the right edge on hover.
            Expanded(
              child: Text(
                row.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.navTab.copyWith(
                  color: row.opened
                      ? (isActive ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant)
                      : AppColors.outline,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (branchLabel.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 110),
                child: Text(
                  branchLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: AppTypography.terminalCode.copyWith(color: AppColors.outline, fontSize: 10, height: 1.0),
                ),
              ),
            ],
            if (row.opened && hover) ...[
              const SizedBox(width: AppSpacing.xs),
              _CloseAffordance(
                keyName: 'close_worktree_${row.path}',
                onTap: () => showCloseWorktreeDialog(
                  context,
                  workspaceId: row.path,
                  name: row.name,
                  branch: row.branch,
                  isMain: row.isMain,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Trailing hover-only "×" affordance used by both flat-folder and worktree
/// rows to close/remove a workspace. Wrapped in its own [Hoverable] (hence
/// its own [GestureDetector]) nested inside the row's — Flutter's gesture
/// arena resolves nested detectors to the innermost one, so tapping the ×
/// never also fires the row's own onTap. Mirrors [SessionWorktreePicker]'s
/// close-session affordance.
class _CloseAffordance extends StatelessWidget {
  const _CloseAffordance({required this.keyName, required this.onTap});

  final String keyName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      key: ValueKey(keyName),
      onTap: onTap,
      builder: (context, closeHover) => Tooltip(
        message: Locales.Shell.CloseWorktree.closeTooltip,
        child: Icon(Symbols.close, size: 14, color: AppColors.outline.withValues(alpha: closeHover ? 1.0 : 0.6)),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.running, required this.opened});

  final bool running;
  final bool opened;

  @override
  Widget build(BuildContext context) {
    final color = running
        ? AppColors.agentRunning
        : (opened ? AppColors.outline : AppColors.outline.withValues(alpha: 0.4));
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: opened ? color : Colors.transparent,
        border: opened ? null : Border.all(color: color, width: 1.2),
      ),
    );
  }
}

class _CollapsedRail extends StatelessWidget {
  const _CollapsedRail();

  @override
  Widget build(BuildContext context) {
    final workspaces = context.select<WorkspacesCubit, List<Workspace>>((c) => c.state.workspacesOrEmpty);
    final activeId = context.select<WorkspacesCubit, WorkspaceId?>((c) => c.state.activeIdOrNull);
    final grouped = groupWorkspaces(workspaces);

    // One avatar per repo group (deduped), then one per folder.
    final avatars = <_RailAvatar>[
      for (final g in grouped.repos)
        _RailAvatar(
          initial: _initialFor(g.name),
          tooltip: g.name,
          tint: _tintFor(g.repoRoot.hashCode),
          targetId: g.worktrees.any((w) => w.id == activeId) ? activeId! : g.worktrees.first.id,
          active: g.worktrees.any((w) => w.id == activeId),
        ),
      for (final f in grouped.folders)
        _RailAvatar(
          initial: _initialFor(f.name),
          tooltip: f.name,
          tint: _tintFor(f.id.hashCode),
          targetId: f.id,
          active: f.id == activeId,
        ),
    ];

    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        _IconButton(
          icon: Symbols.chevron_right,
          tooltip: Locales.Shell.Sidebar.expand,
          onTap: () => context.read<ShellCubit>().toggleSidebar(),
          keyName: 'sidebar_expand',
        ),
        const SizedBox(height: AppSpacing.xs),
        const Divider(height: 1, thickness: 1, indent: 12, endIndent: 12, color: AppColors.outlineVariant),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: avatars.length,
            itemBuilder: (context, index) {
              final a = avatars[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Center(
                  child: Hoverable(
                    onTap: () => context.read<WorkspacesCubit>().setActive(a.targetId),
                    builder: (context, hover) => Tooltip(
                      message: a.tooltip,
                      child: _Avatar(initial: a.initial, tint: a.tint, active: a.active, size: 30),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Hoverable(
            onTap: () => context.read<WorkspacesCubit>().openFromPicker(),
            builder: (context, hover) => Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.outlineVariant),
                color: hover ? AppColors.glassHover : Colors.transparent,
              ),
              child: const Icon(Symbols.add, size: 16, color: AppColors.primary),
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, indent: 12, endIndent: 12, color: AppColors.outlineVariant),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: ActivityMiniRail(axis: Axis.vertical),
        ),
      ],
    );
  }
}

class _RailAvatar {
  const _RailAvatar({
    required this.initial,
    required this.tooltip,
    required this.tint,
    required this.targetId,
    required this.active,
  });

  final String initial;
  final String tooltip;
  final Color tint;
  final WorkspaceId targetId;
  final bool active;
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial, required this.tint, this.active = false, this.size = 18});

  final String initial;
  final Color tint;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: active ? [const BoxShadow(color: AppColors.brandIndigo, spreadRadius: 2)] : null,
      ),
      child: Text(
        initial,
        style: TextStyle(fontSize: size * 0.5, fontWeight: FontWeight.w700, color: AppColors.surfaceContainerLowest),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.tooltip, required this.onTap, required this.keyName});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: onTap,
      builder: (context, hover) => Tooltip(
        message: tooltip,
        child: Container(
          key: ValueKey(keyName),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: hover ? AppColors.glassHover : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}
