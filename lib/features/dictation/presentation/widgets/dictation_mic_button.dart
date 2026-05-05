import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/dictation_mode.dart';
import '../cubit/dictation_cubit.dart';

class DictationMicButton extends HookWidget {
  const DictationMicButton({
    super.key,
    required this.workspaceId,
    required this.controller,
    required this.localeId,
    required this.disabled,
  });

  final String workspaceId;
  final TextEditingController controller;
  final String localeId;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DictationCubit>();
    final mode = context.select<DictationCubit, DictationMode>((c) => c.mode);
    final isListening =
        context.select<DictationCubit, bool>((c) {
      final s = c.state;
      return s is DictationStateListening && s.workspaceId == workspaceId;
    });
    final hover = useState(false);

    final pulse = useAnimationController(
      duration: const Duration(milliseconds: 900),
    );
    useEffect(() {
      if (isListening) {
        pulse.repeat(reverse: true);
      } else {
        pulse.stop();
        pulse.value = 0;
      }
      return null;
    }, [isListening, pulse]);

    void requestStart() {
      if (disabled) return;
      final selection = controller.selection;
      final baseOffset = selection.isValid
          ? (selection.baseOffset < selection.extentOffset
              ? selection.baseOffset
              : selection.extentOffset)
          : controller.text.length;
      cubit.start(
        workspaceId: workspaceId,
        baseText: controller.text,
        baseOffset: baseOffset,
        localeId: localeId,
      );
    }

    Future<void> requestStop() async {
      await cubit.stop();
    }

    void handlePointerDown(PointerDownEvent event) {
      if (disabled) return;
      if (event.buttons != kPrimaryButton) return;
      if (mode == DictationMode.hold) {
        requestStart();
        return;
      }
      // Tap mode: toggle.
      if (isListening) {
        requestStop();
      } else {
        requestStart();
      }
    }

    void handlePointerUp(PointerUpEvent event) {
      if (mode != DictationMode.hold) return;
      if (!isListening) return;
      requestStop();
    }

    void handlePointerCancel(PointerCancelEvent event) {
      if (mode != DictationMode.hold) return;
      if (!isListening) return;
      cubit.cancel();
    }

    Future<void> showModeMenu(Offset globalPosition) async {
      final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
      if (overlay == null) return;
      final selected = await showMenu<DictationMode>(
        context: context,
        position: RelativeRect.fromLTRB(
          globalPosition.dx,
          globalPosition.dy,
          overlay.size.width - globalPosition.dx,
          overlay.size.height - globalPosition.dy,
        ),
        items: [
          CheckedPopupMenuItem(
            value: DictationMode.hold,
            checked: mode == DictationMode.hold,
            child: Text(Locales.Claude.Terminal.Input.Dictation.modeMenuHold),
          ),
          CheckedPopupMenuItem(
            value: DictationMode.tap,
            checked: mode == DictationMode.tap,
            child: Text(Locales.Claude.Terminal.Input.Dictation.modeMenuTap),
          ),
        ],
      );
      if (selected != null) {
        await cubit.setMode(selected);
      }
    }

    final tooltipKey = disabled
        ? Locales.Claude.Terminal.Input.Dictation.tooltipUnavailable
        : isListening
            ? (mode == DictationMode.hold
                ? Locales.Claude.Terminal.Input.Dictation.tooltipListening
                : Locales.Claude.Terminal.Input.Dictation.tooltipListeningTap)
            : (mode == DictationMode.hold
                ? Locales.Claude.Terminal.Input.Dictation.tooltipIdleHold
                : Locales.Claude.Terminal.Input.Dictation.tooltipIdleTap);

    final iconColor = disabled
        ? AppColors.outline
        : isListening
            ? AppColors.error
            : AppColors.primary;

    return Tooltip(
      message: tooltipKey,
      child: MouseRegion(
        cursor: disabled
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        onEnter: (_) => hover.value = true,
        onExit: (_) => hover.value = false,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onSecondaryTapDown: disabled
              ? null
              : (details) => showModeMenu(details.globalPosition),
          child: Listener(
            onPointerDown: handlePointerDown,
            onPointerUp: handlePointerUp,
            onPointerCancel: handlePointerCancel,
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, _) {
                final pulseT = isListening ? pulse.value : 0.0;
                return Container(
                  key: const ValueKey('claude_input_dictation_mic'),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isListening
                        ? Color.lerp(
                            AppColors.errorContainer.withValues(alpha: 0.35),
                            AppColors.errorContainer.withValues(alpha: 0.65),
                            pulseT,
                          )
                        : (hover.value
                            ? AppColors.glassHover
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isListening
                        ? [
                            BoxShadow(
                              color: AppColors.error.withValues(
                                alpha: 0.25 + 0.35 * pulseT,
                              ),
                              blurRadius: 6 + 4 * pulseT,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isListening ? Symbols.mic : Symbols.mic_none,
                    size: 16,
                    color: iconColor,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
