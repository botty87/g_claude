import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

// TODO(claude): replace mock messages with real message stream once subprocess is wired.
class ClaudeMessageList extends StatelessWidget {
  const ClaudeMessageList({super.key});

  static const _mockUserMessage =
      'Can you analyze the linter rules in analysis_options.yaml and suggest improvements for a stricter typing environment?';
  static const _mockAssistantMessage =
      "I've reviewed your analysis_options.yaml. To enforce a stricter typing environment, especially for Dart/Flutter projects, I recommend enabling several key rules under the linter and analyzer sections.";

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: const [
        _UserBubble(text: _mockUserMessage),
        SizedBox(height: AppSpacing.xl),
        _AssistantBubble(text: _mockAssistantMessage),
      ],
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.chevron_right, size: 14, color: AppColors.outline),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'user@workspace',
              style: AppTypography.bodyMain.copyWith(
                color: AppColors.outline,
                fontFamily: 'JetBrains Mono',
                fontSize: 13,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '~',
              style: AppTypography.bodyMain.copyWith(
                color: AppColors.surfaceVariant,
                fontFamily: 'JetBrains Mono',
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xl - AppSpacing.xs),
          child: Text(
            text,
            style: AppTypography.bodyMain.copyWith(
              color: AppColors.onSurface,
              fontFamily: 'JetBrains Mono',
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.smart_toy_outlined,
                size: 14, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'claude',
              style: AppTypography.bodyMain.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontFamily: 'JetBrains Mono',
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xl - AppSpacing.xs),
          child: Text(
            text,
            style: AppTypography.bodyMain.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
