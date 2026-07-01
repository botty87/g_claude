import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
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

    final cubit = context.read<ClaudeSessionsCubit>();
    final tabs = cubit.state.tabsList(workspaceId);
    final activeTabId = cubit.state.tabsFor(workspaceId)?.activeTabId ?? '';
    if (tabs.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: Row(
        children: [
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
        constraints: const BoxConstraints(maxWidth: 200),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : (hover ? AppColors.glassHover : Colors.transparent),
          border: Border(bottom: BorderSide(color: isActive ? AppColors.brandIndigo : Colors.transparent, width: 2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
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
