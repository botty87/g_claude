import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../domain/entities/workspace.dart';

class WorkspaceTab extends StatelessWidget {
  const WorkspaceTab({
    super.key,
    required this.workspace,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  final Workspace workspace;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: onTap,
      builder: (context, hover) {
        final fill = isActive
            ? AppColors.glassActive
            : hover
                ? AppColors.glassHover
                : Colors.transparent;
        final textColor = isActive ? AppColors.onSurface : AppColors.onSurfaceVariant;
        return Container(
          height: AppSpacing.toolbarHeight,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: isActive
                ? const Border(bottom: BorderSide(color: AppColors.brandIndigo, width: 2))
                : null,
          ),
          child: Row(
            children: [
              Icon(Symbols.folder, size: 14, color: textColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                workspace.name,
                style: AppTypography.navTab.copyWith(color: textColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Hoverable(
                onTap: onClose,
                builder: (context, closeHover) => Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: closeHover ? AppColors.glassHover : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(
                    Symbols.close,
                    size: 14,
                    color: textColor.withValues(alpha: closeHover ? 1.0 : 0.6),
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
