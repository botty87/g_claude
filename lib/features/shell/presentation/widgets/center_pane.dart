import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../claude/presentation/widgets/chat_status_indicators.dart';
import '../../../claude/presentation/widgets/claude_terminal_pane.dart';
import '../../../claude/presentation/widgets/session_worktree_picker.dart';
import '../../../editor/presentation/cubit/editor_view_cubit.dart';
import '../../../editor/presentation/cubit/file_tabs_cubit.dart';
import '../../../editor/presentation/widgets/file_tab.dart';
import '../../../editor/presentation/widgets/file_viewer.dart';
import '../../../editor/presentation/widgets/quick_open_palette.dart';
import '../../../terminal/presentation/widgets/terminal_pane.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import 'peek_sheet.dart';

/// Center area of the shell: a segmented control (Chat / Code / Terminal) over
/// the active surface. The open-files set lives in [FileTabsCubit]; the current
/// view lives in [EditorViewCubit]. Opening a file jumps to the Code view.
class CenterPane extends HookWidget {
  const CenterPane({super.key});

  @override
  Widget build(BuildContext context) {
    final activeId = context.select<WorkspacesCubit, WorkspaceId?>((c) => c.state.activeIdOrNull);
    if (activeId == null) return const ClaudeTerminalPane();

    final view = context.select<EditorViewCubit, CenterView>((c) => c.state.dataFor(activeId).view);
    final peekOpen = context.select<EditorViewCubit, bool>((c) => c.state.dataFor(activeId).peekOpen);
    // The Code segment counts editor tabs + diff tabs; either kind enables it.
    final openCount = context.select<FileTabsCubit, int>((c) {
      final f = c.state.filesFor(activeId);
      if (f == null) return 0;
      return f.openPaths.length + f.openDiffs.length;
    });
    final hasFiles = openCount > 0;
    // Code is only reachable with at least one open file.
    final effectiveView = (view == CenterView.code && !hasFiles) ? CenterView.chat : view;

    return Column(
      children: [
        _TopBar(
          workspaceId: activeId,
          current: effectiveView,
          codeCount: openCount,
          codeEnabled: hasFiles,
          onSelect: (v) => context.read<EditorViewCubit>().setView(activeId, v),
        ),
        if (effectiveView == CenterView.code) _CodeTabsBar(workspaceId: activeId),
        Expanded(
          child: switch (effectiveView) {
            CenterView.chat => _ChatSurface(workspaceId: activeId, peekOpen: peekOpen && hasFiles),
            CenterView.code => const FileViewer(),
            CenterView.terminal => const TerminalPane(),
          },
        ),
      ],
    );
  }
}

/// Chat with an optional peek sheet docked below it. The chat keeps the top
/// portion (input bar stays reachable); the peek fills the bottom and is
/// resized by dragging its handle. The split ratio is per-workspace state in
/// [EditorViewCubit].
class _ChatSurface extends StatelessWidget {
  const _ChatSurface({required this.workspaceId, required this.peekOpen});

  final WorkspaceId workspaceId;
  final bool peekOpen;

  static const _minFraction = 0.25;
  static const _maxFraction = 0.75;

