import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/claude_message.dart';

/// Inline card showing a plan proposed by Claude via ExitPlanMode.
/// The user approves or rejects it; after answering the card collapses
/// to a compact read-only view.
class PlanProposedCard extends HookWidget {
  const PlanProposedCard({super.key, required this.message, required this.onDecide});

  final ClaudeMessagePlan message;
  final void Function(bool approve) onDecide;

  @override
  Widget build(BuildContext context) {
    if (message.answered) {
      return _AnsweredView(message: message);
    }
    return _ActiveView(key: ValueKey('plan_proposed_card_${message.id}'), message: message, onDecide: onDecide);
  }
}

class _ActiveView extends StatelessWidget {
  const _ActiveView({super.key, required this.message, required this.onDecide});

  final ClaudeMessagePlan message;
  final void Function(bool approve) onDecide;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Symbols.assignment, size: 16, color: AppColors.secondary, fill: 1),
              const SizedBox(width: AppSpacing.sm),
              Text(
                Locales.Claude.Plan.title,
                style: AppTypography.bodyMain.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SelectableText(
            message.plan,
            style: AppTypography.bodyMain.copyWith(color: AppColors.onSurface, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                key: const ValueKey('plan_reject'),
                onPressed: () => onDecide(false),
                icon: const Icon(Symbols.close, size: 14, fill: 1),
                label: Text(Locales.Claude.Plan.reject),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.6)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton.icon(
                key: const ValueKey('plan_approve'),
                onPressed: () => onDecide(true),
                icon: const Icon(Symbols.check, size: 14, fill: 1),
                label: Text(Locales.Claude.Plan.approve),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnsweredView extends StatelessWidget {
  const _AnsweredView({required this.message});

  final ClaudeMessagePlan message;

  @override
  Widget build(BuildContext context) {
    final approved = message.approved ?? false;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            approved ? Symbols.check_circle : Symbols.block,
            size: 14,
            color: approved ? AppColors.primary : AppColors.error,
            fill: 1,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            approved ? Locales.Claude.Plan.answeredApproved : Locales.Claude.Plan.answeredRejected,
            style: AppTypography.bodyMain.copyWith(
              color: approved ? AppColors.primary : AppColors.error,
              fontSize: 11.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
