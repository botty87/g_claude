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
    super.key,
  });

  final WorkspaceId workspaceId;
  final String path;
  final bool isActive;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: () => context.read<FileTabsCubit>().setActiveFile(workspaceId, path),
      onDoubleTap: isPreview
          ? () => context.read<FileTabsCubit>().pinFile(workspaceId, path)
          : null,
      builder: (context, hover) {
        final fill = isActive
            ? AppColors.surface
            : hover
                ? AppColors.glassHover
                : Colors.transparent;
        final textColor =
            isActive ? AppColors.onSurface : AppColors.onSurfaceVariant;
        return Container(
          height: AppSpacing.toolbarHeight,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: isActive
                ? const Border(
                    bottom: BorderSide(color: AppColors.brandIndigo, width: 2),
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.description, size: 14, color: textColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                p.basename(path),
                style: AppTypography.navTab.copyWith(
                  color: textColor,
                  fontStyle: isPreview ? FontStyle.italic : FontStyle.normal,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Tooltip(
                message: isActive
                    ? '${Locales.Editor.Tab.close} (⌘W)'
                    : Locales.Editor.Tab.close,
                child: Hoverable(
                  onTap: () => context
                      .read<FileTabsCubit>()
                      .closeFile(workspaceId, path),
                  builder: (context, closeHover) => Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: closeHover
                          ? AppColors.glassHover
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Icon(
                      Symbols.close,
                      size: 14,
                      color:
                          textColor.withValues(alpha: closeHover ? 1.0 : 0.6),
                    ),
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
