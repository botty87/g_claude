import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/slash_command.dart';

class SlashArgumentHintBar extends StatelessWidget {
  const SlashArgumentHintBar({super.key, required this.command});

  final SlashCommand? command;

  @override
  Widget build(BuildContext context) {
    final cmd = command;
    if (cmd == null || cmd.argumentHint == null) return const SizedBox.shrink();

    return Container(
      color: AppColors.surfaceContainer,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        'slashCommands.argumentHint'.tr(namedArgs: {'hint': cmd.argumentHint!}),
        style: AppTypography.bodyMain.copyWith(
          fontSize: 11,
          color: AppColors.outline,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
