import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../editor/presentation/cubit/editor_view_cubit.dart';
import '../../../editor/presentation/cubit/file_tabs_cubit.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../domain/entities/file_node.dart';
import '../cubit/explorer_cubit.dart';

class ExplorerNodeRow extends StatelessWidget {
  const ExplorerNodeRow({
    super.key,
    required this.node,
    required this.depth,
    required this.workspaceId,
    required this.isExpanded,
    required this.isLoading,
    this.isSelected = false,
    this.error,
  });

  final FileNode node;
  final int depth;
  final WorkspaceId workspaceId;
  final bool isExpanded;
  final bool isLoading;
  final bool isSelected;
  final Failure? error;

  static const indentPerLevel = 14.0;
  static const chevronSize = 14.0;
  static const fileIconSize = 16.0;
  static const rowHeight = 22.0;

  @override
  Widget build(BuildContext context) {
    final isDir = node.isDir;

    // Opening a file surfaces it in the center: peek over the chat, unless the
    // full Code view is already showing (then it just adds a tab). Explicit —
    // re-clicking the already-active file re-opens the peek.
    void surface() {
      final editorView = context.read<EditorViewCubit>();
      if (editorView.state.dataFor(workspaceId).view != CenterView.code) {
        editorView.openPeek(workspaceId);
      }
    }

    return Hoverable(
      onTap: isDir
          ? () => context.read<ExplorerCubit>().toggleFolder(workspaceId, node.path)
          : () {
              context.read<FileTabsCubit>().openFile(workspaceId, node.path);
              surface();
            },
      onDoubleTap: isDir
          ? null
          : () {
              final cubit = context.read<FileTabsCubit>();
              cubit.openFile(workspaceId, node.path);
              cubit.pinFile(workspaceId, node.path);
              surface();
            },
      builder: (context, hover) {
        final Color background;
        if (isSelected) {
          background = AppColors.primaryContainer.withValues(alpha: 0.35);
        } else if (hover) {
          background = AppColors.glassHover;
        } else {
          background = Colors.transparent;
        }
        return Container(
          height: rowHeight,
          color: background,
          padding: EdgeInsetsDirectional.only(start: AppSpacing.sm + depth * indentPerLevel, end: AppSpacing.sm),
          child: Row(
            children: [
              _buildLeadingSlot(),
              const SizedBox(width: 4),
              _buildFileIcon(),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  node.name,
                  style: AppTypography.bodyMain.copyWith(
                    fontSize: 13,
                    color: isSelected ? AppColors.onPrimaryContainer : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeadingSlot() {
    // Files get a fixed-size spacer so names align with dir names
    if (!node.isDir) {
      return const SizedBox(width: chevronSize, height: chevronSize);
    }

    if (isLoading) {
      return const SizedBox(
        width: chevronSize,
        height: chevronSize,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      );
    }

    if (error != null) {
      final message = switch (error!) {
        NotFoundFailure(:final message) => message,
        UnexpectedFailure(:final message) => message,
        ValidationFailure(:final message) => message,
        _ => 'Error',
      };
      return Tooltip(
        message: message,
        child: const Icon(Symbols.error_outline, size: chevronSize, color: AppColors.error),
      );
    }

    return Icon(
      isExpanded ? Symbols.expand_more : Symbols.chevron_right,
      size: chevronSize,
      color: AppColors.onSurfaceVariant,
    );
  }

  Widget _buildFileIcon() {
    final IconData icon;
    if (node.isDir) {
      icon = isExpanded ? Symbols.folder_open : Symbols.folder;
    } else {
      icon = Symbols.description;
    }
    return Icon(icon, size: fileIconSize, color: AppColors.onSurfaceVariant);
  }
}
