import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../editor/presentation/cubit/file_tabs_cubit.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../../domain/entities/file_node.dart';
import '../cubit/explorer_cubit.dart';
import 'explorer_header.dart';
import 'explorer_node_row.dart';

class ExplorerView extends HookWidget {
  const ExplorerView({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      final active = context.read<WorkspacesCubit>().state.activeWorkspace;
      if (active != null) {
        final explorer = context.read<ExplorerCubit>();
        final fileTabs = context.read<FileTabsCubit>();
        explorer.ensureRootLoaded(active.id, active.path).then((_) {
          final activePath = fileTabs.state.filesFor(active.id)?.activePath;
          if (activePath != null) {
            explorer.revealPath(active.id, active.path, activePath);
          }
        });
      }
      return null;
    }, const []);

    return MultiBlocListener(
      listeners: [
        BlocListener<WorkspacesCubit, WorkspacesState>(
          listenWhen: (prev, curr) =>
              prev.activeWorkspace?.id != curr.activeWorkspace?.id,
          listener: (context, state) async {
            final active = state.activeWorkspace;
            if (active == null) return;
            final explorer = context.read<ExplorerCubit>();
            final fileTabs = context.read<FileTabsCubit>();
            await explorer.ensureRootLoaded(active.id, active.path);
            final activePath = fileTabs.state.filesFor(active.id)?.activePath;
            if (activePath != null) {
              await explorer.revealPath(active.id, active.path, activePath);
            } else {
              explorer.clearSelection(active.id);
            }
          },
        ),
        BlocListener<FileTabsCubit, FileTabsState>(
          listenWhen: (prev, curr) {
            final active = context.read<WorkspacesCubit>().state.activeWorkspace;
            if (active == null) return false;
            return prev.filesFor(active.id)?.activePath !=
                curr.filesFor(active.id)?.activePath;
          },
          listener: (context, state) {
            final active = context.read<WorkspacesCubit>().state.activeWorkspace;
            if (active == null) return;
            final activePath = state.filesFor(active.id)?.activePath;
            final explorer = context.read<ExplorerCubit>();
            if (activePath == null) {
              explorer.clearSelection(active.id);
            } else {
              explorer.revealPath(active.id, active.path, activePath);
            }
          },
        ),
      ],
      child: BlocBuilder<WorkspacesCubit, WorkspacesState>(
        builder: (context, wsState) {
          final active = wsState.activeWorkspace;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExplorerHeader(
                onRefresh: active != null
                    ? () => context
                        .read<ExplorerCubit>()
                        .refresh(active.id, active.path)
                    : null,
              ),
              Expanded(
                child: active == null
                    ? const SizedBox.shrink()
                    : _ExplorerTree(workspace: active),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExplorerTree extends HookWidget {
  const _ExplorerTree({required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final lastScrolledPath = useRef<String?>(null);

    return BlocBuilder<ExplorerCubit, ExplorerState>(
      builder: (context, state) {
        final tree = state.trees[workspace.id];

        if (tree == null) {
          return const SizedBox.shrink();
        }

        if (tree.errors.containsKey(workspace.path) &&
            !tree.children.containsKey(workspace.path)) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              'shell.sidePanel.loadError'.tr(),
              style: AppTypography.bodyMain.copyWith(
                fontSize: 13,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          );
        }

        final visible = _buildVisible(workspace.path, tree, state.showHidden);

        if (visible.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              'shell.sidePanel.emptyFolder'.tr(),
              style: AppTypography.bodyMain.copyWith(
                fontSize: 13,
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          );
        }

        final selectedPath = tree.selectedPath;
        if (selectedPath != null && selectedPath != lastScrolledPath.value) {
          final idx = visible.indexWhere((e) => e.node.path == selectedPath);
          if (idx >= 0) {
            lastScrolledPath.value = selectedPath;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!scrollController.hasClients) return;
              final target = idx * ExplorerNodeRow.rowHeight;
              final viewport = scrollController.position.viewportDimension;
              final offset = scrollController.offset;
              if (target < offset || target > offset + viewport - ExplorerNodeRow.rowHeight) {
                final desired = (target - viewport / 2 + ExplorerNodeRow.rowHeight)
                    .clamp(0.0, scrollController.position.maxScrollExtent);
                scrollController.animateTo(
                  desired,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        } else if (selectedPath == null) {
          lastScrolledPath.value = null;
        }

        return ListView.builder(
          controller: scrollController,
          itemCount: visible.length,
          itemExtent: ExplorerNodeRow.rowHeight,
          itemBuilder: (context, index) {
            final entry = visible[index];
            return ExplorerNodeRow(
              key: ValueKey<String>(entry.node.path),
              node: entry.node,
              depth: entry.depth,
              workspaceId: workspace.id,
              isExpanded: tree.expanded.contains(entry.node.path),
              isLoading: tree.loading.contains(entry.node.path),
              isSelected: tree.selectedPath == entry.node.path,
              error: tree.errors[entry.node.path],
            );
          },
        );
      },
    );
  }

  List<_VisibleEntry> _buildVisible(
    String rootPath,
    WorkspaceTree tree,
    bool showHidden,
  ) {
    final out = <_VisibleEntry>[];
    void walk(String parent, int depth) {
      final children = tree.children[parent];
      if (children == null) return;
      for (final c in children) {
        if (!showHidden && c.name.startsWith('.')) continue;
        out.add(_VisibleEntry(node: c, depth: depth));
        if (c.isDir && tree.expanded.contains(c.path)) {
          walk(c.path, depth + 1);
        }
      }
    }

    walk(rootPath, 0);
    return out;
  }
}

class _VisibleEntry {
  const _VisibleEntry({required this.node, required this.depth});

  final FileNode node;
  final int depth;
}
