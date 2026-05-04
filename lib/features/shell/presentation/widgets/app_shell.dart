import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'package:path/path.dart' as p;

import '../../../../core/di/di.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../claude/domain/entities/chat_attachment.dart';
import '../../../claude/domain/entities/chat_input_draft.dart';
import '../../../claude/presentation/cubit/claude_sessions_cubit.dart';
import '../../../claude/presentation/widgets/claude_terminal_pane.dart';
import '../../../claude/presentation/widgets/session_preview_view.dart';
import '../../../editor/presentation/cubit/active_editor_cubit.dart';
import '../../../editor/presentation/cubit/file_tabs_cubit.dart';
import '../../../editor/presentation/widgets/file_tabs_bar.dart';
import '../../../editor/presentation/widgets/file_viewer.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../../workspace/presentation/widgets/empty_state_view.dart';
import '../cubit/shell_cubit.dart';
import 'activity_bar.dart';
import 'side_panel.dart';

@RoutePage()
class AppShellPage extends HookWidget {
  const AppShellPage({super.key});

  // Stable across the two layout branches (workspace open vs fullscreen chat)
  // and across MultiSplitView controller recreations. Without it, the pane
  // remounts every Cmd+B toggle and loses scroll/state.
  static final _claudePaneKey = GlobalKey(debugLabel: 'ClaudeTerminalPane');

  @override
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();

    bool toggleWorkspace() {
      context.read<ShellCubit>().toggleWorkspace();
      return true;
    }

    bool closeActiveTab() {
      final activeId = context.read<WorkspacesCubit>().state.activeIdOrNull;
      if (activeId == null) return false;
      final activePath = context.read<FileTabsCubit>().state.filesFor(activeId)?.activePath;
      if (activePath == null) return false;
      context.read<FileTabsCubit>().closeFile(activeId, activePath);
      return true;
    }

    bool attachActiveEditor() {
      final activeId = context.read<WorkspacesCubit>().state.activeIdOrNull;
      if (activeId == null) return false;
      final activePath = context.read<FileTabsCubit>().state.filesFor(activeId)?.activePath;
      if (activePath == null) return false;
      final sessions = context.read<ClaudeSessionsCubit>();
      final selection = getIt<ActiveEditorCubit>().snapshotFor(activeId);
      final current = sessions.state.sessions[activeId]?.inputDraft;
      final currentAttachments = current?.attachments ?? const <ChatAttachment>[];

      final ChatAttachment newAttachment;
      bool isDuplicate = false;
      if (selection != null && !selection.isEmpty) {
        newAttachment = ChatAttachment(
          path: selection.path,
          displayName: '${p.basename(selection.path)}:${selection.startLine}-${selection.endLine}',
          kind: ChatAttachmentKind.fileRange,
          startLine: selection.startLine,
          endLine: selection.endLine,
          snippet: selection.snippet,
        );
        isDuplicate = currentAttachments.any(
          (a) =>
              a.kind == ChatAttachmentKind.fileRange &&
              p.normalize(a.path) == p.normalize(selection.path) &&
              a.startLine == selection.startLine &&
              a.endLine == selection.endLine,
        );
      } else {
        final norm = p.normalize(activePath);
        isDuplicate = currentAttachments.any((a) => a.kind == ChatAttachmentKind.file && p.normalize(a.path) == norm);
        newAttachment = ChatAttachment(
          path: activePath,
          displayName: p.basename(activePath),
          kind: ChatAttachmentKind.file,
        );
      }

      if (isDuplicate) {
        ScaffoldMessenger.maybeOf(context)
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(Locales.Shell.Shortcuts.alreadyAttached),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        return true;
      }

      sessions.setInputDraft(
        activeId,
        ChatInputDraft(
          text: current?.text ?? '',
          selectedCommands: current?.selectedCommands ?? const [],
          attachments: [...currentAttachments, newAttachment],
        ),
      );

      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              newAttachment.kind == ChatAttachmentKind.fileRange
                  ? Locales.Shell.Shortcuts.attachedRange(name: newAttachment.displayName)
                  : Locales.Shell.Shortcuts.attachedFile(name: newAttachment.displayName),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return true;
    }

