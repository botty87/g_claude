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
import '../../../claude/presentation/widgets/claude_terminal_pane.dart';
import '../../../editor/presentation/cubit/editor_view_cubit.dart';
import '../../../editor/presentation/cubit/file_tabs_cubit.dart';
import '../../../editor/presentation/widgets/file_tab.dart';
import '../../../editor/presentation/widgets/file_viewer.dart';
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
    final openCount = context.select<FileTabsCubit, int>((c) => c.state.filesFor(activeId)?.openPaths.length ?? 0);
    final hasFiles = openCount > 0;
    // Code is only reachable with at least one open file.
    final effectiveView = (view == CenterView.code && !hasFiles) ? CenterView.chat : view;

    return Column(
      children: [
        _Segmented(
          current: effectiveView,
          codeCount: openCount,
          codeEnabled: hasFiles,
          onSelect: (v) => context.read<EditorViewCubit>().setView(activeId, v),
        ),
        Expanded(
          child: switch (effectiveView) {
            CenterView.chat => _ChatSurface(workspaceId: activeId, peekOpen: peekOpen && hasFiles),
            CenterView.code => _CodeView(workspaceId: activeId),
            CenterView.terminal => const TerminalPane(),
          },
        ),
      ],
    );
  }
}

/// Chat with an optional peek sheet docked below it. The chat keeps the top
/// portion (input bar stays reachable); the peek fills the bottom and is
/// resized by dragging its handle.
class _ChatSurface extends HookWidget {
  const _ChatSurface({required this.workspaceId, required this.peekOpen});

  final WorkspaceId workspaceId;
  final bool peekOpen;

  static const _minFraction = 0.25;
  static const _maxFraction = 0.75;

  @override
  Widget build(BuildContext context) {
    final fraction = useState(0.56);
    if (!peekOpen) return const ClaudeTerminalPane();
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxHeight;
        final peekHeight = total * fraction.value;
        return Column(
          children: [
            const Expanded(child: ClaudeTerminalPane()),
            SizedBox(
              height: peekHeight,
              child: PeekSheet(
                workspaceId: workspaceId,
                onResizeDrag: (dy) {
                  if (total <= 0) return;
                  fraction.value = (fraction.value - dy / total).clamp(_minFraction, _maxFraction);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.current, required this.codeCount, required this.codeEnabled, required this.onSelect});

  final CenterView current;
  final int codeCount;
  final bool codeEnabled;
  final ValueChanged<CenterView> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      alignment: Alignment.centerLeft,
      child: Container(
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
              isActive: current == CenterView.code,
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
          const SizedBox(width: 6),
          Text(label, style: AppTypography.navTab.copyWith(color: fg)),
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

    if (!enabled) {
      return Opacity(opacity: 1, child: content);
    }
    return Hoverable(onTap: onTap, builder: (context, hover) => content);
  }
}

class _CodeView extends HookWidget {
  const _CodeView({required this.workspaceId});

  final WorkspaceId workspaceId;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final openPaths = context.select<FileTabsCubit, List<String>>(
      (c) => c.state.filesFor(workspaceId)?.openPaths ?? const [],
    );
    final activePath = context.select<FileTabsCubit, String?>((c) => c.state.filesFor(workspaceId)?.activePath);
    final previewPath = context.select<FileTabsCubit, String?>((c) => c.state.filesFor(workspaceId)?.previewPath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: AppSpacing.toolbarHeight,
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
                          isActive: path == activePath,
                          isPreview: path == previewPath,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
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
              const SizedBox(width: AppSpacing.md),
            ],
          ),
        ),
        const Expanded(child: FileViewer()),
      ],
    );
  }
}
