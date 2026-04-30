import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ClaudeInputBar extends HookWidget {
  const ClaudeInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.chevron_right,
                size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: false,
              style: AppTypography.bodyMain.copyWith(
                color: AppColors.onSurface,
                fontFamily: 'JetBrains Mono',
                fontSize: 13,
                height: 1.6,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'claude.terminal.input.placeholder'.tr(),
                hintStyle: AppTypography.bodyMain.copyWith(
                  color: AppColors.outline,
                  fontFamily: 'JetBrains Mono',
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
