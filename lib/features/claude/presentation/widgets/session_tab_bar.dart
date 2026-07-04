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
import '../../../git/domain/entities/git_worktree.dart';
import '../../../shell/presentation/cubit/shell_cubit.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../cubit/claude_sessions_cubit.dart';

bool _isBusy(ClaudeRunStatus s) =>
    s == ClaudeRunStatus.running || s == ClaudeRunStatus.connecting || s == ClaudeRunStatus.compacting;

/// Top bar listing the chat sessions of the active workspace as tabs, with a
/// per-tab "running" dot and a ＋ to open a new session. Switching a tab is
/// instant (state kept in memory by [ClaudeSessionsCubit]).
class SessionTabBar extends StatelessWidget {
  const SessionTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final workspaceId = context.select<WorkspacesCubit, WorkspaceId?>((c) => c.state.activeIdOrNull);
    if (workspaceId == null) return const SizedBox.shrink();

    // Gate rebuilds on the tab set / active tab / per-tab title+status only —
    // NOT on streaming message text (title is derived from the first user
    // message and is stable once set).
    context.select<ClaudeSessionsCubit, String>((c) {
      final ws = c.state.tabsFor(workspaceId);
      if (ws == null) return '';
      return '${ws.activeTabId}|'
          '${ws.tabs.map((t) => '${t.tabId}:${t.runStatus.index}:${ClaudeSessionsCubit.sessionTitle(t)}').join(',')}';
    });

    // The worktree chip is a *quick* switcher: it only earns its place when the
    // sidebar is collapsed. With the sidebar open the tree already switches
    // worktrees, so the chip would be redundant.
    final sidebarCollapsed = context.select<ShellCubit, bool>((c) => c.state.sidebarCollapsed);

