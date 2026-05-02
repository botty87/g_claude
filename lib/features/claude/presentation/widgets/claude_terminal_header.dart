import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../cubit/claude_sessions_cubit.dart';
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
      child: Row(
        children: [
          const Icon(Icons.terminal, size: 14, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'claude.terminal.title'.tr(),
            style: AppTypography.bodyMain.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          ModelPicker(
            current: session.model,
            enabled: !_isBusy,
            onSelected: (m) => cubit.setModel(workspaceId, m),
          ),
          const SizedBox(width: AppSpacing.sm),
          PermissionPicker(
            current: session.permissionMode,
            enabled: !_isBusy,
            onSelected: (m) => cubit.setPermissionMode(workspaceId, m),
          ),
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
                    color: hover ? AppColors.glassHover : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
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
          _StatusIndicator(status: session.runStatus),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.status});

  final ClaudeRunStatus status;

  Color get _color {
    switch (status) {
      case ClaudeRunStatus.idle:
        return AppColors.outline;
      case ClaudeRunStatus.connecting:
        return AppColors.tertiary;
      case ClaudeRunStatus.running:
        return AppColors.secondary;
      case ClaudeRunStatus.error:
        return AppColors.error;
      case ClaudeRunStatus.sessionDead:
        return AppColors.error;
    }
  }

  String get _labelKey {
    switch (status) {
      case ClaudeRunStatus.idle:
        return 'claude.terminal.status.idle';
      case ClaudeRunStatus.connecting:
        return 'claude.terminal.status.connecting';
      case ClaudeRunStatus.running:
        return 'claude.terminal.status.running';
      case ClaudeRunStatus.error:
        return 'claude.terminal.status.error';
      case ClaudeRunStatus.sessionDead:
        return 'claude.terminal.status.sessionDead';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          _labelKey.tr(),
          style: AppTypography.bodyMain.copyWith(
            color: AppColors.outline,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
