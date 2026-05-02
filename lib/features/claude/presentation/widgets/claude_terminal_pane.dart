import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../cubit/claude_sessions_cubit.dart';
import 'claude_input_bar.dart';
import 'claude_message_list.dart';
import 'claude_terminal_header.dart';

class ClaudeTerminalPane extends StatelessWidget {
  const ClaudeTerminalPane({super.key});

  @override
  Widget build(BuildContext context) {
    final activeId = context.select<WorkspacesCubit, String?>(
      (c) => c.state.activeIdOrNull,
    );

    final session = context.select<ClaudeSessionsCubit, ClaudeSessionData?>(
      (c) => c.state.sessionFor(activeId),
    );

    if (activeId == null || session == null) {
      return const _NoWorkspaceState();
    }

    final isBusy = session.runStatus == ClaudeRunStatus.running ||
        session.runStatus == ClaudeRunStatus.connecting;

    return ColoredBox(
      color: AppColors.surface,
      child: Column(
        children: [
          ClaudeTerminalHeader(workspaceId: activeId, session: session),
          _RunProgressBar(visible: isBusy),
          Expanded(
            child: ClaudeMessageList(
              workspaceId: activeId,
              messages: session.messages,
              status: session.runStatus,
              lastError: session.lastError,
              stderrTail: session.stderrTail,
            ),
          ),
          ClaudeInputBar(workspaceId: activeId, status: session.runStatus),
        ],
      ),
    );
  }
}

class _RunProgressBar extends StatelessWidget {
  const _RunProgressBar({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: visible
          ? const LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: AppColors.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _NoWorkspaceState extends StatelessWidget {
  const _NoWorkspaceState();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'claude.terminal.status.noWorkspace'.tr(),
            style: AppTypography.bodyMain.copyWith(
              color: AppColors.outline,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
