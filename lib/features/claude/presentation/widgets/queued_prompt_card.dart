import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/queued_prompt.dart';
import '../cubit/claude_sessions_cubit.dart';

class QueuedPromptCard extends HookWidget {
  const QueuedPromptCard({super.key, required this.workspaceId});

  final String workspaceId;

  @override
  Widget build(BuildContext context) {
    final queued = context.select<ClaudeSessionsCubit, QueuedPrompt?>(
      (c) => c.state.sessions[workspaceId]?.queuedPrompt,
    );
    final status = context.select<ClaudeSessionsCubit, ClaudeRunStatus>(
      (c) => c.state.sessions[workspaceId]?.runStatus ?? ClaudeRunStatus.idle,
    );
    final isBusy = status == ClaudeRunStatus.connecting ||
        status == ClaudeRunStatus.running;

    final controller = useTextEditingController(text: queued?.text ?? '');
    final cubit = context.read<ClaudeSessionsCubit>();

    useEffect(() {
      final t = queued?.text ?? '';
      if (controller.text != t) {
        controller.value = TextEditingValue(
          text: t,
          selection: TextSelection.collapsed(offset: t.length),
        );
      }
      return null;
    }, [queued?.text]);

    useEffect(() {
      void listener() {
        final current = cubit.state.sessions[workspaceId]?.queuedPrompt;
        if (current == null) return;
        if (controller.text == current.text) return;
        cubit.setQueuedPrompt(workspaceId, controller.text);
      }
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    if (queued == null || !isBusy) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: const Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Symbols.schedule,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            Locales.Claude.Terminal.Input.Queue.label,
            style: AppTypography.terminalCode.copyWith(
              color: AppColors.outline,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              key: const ValueKey('claude_queued_prompt_field'),
              controller: controller,
              maxLines: 3,
              minLines: 1,
              style: AppTypography.terminalCode.copyWith(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 2),
                border: InputBorder.none,
                hintText: Locales.Claude.Terminal.Input.Queue.editPlaceholder,
                hintStyle: AppTypography.terminalCode.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: IconButton(
              key: const ValueKey('claude_queued_prompt_remove'),
              icon: const Icon(Symbols.close, size: 16),
              color: AppColors.outline,
              tooltip: Locales.Claude.Terminal.Input.Queue.removeTooltip,
              visualDensity: VisualDensity.compact,
              onPressed: () => cubit.clearQueuedPrompt(workspaceId),
            ),
          ),
        ],
      ),
    );
  }
}
