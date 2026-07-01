import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:multi_split_view/multi_split_view.dart';

import 'package:path/path.dart' as p;

import '../../../../core/di/di.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../app_logs/presentation/cubit/app_logs_cubit.dart';
import '../../../app_logs/presentation/widgets/logs_view.dart';
import '../../../claude/domain/entities/chat_attachment.dart';
import '../../../claude/domain/entities/chat_input_draft.dart';
import '../../../claude/domain/entities/claude_effort.dart';
import '../../../claude/domain/entities/claude_permission_mode.dart';
import '../../../claude/domain/entities/claude_thinking_mode.dart';
import '../../../claude/presentation/cubit/chat_history_cubit.dart';
import '../../../claude/presentation/cubit/claude_sessions_cubit.dart';
import '../../../claude/presentation/widgets/claude_terminal_pane.dart';
import '../../../claude/presentation/widgets/session_preview_view.dart';
import '../../../editor/presentation/cubit/active_editor_cubit.dart';
import '../../../editor/presentation/cubit/file_tabs_cubit.dart';
import '../../../editor/presentation/widgets/file_tabs_bar.dart';
import '../../../editor/presentation/widgets/file_viewer.dart';
import '../../../terminal/presentation/widgets/terminal_pane.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../../workspace/presentation/widgets/empty_state_view.dart';
import '../cubit/shell_cubit.dart';
import 'activity_bar.dart';
import 'side_panel.dart';

@RoutePage()
class AppShellPage extends HookWidget {
  const AppShellPage({super.key});

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

    bool closeAllTabs() {
      final activeId = context.read<WorkspacesCubit>().state.activeIdOrNull;
      if (activeId == null) return false;
      final files = context.read<FileTabsCubit>().state.filesFor(activeId);
      if (files == null || files.openPaths.isEmpty) return false;
      context.read<FileTabsCubit>().closeAllFiles(activeId);
      return true;
    }

    void showSnack(String text) {
      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(text),
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }

    String? activeWorkspaceId() => context.read<WorkspacesCubit>().state.activeIdOrNull;

