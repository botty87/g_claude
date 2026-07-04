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
import '../../../editor/presentation/cubit/editor_view_cubit.dart';
import '../../../editor/presentation/cubit/file_tabs_cubit.dart';
import '../../../editor/presentation/widgets/file_tab.dart';
import '../../../editor/presentation/widgets/file_viewer.dart';
import '../../../workspace/domain/entities/workspace.dart';

/// "Peek" sheet: an editor panel that rises over the chat so a file can be
/// glanced at without leaving the conversation. Promote to full context or
/// dismiss (× / drag the handle down). Shares the open-files set with the
/// full Code view.
class PeekSheet extends HookWidget {
  const PeekSheet({super.key, required this.workspaceId, required this.onResizeDrag});

  final WorkspaceId workspaceId;

  /// Called on each vertical drag delta of the handle (dy > 0 = downward).
  final ValueChanged<double> onResizeDrag;

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

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.glassBorder, width: 1)),
        boxShadow: [BoxShadow(color: Color(0x99000000), blurRadius: 40, offset: Offset(0, -18))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (d) => onResizeDrag(d.delta.dy),
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeUpDown,
              child: SizedBox(
                height: 24,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 34,
            decoration: const BoxDecoration(
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
                            key: ValueKey('peek-tab-$path'),
                            workspaceId: workspaceId,
                            path: path,
                            isActive: !showingDiff && path == activePath,
                            isPreview: path == previewPath,
                          ),
                        for (final diff in openDiffs)
                          FileTab(
                            key: ValueKey('peek-diff-tab-${diff.path}'),
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
                const SizedBox(width: AppSpacing.sm),
                Hoverable(
                  onTap: () => context.read<EditorViewCubit>().promoteToFull(workspaceId),
                  builder: (context, hover) => Container(
                    key: const ValueKey('peek_open_full'),
                    height: 26,
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    decoration: BoxDecoration(
                      color: AppColors.brandIndigo,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Symbols.open_in_full, size: 13, color: AppColors.onPrimaryContainer),
                        const SizedBox(width: 6),
                        Text(
                          Locales.Editor.Peek.openFull,
                          style: AppTypography.navTab.copyWith(color: AppColors.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Hoverable(
                  onTap: () => context.read<EditorViewCubit>().closePeek(workspaceId),
                  builder: (context, hover) => Container(
                    key: const ValueKey('peek_close'),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: hover ? AppColors.glassHover : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Icon(Symbols.close, size: 15, color: AppColors.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
          ),
          const Expanded(child: FileViewer()),
        ],
      ),
    );
  }
}
