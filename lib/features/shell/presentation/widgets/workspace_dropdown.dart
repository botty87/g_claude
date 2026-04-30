import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';

class WorkspaceDropdown extends StatelessWidget {
  const WorkspaceDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final active = context.select<WorkspacesCubit, Workspace?>(
      (c) => c.state.activeWorkspace,
    );
    final workspaces = context.select<WorkspacesCubit, List<Workspace>>(
      (c) => c.state.workspacesOrEmpty,
    );

    return Hoverable(
      key: const ValueKey('workspace_dropdown'),
      onTap: () => _showMenu(context, workspaces, active),
      builder: (context, hover) {
        return Container(
          height: 28,
          constraints: const BoxConstraints(maxWidth: 200),
          decoration: BoxDecoration(
            color: hover ? AppColors.glassHover : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Symbols.folder,
                  size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  active?.name ?? 'workspace.dropdown.empty'.tr(),
                  style: AppTypography.bodyMain.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Symbols.expand_more,
                  size: 14, color: AppColors.onSurfaceVariant),
            ],
          ),
        );
      },
    );
  }

  void _showMenu(
    BuildContext context,
    List<Workspace> workspaces,
    Workspace? active,
  ) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + size.height,
      offset.dx + size.width,
      offset.dy + size.height + 8,
    );

    final cubit = context.read<WorkspacesCubit>();

    final items = <PopupMenuEntry<String>>[];

    for (final ws in workspaces) {
      items.add(
        PopupMenuItem<String>(
          value: 'select:${ws.id}',
          padding: EdgeInsets.zero,
          mouseCursor: SystemMouseCursors.click,
          child: _WorkspaceMenuItem(
            workspace: ws,
            isActive: ws.id == active?.id,
            onClose: () {
              Navigator.of(context, rootNavigator: true).pop();
              cubit.closeWorkspace(ws.id);
            },
          ),
        ),
      );
    }

    if (workspaces.isNotEmpty) {
      items.add(const PopupMenuDivider());
    }

    items.add(
      PopupMenuItem<String>(
        value: 'open',
        mouseCursor: SystemMouseCursors.click,
        child: Row(
          children: [
            const Icon(Symbols.add,
                size: 16, color: AppColors.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'workspace.dropdown.openFolder'.tr(),
              style: AppTypography.bodyMain.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );

    showMenu<String>(
      context: context,
      position: position,
      color: AppColors.surfaceContainerHigh,
      items: items,
    ).then((value) {
      if (value == null) return;
      if (value == 'open') {
        cubit.openFromPicker();
      } else if (value.startsWith('select:')) {
        final id = value.substring('select:'.length);
        cubit.setActive(id);
      }
    });
  }
}

class _WorkspaceMenuItem extends StatelessWidget {
  const _WorkspaceMenuItem({
    required this.workspace,
    required this.isActive,
    required this.onClose,
  });

  final Workspace workspace;
  final bool isActive;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: workspace.path,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(
              Symbols.folder,
              size: 16,
              color: isActive
                  ? AppColors.brandIndigo
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                workspace.name,
                style: AppTypography.bodyMain.copyWith(
                  fontSize: 13,
                  color: isActive
                      ? AppColors.onSurface
                      : AppColors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Hoverable(
              onTap: onClose,
              builder: (context, hover) => Tooltip(
                message: 'workspace.dropdown.closeWorkspace'.tr(),
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: hover
                        ? AppColors.glassHover
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Symbols.close,
                    size: 14,
                    color: AppColors.onSurfaceVariant
                        .withValues(alpha: hover ? 1.0 : 0.6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
