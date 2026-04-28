import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
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

    GlobalKey keyFor(String path) =>
        tabKeys.putIfAbsent(path, () => GlobalKey());

    void ensureActiveVisible(String? activePath) {
      if (activePath == null) return;
      final ctx = tabKeys[activePath]?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: 0.5,
      );
    }

    return Container(
      height: AppSpacing.toolbarHeight,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          const OpenFilesButton(),
          Expanded(
            child: BlocSelector<WorkspacesCubit, WorkspacesState, WorkspaceId?>(
              selector: (state) => state.activeIdOrNull,
              builder: (context, activeId) {
                if (activeId == null) return const SizedBox.shrink();
                return BlocConsumer<FileTabsCubit, FileTabsState>(
                  listenWhen: (prev, curr) =>
                      prev.filesFor(activeId)?.activePath !=
                      curr.filesFor(activeId)?.activePath,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