  @override
  Widget build(BuildContext context) {
    if (!peekOpen) return const ClaudeTerminalPane();
    final fraction = context.select<EditorViewCubit, double>((c) => c.state.dataFor(workspaceId).peekFraction);
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxHeight;
        return Column(
          children: [
            const Expanded(child: ClaudeTerminalPane()),
            SizedBox(
              height: total * fraction,
              child: PeekSheet(
                workspaceId: workspaceId,
                onResizeDrag: (dy) {
                  if (total <= 0) return;
                  final next = (fraction - dy / total).clamp(_minFraction, _maxFraction);
                  context.read<EditorViewCubit>().setPeekFraction(workspaceId, next);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Row 1: the worktree·session breadcrumb picker, the icon-only view switcher,
/// the "reduce to peek" affordance (Code view only) and the context meter /
/// status indicator. Always visible.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.workspaceId,
    required this.current,
    required this.codeCount,
    required this.codeEnabled,
    required this.onSelect,
  });

  final WorkspaceId workspaceId;
  final CenterView current;
  final int codeCount;
  final bool codeEnabled;
  final ValueChanged<CenterView> onSelect;

  @override
  Widget build(BuildContext context) {
    final isCode = current == CenterView.code;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: Row(
        children: [
          SessionWorktreePicker(workspaceId: workspaceId),
          const Spacer(),
          // "Reduce to peek" sits to the LEFT of the segmented so the switcher
          // keeps a fixed position (anchored on the right by meter/status) and
          // this button just appears/disappears in the free space.
          if (isCode) ...[
            Hoverable(
              onTap: () => context.read<EditorViewCubit>().demoteToPeek(workspaceId),
              builder: (context, hover) => Container(
                key: const ValueKey('code_reduce_to_peek'),
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: 11),
                decoration: BoxDecoration(
                  color: hover ? AppColors.glassHover : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Symbols.close_fullscreen, size: 13, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      Locales.Editor.Peek.reduceToPeek,
                      style: AppTypography.navTab.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Segment(
                  keyName: 'segment_chat',
                  icon: Symbols.forum,
                  label: Locales.Editor.CenterView.chat,
                  isActive: current == CenterView.chat,
                  onTap: () => onSelect(CenterView.chat),
                ),
                _Segment(
                  keyName: 'segment_code',
                  icon: Symbols.code,
                  label: Locales.Editor.CenterView.code,
                  isActive: isCode,
                  enabled: codeEnabled,
                  badge: codeCount > 0 ? '$codeCount' : null,
                  onTap: () => onSelect(CenterView.code),
                ),
                _Segment(
                  keyName: 'segment_terminal',
                  icon: Symbols.terminal,
                  label: Locales.Editor.CenterView.terminal,
                  isActive: current == CenterView.terminal,
                  onTap: () => onSelect(CenterView.terminal),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SessionContextMeter(workspaceId: workspaceId),
          const SizedBox(width: AppSpacing.md),
          SessionStatusIndicator(workspaceId: workspaceId),
        ],
      ),
    );
  }
}

/// Row 2 (Code view only): the open file tabs plus the quick-open trigger.
class _CodeTabsBar extends HookWidget {
  const _CodeTabsBar({required this.workspaceId});

  final WorkspaceId workspaceId;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final openPaths = context.select<FileTabsCubit, List<String>>(
      (c) => c.state.filesFor(workspaceId)?.openPaths ?? const [],
    );
    final activePath = context.select<FileTabsCubit, String?>((c) => c.state.filesFor(workspaceId)?.activePath);
    final previewPath = context.select<FileTabsCubit, String?>((c) => c.state.filesFor(workspaceId)?.previewPath);
    final activeDiffId = context.select<FileTabsCubit, String?>((c) => c.state.filesFor(workspaceId)?.activeDiffId);
    final previewDiffId = context.select<FileTabsCubit, String?>((c) => c.state.filesFor(workspaceId)?.previewDiffId);
    final openDiffs = context.select<FileTabsCubit, List<DiffTabRef>>(
      (c) => c.state.filesFor(workspaceId)?.openDiffs ?? const [],
    );
    final showingDiff = activeDiffId != null;

    return Container(
      height: AppSpacing.toolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final path in openPaths)
                    FileTab(
                      key: ValueKey('code-tab-$path'),
                      workspaceId: workspaceId,
                      path: path,
                      isActive: !showingDiff && path == activePath,
                      isPreview: path == previewPath,
                    ),
                  for (final diff in openDiffs)
                    FileTab(
                      key: ValueKey('code-diff-tab-${diff.path}'),
                      workspaceId: workspaceId,
                      path: diff.path,
                      isActive: diff.path == activeDiffId,
                      isPreview: diff.path == previewDiffId,
                      isDiff: true,
                    ),
                ],
              ),
            ),
          ),
          const _VerticalDivider(),
          Hoverable(
            key: const ValueKey('quick_open_trigger'),
            onTap: () => showQuickOpen(context, workspaceId),
            builder: (context, hover) => Tooltip(
              message: Locales.Editor.QuickOpen.tooltip,
              child: Container(
                height: 26,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: hover ? AppColors.glassHover : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Symbols.search, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text('⌘P', style: AppTypography.terminalCode.copyWith(fontSize: 10, color: AppColors.outline)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: AppColors.outlineVariant,
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.keyName,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.enabled = true,
    this.badge,
  });

  final String keyName;
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool enabled;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final Color fg;
    if (!enabled) {
      fg = AppColors.onSurfaceVariant.withValues(alpha: 0.35);
    } else if (isActive) {
      fg = AppColors.onPrimaryContainer;
    } else {
      fg = AppColors.onSurfaceVariant;
    }

    final content = Container(
      key: ValueKey(keyName),
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: isActive ? AppColors.brandIndigo : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isActive ? AppColors.onPrimaryContainer.withValues(alpha: 0.22) : AppColors.glassHover,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Text(badge!, style: AppTypography.navTab.copyWith(fontSize: 9.5, color: fg)),
            ),
          ],
        ],
      ),
    );

    final tooltipped = Tooltip(message: label, child: content);

    if (!enabled) {
      return Opacity(opacity: 1, child: tooltipped);
    }
    return Hoverable(onTap: onTap, builder: (context, hover) => tooltipped);
  }
}