    KeyEventResult onKey(FocusNode node, KeyEvent event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;
      if (!HardwareKeyboard.instance.isMetaPressed) {
        return KeyEventResult.ignored;
      }
      final altPressed = HardwareKeyboard.instance.isAltPressed;
      if (event.logicalKey == LogicalKeyboardKey.keyK && altPressed) {
        return attachActiveEditor() ? KeyEventResult.handled : KeyEventResult.ignored;
      }
      if (altPressed) return KeyEventResult.ignored;
      final handled = switch (event.logicalKey) {
        LogicalKeyboardKey.keyB => toggleWorkspace(),
        LogicalKeyboardKey.keyW => closeActiveTab(),
        _ => false,
      };
      return handled ? KeyEventResult.handled : KeyEventResult.ignored;
    }

    final workspaceOpen = context.select<ShellCubit, bool>((c) => c.state.workspaceOpen);

    return Focus(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: onKey,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            const FileTabsBar(),
            Expanded(
              child: workspaceOpen
                  ? Row(
                      children: [
                        const ActivityBar(),
                        Expanded(child: _MainArea(claudePaneKey: _claudePaneKey)),
                      ],
                    )
                  : ClaudeTerminalPane(key: _claudePaneKey),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainArea extends HookWidget {
  const _MainArea({required this.claudePaneKey});

  final Key claudePaneKey;

  static const _idSide = 'side';
  static const _idPreview = 'preview';
  static const _idClaude = 'claude';

  static final _splitTheme = MultiSplitViewThemeData(
    dividerThickness: 1,
    dividerHandleBuffer: 2,
    dividerPainter: DividerPainters.background(
      color: AppColors.outlineVariant,
      highlightedColor: AppColors.brandIndigo,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final sidePanelCollapsed = context.select<ShellCubit, bool>((c) => c.state.sidePanelCollapsed);
    final selectedActivity = context.select<ShellCubit, ActivityId>((c) => c.state.selectedActivity);
    final activeId = context.select<WorkspacesCubit, WorkspaceId?>((c) => c.state.activeIdOrNull);
    final hasOpenFiles = context.select<FileTabsCubit, bool>(
      (c) => activeId != null && (c.state.filesFor(activeId)?.openPaths.isNotEmpty ?? false),
    );

    final hidesPreview =
        selectedActivity == ActivityId.logs || (selectedActivity != ActivityId.sessions && !hasOpenFiles);

    final savedSizes = context.read<ShellCubit>().state.paneSizes;

    final controller = useMemoized(
      () => MultiSplitViewController(
        areas: [
          if (!sidePanelCollapsed)
            Area(
              id: _idSide,
              size: savedSizes[_idSide] ?? (hidesPreview ? 660 : 280),
              min: 200,
              max: hidesPreview ? 1100 : 480,
            ),
          if (!hidesPreview) Area(id: _idPreview, size: savedSizes[_idPreview] ?? 380, min: 320),
          Area(id: _idClaude, size: savedSizes[_idClaude] ?? 600, min: 360),
        ],
      ),
      [sidePanelCollapsed, hidesPreview],
    );
    useEffect(() => controller.dispose, [controller]);

    void persistSizes() {
      final next = <String, double>{};
      for (final area in controller.areas) {
        final id = area.id;
        final size = area.size;
        if (id is String && size != null) {
          next[id] = size;
        }
      }
      if (next.isNotEmpty) {
        context.read<ShellCubit>().setPaneSizes(next);
      }
    }

    final active = context.select<WorkspacesCubit, Workspace?>((c) => c.state.activeWorkspace);
    if (active == null) {
      return const EmptyStateView();
    }
    return MultiSplitViewTheme(
      data: _splitTheme,
      child: MultiSplitView(
        controller: controller,
        sizeOverflowPolicy: SizeOverflowPolicy.shrinkFirst,
        onDividerDragEnd: (_) => persistSizes(),
        builder: (context, area) {
          switch (area.id) {
            case _idSide:
              return const SidePanel();
            case _idPreview:
              return BlocBuilder<ShellCubit, ShellState>(
                buildWhen: (p, c) => p.selectedActivity != c.selectedActivity,
                builder: (context, state) {
                  if (state.selectedActivity == ActivityId.sessions) {
                    return const SessionPreviewView();
                  }
                  return const FileViewer();
                },
              );
            case _idClaude:
              return ClaudeTerminalPane(key: claudePaneKey);
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