    bool noWorkspaceGuard() {
      if (activeWorkspaceId() == null) {
        showSnack(Locales.Shell.Shortcuts.noActiveWorkspace);
        return true;
      }
      return false;
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

    bool cycleEffort() {
      if (noWorkspaceGuard()) return true;
      final id = activeWorkspaceId()!;
      final cubit = context.read<ClaudeSessionsCubit>();
      final current = cubit.state.sessions[id]?.effort ?? ClaudeEffort.defaultEffort;
      final next = current.next;
      cubit.setEffort(id, next);
      showSnack(Locales.Shell.Shortcuts.effortChanged(value: next.labelKey.tr()));
      return true;
    }

    bool cycleThinking() {
      if (noWorkspaceGuard()) return true;
      final id = activeWorkspaceId()!;
      final cubit = context.read<ClaudeSessionsCubit>();
      final current = cubit.state.sessions[id]?.thinkingMode ?? ClaudeThinkingMode.defaultMode;
      final next = current.next;
      cubit.setThinking(id, next);
      showSnack(Locales.Shell.Shortcuts.thinkingChanged(value: next.labelKey.tr()));
      return true;
    }

    bool cyclePermission() {
      if (noWorkspaceGuard()) return true;
      final id = activeWorkspaceId()!;
      final cubit = context.read<ClaudeSessionsCubit>();
      final current = cubit.state.sessions[id]?.permissionMode ?? ClaudePermissionMode.defaultChoice;
      final next = current.next;
      cubit.setPermissionMode(id, next);
      showSnack(Locales.Shell.Shortcuts.permissionChanged(value: next.labelKey.tr()));
      return true;
    }

    bool setEffortDirect(ClaudeEffort e) {
      if (noWorkspaceGuard()) return true;
      final id = activeWorkspaceId()!;
      context.read<ClaudeSessionsCubit>().setEffort(id, e);
      showSnack(Locales.Shell.Shortcuts.effortChanged(value: e.labelKey.tr()));
      return true;
    }

    bool setThinkingDirect(ClaudeThinkingMode m) {
      if (noWorkspaceGuard()) return true;
      final id = activeWorkspaceId()!;
      context.read<ClaudeSessionsCubit>().setThinking(id, m);
      showSnack(Locales.Shell.Shortcuts.thinkingChanged(value: m.labelKey.tr()));
      return true;
    }

    bool setPermissionDirect(ClaudePermissionMode m) {
      if (noWorkspaceGuard()) return true;
      final id = activeWorkspaceId()!;
      context.read<ClaudeSessionsCubit>().setPermissionMode(id, m);
      showSnack(Locales.Shell.Shortcuts.permissionChanged(value: m.labelKey.tr()));
      return true;
    }

    KeyEventResult onKey(FocusNode node, KeyEvent event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;
      if (!HardwareKeyboard.instance.isMetaPressed) {
        return KeyEventResult.ignored;
      }

      final shift = HardwareKeyboard.instance.isShiftPressed;
      final alt = HardwareKeyboard.instance.isAltPressed;
      final ctrl = HardwareKeyboard.instance.isControlPressed;
      final key = event.logicalKey;

      bool handled = false;

      // Cmd+Opt+K
      if (alt && !shift && !ctrl && key == LogicalKeyboardKey.keyK) {
        handled = attachActiveEditor();
      }
      // Cmd+B / Cmd+W
      else if (!alt && !shift && !ctrl) {
        handled = switch (key) {
          LogicalKeyboardKey.keyB => toggleWorkspace(),
          LogicalKeyboardKey.keyW => closeActiveTab(),
          _ => false,
        };
      }
      // Cmd+Shift — cycle letters + set thinking by digit
      else if (shift && !alt && !ctrl) {
        handled = switch (key) {
          LogicalKeyboardKey.keyW => closeAllTabs(),
          LogicalKeyboardKey.keyE => cycleEffort(),
          LogicalKeyboardKey.keyT => cycleThinking(),
          LogicalKeyboardKey.keyM => cyclePermission(),
          LogicalKeyboardKey.digit1 => setThinkingDirect(ClaudeThinkingMode.off),
          LogicalKeyboardKey.digit2 => setThinkingDirect(ClaudeThinkingMode.on),
          _ => false,
        };
      }
      // Cmd+Opt — set effort by digit
      else if (alt && !shift && !ctrl) {
        handled = switch (key) {
          LogicalKeyboardKey.digit1 => setEffortDirect(ClaudeEffort.low),
          LogicalKeyboardKey.digit2 => setEffortDirect(ClaudeEffort.medium),
          LogicalKeyboardKey.digit3 => setEffortDirect(ClaudeEffort.high),
          LogicalKeyboardKey.digit4 => setEffortDirect(ClaudeEffort.xhigh),
          LogicalKeyboardKey.digit5 => setEffortDirect(ClaudeEffort.max),
          _ => false,
        };
      }
      // Cmd+Ctrl — set permission by digit
      else if (ctrl && !shift && !alt) {
        handled = switch (key) {
          LogicalKeyboardKey.digit1 => setPermissionDirect(ClaudePermissionMode.defaultMode),
          LogicalKeyboardKey.digit2 => setPermissionDirect(ClaudePermissionMode.plan),
          LogicalKeyboardKey.digit3 => setPermissionDirect(ClaudePermissionMode.acceptEdits),
          LogicalKeyboardKey.digit4 => setPermissionDirect(ClaudePermissionMode.bypassPermissions),
          _ => false,
        };
      }

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
                  ? const Row(
                      children: [
                        ActivityBar(),
                        Expanded(child: _MainArea()),
                      ],
                    )
                  : const ClaudeTerminalPane(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainArea extends HookWidget {
  const _MainArea();

  static const _idSide = 'side';
  static const _idPreview = 'preview';
  static const _idClaude = 'claude';
  static const _idTerminal = 'terminal';

  static const _sideMin = 200.0;
  static const _sideMax = 480.0;
  static const _sideDefault = 280.0;
  static const _previewMin = 320.0;
  static const _previewDefault = 380.0;
  static const _claudeMin = 360.0;
  static const _terminalMin = 320.0;
  static const _terminalDefault = 480.0;

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
    final selectedActivity = context.select<ShellCubit, ActivityId>((c) => c.state.selectedActivity);
    final activeId = context.select<WorkspacesCubit, WorkspaceId?>((c) => c.state.activeIdOrNull);

    final hasPreviewItem = switch (selectedActivity) {
      ActivityId.explorer => context.select<FileTabsCubit, bool>(
        (c) => activeId != null && (c.state.filesFor(activeId)?.activePath != null),
      ),
      ActivityId.sessions => context.select<ChatHistoryCubit, bool>(
        (c) => activeId != null && (c.state.historyFor(activeId)?.selectedId != null),
      ),
      ActivityId.logs => context.select<AppLogsCubit, bool>((c) => c.state.selectedSessionId != null),
      // Terminal owns its own pane via `showTerminal` below — no preview item.
      ActivityId.terminal => false,
      // Stub activities: not implemented yet.
      ActivityId.search || ActivityId.git || ActivityId.settings => false,
    };

    final savedSizes = context.read<ShellCubit>().state.paneSizes;
    final showTerminal = selectedActivity == ActivityId.terminal;

    final controller = useMemoized(() {
      final savedSide = (savedSizes[_idSide] ?? _sideDefault).clamp(_sideMin, _sideMax);
      return MultiSplitViewController(
        areas: [
          // Terminal mode dedicates the full main area to terminal+Claude;
          // the side panel and preview are skipped.
          if (showTerminal) ...[
            Area(id: _idTerminal, size: savedSizes[_idTerminal] ?? _terminalDefault, min: _terminalMin),
            Area(id: _idClaude, flex: 1, min: _claudeMin),
          ] else ...[
            Area(id: _idSide, size: savedSide, min: _sideMin, max: _sideMax),
            if (hasPreviewItem) Area(id: _idPreview, size: savedSizes[_idPreview] ?? _previewDefault, min: _previewMin),
            Area(id: _idClaude, flex: 1, min: _claudeMin),
          ],
        ],
      );
    }, [hasPreviewItem, showTerminal]);
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
              return switch (selectedActivity) {
                ActivityId.sessions => const SessionPreviewView(),
                ActivityId.explorer => const FileViewer(),
                ActivityId.logs => const LogsDetailView(),
                _ => const SizedBox.shrink(),
              };
            case _idClaude:
              return const ClaudeTerminalPane();
            case _idTerminal:
              return const TerminalPane();
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
