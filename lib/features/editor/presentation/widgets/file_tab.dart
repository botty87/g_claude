import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../cubit/file_tabs_cubit.dart';

class FileTab extends StatelessWidget {
  const FileTab({
    required this.workspaceId,
    required this.path,
    required this.isActive,
    required this.isPreview,
    this.isDiff = false,
    super.key,
  });

  final WorkspaceId workspaceId;
  final String path;
  final bool isActive;
  final bool isPreview;

  /// A diff tab (git changes) instead of a file editor tab: different icon,
  /// a "DIFF" badge, and it is not reorderable (no drag).
  final bool isDiff;

  @override
  Widget build(BuildContext context) {
    final tab = _TabBody(
      workspaceId: workspaceId,
      path: path,
      isActive: isActive,
      isPreview: isPreview,
      isDiff: isDiff,
    );

    // Diff tabs and preview tabs are not draggable/reorderable.
    if (isPreview || isDiff) {
      return tab;
    }

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        if (details.data == path) return false;
        final files = context.read<FileTabsCubit>().state.filesFor(workspaceId);
        if (files == null) return false;
        if (files.previewPath == details.data) return false;
        return files.openPaths.contains(details.data);
      },
      onAcceptWithDetails: (details) {
        context.read<FileTabsCubit>().reorderPinned(workspaceId, details.data, path);
      },
      builder: (context, candidate, rejected) {
        final hovering = candidate.isNotEmpty;
        return Draggable<String>(
          data: path,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.85,
              child: _TabBody(
                workspaceId: workspaceId,
                path: path,
                isActive: isActive,
                isPreview: false,
                interactive: false,
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: tab),
          child: Stack(
            children: [
              tab,
              if (hovering)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: AppColors.brandIndigo, width: 1.5)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({
    required this.workspaceId,
    required this.path,
    required this.isActive,
    required this.isPreview,
    this.isDiff = false,
    this.interactive = true,
  });

  final WorkspaceId workspaceId;
  final String path;
  final bool isActive;
  final bool isPreview;
  final bool isDiff;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: !interactive
          ? null
          : isDiff
          ? () => context.read<FileTabsCubit>().setActiveDiff(workspaceId, path)
          : () => context.read<FileTabsCubit>().setActiveFile(workspaceId, path),
      onDoubleTap: !(interactive && isPreview)
          ? null
          : isDiff
          ? () => context.read<FileTabsCubit>().pinDiff(workspaceId, path)
          : () => context.read<FileTabsCubit>().pinFile(workspaceId, path),
      builder: (context, hover) {
        final fill = isActive
            ? AppColors.surface
            : hover
            ? AppColors.glassHover
            : Colors.transparent;
        final textColor = isActive ? AppColors.onSurface : AppColors.onSurfaceVariant;
        return Container(
          height: AppSpacing.toolbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          // Flat VS Code-style tab (design 11a): active accent is a 2px bar on
          // TOP, tabs are separated by a thin right divider (no rounded pills).
          // The inactive top border is transparent so the content never shifts.
          decoration: BoxDecoration(
            color: fill,
            border: Border(
              top: BorderSide(color: isActive ? AppColors.brandIndigo : Colors.transparent, width: 2),
              right: const BorderSide(color: AppColors.glassBorder, width: 1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDiff ? Symbols.difference : Symbols.description,
                size: 14,
                color: isDiff ? AppColors.secondary : textColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                p.basename(path),
                style: AppTypography.navTab.copyWith(
                  color: textColor,
                  fontStyle: isPreview ? FontStyle.italic : FontStyle.normal,
                ),
              ),
              if (isDiff) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.brandIndigo.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Text(
                    Locales.Editor.Diff.badge,
                    style: AppTypography.navTab.copyWith(fontSize: 9.5, color: AppColors.primary),
                  ),
                ),
              ],
              const SizedBox(width: AppSpacing.sm),
              if (interactive)
                Tooltip(
                  message: isActive ? '${Locales.Editor.Tab.close} (⌘W)' : Locales.Editor.Tab.close,
                  child: Hoverable(
                    onTap: () => isDiff
                        ? context.read<FileTabsCubit>().closeDiff(workspaceId, path)
                        : context.read<FileTabsCubit>().closeFile(workspaceId, path),
                    builder: (context, closeHover) => Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: closeHover ? AppColors.glassHover : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Icon(Symbols.close, size: 14, color: textColor.withValues(alpha: closeHover ? 1.0 : 0.6)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
