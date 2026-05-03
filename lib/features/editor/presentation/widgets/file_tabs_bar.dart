import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../shell/presentation/cubit/shell_cubit.dart';
import '../../../shell/presentation/widgets/workspace_dropdown.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../cubit/file_tabs_cubit.dart';
import 'file_tab.dart';
import 'open_files_button.dart';

class FileTabsBar extends HookWidget {
  const FileTabsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final tabKeys = useMemoized(() => <String, GlobalKey>{}, const []);
    final lastActivePath = useRef<String?>(null);

    GlobalKey keyFor(String path) => tabKeys.putIfAbsent(path, () => GlobalKey());

    void ensureActiveVisible(String? activePath) {
      if (activePath == null) return;
      final ctx = tabKeys[activePath]?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 200), curve: Curves.easeOut, alignment: 0.5);
    }

    final activeId = context.select<WorkspacesCubit, WorkspaceId?>((c) => c.state.activeIdOrNull);
    final isSessionsActivity = context.select<ShellCubit, bool>(
      (c) => c.state.selectedActivity == ActivityId.sessions,
    );

    return Container(
      height: AppSpacing.toolbarHeight,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: Row(
        children: [
          if (!isSessionsActivity) const OpenFilesButton(),
          Expanded(
            child: isSessionsActivity || activeId == null
                ? const SizedBox.shrink()
                : BlocConsumer<FileTabsCubit, FileTabsState>(
                    listenWhen: (prev, curr) =>
                        prev.filesFor(activeId)?.activePath != curr.filesFor(activeId)?.activePath,
                    listener: (context, state) {
                      final activePath = state.filesFor(activeId)?.activePath;
                      if (activePath == lastActivePath.value) return;
                      lastActivePath.value = activePath;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ensureActiveVisible(activePath);
                      });
                    },
                    builder: (context, state) {
                      final files = state.filesFor(activeId);
                      if (files == null || files.openPaths.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return SingleChildScrollView(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final path in files.openPaths)
                              FileTab(
                                key: keyFor(path),
                                workspaceId: activeId,
                                path: path,
                                isActive: path == files.activePath,
                                isPreview: path == files.previewPath,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: WorkspaceDropdown(),
          ),
          const _WorkspaceToggleButton(),
        ],
      ),
    );
  }
}

class _WorkspaceToggleButton extends StatelessWidget {
  const _WorkspaceToggleButton();

  @override
  Widget build(BuildContext context) {
    final workspaceOpen = context.select<ShellCubit, bool>((c) => c.state.workspaceOpen);
    final action = workspaceOpen ? Locales.Shell.Workspace.toggleToFullscreen : Locales.Shell.Workspace.toggleToWorkspace;
    return Tooltip(
      message: '$action (⌘B)',
      child: IconButton(
        key: const ValueKey('workspace_toggle_button'),
        onPressed: () => context.read<ShellCubit>().toggleWorkspace(),
        icon: Icon(workspaceOpen ? Symbols.fullscreen : Symbols.fullscreen_exit, size: 16, color: AppColors.onSurface),
        visualDensity: VisualDensity.compact,
        splashRadius: 14,
      ),
    );
  }
}
