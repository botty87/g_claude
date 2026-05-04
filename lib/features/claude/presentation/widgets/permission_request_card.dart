import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/pretty_json.dart';
import '../../domain/entities/claude_message.dart';

/// Inline card asking the user to approve / deny a tool invocation surfaced
/// by the `PreToolUse` permission hook.
class PermissionRequestCard extends HookWidget {
  const PermissionRequestCard({
    super.key,
    required this.message,
    required this.onDecide,
  });

  final ClaudeMessagePermissionRequest message;
  final void Function(ClaudePermissionDecision decision) onDecide;

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);

    if (message.answered) {
      return _AnsweredView(message: message);
    }

    final encodedInput = useMemoized(
      () => message.toolInput.isEmpty
          ? ''
          : prettyJson.convert(message.toolInput),
      [message.toolInput],
    );

    return Container(
      key: ValueKey('permission_request_card_${message.id}'),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.tertiary.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Symbols.shield_question,
                size: 16,
                color: AppColors.tertiary,
                fill: 1,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  Locales.Claude.PermissionRequest.title,
                  style: AppTypography.bodyMain.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Locales.Claude.PermissionRequest.subtitle(tool: message.toolName),
            style: AppTypography.bodyMain.copyWith(
              color: AppColors.onSurface,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (encodedInput.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: () => expanded.value = !expanded.value,
              child: Row(
                children: [
                  Icon(
                    expanded.value ? Symbols.expand_less : Symbols.expand_more,
                    size: 14,
                    color: AppColors.outline,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    Locales.Claude.PermissionRequest.inputLabel,
                    style: AppTypography.bodyMain.copyWith(
                      color: AppColors.outline,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
            if (expanded.value)
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.xs),
                padding: const EdgeInsets.all(AppSpacing.sm),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    encodedInput,
                    style: AppTypography.terminalCode.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 11.5,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => onDecide(ClaudePermissionDecision.deny),
                icon: const Icon(Symbols.block, size: 14, fill: 1),
                label: Text(Locales.Claude.PermissionRequest.deny),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.6),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () =>
                    onDecide(ClaudePermissionDecision.allowAlways),
                child: Text(Locales.Claude.PermissionRequest.allowAlways),
              ),
              FilledButton.icon(
                onPressed: () => onDecide(ClaudePermissionDecision.allowOnce),
                icon: const Icon(Symbols.check, size: 14, fill: 1),
                label: Text(Locales.Claude.PermissionRequest.allowOnce),
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

  final ClaudeMessagePermissionRequest message;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (message.decision) {
      ClaudePermissionDecision.allowOnce => (
          Symbols.check_circle,
          AppColors.primary,
          Locales.Claude.PermissionRequest.answeredAllowOnce,
        ),
      ClaudePermissionDecision.allowAlways => (
          Symbols.check_circle,
          AppColors.primary,
          Locales.Claude.PermissionRequest.answeredAllowAlways,
        ),
      ClaudePermissionDecision.deny => (
          Symbols.block,
          AppColors.error,
          Locales.Claude.PermissionRequest.answeredDeny,
        ),
      null => (Symbols.help, AppColors.outline, '—'),
    };
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color, fill: 1),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${message.toolName}  ',
            style: AppTypography.terminalCode.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodyMain.copyWith(
              color: color,
              fontSize: 11.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
