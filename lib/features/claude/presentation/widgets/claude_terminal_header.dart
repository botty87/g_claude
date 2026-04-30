import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ClaudeTerminalHeader extends StatelessWidget {
  const ClaudeTerminalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.toolbarHeight,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          const Icon(Icons.terminal, size: 14, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'claude.terminal.title'.tr(),
            style: AppTypography.bodyMain.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'claude.terminal.status.connected'.tr(),
            style: AppTypography.bodyMain.copyWith(
              color: AppColors.outline,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
