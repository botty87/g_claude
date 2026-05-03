import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../domain/entities/slash_command.dart';
import '../../domain/entities/slash_command_source.dart';
import 'slash_command_source_color.dart';

class SlashCommandItem extends StatelessWidget {
  const SlashCommandItem({
    super.key,
    required this.command,
    required this.selected,
    required this.onTap,
  });

  final SlashCommand command;
  final bool selected;
  final VoidCallback onTap;

  String _badgeLabel(SlashCommandSource source, BuildContext context) =>
      'slashCommands.source.${source.name}'.tr();

  String _resolveDescription(String description) {
    if (description.startsWith('slashCommands.')) return description.tr();
    return description;
  }

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: onTap,
      builder: (context, hover) => Container(
        height: 44,
        color: selected
            ? AppColors.glassHover
            : hover
                ? AppColors.glassHover.withValues(alpha: 0.5)
                : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            _SourceBadge(
              label: _badgeLabel(command.source, context),
              color: command.source.badgeColor,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Row(
                children: [
                  Text(
                    command.trigger,
                    style: AppTypography.terminalCode.copyWith(
                      fontSize: 13,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _resolveDescription(command.description),
                      style: AppTypography.bodyMain.copyWith(
                        fontSize: 12,
                        color: AppColors.outline,
                      ),
                      overflow: TextOverflow.ellipsis,
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

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(
        label,
        style: AppTypography.navTab.copyWith(
          fontSize: 10,
          color: color,
        ),
      ),
    );
  }
}
