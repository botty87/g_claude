import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/claude_model.dart';
import '../cubit/claude_sessions_cubit.dart';
import '_enum_ui.dart';

/// Live run-status dot + label for the active session of [workspaceId].
/// Mounted on the segmented control row (design 1a `• In esecuzione`), it
/// replaces the retired terminal header's status pill.
class SessionStatusIndicator extends StatelessWidget {
  const SessionStatusIndicator({super.key, required this.workspaceId, this.compact = false});

  final String workspaceId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final status = context.select<ClaudeSessionsCubit, ClaudeRunStatus>(
      (c) => c.state.sessionFor(workspaceId)?.runStatus ?? ClaudeRunStatus.idle,
    );
    final label = status.labelKey.tr();
    return Tooltip(
      message: label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
          ),
          if (!compact) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(label, style: AppTypography.bodyMain.copyWith(color: AppColors.outline, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}

/// Circular context-token meter for the active session of [workspaceId].
/// Hidden until the session reports usage. Extracted verbatim from the
/// retired terminal header.
class SessionContextMeter extends StatelessWidget {
  const SessionContextMeter({super.key, required this.workspaceId});

  final String workspaceId;

  static String _fmt(int n) {
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(0)}k';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    // All meter inputs flip together inside a single SessionUsage emit, so
    // splitting them into N selectors buys nothing — collapse into one record
    // select. The record's `==` (structural) is stable when usage is unchanged.
    final usage = context
        .select<
          ClaudeSessionsCubit,
          ({
            bool hasUsage,
            int contextTokens,
            int inputTokens,
            int cacheReadTokens,
            int cacheCreationTokens,
            int outputTokens,
            int limit,
          })
        >((c) {
          final session = c.state.sessionFor(workspaceId);
          final u = session?.usage;
          final model = session?.model ?? ClaudeModel.defaultModel;
          return (
            hasUsage: u != null,
            contextTokens: u?.contextTokens ?? 0,
            inputTokens: u?.inputTokens ?? 0,
            cacheReadTokens: u?.cacheReadTokens ?? 0,
            cacheCreationTokens: u?.cacheCreationTokens ?? 0,
            outputTokens: u?.outputTokens ?? 0,
            limit: model.contextLimit,
          );
        });
    if (!usage.hasUsage) return const SizedBox.shrink();

    final contextTokens = usage.contextTokens;
    final limit = usage.limit;
    final ratio = limit > 0 ? (contextTokens / limit).clamp(0.0, 1.0) : 0.0;
    final pct = (ratio * 100).round();

    final Color color;
    if (ratio < 0.7) {
      color = AppColors.primary;
    } else if (ratio < 0.9) {
      color = AppColors.tertiary;
    } else {
      color = AppColors.error;
    }

    final tooltip = Locales.Claude.Terminal.Context.tooltip(
      input: _fmt(usage.inputTokens),
      cacheRead: _fmt(usage.cacheReadTokens),
      cacheCreation: _fmt(usage.cacheCreationTokens),
      output: _fmt(usage.outputTokens),
      total: _fmt(contextTokens),
      limit: _fmt(limit),
      pct: '$pct',
    );

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 22,
        height: 22,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox.expand(
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.outlineVariant),
                backgroundColor: Colors.transparent,
              ),
            ),
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: ratio == 0 ? 0.0001 : ratio,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(color),
                backgroundColor: Colors.transparent,
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '$pct',
              style: AppTypography.bodyMain.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 8,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
