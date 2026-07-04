import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../shell/presentation/cubit/shell_cubit.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../cubit/claude_sessions_cubit.dart';

bool _isBusy(ClaudeRunStatus s) =>
    s == ClaudeRunStatus.running || s == ClaudeRunStatus.connecting || s == ClaudeRunStatus.compacting;

const _chipTints = [AppColors.brandIndigo, AppColors.secondary, AppColors.tertiary, AppColors.primary];

/// Breadcrumb "worktree · session" picker: the single entry point for
/// switching sessions (and, for a git worktree with the sidebar collapsed,
/// sibling worktrees). Replaces the old horizontal session tabs bar — tabs are
/// gone, this dropdown is the only session-switching UI. Always renders, even
/// for a plain-folder workspace (no `repoRoot`) or a workspace with a single
/// tab, so the center pane's top bar has a stable anchor.
class SessionWorktreePicker extends HookWidget {
  const SessionWorktreePicker({super.key, required this.workspaceId});

  final WorkspaceId workspaceId;

  @override
  Widget build(BuildContext context) {
    // Gate rebuilds on the tab set / active tab / per-tab title+status only —
    // NOT on streaming message text (title is derived from the first user
    // message and is stable once set).
    context.select<ClaudeSessionsCubit, String>((c) {
      final ws = c.state.tabsFor(workspaceId);
      if (ws == null) return '';
      return '${ws.activeTabId}|'
          '${ws.tabs.map((t) => '${t.tabId}:${t.runStatus.index}:${ClaudeSessionsCubit.sessionTitle(t)}').join(',')}';
    });
    final sidebarCollapsed = context.select<ShellCubit, bool>((c) => c.state.sidebarCollapsed);
    final repoRoot = context.select<WorkspacesCubit, String?>((c) => c.state.activeWorkspace?.repoRoot);
    final branch = context.select<WorkspacesCubit, String?>((c) => c.state.activeWorkspace?.branch);
    final path = context.select<WorkspacesCubit, String>((c) => c.state.activeWorkspace?.path ?? workspaceId);

    final sessionsCubit = context.read<ClaudeSessionsCubit>();
    final wsCubit = context.read<WorkspacesCubit>();
    final tabs = sessionsCubit.state.tabsList(workspaceId);
    final activeTabId = sessionsCubit.state.tabsFor(workspaceId)?.activeTabId ?? '';
    final active = tabs.firstWhereOrNull((t) => t.tabId == activeTabId);

    final panelCtrl = useMemoized(OverlayPortalController.new, const []);
    final panelShown = useState(false);

    void closePanel() {
      if (panelShown.value) {
        panelCtrl.hide();
        panelShown.value = false;
      }
    }

    void togglePanel() {
      if (panelShown.value) {
        closePanel();
      } else {
        panelCtrl.show();
        panelShown.value = true;
      }
    }

    final hasBusyOtherTab = tabs.any((t) => t.tabId != activeTabId && _isBusy(t.runStatus));
    final tint = _chipTints[(repoRoot ?? path).hashCode.abs() % _chipTints.length];
    final label = repoRoot != null ? (branch ?? p.basename(path)) : p.basename(path);
    final initial = label.isEmpty ? '?' : label.characters.first.toUpperCase();

    final breadcrumb = Hoverable(
      onTap: togglePanel,
      builder: (context, hover) => Tooltip(
        message: Locales.Claude.Terminal.WorktreeChip.switchTooltip,
        child: Container(
          key: const ValueKey('session_worktree_picker'),
          height: 30,
          padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 15,
                height: 15,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(4)),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: AppColors.surfaceContainerLowest,
                        ),
                      ),
                    ),
                    if (hasBusyOtherTab)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.agentRunning,
                            border: Border.all(color: AppColors.surfaceContainerLowest, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.terminalCode.copyWith(fontSize: 11, color: AppColors.outline, height: 1.0),
              ),
              if (active != null) ...[
                Text(' · ', style: TextStyle(color: AppColors.outlineVariant)),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    ClaudeSessionsCubit.sessionTitle(active),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.navTab.copyWith(color: AppColors.onSurface),
                  ),
                ),
              ],
              const SizedBox(width: 6),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isBusy(active?.runStatus ?? ClaudeRunStatus.idle)
                      ? AppColors.agentRunning
                      : AppColors.secondary,
                ),
              ),
              const Icon(Symbols.arrow_drop_down, size: 16, color: AppColors.outline),
            ],
          ),
        ),
      ),
    );

    return OverlayPortal.overlayChildLayoutBuilder(
      controller: panelCtrl,
      overlayChildBuilder: (context, info) {
        final targetBottomLeft = MatrixUtils.transformPoint(info.childPaintTransform, Offset(0, info.childSize.height));
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: closePanel),
            ),
            Positioned(
              left: targetBottomLeft.dx,
              top: targetBottomLeft.dy + 8,
              child: _PickerPanel(
                workspaceId: workspaceId,
                repoRoot: repoRoot,
                sidebarCollapsed: sidebarCollapsed,
                tabs: tabs,
                activeTabId: activeTabId,
                sessionsCubit: sessionsCubit,
                wsCubit: wsCubit,
                onClose: closePanel,
              ),
            ),
          ],
        );
      },
      child: breadcrumb,
    );
  }
}

