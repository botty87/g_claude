import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/menu_position.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../domain/entities/claude_model.dart';

class ModelPicker extends StatelessWidget {
  const ModelPicker({
    super.key,
    required this.current,
    required this.onSelected,
    this.enabled = true,
  });

  final ClaudeModel current;
  final ValueChanged<ClaudeModel> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: Locales.Claude.Terminal.Model.tooltip,
      child: Hoverable(
        key: const ValueKey('claude_model_picker'),
        onTap: enabled ? () => _showMenu(context) : null,
        builder: (context, hover) {
          return Container(
            height: 24,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: hover ? AppColors.glassHover : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.outlineVariant,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Symbols.smart_toy,
                    size: 12, color: AppColors.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  current.labelKey.tr(),
                  style: AppTypography.bodyMain.copyWith(
                    fontSize: 11,
                    color: enabled
                        ? AppColors.onSurface
                        : AppColors.outline,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(Symbols.expand_more,
                    size: 12, color: AppColors.onSurfaceVariant),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    showMenu<ClaudeModel>(
      context: context,
      position: relativeRectBelow(box),
      color: AppColors.surfaceContainerHigh,
      items: [
        for (final m in ClaudeModel.values)
          PopupMenuItem<ClaudeModel>(
            value: m,
            mouseCursor: SystemMouseCursors.click,
            child: Row(
              children: [
                Icon(
                  m == current ? Symbols.check : Symbols.smart_toy,
                  size: 14,
                  color: m == current
                      ? AppColors.brandIndigo
                      : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  m.labelKey.tr(),
                  style: AppTypography.bodyMain.copyWith(
                    fontSize: 12,
                    fontWeight:
                        m == current ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
      ],
    ).then((value) {
      if (value != null && value != current) onSelected(value);
    });
  }
}
