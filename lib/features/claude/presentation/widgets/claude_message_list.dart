import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ClaudeMessageList extends StatelessWidget {
  const ClaudeMessageList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: const [
        _ChatBubble(role: _Role.user, text: _ClaudeMockMessages.user),
        SizedBox(height: AppSpacing.xl),
        _ChatBubble(role: _Role.assistant, text: _ClaudeMockMessages.assistant),
      ],
    );
  }
}

enum _Role { user, assistant }

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.role, required this.text});

  final _Role role;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isUser = role == _Role.user;
    final bodyStyle = isUser
        ? AppTypography.terminalCode.copyWith(color: AppColors.onSurface)
        : AppTypography.bodyMain.copyWith(
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BubbleHeader(role: role),
        SizedBox(height: isUser ? AppSpacing.sm : AppSpacing.md),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xl - AppSpacing.xs),
          child: Text(text, style: bodyStyle),
        ),
      ],
    );
  }
}

class _BubbleHeader extends StatelessWidget {
  const _BubbleHeader({required this.role});

  final _Role role;

  @override
  Widget build(BuildContext context) {
    final isUser = role == _Role.user;
    return Row(
      children: [
        Icon(
          isUser ? Icons.chevron_right : Icons.smart_toy_outlined,
          size: 14,
          color: isUser ? AppColors.outline : AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        if (isUser) ...[
          Text(
            'claude.message.userLabel'.tr(),
            style: AppTypography.terminalCode.copyWith(color: AppColors.outline),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'claude.message.promptDelimiter'.tr(),
            style: AppTypography.terminalCode.copyWith(color: AppColors.surfaceVariant),
          ),
        ] else
          Text(
            'claude.message.assistantLabel'.tr(),
            style: AppTypography.terminalPrompt.copyWith(color: AppColors.primary),
          ),
      ],
    );
  }
}

abstract final class _ClaudeMockMessages {
  static const user =
      'Can you analyze the linter rules in analysis_options.yaml and suggest improvements for a stricter typing environment?';
  static const assistant =
      "I've reviewed your analysis_options.yaml. To enforce a stricter typing environment, especially for Dart/Flutter projects, I recommend enabling several key rules under the linter and analyzer sections.";
}
