import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/di/di.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../slash_commands/domain/entities/slash_command.dart';
import '../../../slash_commands/presentation/cubit/slash_commands_cubit.dart';
import '../../../slash_commands/presentation/widgets/slash_argument_hint_bar.dart';
import '../../../slash_commands/presentation/widgets/slash_command_overlay.dart';
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
    final wrapperFocus = useFocusNode(debugLabel: 'claude_input_wrapper');
    final inputFocus = useFocusNode(debugLabel: 'claude_input_field');
    final sessionsCubit = context.read<ClaudeSessionsCubit>();

    final slashCubit = useMemoized(
      () => getIt<SlashCommandsCubit>()..loadFor(workspaceId),
      [workspaceId],
    );
    useEffect(() => slashCubit.close, [slashCubit]);

    final link = useMemoized(LayerLink.new, const []);
    final lastInserted = useState<SlashCommand?>(null);

    // Sync skills from sessions state into slash cubit.
    final skills = context.select<ClaudeSessionsCubit, List<String>>(
      (c) => c.state.sessions[workspaceId]?.availableSkills ?? const [],
    );
    useEffect(() {
      slashCubit.updateSkills(skills);
      return null;
    }, [skills]);

    // Forward text changes to slash cubit.
    useEffect(() {
      void listener() => slashCubit.onInputChanged(controller.text);
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    // Clear hint when user edits away from the inserted trigger.
    useEffect(() {
      void listener() {
        final inserted = lastInserted.value;
        if (inserted == null) return;
        final lastLine = controller.text.split('\n').last.trimLeft();
        if (!lastLine.startsWith('${inserted.trigger} ')) {
          lastInserted.value = null;
        }
      }
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    void applySelection(SlashCommand cmd) {
      final lines = controller.text.split('\n');
      final replacement = '${cmd.trigger} ';
      lines[lines.length - 1] = replacement;
      final newText = lines.join('\n');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
      lastInserted.value = cmd;
      slashCubit.dismiss();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        inputFocus.requestFocus();
      });
    }

    void submit() {
      final text = controller.text;
      if (text.trim().isEmpty) return;
      controller.clear();
      lastInserted.value = null;
      sessionsCubit.sendPrompt(workspaceId, text);
    }

    KeyEventResult onKey(FocusNode node, KeyEvent event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;

      final isSuggesting = slashCubit.state is SlashCommandsStateSuggesting;

      if (isSuggesting) {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          slashCubit.moveSelection(1);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          slashCubit.moveSelection(-1);
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.tab ||
            event.logicalKey == LogicalKeyboardKey.enter) {
          final cmd = slashCubit.accept();
          if (cmd != null) {
            applySelection(cmd);
            return KeyEventResult.handled;
          }
          // No match — dismiss overlay and fall through to normal Enter handling.
          slashCubit.dismiss();
        }
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          slashCubit.dismiss();
          return KeyEventResult.handled;
        }
      }

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
        if (_isBusy) sessionsCubit.stopRun();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    return SlashCommandOverlay(
      link: link,
      cubit: slashCubit,
      onAccept: applySelection,
      onDismiss: slashCubit.dismiss,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<SlashCommand?>(
              valueListenable: lastInserted,
              builder: (context, cmd, _) => SlashArgumentHintBar(command: cmd),
            ),
            Container(
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
              child: CompositedTransformTarget(
                link: link,
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
                        focusNode: wrapperFocus,
                        onKeyEvent: onKey,
                        canRequestFocus: false,
                        child: TextField(
                          key: const ValueKey('claude_input_field'),
                          controller: controller,
                          focusNode: inputFocus,
                          autofocus: true,
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
                        onTap: sessionsCubit.stopRun,
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
              ),
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
