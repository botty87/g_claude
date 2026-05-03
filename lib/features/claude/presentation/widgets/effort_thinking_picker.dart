import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/menu_position.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../domain/entities/claude_effort.dart';
import '../../domain/entities/claude_thinking_mode.dart';

Color _thinkingAccent(ClaudeThinkingMode m) => switch (m) {
  ClaudeThinkingMode.off => AppColors.onSurfaceVariant,
  ClaudeThinkingMode.think => AppColors.trafficMaximize,
  ClaudeThinkingMode.thinkHard => AppColors.trafficMinimize,
  ClaudeThinkingMode.ultrathink => AppColors.trafficClose,
};

class EffortThinkingPicker extends StatelessWidget {
  const EffortThinkingPicker({
    super.key,
    required this.currentEffort,
    required this.currentThinking,
    required this.onEffortSelected,
    required this.onThinkingSelected,
    this.enabled = true,
  });

  final ClaudeEffort currentEffort;
  final ClaudeThinkingMode currentThinking;
  final ValueChanged<ClaudeEffort> onEffortSelected;
  final ValueChanged<ClaudeThinkingMode> onThinkingSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: Locales.Claude.Terminal.Effort.tooltip,
      child: Hoverable(
        key: const ValueKey('claude_effort_thinking_picker'),
        onTap: enabled ? () => _showOverlay(context) : null,
        builder: (context, hover) {
          return Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: hover ? AppColors.glassHover : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.outlineVariant, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Symbols.bolt,
                  size: 12,
                  color: _thinkingAccent(currentThinking),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  currentEffort.labelKey.tr(),
                  style: AppTypography.bodyMain.copyWith(
                    fontSize: 11,
                    color: enabled ? AppColors.onSurface : AppColors.outline,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Symbols.expand_more,
                  size: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showOverlay(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    showMenu<void>(
      context: context,
      position: relativeRectBelow(box),
      color: AppColors.surfaceContainerHigh,
      constraints: const BoxConstraints(minWidth: 320, maxWidth: 360),
      items: [
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _OverlayContent(
            currentEffort: currentEffort,
            currentThinking: currentThinking,
            onEffortSelected: onEffortSelected,
            onThinkingSelected: onThinkingSelected,
          ),
        ),
      ],
    );
  }
}

class _OverlayContent extends HookWidget {
  const _OverlayContent({
    required this.currentEffort,
    required this.currentThinking,
    required this.onEffortSelected,
    required this.onThinkingSelected,
  });

  final ClaudeEffort currentEffort;
  final ClaudeThinkingMode currentThinking;
  final ValueChanged<ClaudeEffort> onEffortSelected;
  final ValueChanged<ClaudeThinkingMode> onThinkingSelected;

  @override
  Widget build(BuildContext context) {
    final effort = useState(currentEffort);
    final thinking = useState(currentThinking);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _SectionLabel(label: Locales.Claude.Terminal.Effort.label),
          const SizedBox(height: AppSpacing.xs),
          _EffortSegments(
            current: effort.value,
            onSelected: (e) {
              effort.value = e;
              onEffortSelected(e);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionLabel(label: Locales.Claude.Terminal.Thinking.label),
          const SizedBox(height: AppSpacing.xs),
          _ThinkingSegments(
            current: thinking.value,
            onSelected: (t) {
              thinking.value = t;
              onThinkingSelected(t);
            },
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTypography.bodyMain.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _EffortSegments extends StatelessWidget {
  const _EffortSegments({required this.current, required this.onSelected});

  final ClaudeEffort current;
  final ValueChanged<ClaudeEffort> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ClaudeEffort.values.map((e) {
        final selected = current == e;
        final isFirst = e == ClaudeEffort.values.first;
        final isLast = e == ClaudeEffort.values.last;
        return Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelected(e),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.brandIndigo.withValues(alpha: 0.25)
                      : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: isFirst
                        ? const Radius.circular(AppRadii.sm)
                        : Radius.zero,
                    right: isLast
                        ? const Radius.circular(AppRadii.sm)
                        : Radius.zero,
                  ),
                  border: Border(
                    top: BorderSide(
                      color: selected
                          ? AppColors.brandIndigo
                          : AppColors.outlineVariant,
                    ),
                    bottom: BorderSide(
                      color: selected
                          ? AppColors.brandIndigo
                          : AppColors.outlineVariant,
                    ),
                    left: BorderSide(
                      color: selected
                          ? AppColors.brandIndigo
                          : AppColors.outlineVariant,
                    ),
                    right: isLast
                        ? BorderSide(
                            color: selected
                                ? AppColors.brandIndigo
                                : AppColors.outlineVariant,
                          )
                        : BorderSide.none,
                  ),
                ),
                child: Center(
                  child: Text(
                    e.labelKey.tr(),
                    style: AppTypography.bodyMain.copyWith(
                      fontSize: 10,
                      color: selected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ThinkingSegments extends StatelessWidget {
  const _ThinkingSegments({required this.current, required this.onSelected});

  final ClaudeThinkingMode current;
  final ValueChanged<ClaudeThinkingMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ClaudeThinkingMode.values.map((t) {
        final selected = current == t;
        final isFirst = t == ClaudeThinkingMode.values.first;
        final isLast = t == ClaudeThinkingMode.values.last;
        final dotColor = _thinkingAccent(t);
        return Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelected(t),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.brandIndigo.withValues(alpha: 0.25)
                      : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: isFirst
                        ? const Radius.circular(AppRadii.sm)
                        : Radius.zero,
                    right: isLast
                        ? const Radius.circular(AppRadii.sm)
                        : Radius.zero,
                  ),
                  border: Border(
                    top: BorderSide(
                      color: selected
                          ? AppColors.brandIndigo
                          : AppColors.outlineVariant,
                    ),
                    bottom: BorderSide(
                      color: selected
                          ? AppColors.brandIndigo
                          : AppColors.outlineVariant,
                    ),
                    left: BorderSide(
                      color: selected
                          ? AppColors.brandIndigo
                          : AppColors.outlineVariant,
                    ),
                    right: isLast
                        ? BorderSide(
                            color: selected
                                ? AppColors.brandIndigo
                                : AppColors.outlineVariant,
                          )
                        : BorderSide.none,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        t.labelKey.tr(),
                        style: AppTypography.bodyMain.copyWith(
                          fontSize: 10,
                          color: selected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

}
