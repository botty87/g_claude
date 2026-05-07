import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/slash_command.dart';
import 'slash_command_chip.dart';

class SlashCommandChipRow extends StatelessWidget {
  const SlashCommandChipRow({super.key, required this.chips, required this.onRemove});

  final List<SlashCommand> chips;
  final ValueChanged<SlashCommand> onRemove;

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          for (final cmd in chips)
            SlashCommandChip(key: ValueKey('chip_${cmd.trigger}'), command: cmd, onRemove: () => onRemove(cmd)),
        ],
      ),
    );
  }
}
