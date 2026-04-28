import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../cubit/file_tabs_cubit.dart';
import 'file_tab.dart';
import 'open_files_button.dart';

class FileTabsBar extends StatefulWidget {
  const FileTabsBar({super.key});

  @override
  State<FileTabsBar> createState() => _FileTabsBarState();
}

class _FileTabsBarState extends State<FileTabsBar> {
  late final ScrollController _scrollController;
  final Map<String, GlobalKey> _tabKeys = {};
  String? _lastActivePath;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(String path) =>
      _tabKeys.putIfAbsent(path, () => GlobalKey());

  void _ensureActiveVisible(String? activePath) {
    if (activePath == null) return;
    final ctx = _tabKeys[activePath]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    if (activePath == _lastActivePath) return;
                    _lastActivePath = activePath;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _ensureActiveVisible(activePath);
                    });
                  },
                  builder: (context, state) {
                    final files = state.filesFor(activeId);
                    if (files == null || files.openPaths.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final path in files.openPaths)
                            FileTab(
                              key: _keyFor(path),
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
