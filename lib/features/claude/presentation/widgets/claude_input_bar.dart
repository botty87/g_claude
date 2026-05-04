import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;

import '../../../../core/di/di.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../slash_commands/domain/entities/slash_command.dart';
import '../../../slash_commands/presentation/cubit/slash_commands_cubit.dart';
import '../../../slash_commands/presentation/widgets/slash_command_chip_row.dart';
import '../../../slash_commands/presentation/widgets/slash_command_overlay.dart';
import '../../domain/entities/chat_attachment.dart';
import '../../domain/entities/chat_input_draft.dart';
import '../cubit/claude_sessions_cubit.dart';
import '../utils/attachment_token.dart';
import 'attachment_chip_row.dart';

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
    final sessionsCubit = context.read<ClaudeSessionsCubit>();
    final initialDraft = useMemoized(
      () =>
          sessionsCubit.state.sessions[workspaceId]?.inputDraft ??
          ChatInputDraft.empty,
      const [],
    );

    final controller = useTextEditingController(text: initialDraft.text);
    final wrapperFocus = useFocusNode(debugLabel: 'claude_input_wrapper');
    final inputFocus = useFocusNode(debugLabel: 'claude_input_field');

    final slashCubit = useMemoized(
      () => getIt<SlashCommandsCubit>()..loadFor(workspaceId),
      [workspaceId],
    );
    useEffect(() => slashCubit.close, [slashCubit]);

    final link = useMemoized(LayerLink.new, const []);
    final selectedChips =
        useState<List<SlashCommand>>(initialDraft.selectedCommands);
    final attachments = context.select<ClaudeSessionsCubit, List<ChatAttachment>>(
      (c) => c.state.sessions[workspaceId]?.inputDraft.attachments ?? const [],
    );
    final escArmedAt = useRef<DateTime?>(null);

    void persistDraft({
      String? text,
      List<SlashCommand>? chips,
      List<ChatAttachment>? attachmentsOverride,
    }) {
      sessionsCubit.setInputDraft(
        workspaceId,
        ChatInputDraft(
          text: text ?? controller.text,
          selectedCommands: chips ?? selectedChips.value,
          attachments: attachmentsOverride ?? attachments,
        ),
      );
    }

    final skills = context.select<ClaudeSessionsCubit, List<String>>(
      (c) => c.state.sessions[workspaceId]?.availableSkills ?? const [],
    );
    useEffect(() {
      slashCubit.updateSkills(skills);
      return null;
    }, [skills]);

    useEffect(() {
      void listener() {
        slashCubit.onInputChanged(controller.text);
        persistDraft(text: controller.text);
      }

      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller, slashCubit]);

    void applySelection(SlashCommand cmd) {
      if (selectedChips.value.any((c) => c.trigger == cmd.trigger)) {
        _stripSlashPrefix(controller);
        slashCubit.dismiss();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          inputFocus.requestFocus();
        });
        return;
      }
      final next = [...selectedChips.value, cmd];
      selectedChips.value = next;
      _stripSlashPrefix(controller);
      slashCubit.dismiss();
      persistDraft(chips: next, text: controller.text);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        inputFocus.requestFocus();
      });
    }

    Future<void> pickFiles() async {
      if (_isBusy) return;
      final res = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      if (res == null) return;
      final current = attachments;
      final existing = current.map((a) => p.normalize(a.path)).toSet();
      final additions = <ChatAttachment>[];
      for (final f in res.files) {
        final path = f.path;
        if (path == null) continue;
        final norm = p.normalize(path);
        if (existing.contains(norm)) continue;
        existing.add(norm);
        additions.add(ChatAttachment(
          path: path,
          displayName: p.basename(path),
          kind: ChatAttachmentKind.file,
        ));
      }
      if (additions.isNotEmpty) {
        persistDraft(attachmentsOverride: [...current, ...additions]);
      }
    }

    Future<void> pickFolder() async {
      if (_isBusy) return;
      final path = await FilePicker.getDirectoryPath();
      if (path == null) return;
      final current = attachments;
      final norm = p.normalize(path);
      if (current.any((a) => p.normalize(a.path) == norm)) return;
      persistDraft(attachmentsOverride: [
        ...current,
        ChatAttachment(
          path: path,
          displayName: p.basename(path),
          kind: ChatAttachmentKind.directory,
        ),
      ]);
    }

    void removeAttachment(ChatAttachment a) {
      final next = attachments.where((x) => x.path != a.path).toList();
      persistDraft(attachmentsOverride: next);
    }

    void submit() {
      final userText = controller.text.trim();
      if (_isBusy) {
        if (userText.isEmpty) return;
        controller.clear();
        sessionsCubit.clearInputDraft(workspaceId);
        sessionsCubit.setQueuedPrompt(workspaceId, userText);
        return;
      }
      final chipPrefix =
          selectedChips.value.map((c) => c.trigger).join(' ');
      final attachmentTokens =
          attachments.map((a) => formatAttachmentToken(a.path)).join(' ');
      final parts = <String>[
        if (chipPrefix.isNotEmpty) chipPrefix,
        if (attachmentTokens.isNotEmpty) attachmentTokens,
        if (userText.isNotEmpty) userText,
      ];
      if (parts.isEmpty) return;
      final prompt = parts.join(' ');
      controller.clear();
      selectedChips.value = const [];
      sessionsCubit.clearInputDraft(workspaceId);
      sessionsCubit.sendPrompt(workspaceId, prompt);
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
          slashCubit.dismiss();
        }
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          slashCubit.dismiss();
          return KeyEventResult.handled;
        }
      }

      if (event.logicalKey == LogicalKeyboardKey.backspace &&
          controller.text.isEmpty &&
          !isSuggesting) {
        if (selectedChips.value.isNotEmpty) {
          final next =
              selectedChips.value.sublist(0, selectedChips.value.length - 1);
          selectedChips.value = next;
          persistDraft(chips: next);
          return KeyEventResult.handled;
        }
        if (attachments.isNotEmpty) {
          final next = attachments.sublist(0, attachments.length - 1);
          persistDraft(attachmentsOverride: next);
          return KeyEventResult.handled;
        }
      }

      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (HardwareKeyboard.instance.isShiftPressed) {
          return KeyEventResult.ignored;
        }
        submit();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.period &&
          HardwareKeyboard.instance.isMetaPressed) {
        if (_isBusy) sessionsCubit.stopRun();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (!_isBusy) {
          escArmedAt.value = null;
          return KeyEventResult.ignored;
        }
        final now = DateTime.now();
        final armed = escArmedAt.value;
        if (armed != null &&
            now.difference(armed) <= const Duration(seconds: 3)) {
          escArmedAt.value = null;
          ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
          sessionsCubit.stopRun();
          return KeyEventResult.handled;
        }
        escArmedAt.value = now;
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(Locales.Claude.Terminal.Input.escConfirmStop),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        Future<void>.delayed(const Duration(seconds: 3), () {
          if (escArmedAt.value == now) {
            escArmedAt.value = null;
          }
        });
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    return SlashCommandOverlay(
      link: link,
      cubit: slashCubit,
      excludedTriggers: selectedChips.value.map((c) => c.trigger).toSet(),
      onAccept: applySelection,
      onDismiss: slashCubit.dismiss,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SlashCommandChipRow(
            chips: selectedChips.value,
            onRemove: (cmd) {
              final next = selectedChips.value
                  .where((c) => c.trigger != cmd.trigger)
                  .toList();
              selectedChips.value = next;
              persistDraft(chips: next);
            },
          ),
          AttachmentChipRow(
            attachments: attachments,
            onRemove: removeAttachment,
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
                              ? Locales.Claude.Terminal.Input.placeholderQueueing
                              : Locales.Claude.Terminal.Input.placeholder,
                          hintStyle: AppTypography.terminalCode.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _ActionButton(
                    key: const ValueKey('claude_input_attach_file'),
                    icon: Symbols.attach_file,
                    tooltipKey: 'claude.terminal.input.attachments.addFile',
                    color: _isBusy ? AppColors.outline : AppColors.primary,
                    onTap: _isBusy ? () {} : pickFiles,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _ActionButton(
                    key: const ValueKey('claude_input_attach_folder'),
                    icon: Symbols.folder,
                    tooltipKey: 'claude.terminal.input.attachments.addFolder',
                    color: _isBusy ? AppColors.outline : AppColors.primary,
                    onTap: _isBusy ? () {} : pickFolder,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (_isBusy && controller.text.trim().isNotEmpty)
                    _ActionButton(
                      key: const ValueKey('claude_input_queue'),
                      icon: Symbols.schedule_send,
                      tooltipKey: 'claude.terminal.input.queue.send',
                      color: AppColors.primary,
                      onTap: submit,
                    )
                  else if (_isBusy)
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

void _stripSlashPrefix(TextEditingController controller) {
  final lines = controller.text.split('\n');
  final last = lines.last;
  if (slashTriggerRegex.hasMatch(last)) {
    lines[lines.length - 1] = '';
  }
  final newText = lines.join('\n');
  controller.value = TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: newText.length),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
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
