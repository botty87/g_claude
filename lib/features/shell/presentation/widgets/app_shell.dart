import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:multi_split_view/multi_split_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../claude/presentation/widgets/claude_terminal_pane.dart';
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

    KeyEventResult onKey(FocusNode node, KeyEvent event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;
      final isMeta = HardwareKeyboard.instance.isMetaPressed;
      if (!isMeta) return KeyEventResult.ignored;
      if (event.logicalKey == LogicalKeyboardKey.keyB) {
        context.read<ShellCubit>().toggleWorkspace();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    return Focus(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: onKey,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: BlocSelector<ShellCubit, ShellState, bool>(
          selector: (state) => state.workspaceOpen,
          builder: (context, workspaceOpen) {
            return Column(
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
            );
          },
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
    dividerHandleBuffer: 10,
    dividerPainter: DividerPainters.background(
      color: AppColors.outlineVariant,
      highlightedColor: AppColors.brandIndigo,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final controller = useMemoized(
      () => MultiSplitViewController(
        areas: [
          Area(id: _idSide, size: 280, min: 200, max: 480),
          Area(id: _idPreview, size: 380, min: 320),
          Area(id: _idClaude, flex: 1),
        ],
      ),
    );
    useEffect(() => controller.dispose, [controller]);

    return BlocSelector<WorkspacesCubit, WorkspacesState, Workspace?>(
      selector: (state) => state.activeWorkspace,
      builder: (context, active) {
        if (active == null) {
          return const EmptyStateView();
        }
        return MultiSplitViewTheme(
          data: _splitTheme,
          child: MultiSplitView(
            controller: controller,
            builder: (context, area) {
              switch (area.id) {
                case _idSide:
                  return const SidePanel();
                case _idPreview:
                  return const FileViewer();
                case _idClaude:
                  return const ClaudeTerminalPane();
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        );
      },
    );
  }
}
