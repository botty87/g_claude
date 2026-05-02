import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../cubit/claude_sessions_cubit.dart';

class ClaudeInputBar extends HookWidget {
  const ClaudeInputBar({
    super.key,
    required this.workspaceId,
    required this.status,
  });

  final String workspaceId;
  final ClaudeRunStatus status;

  bool get _isBusy =>
      status == ClaudeRunStatus.connecting ||
      status == ClaudeRunStatus.running;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final focusNode = useFocusNode();
    final cubit = context.read<ClaudeSessionsCubit>();

    void submit() {
      final text = controller.text;
      if (text.trim().isEmpty) return;
      controller.clear();
      cubit.sendPrompt(workspaceId, text);
    }

    KeyEventResult onKey(FocusNode node, KeyEvent event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (HardwareKeyboard.instance.isShiftPressed) {
          return KeyEventResult.ignored;
        }
        if (_isBusy) return KeyEventResult.handled;
        submit();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.period &&
          HardwareKeyboard.instance.isMetaPressed) {
        if (_isBusy) cubit.stopRun();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.chevron_right,
                size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Focus(
              focusNode: focusNode,
              onKeyEvent: onKey,
              child: TextField(
                key: const ValueKey('claude_input_field'),
                controller: controller,
                enabled: !_isBusy,
                maxLines: 6,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: AppTypography.terminalCode.copyWith(
                  color: AppColors.onSurface,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: _isBusy
                      ? 'claude.terminal.input.placeholderRunning'.tr()
                      : 'claude.terminal.input.placeholder'.tr(),
                  hintStyle: AppTypography.terminalCode.copyWith(
                    color: AppColors.outline,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (_isBusy)
            _ActionButton(
              icon: Symbols.stop_circle,
              tooltipKey: 'claude.terminal.input.stop',
              color: AppColors.error,
              onTap: cubit.stopRun,
            )
          else
            _ActionButton(
              icon: Symbols.send,
              tooltipKey: 'claude.terminal.input.send',
              color: AppColors.primary,
              onTap: submit,
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltipKey,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltipKey;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      key: ValueKey('claude_input_${tooltipKey.split('.').last}'),
      onTap: onTap,
      builder: (context, hover) => Tooltip(
        message: tooltipKey.tr(),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: hover ? AppColors.glassHover : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
