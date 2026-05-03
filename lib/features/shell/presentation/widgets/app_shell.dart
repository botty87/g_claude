import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:multi_split_view/multi_split_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../claude/presentation/widgets/claude_terminal_pane.dart';
import '../../../claude/presentation/widgets/session_preview_view.dart';
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
      final activePath =
          context.read<FileTabsCubit>().state.filesFor(activeId)?.activePath;
      if (activePath == null) return false;
      context.read<FileTabsCubit>().closeFile(activeId, activePath);
      return true;
    }

    KeyEventResult onKey(FocusNode node, KeyEvent event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;
      if (!HardwareKeyboard.instance.isMetaPressed) {
        return KeyEventResult.ignored;
      }
      final handled = switch (event.logicalKey) {
        LogicalKeyboardKey.keyB => toggleWorkspace(),
        LogicalKeyboardKey.keyW => closeActiveTab(),
        _ => false,
      };
      return handled ? KeyEventResult.handled : KeyEventResult.ignored;
    }

    final workspaceOpen = context.select<ShellCubit, bool>(
      (c) => c.state.workspaceOpen,
    );

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
                      children: const [
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
    final sidePanelCollapsed = context.select<ShellCubit, bool>(
      (c) => c.state.sidePanelCollapsed,
    );
    final controller = useMemoized(
      () => MultiSplitViewController(
        areas: [
          if (!sidePanelCollapsed)
            Area(id: _idSide, size: 280, min: 200, max: 480),
          Area(id: _idPreview, size: 380, min: 320),
          Area(id: _idClaude, size: 600, min: 360),
        ],
      ),
      [sidePanelCollapsed],
    );
    useEffect(() => controller.dispose, [controller]);

    final active = context.select<WorkspacesCubit, Workspace?>(
      (c) => c.state.activeWorkspace,
    );
    if (active == null) {
      return const EmptyStateView();
    }
    return MultiSplitViewTheme(
      data: _splitTheme,
      child: MultiSplitView(
        controller: controller,
        sizeOverflowPolicy: SizeOverflowPolicy.shrinkFirst,
        builder: (context, area) {
          switch (area.id) {
            case _idSide:
              return const SidePanel();
            case _idPreview:
              return BlocBuilder<ShellCubit, ShellState>(
                buildWhen: (p, c) =>
                    p.selectedActivity != c.selectedActivity,
                builder: (context, state) {
                  if (state.selectedActivity == ActivityId.sessions) {
                    return const SessionPreviewView();
                  }
                  return const FileViewer();
                },
              );
            case _idClaude:
              return const ClaudeTerminalPane();
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
