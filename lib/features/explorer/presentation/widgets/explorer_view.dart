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
    final activeId = context
        .select<WorkspacesCubit, WorkspaceId?>((c) => c.state.activeIdOrNull);

    useEffect(() {
      if (activeId == null) return null;
      final active = context.read<WorkspacesCubit>().state.activeWorkspace;
      if (active == null) return null;
      final explorer = context.read<ExplorerCubit>();
      final fileTabs = context.read<FileTabsCubit>();
      explorer.ensureRootLoaded(active.id, active.path).then((_) {
        if (!context.mounted) return;
        final activePath = fileTabs.state.filesFor(active.id)?.activePath;
        if (activePath != null) {
          explorer.revealPath(active.id, active.path, activePath);
        } else {
          explorer.clearSelection(active.id);
        }
      });
      return null;
    }, [activeId]);

    final active = context.select<WorkspacesCubit, Workspace?>(
      (c) => c.state.activeWorkspace,
    );

    return BlocListener<FileTabsCubit, FileTabsState>(
      listenWhen: (prev, curr) {
        if (activeId == null) return false;
        return prev.filesFor(activeId)?.activePath !=
            curr.filesFor(activeId)?.activePath;
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
      child: Column(
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

    return BlocConsumer<ExplorerCubit, ExplorerState>(
      listenWhen: (prev, curr) =>
          prev.trees[workspace.id]?.selectedPath !=
          curr.trees[workspace.id]?.selectedPath,
      listener: (context, state) {
        final tree = state.trees[workspace.id];
        if (tree == null) return;
        final selected = tree.selectedPath;
        if (selected == null) return;
        final visible = _buildVisible(workspace.path, tree, state.showHidden);
        final idx = visible.indexWhere((e) => e.node.path == selected);
        if (idx < 0) return;
        _maybeAutoScroll(scrollController, idx);
      },
      buildWhen: (prev, curr) =>
          prev.trees[workspace.id] != curr.trees[workspace.id] ||
          prev.showHidden != curr.showHidden,
      builder: (context, state) {
        final tree = state.trees[workspace.id];
        if (tree == null) {
          return const SizedBox.shrink();
        }

        if (tree.errors.containsKey(workspace.path) &&
            !tree.children.containsKey(workspace.path)) {
          return _ExplorerMessage(text: 'shell.sidePanel.loadError'.tr());
        }

        final visible = _buildVisible(workspace.path, tree, state.showHidden);
        if (visible.isEmpty) {
          return _ExplorerMessage(text: 'shell.sidePanel.emptyFolder'.tr());
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

  void _maybeAutoScroll(ScrollController controller, int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;
      final target = index * ExplorerNodeRow.rowHeight;
      final viewport = controller.position.viewportDimension;
      final offset = controller.offset;
      final inView = target >= offset &&
          target <= offset + viewport - ExplorerNodeRow.rowHeight;
      if (inView) return;
      final desired =
          (target - viewport / 2 + ExplorerNodeRow.rowHeight)
              .clamp(0.0, controller.position.maxScrollExtent);
      controller.animateTo(
        desired,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
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

class _ExplorerMessage extends StatelessWidget {
  const _ExplorerMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Text(
        text,
        style: AppTypography.bodyMain.copyWith(
          fontSize: 13,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}

class _VisibleEntry {
  const _VisibleEntry({required this.node, required this.depth});

  final FileNode node;
  final int depth;
}
