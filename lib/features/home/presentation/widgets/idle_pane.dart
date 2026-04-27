import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/glass/glass_pane.dart';

/// Right-hand watermark pane shown when no secondary view is active.
class IdlePane extends StatelessWidget {
  const IdlePane({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      child: Center(
        child: Opacity(
          opacity: 0.2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.terminal, size: 64, color: Colors.white.withValues(alpha: 0.5)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Waiting for output...',
                style: AppTypography.terminalPrompt.copyWith(
                  fontSize: 18,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
