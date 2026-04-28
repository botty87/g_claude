import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/workspace.dart';

class WorkspaceTab extends StatefulWidget {
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
  State<WorkspaceTab> createState() => _WorkspaceTabState();
}

class _WorkspaceTabState extends State<WorkspaceTab> {
  bool _hover = false;
  bool _hoverClose = false;

  @override
  Widget build(BuildContext context) {
    final fill = widget.isActive
        ? AppColors.glassActive
        : _hover
            ? AppColors.glassHover
            : Colors.transparent;
    final textColor = widget.isActive
        ? AppColors.onSurface
        : AppColors.onSurfaceVariant;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: AppSpacing.toolbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: widget.isActive
                ? const Border(bottom: BorderSide(color: AppColors.brandIndigo, width: 2))
                : null,
          ),
          child: Row(
            children: [
              Icon(Symbols.folder, size: 14, color: textColor),
              const SizedBox(width: AppSpacing.sm),
              Text(
                widget.workspace.name,
                style: AppTypography.navTab.copyWith(color: textColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _hoverClose = true),
                onExit: (_) => setState(() => _hoverClose = false),
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _hoverClose ? AppColors.glassHover : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Icon(
                      Symbols.close,
                      size: 14,
                      color: textColor.withValues(alpha: _hoverClose ? 1.0 : 0.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