class _PickerPanel extends StatelessWidget {
  const _PickerPanel({
    required this.workspaceId,
    required this.repoRoot,
    required this.sidebarCollapsed,
    required this.tabs,
    required this.activeTabId,
    required this.sessionsCubit,
    required this.wsCubit,
    required this.onClose,
  });

  final WorkspaceId workspaceId;
  final String? repoRoot;
  final bool sidebarCollapsed;
  final List<ClaudeSessionData> tabs;
  final String activeTabId;
  final ClaudeSessionsCubit sessionsCubit;
  final WorkspacesCubit wsCubit;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final showWorktreeSection = sidebarCollapsed && repoRoot != null;
    final showHint = !sidebarCollapsed && repoRoot != null;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 40, offset: Offset(0, 18))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showWorktreeSection) ...[
              _SectionHeader(
                Locales.Claude.WorktreePicker.worktreeHeader,
                key: const ValueKey('worktree_picker_worktree_header'),
              ),
              for (final w in wsCubit.state.workspacesOrEmpty.where((w) => w.repoRoot == repoRoot))
                _WorktreeRow(workspace: w, isActive: w.id == workspaceId, wsCubit: wsCubit, onClose: onClose),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                color: AppColors.outlineVariant,
              ),
            ],
            _SectionHeader(Locales.Claude.WorktreePicker.sessionsHeader),
            for (final t in tabs)
              _SessionRow(
                workspaceId: workspaceId,
                tab: t,
                isActive: t.tabId == activeTabId,
                showClose: tabs.length > 1,
                sessionsCubit: sessionsCubit,
                onClose: onClose,
              ),
            _NewSessionRow(workspaceId: workspaceId, sessionsCubit: sessionsCubit, onClose: onClose),
            if (showHint)
              Container(
                key: const ValueKey('worktree_picker_change_hint'),
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.outlineVariant)),
                ),
                child: Row(
                  children: [
                    const Icon(Symbols.arrow_back, size: 12, color: AppColors.outline),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        Locales.Claude.WorktreePicker.changeWorktreeHint,
                        style: const TextStyle(fontSize: 10.5, color: AppColors.outline),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
      child: Text(
        label,
        style: AppTypography.bodyMain.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.outline,
        ),
      ),
    );
  }
}

class _WorktreeRow extends StatelessWidget {
  const _WorktreeRow({required this.workspace, required this.isActive, required this.wsCubit, required this.onClose});

  final Workspace workspace;
  final bool isActive;
  final WorkspacesCubit wsCubit;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final tint = _chipTints[(workspace.repoRoot ?? workspace.path).hashCode.abs() % _chipTints.length];
    final label = workspace.branch ?? p.basename(workspace.path);
    return Hoverable(
      key: ValueKey('worktree_picker_worktree_${workspace.path}'),
      onTap: () {
        wsCubit.openPath(workspace.path);
        onClose();
      },
      builder: (context, hover) => Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.brandIndigo.withValues(alpha: 0.14)
              : (hover ? AppColors.glassHover : Colors.transparent),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Row(
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
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.terminalCode.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
            ),
            if (isActive) const Icon(Symbols.check, size: 14, color: AppColors.secondary),
          ],
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow({
    required this.workspaceId,
    required this.tab,
    required this.isActive,
    required this.showClose,
    required this.sessionsCubit,
    required this.onClose,
  });

  final WorkspaceId workspaceId;
  final ClaudeSessionData tab;
  final bool isActive;
  final bool showClose;
  final ClaudeSessionsCubit sessionsCubit;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final Color dotColor;
    if (_isBusy(tab.runStatus)) {
      dotColor = AppColors.agentRunning;
    } else if (isActive) {
      dotColor = AppColors.secondary;
    } else {
      dotColor = AppColors.outline.withValues(alpha: 0.5);
    }
    return Hoverable(
      key: ValueKey('worktree_picker_session_${tab.tabId}'),
      onTap: () {
        sessionsCubit.switchTab(workspaceId, tab.tabId);
        onClose();
      },
      builder: (context, hover) => Container(
        height: 31,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.brandIndigo.withValues(alpha: 0.14)
              : (hover ? AppColors.glassHover : Colors.transparent),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        child: Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ClaudeSessionsCubit.sessionTitle(tab),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.navTab.copyWith(
                  color: isActive ? AppColors.onSurface : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            if (showClose)
              Hoverable(
                key: ValueKey('worktree_picker_session_close_${tab.tabId}'),
                onTap: () => sessionsCubit.closeTab(workspaceId, tab.tabId),
                builder: (context, closeHover) => Tooltip(
                  message: Locales.Editor.Tab.close,
                  child: Icon(
                    Symbols.close,
                    size: 14,
                    color: AppColors.onSurfaceVariant.withValues(alpha: closeHover ? 1.0 : 0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NewSessionRow extends StatelessWidget {
  const _NewSessionRow({required this.workspaceId, required this.sessionsCubit, required this.onClose});

  final WorkspaceId workspaceId;
  final ClaudeSessionsCubit sessionsCubit;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      key: const ValueKey('worktree_picker_new_session'),
      onTap: () {
        sessionsCubit.openNewSession(workspaceId);
        onClose();
      },
      builder: (context, hover) => Container(
        margin: const EdgeInsets.only(top: 2),
        height: 31,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: hover ? AppColors.glassHover : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Row(
          children: [
            const Icon(Symbols.add, size: 14, color: AppColors.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                Locales.Claude.Terminal.Actions.newSession,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.navTab.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
