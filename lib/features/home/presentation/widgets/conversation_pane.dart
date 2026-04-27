import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass/glass_pane.dart';

/// Active conversation pane: user message → Claude response with diff code block
/// → input bar. Content is hardcoded for now and will move to bloc state later.
class ConversationPane extends StatelessWidget {
  const ConversationPane({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      isActive: true,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: const [
                _UserMessage(text: '> Refactor the calculate_metrics function in main.py to be more efficient and handle edge cases better.'),
                SizedBox(height: AppSpacing.xl),
                _ClaudeMessage(),
              ],
            ),
          ),
          const _CommandInputBar(),
        ],
      ),
    );
  }
}

class _UserMessage extends StatelessWidget {
  const _UserMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(
          background: AppColors.primaryContainer.withValues(alpha: 0.2),
          border: AppColors.primary.withValues(alpha: 0.3),
          child: const Icon(Symbols.person, size: 14, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You',
                style: AppTypography.terminalPrompt.copyWith(color: AppColors.primary.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(text, style: AppTypography.terminalPrompt.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClaudeMessage extends StatelessWidget {
  const _ClaudeMessage();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(
          background: AppColors.surfaceContainerHigh,
          border: AppColors.glassBorder,
          child: const Text('C', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Claude',
                style: AppTypography.terminalPrompt.copyWith(color: Colors.white.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "I'll refactor `calculate_metrics` to improve efficiency by using vectorized numpy operations instead of list comprehensions, and add proper handling for empty input arrays.",
                style: AppTypography.bodyMain.copyWith(color: Colors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: AppSpacing.md),
              const _CodeBlock(),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Would you like me to apply these changes directly to `main.py`?',
                style: AppTypography.bodyMain.copyWith(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.background, required this.border, required this.child});

  final Color background;
  final Color border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: child,
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock();

  // Hardcoded diff lines: `null` color = removed (error/red), secondary = added.
  static const _lines = <(_DiffKind, String)>[
    (_DiffKind.removed, '- def calculate_metrics(data):'),
    (_DiffKind.removed, '-     if not data: return 0'),
    (_DiffKind.removed, '-     return sum([x*2 for x in data]) / len(data)'),
    (_DiffKind.spacer, ''),
    (_DiffKind.added, '+ import numpy as np'),
    (_DiffKind.added, '+'),
    (_DiffKind.added, '+ def calculate_metrics(data: np.ndarray) -> float:'),
    (_DiffKind.added, '+     """Calculate core metrics efficiently."""'),
    (_DiffKind.added, '+     if data is None or len(data) == 0:'),
    (_DiffKind.added, '+         return 0.0'),
    (_DiffKind.added, '+     return float(np.mean(data * 2))'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x4D000000), // black 30%
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg + 8, AppSpacing.lg, AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _lines.map(_buildLine).toList(),
            ),
          ),
          Positioned(top: 0, right: 0, child: _CodeBlockHeader()),
        ],
      ),
    );
  }

  Widget _buildLine((_DiffKind, String) entry) {
    final (kind, line) = entry;
    final style = switch (kind) {
      _DiffKind.removed => AppTypography.terminalCode.copyWith(
        color: AppColors.error.withValues(alpha: 0.7),
        decoration: TextDecoration.lineThrough,
        decorationColor: AppColors.error.withValues(alpha: 0.7),
      ),
      _DiffKind.added => AppTypography.terminalCode.copyWith(
        color: AppColors.secondary.withValues(alpha: 0.9),
      ),
      _DiffKind.spacer => AppTypography.terminalCode,
    };
    return Text(line.isEmpty ? ' ' : line, style: style);
  }
}

enum _DiffKind { removed, added, spacer }

class _CodeBlockHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.glassActive,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(4),
          topRight: Radius.circular(6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'python',
            style: AppTypography.bodyMain.copyWith(fontSize: 10, color: Colors.white.withValues(alpha: 0.5)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(Symbols.content_copy, size: 12, color: Colors.white.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}

class _CommandInputBar extends StatelessWidget {
  const _CommandInputBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
        border: const Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer.withValues(alpha: 0.5),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(AppRadii.md - 2),
        ),
        child: Row(
          children: [
            Icon(Symbols.auto_awesome, size: 18, color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Text(
                    'Ask Claude...',
                    style: AppTypography.terminalPrompt.copyWith(color: Colors.white.withValues(alpha: 0.45)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 90),
                    child: _BlinkingCursor(),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.glassHover,
                border: Border.all(color: AppColors.glassBorder),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '⌘ ↵',
                style: AppTypography.bodyMain.copyWith(fontSize: 10, color: Colors.white.withValues(alpha: 0.3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final visible = _ctrl.value < 0.5;
        return Container(
          width: 8,
          height: 14,
          color: visible ? AppColors.primary.withValues(alpha: 0.8) : Colors.transparent,
        );
      },
    );
  }
}
