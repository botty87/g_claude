import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../domain/entities/claude_effort.dart';
import '../../domain/entities/claude_model.dart';
import '../../domain/entities/claude_permission_mode.dart';
import '../../domain/entities/claude_thinking_mode.dart';
import '../cubit/claude_sessions_cubit.dart';
import '_enum_ui.dart';
import 'effort_thinking_picker.dart';
import 'mcp_picker.dart';
import 'model_picker.dart';
import 'permission_picker.dart';

class ClaudeTerminalHeader extends StatelessWidget {
  const ClaudeTerminalHeader({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClaudeSessionsCubit>();
    final runStatus = context.select<ClaudeSessionsCubit, ClaudeRunStatus>(
      (c) => c.state.sessions[workspaceId]?.runStatus ?? ClaudeRunStatus.idle,
    );
    final model = context.select<ClaudeSessionsCubit, ClaudeModel>(
      (c) => c.state.sessions[workspaceId]?.model ?? ClaudeModel.defaultModel,
    );
    final effort = context.select<ClaudeSessionsCubit, ClaudeEffort>(
      (c) => c.state.sessions[workspaceId]?.effort ?? ClaudeEffort.defaultEffort,
    );
    final thinkingMode = context.select<ClaudeSessionsCubit, ClaudeThinkingMode>(
      (c) => c.state.sessions[workspaceId]?.thinkingMode ?? ClaudeThinkingMode.defaultMode,
    );
    final permissionMode = context.select<ClaudeSessionsCubit, ClaudePermissionMode>(
      (c) => c.state.sessions[workspaceId]?.permissionMode ?? ClaudePermissionMode.defaultChoice,
    );
    final hasMessages = context.select<ClaudeSessionsCubit, bool>(
      (c) => (c.state.sessions[workspaceId]?.messages.isNotEmpty) ?? false,
    );

    final isBusy =
        runStatus == ClaudeRunStatus.running ||
        runStatus == ClaudeRunStatus.connecting ||
        runStatus == ClaudeRunStatus.compacting;

    return Container(
      height: AppSpacing.toolbarHeight,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;
          return Row(
            children: [
              Tooltip(
                message: Locales.Claude.Terminal.title,
                child: const Icon(Icons.terminal, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ModelPicker(current: model, enabled: !isBusy, onSelected: (m) => cubit.setModel(workspaceId, m)),
                      const SizedBox(width: AppSpacing.xs),
                      EffortThinkingPicker(
                        currentEffort: effort,
                        currentThinking: thinkingMode,
                        enabled: !isBusy,
                        onEffortSelected: (e) => cubit.setEffort(workspaceId, e),
                        onThinkingSelected: (t) => cubit.setThinking(workspaceId, t),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      PermissionPicker(
                        current: permissionMode,
                        enabled: !isBusy,
                        onSelected: (m) => cubit.setPermissionMode(workspaceId, m),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      McpPicker(workspaceId: workspaceId),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (hasMessages)
                Hoverable(
                  onTap: isBusy ? null : () => cubit.newSession(workspaceId),
                  builder: (context, hover) => Tooltip(
                    message: Locales.Claude.Terminal.Actions.newSession,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: hover ? AppColors.glassHover : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Icon(
                        Symbols.add_comment,
                        size: 14,
                        color: isBusy ? AppColors.outline : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),
              _ContextMeter(workspaceId: workspaceId),
              const SizedBox(width: AppSpacing.sm),
              _StatusIndicator(status: runStatus, compact: compact),
            ],
          );
        },
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.status, this.compact = false});

  final ClaudeRunStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
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

class _ContextMeter extends StatelessWidget {
  const _ContextMeter({required this.workspaceId});

  final String workspaceId;

  static String _fmt(int n) {
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(0)}k';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    // All meter inputs flip together inside a single SessionUsage emit, so
    // splitting them into N selectors buys nothing — collapse into one
    // record select. The record's `==` (structural) is stable when usage is
    // unchanged, so this still avoids unnecessary rebuilds.
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
          final session = c.state.sessions[workspaceId];
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
    final inputTokens = usage.inputTokens;
    final cacheReadTokens = usage.cacheReadTokens;
    final cacheCreationTokens = usage.cacheCreationTokens;
    final outputTokens = usage.outputTokens;
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
      input: _fmt(inputTokens),
      cacheRead: _fmt(cacheReadTokens),
      cacheCreation: _fmt(cacheCreationTokens),
      output: _fmt(outputTokens),
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
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: 2,
                valueColor: const AlwaysStoppedAnimation(AppColors.outlineVariant),
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
