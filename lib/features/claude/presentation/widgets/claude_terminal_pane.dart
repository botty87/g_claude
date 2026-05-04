import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path/path.dart' as p;

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../domain/entities/chat_attachment.dart';
import '../cubit/claude_sessions_cubit.dart';
import 'claude_input_bar.dart';
import 'claude_message_list.dart';
import 'claude_terminal_header.dart';
import 'queued_prompt_card.dart';

class ClaudeTerminalPane extends HookWidget {
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

    final sessionsCubit = context.read<ClaudeSessionsCubit>();
    final attachmentList = session.inputDraft.attachments;

    void setAttachments(List<ChatAttachment> next) {
      sessionsCubit.setInputDraft(
        activeId,
        session.inputDraft.copyWith(attachments: next),
      );
    }

    final isHovering = useState(false);

    return DropTarget(
      enable: !isBusy,
      onDragEntered: (_) => isHovering.value = true,
      onDragExited: (_) => isHovering.value = false,
      onDragDone: (details) {
        if (isBusy) return;
        final current = attachmentList;
        final existing = current.map((a) => p.normalize(a.path)).toSet();
        final additions = <ChatAttachment>[];
        for (final xfile in details.files) {
          final path = xfile.path;
          if (path.isEmpty) continue;
          final norm = p.normalize(path);
          if (existing.contains(norm)) continue;
          existing.add(norm);
          final type = FileSystemEntity.typeSync(path);
          final kind = type == FileSystemEntityType.directory
              ? ChatAttachmentKind.directory
              : ChatAttachmentKind.file;
          additions.add(ChatAttachment(
            path: path,
            displayName: p.basename(path),
            kind: kind,
          ));
        }
        if (additions.isNotEmpty) {
          setAttachments([...current, ...additions]);
        }
        isHovering.value = false;
      },
      child: Stack(
        children: [
          ColoredBox(
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
                QueuedPromptCard(
                  key: ValueKey('claude_queued_card_$activeId'),
                  workspaceId: activeId,
                ),
                ClaudeInputBar(
                  key: ValueKey('claude_input_bar_$activeId'),
                  workspaceId: activeId,
                  status: session.runStatus,
                ),
              ],
            ),
          ),
          if (isHovering.value)
            const Positioned.fill(
              child: IgnorePointer(child: _DropOverlay()),
            ),
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
            Locales.Claude.Terminal.Status.noWorkspace,
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

class _DropOverlay extends StatelessWidget {
  const _DropOverlay();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Text(
            Locales.Claude.Terminal.Input.Attachments.dropHint,
            style: AppTypography.bodyMain.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
