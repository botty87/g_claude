import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
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
    this.error,
  });

  final FileNode node;
  final int depth;
  final WorkspaceId workspaceId;
  final bool isExpanded;
  final bool isLoading;
  final Failure? error;

  static const indentPerLevel = 14.0;
  static const chevronSize = 14.0;
  static const fileIconSize = 16.0;
  static const rowHeight = 22.0;

  @override
  Widget build(BuildContext context) {
    final isDir = node.isDir;

    return Hoverable(
      cursor: isDir ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onTap: isDir
          ? () => context.read<ExplorerCubit>().toggleFolder(workspaceId, node.path)
          : null,
      builder: (context, hover) {
        return Container(
          height: rowHeight,
          color: hover && isDir ? AppColors.glassHover : Colors.transparent,
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.sm + depth * indentPerLevel,
            end: AppSpacing.sm,
          ),
          child: Row(
            children: [
              _buildLeadingSlot(),
              const SizedBox(width: 4),
              _buildFileIcon(),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  node.name,
                  style: AppTypography.bodyMain.copyWith(fontSize: 13),
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
        child: const Icon(
          Symbols.error_outline,
          size: chevronSize,
          color: AppColors.error,
        ),
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
