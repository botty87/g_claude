import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/slash_command.dart';
import '../../domain/entities/slash_command_source.dart';

class SlashCommandChip extends StatelessWidget {
  const SlashCommandChip({
    super.key,
    required this.command,
    required this.onRemove,
  });

  final SlashCommand command;
  final VoidCallback onRemove;

  Color _color() => switch (command.source) {
        SlashCommandSource.cliBuiltin => AppColors.outline,
        SlashCommandSource.user => AppColors.brandIndigo,
        SlashCommandSource.project => AppColors.tertiary,
        SlashCommandSource.plugin => AppColors.primary,
        SlashCommandSource.skill => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final tooltipMessage = command.argumentHint != null
        ? '${command.description}\nargs: ${command.argumentHint}'
        : command.description;

    return Tooltip(
      message: tooltipMessage,
      waitDuration: const Duration(milliseconds: 400),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        padding: const EdgeInsets.only(
          left: AppSpacing.sm,
          right: AppSpacing.xs,
          top: 2,
          bottom: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              command.trigger,
              style: AppTypography.terminalCode.copyWith(
                fontSize: 12,
                color: color,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            _RemoveButton(color: color, onTap: onRemove),
          ],
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.color, required this.onTap});

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'slashCommands.chip.removeTooltip'.tr(),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(Symbols.close, size: 12, color: color),
          ),
        ),
      ),
    );
  }
}
