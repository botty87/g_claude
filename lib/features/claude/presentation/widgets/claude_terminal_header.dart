import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../cubit/claude_sessions_cubit.dart';
import '_enum_ui.dart';
import 'effort_thinking_picker.dart';
import 'mcp_picker.dart';
import 'model_picker.dart';
import 'permission_picker.dart';

class ClaudeTerminalHeader extends StatelessWidget {
  const ClaudeTerminalHeader({
    super.key,
    required this.workspaceId,
    required this.session,
  });

  final String workspaceId;
  final ClaudeSessionData session;

  bool get _isBusy =>
      session.runStatus == ClaudeRunStatus.running ||
      session.runStatus == ClaudeRunStatus.connecting;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ClaudeSessionsCubit>();
    return Container(
      height: AppSpacing.toolbarHeight,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;
          return Row(
            children: [
              Tooltip(
                message: 'claude.terminal.title'.tr(),
                child: const Icon(
                  Icons.terminal,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              ModelPicker(
                current: session.model,
                enabled: !_isBusy,
                onSelected: (m) => cubit.setModel(workspaceId, m),
              ),
              const SizedBox(width: AppSpacing.xs),
              EffortThinkingPicker(
                currentEffort: session.effort,
                currentThinking: session.thinkingMode,
                enabled: !_isBusy,
                onEffortSelected: (e) => cubit.setEffort(workspaceId, e),
                onThinkingSelected: (t) =>
                    cubit.setThinking(workspaceId, t),
              ),
              const SizedBox(width: AppSpacing.xs),
              PermissionPicker(
                current: session.permissionMode,
                enabled: !_isBusy,
                onSelected: (m) => cubit.setPermissionMode(workspaceId, m),
              ),
              const SizedBox(width: AppSpacing.xs),
              McpPicker(workspaceId: workspaceId),
              const Spacer(),
              if (session.messages.isNotEmpty)
                Hoverable(
                  onTap: _isBusy
                      ? null
                      : () => cubit.clearConversation(workspaceId),
                  builder: (context, hover) => Tooltip(
                    message: 'claude.terminal.actions.clear'.tr(),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color:
                            hover ? AppColors.glassHover : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Icon(
                        Symbols.delete_sweep,
                        size: 14,
                        color: _isBusy
                            ? AppColors.outline
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),
              _StatusIndicator(
                status: session.runStatus,
                compact: compact,
              ),
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
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.bodyMain.copyWith(
                color: AppColors.outline,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
