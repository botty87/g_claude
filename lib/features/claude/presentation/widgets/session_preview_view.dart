import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../domain/entities/chat_session_summary.dart';
import '../cubit/chat_history_cubit.dart';
import '../cubit/claude_sessions_cubit.dart';
import 'claude_message_list.dart';

class SessionPreviewView extends HookWidget {
  const SessionPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final active = context.select<WorkspacesCubit, Workspace?>(
      (c) => c.state.activeWorkspace,
    );
    if (active == null) return const SizedBox.shrink();

    return BlocBuilder<ChatHistoryCubit, ChatHistoryState>(
      buildWhen: (p, c) => p.byWorkspace[active.id] != c.byWorkspace[active.id],
      builder: (context, state) {
        final h = state.historyFor(active.id);
        if (h == null || h.selectedId == null) {
          return const _EmptyPreview();
        }
        final summary = h.sessions.firstWhereOrNull(
          (s) => s.id == h.selectedId,
        );
        if (summary == null) return const _EmptyPreview();

        return Column(
          children: [
            _PreviewToolbar(workspace: active, summary: summary),
            const Divider(height: 1, color: AppColors.outlineVariant),
            Expanded(
              child: h.previewLoading
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : ClaudeMessageList(
                      workspaceId: active.id,
                      messages: h.previewMessages,
                      status: ClaudeRunStatus.idle,
                      lastError: null,
                      stderrTail: const [],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        Locales.Sessions.Preview.empty,
        style: AppTypography.bodyMain.copyWith(
          color: AppColors.outline,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _PreviewToolbar extends StatelessWidget {
  const _PreviewToolbar({
    required this.workspace,
    required this.summary,
  });

  final Workspace workspace;
  final ChatSessionSummary summary;

  static final _dateFmt = DateFormat('dd/MM/yyyy HH:mm');

  Future<void> _onResume(BuildContext context) async {
    final sessionsCubit = context.read<ClaudeSessionsCubit>();
    final historyCubit = context.read<ChatHistoryCubit>();

    final liveMessages =
        sessionsCubit.state.sessionFor(workspace.id)?.messages ?? const [];

    if (liveMessages.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(Locales.Sessions.Preview.resumeConfirmTitle),
          content: Text(Locales.Sessions.Preview.resumeConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(Locales.Sessions.Preview.resumeConfirmCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(Locales.Sessions.Preview.resumeConfirmOk),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    await sessionsCubit.resumeSession(workspace.id, summary.id);
    if (!context.mounted) return;
    historyCubit.clearSelection(workspace.id);
  }

  Future<void> _onExport(BuildContext context) async {
    final historyCubit = context.read<ChatHistoryCubit>();

    final path = await FilePicker.saveFile(
      dialogTitle: Locales.Sessions.Preview.export,
      fileName: '${summary.id}.md',
      type: FileType.custom,
      allowedExtensions: const ['md'],
    );
    if (path == null) return;
    if (!context.mounted) return;

    final result = await historyCubit.export(
      workspace.id,
      summary.id,
      summary.encodedPath,
      path,
    );
    if (!context.mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Locales.Sessions.Preview.exportDone(path: result),
          ),
        ),
      );
    }
  }

  Future<void> _onDelete(BuildContext context) async {
    final sessionsCubit = context.read<ClaudeSessionsCubit>();
    final historyCubit = context.read<ChatHistoryCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(Locales.Sessions.Preview.deleteConfirmTitle),
        content: Text(Locales.Sessions.Preview.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(Locales.Sessions.Preview.deleteConfirmCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(Locales.Sessions.Preview.deleteConfirmOk),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final liveSessionId =
        sessionsCubit.state.sessionFor(workspace.id)?.claudeSessionId;

    await historyCubit.delete(workspace.id, summary.id, summary.encodedPath);
    if (!context.mounted) return;

    if (liveSessionId == summary.id) {
      sessionsCubit.newSession(workspace.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.toolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      color: AppColors.surfaceContainerLow,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.title,
                  style: AppTypography.bodyMain.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  _dateFmt.format(summary.lastMessageAt.toLocal()),
                  style: AppTypography.bodyMain.copyWith(
                    color: AppColors.outline,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const ValueKey('session_preview_resume'),
            tooltip: Locales.Sessions.Preview.resume,
            icon: const Icon(Symbols.play_arrow, size: 18),
            onPressed: () => _onResume(context),
          ),
          IconButton(
            key: const ValueKey('session_preview_export'),
            tooltip: Locales.Sessions.Preview.export,
            icon: const Icon(Symbols.download, size: 18),
            onPressed: () => _onExport(context),
          ),
          IconButton(
            key: const ValueKey('session_preview_delete'),
            tooltip: Locales.Sessions.Preview.delete,
            color: AppColors.error,
            icon: const Icon(Symbols.delete, size: 18),
            onPressed: () => _onDelete(context),
          ),
        ],
      ),
    );
  }
}