    final cubit = context.read<ClaudeSessionsCubit>();
    final tabs = cubit.state.tabsList(workspaceId);
    final activeTabId = cubit.state.tabsFor(workspaceId)?.activeTabId ?? '';
    if (tabs.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 34,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: Row(
        children: [
          if (sidebarCollapsed) _WorktreeChip(workspaceId: workspaceId),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              itemCount: tabs.length,
              itemBuilder: (context, i) {
                final t = tabs[i];
                return _SessionTab(
                  workspaceId: workspaceId,
                  tabId: t.tabId,
                  title: ClaudeSessionsCubit.sessionTitle(t),
                  running: _isBusy(t.runStatus),
                  isActive: t.tabId == activeTabId,
                  showClose: tabs.length > 1,
                );
              },
            ),
          ),
          Hoverable(
            onTap: () => cubit.openNewSession(workspaceId),
            builder: (context, hover) => Tooltip(
              message: Locales.Claude.Terminal.Actions.newSession,
              child: Container(
                key: const ValueKey('session_new_tab'),
                width: 28,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: hover ? AppColors.glassHover : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: const Icon(Symbols.add, size: 16, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _chipTints = [AppColors.brandIndigo, AppColors.secondary, AppColors.tertiary, AppColors.primary];

/// Worktree switcher shown to the left of the session tabs when the active
/// workspace is a git worktree. `[avatar] branch ▾` opens a menu of the repo's
/// worktrees; picking one reuses [WorkspacesCubit.openPath] (activates if
/// already open, registers lazily otherwise).
class _WorktreeChip extends HookWidget {
  const _WorktreeChip({required this.workspaceId});

  final WorkspaceId workspaceId;

  @override
  Widget build(BuildContext context) {
    final repoRoot = context.select<WorkspacesCubit, String?>((c) => c.state.activeWorkspace?.repoRoot);
    if (repoRoot == null) return const SizedBox.shrink();
    final branch = context.select<WorkspacesCubit, String?>((c) => c.state.activeWorkspace?.branch);

    final wsCubit = context.read<WorkspacesCubit>();
    final future = useMemoized(() => wsCubit.ensureWorktrees(repoRoot), [repoRoot]);
    final snap = useFuture(future, initialData: wsCubit.cachedWorktrees(repoRoot));
    final gitWorktrees = snap.data ?? const <GitWorktree>[];

    final tint = _chipTints[repoRoot.hashCode.abs() % _chipTints.length];
    // Branchless: distinguish a real detached HEAD (git says so) from a bare
    // repo container (root == the workspace itself). Consult the git list so the
    // chip agrees with the sidebar row instead of labelling a detached main as
    // "root".
    final isDetached = gitWorktrees.any((g) => g.path == workspaceId && g.isDetached);
    final label =
        branch ??
        (isDetached
            ? Locales.Claude.Terminal.WorktreeChip.detached
            : repoRoot == workspaceId
            ? Locales.Claude.Terminal.WorktreeChip.root
            // Branchless but neither detached nor the repo root: don't mislabel
            // as "detached" — fall back to the folder name.
            : p.basename(workspaceId));

    // Only opened worktrees, to stay consistent with the sidebar's default
    // "open only" view: branches without an open worktree are hidden there, so
    // the quick switcher hides them too. To open a new worktree, expand the
    // sidebar. (`gitWorktrees` is still consulted above for the detached label.)
    final opened = wsCubit.state.workspacesOrEmpty.where((w) => w.repoRoot == repoRoot).toList(growable: false);
    final items = <_ChipItem>[
      for (final w in opened)
        _ChipItem(path: w.path, label: w.branch ?? p.basename(w.path), opened: true, isActive: w.id == workspaceId),
    ];

    return MenuAnchor(
      menuChildren: [
        for (final item in items)
          MenuItemButton(
            key: ValueKey('worktree_menu_${item.path}'),
            onPressed: () => wsCubit.openPath(item.path),
            leadingIcon: Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.opened ? AppColors.outline : Colors.transparent,
                border: item.opened ? null : Border.all(color: AppColors.outline.withValues(alpha: 0.5), width: 1.2),
              ),
            ),
            child: Text(
              item.label,
              style: AppTypography.navTab.copyWith(
                color: item.isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: item.isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
      ],
      builder: (context, controller, child) => Hoverable(
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        builder: (context, hover) => Tooltip(
          message: Locales.Claude.Terminal.WorktreeChip.switchTooltip,
          child: Container(
            key: const ValueKey('worktree_chip'),
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: hover ? AppColors.glassHover : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    label.isEmpty ? '?' : label.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surfaceContainerLowest,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.terminalCode.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                      height: 1.0,
                    ),
                  ),
                ),
                const Icon(Symbols.arrow_drop_down, size: 16, color: AppColors.outline),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipItem {
  const _ChipItem({required this.path, required this.label, required this.opened, required this.isActive});

  final String path;
  final String label;
  final bool opened;
  final bool isActive;
}

class _SessionTab extends StatelessWidget {
  const _SessionTab({
    required this.workspaceId,
    required this.tabId,
    required this.title,
    required this.running,
    required this.isActive,
    required this.showClose,
  });

  final WorkspaceId workspaceId;
  final String tabId;
  final String title;
  final bool running;
  final bool isActive;
  final bool showClose;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClaudeSessionsCubit>();
    final textColor = isActive ? AppColors.onSurface : AppColors.onSurfaceVariant;
    return Hoverable(
      onTap: () => cubit.switchTab(workspaceId, tabId),
      builder: (context, hover) => Container(
        key: ValueKey('session_tab_$tabId'),
        constraints: const BoxConstraints(maxWidth: 160),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : (hover ? AppColors.glassHover : Colors.transparent),
          border: Border(bottom: BorderSide(color: isActive ? AppColors.brandIndigo : Colors.transparent, width: 2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: running ? AppColors.agentRunning : AppColors.outline.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.navTab.copyWith(color: textColor),
              ),
            ),
            if (showClose) ...[
              const SizedBox(width: AppSpacing.sm),
              Hoverable(
                key: ValueKey('session_tab_close_$tabId'),
                onTap: () => cubit.closeTab(workspaceId, tabId),
                builder: (context, closeHover) => Tooltip(
                  message: Locales.Editor.Tab.close,
                  child: Icon(Symbols.close, size: 14, color: textColor.withValues(alpha: closeHover ? 1.0 : 0.6)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
