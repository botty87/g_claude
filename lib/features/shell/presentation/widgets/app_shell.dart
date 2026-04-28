import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_split_view/multi_split_view.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../editor/presentation/widgets/file_tabs_bar.dart';
import '../../../editor/presentation/widgets/file_viewer.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../../workspace/presentation/widgets/empty_state_view.dart';
import '../cubit/shell_cubit.dart';
import 'activity_bar.dart';
import 'side_panel.dart';

@RoutePage()
class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key});

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  late final FocusNode _focusNode;
  late final MultiSplitViewController _splitController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _splitController = MultiSplitViewController(
      areas: [
        Area(size: 280, min: 200, max: 480),
        Area(),
      ],
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _splitController.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final isMetaB = event.logicalKey == LogicalKeyboardKey.keyB &&
        HardwareKeyboard.instance.isMetaPressed;
    if (isMetaB) {
      context.read<ShellCubit>().toggleSidePanel();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Column(
          children: [
            const FileTabsBar(),
            Expanded(
              child: Row(
                children: [
                  const ActivityBar(),
                  Expanded(child: _MainArea(splitController: _splitController)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainArea extends StatelessWidget {
  const _MainArea({required this.splitController});

  final MultiSplitViewController splitController;

  static final _splitTheme = MultiSplitViewThemeData(
    dividerThickness: 1,
    dividerPainter: DividerPainters.background(
      color: AppColors.outlineVariant,
      highlightedColor: AppColors.brandIndigo,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocSelector<WorkspacesCubit, WorkspacesState, Workspace?>(
      selector: (state) => state.activeWorkspace,
      builder: (context, active) {
        if (active == null) {
          return const EmptyStateView();
        }
        return BlocSelector<ShellCubit, ShellState, bool>(
          selector: (state) => state.sidePanelOpen,
          builder: (context, sidePanelOpen) {
            if (!sidePanelOpen) {
              return const FileViewer();
            }
            return MultiSplitViewTheme(
              data: _splitTheme,
              child: MultiSplitView(
                controller: splitController,
                builder: (context, area) {
                  if (area.index == 0) {
                    return const SidePanel();
                  }
                  return const FileViewer();
                },
              ),
            );
          },
        );
      },
    );
  }
}
