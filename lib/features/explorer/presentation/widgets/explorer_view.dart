import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
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
    // Trigger initial load for the currently active workspace.
    // ExplorerCubit.ensureRootLoaded is idempotent — re-runs are a no-op.
    useEffect(() {
      final active = context.read<WorkspacesCubit>().state.activeWorkspace;
      if (active != null) {
        context.read<ExplorerCubit>().ensureRootLoaded(active.id, active.path);
      }
      return null;
    }, const []);

    return BlocListener<WorkspacesCubit, WorkspacesState>(
      listenWhen: (prev, curr) =>
          prev.activeWorkspace?.id != curr.activeWorkspace?.id,
      listener: (context, state) {
        final active = state.activeWorkspace;
        if (active == null) return;
        context.read<ExplorerCubit>().ensureRootLoaded(active.id, active.path);
      },
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

class _ExplorerTree extends StatelessWidget {
  const _ExplorerTree({required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExplorerCubit, ExplorerState>(
      builder: (context, state) {
        final tree = state.trees[workspace.id];

        if (tree == null) {
          return const SizedBox.shrink();
        }

        // Root-level error
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

        return ListView.builder(
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
