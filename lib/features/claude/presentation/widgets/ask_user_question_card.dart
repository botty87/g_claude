import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/claude_event.dart';
import '../../domain/entities/claude_message.dart';

/// Inline card asking the user to answer one or more `AskUserQuestion`
/// questions emitted by Claude. After submission, collapses to show the
/// chosen answers (read-only).
class AskUserQuestionCard extends HookWidget {
  const AskUserQuestionCard({
    super.key,
    required this.message,
    required this.onSubmit,
  });

  final ClaudeMessageAskUserQuestion message;
  final void Function(Map<String, String> answers) onSubmit;

  @override
  Widget build(BuildContext context) {
    if (message.answered) {
      return _AnsweredView(message: message);
    }
    return _ActiveView(
      key: ValueKey('ask_user_question_card_${message.id}'),
      questions: message.questions,
      onSubmit: onSubmit,
    );
  }
}

class _ActiveView extends HookWidget {
  const _ActiveView({
    super.key,
    required this.questions,
    required this.onSubmit,
  });

  final List<AskUserQuestionItem> questions;
  final void Function(Map<String, String> answers) onSubmit;

  @override
  Widget build(BuildContext context) {
    final stepIndex = useState(0);
    final answers = useState(<String, String>{});
    final useOther = useState(<String, bool>{});
    final otherController = useTextEditingController();

    final current = questions[stepIndex.value];
    final isLast = stepIndex.value == questions.length - 1;

    void selectOption(String label) {
      answers.value = {...answers.value, current.question: label};
      useOther.value = {...useOther.value, current.question: false};
    }

    void toggleOther() {
      final next = !(useOther.value[current.question] ?? false);
      useOther.value = {...useOther.value, current.question: next};
      if (next) {
        otherController.text = answers.value[current.question] ?? '';
      }
    }

    void commitOtherAndAdvance() {
      final text = otherController.text.trim();
      if (text.isEmpty) return;
      answers.value = {...answers.value, current.question: text};
      otherController.clear();
      if (isLast) {
        onSubmit(answers.value);
      } else {
        stepIndex.value += 1;
        useOther.value = {...useOther.value, current.question: false};
      }
    }

    final hasAnswer = (answers.value[current.question]?.isNotEmpty ?? false) ||
        ((useOther.value[current.question] ?? false) &&
            otherController.text.trim().isNotEmpty);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
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
                Symbols.help,
                size: 16,
                color: AppColors.primary,
                fill: 1,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  current.header.isNotEmpty
                      ? current.header
                      : Locales.Claude.AskUser.title,
                  style: AppTypography.bodyMain.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (questions.length > 1)
                Text(
                  Locales.Claude.AskUser.stepCounter(
                    current: '${stepIndex.value + 1}',
                    total: '${questions.length}',
                  ),
                  style: AppTypography.bodyMain.copyWith(
                    color: AppColors.outline,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            current.question,
            style: AppTypography.bodyMain.copyWith(
              color: AppColors.onSurface,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          if (current.multiSelect)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                Locales.Claude.AskUser.multiSelectHint,
                style: AppTypography.bodyMain.copyWith(
                  color: AppColors.outline,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          ...current.options.map(
            (opt) => _OptionTile(
              option: opt,
              selected: answers.value[current.question] == opt.label &&
                  !(useOther.value[current.question] ?? false),
              onTap: () => selectOption(opt.label),
            ),
          ),
          _OptionTile(
            option: const AskUserQuestionOption(label: ''),
            selected: useOther.value[current.question] ?? false,
            onTap: toggleOther,
            customLabel: Locales.Claude.AskUser.otherOption,
          ),
          if (useOther.value[current.question] ?? false) ...[
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: otherController,
              autofocus: true,
              style: AppTypography.bodyMain.copyWith(
                color: AppColors.onSurface,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: Locales.Claude.AskUser.otherPlaceholder,
                hintStyle: AppTypography.bodyMain.copyWith(
                  color: AppColors.outline,
                  fontSize: 13,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              onSubmitted: (_) => commitOtherAndAdvance(),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (stepIndex.value > 0)
                TextButton(
                  onPressed: () => stepIndex.value -= 1,
                  child: Text(Locales.Claude.AskUser.back),
                ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                key: const ValueKey('ask_user_question_submit'),
                onPressed: hasAnswer
                    ? () {
                        if (useOther.value[current.question] ?? false) {
                          commitOtherAndAdvance();
                          return;
                        }
                        if (isLast) {
                          onSubmit(answers.value);
                        } else {
                          stepIndex.value += 1;
                        }
                      }
                    : null,
                child: Text(
                  isLast
                      ? Locales.Claude.AskUser.submit
                      : Locales.Claude.AskUser.next,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
    this.customLabel,
  });

  final AskUserQuestionOption option;
  final bool selected;
  final VoidCallback onTap;
  final String? customLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surfaceContainerLow.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.7)
                  : AppColors.outlineVariant.withValues(alpha: 0.4),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Symbols.radio_button_checked
                    : Symbols.radio_button_unchecked,
                size: 16,
                color: selected ? AppColors.primary : AppColors.outline,
                fill: selected ? 1 : 0,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customLabel ?? option.label,
                      style: AppTypography.bodyMain.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (option.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          option.description,
                          style: AppTypography.bodyMain.copyWith(
                            color: AppColors.outline,
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnsweredView extends StatelessWidget {
  const _AnsweredView({required this.message});

  final ClaudeMessageAskUserQuestion message;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Symbols.check_circle,
                size: 14,
                color: AppColors.primary,
                fill: 1,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                Locales.Claude.AskUser.answeredLabel,
                style: AppTypography.bodyMain.copyWith(
                  color: AppColors.outline,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final q in message.questions)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: RichText(
                text: TextSpan(
                  style: AppTypography.bodyMain.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: '${q.question}  '),
                    TextSpan(
                      text: message.answers[q.question] ?? '—',
                      style: AppTypography.bodyMain.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
