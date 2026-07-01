import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../workspace/domain/entities/workspace.dart';
import '../../../workspace/presentation/cubit/workspaces_cubit.dart';
import '../cubit/shell_cubit.dart';
import 'activity_mini_rail.dart';

const double kSidebarExpandedWidth = 262;
const double kSidebarCollapsedWidth = 52;

const _tints = [AppColors.brandIndigo, AppColors.secondary, AppColors.tertiary, AppColors.primary];

Color _tintFor(int index) => _tints[index % _tints.length];

String _initialFor(String name) => name.isEmpty ? '?' : name.characters.first.toUpperCase();

/// Left navigation region: workspace switcher + activity mini-rail.
/// Replaces the old vertical [ActivityBar] and the top-right workspace dropdown.
class WorkspaceSidebar extends StatelessWidget {
  const WorkspaceSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final collapsed = context.select<ShellCubit, bool>((c) => c.state.sidebarCollapsed);
    return Container(
      width: collapsed ? kSidebarCollapsedWidth : kSidebarExpandedWidth,
      decoration: BoxDecoration(
        color: collapsed ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
        border: const Border(right: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: collapsed ? const _CollapsedRail() : const _ExpandedSidebar(),
    );
  }
}

class _ExpandedSidebar extends StatelessWidget {
  const _ExpandedSidebar();

  @override
  Widget build(BuildContext context) {
    final workspaces = context.select<WorkspacesCubit, List<Workspace>>((c) => c.state.workspacesOrEmpty);
    final activeId = context.select<WorkspacesCubit, WorkspaceId?>((c) => c.state.activeIdOrNull);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
          child: Row(
            children: [
              Text(Locales.Shell.Sidebar.header, style: AppTypography.sidebarLabel.copyWith(color: AppColors.outline)),
              const Spacer(),
              _IconButton(
                icon: Symbols.chevron_left,
                tooltip: Locales.Shell.Sidebar.collapse,
                onTap: () => context.read<ShellCubit>().toggleSidebar(),
                keyName: 'sidebar_collapse',
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
          child: Hoverable(
            onTap: () => context.read<WorkspacesCubit>().openFromPicker(),
            builder: (context, hover) => Container(
              key: const ValueKey('sidebar_new_workspace'),
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: hover ? AppColors.glassHover : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid),
              ),
              child: Row(
                children: [
                  const Icon(Symbols.add, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    Locales.Shell.Sidebar.newWorkspace,
                    style: AppTypography.navTab.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            itemCount: workspaces.length,
            itemBuilder: (context, index) {
              final w = workspaces[index];
              return _WorkspaceRow(workspace: w, tint: _tintFor(index), isActive: w.id == activeId);
            },
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
          child: ActivityMiniRail(axis: Axis.horizontal),
        ),
      ],
    );
  }
}

class _WorkspaceRow extends StatelessWidget {
  const _WorkspaceRow({required this.workspace, required this.tint, required this.isActive});

  final Workspace workspace;
  final Color tint;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: () => context.read<WorkspacesCubit>().setActive(workspace.id),
      builder: (context, hover) => Container(
        height: 34,
        margin: const EdgeInsets.symmetric(vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.brandIndigo.withValues(alpha: 0.14)
              : (hover ? AppColors.glassHover : Colors.transparent),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border(left: BorderSide(color: isActive ? AppColors.brandIndigo : Colors.transparent, width: 2)),
        ),
        child: Row(
          children: [
            _Avatar(initial: _initialFor(workspace.name), tint: tint),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                workspace.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.navTab.copyWith(
                  color: isActive ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsedRail extends StatelessWidget {
  const _CollapsedRail();

  @override
  Widget build(BuildContext context) {
    final workspaces = context.select<WorkspacesCubit, List<Workspace>>((c) => c.state.workspacesOrEmpty);
    final activeId = context.select<WorkspacesCubit, WorkspaceId?>((c) => c.state.activeIdOrNull);

    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        _IconButton(
          icon: Symbols.chevron_right,
          tooltip: Locales.Shell.Sidebar.expand,
          onTap: () => context.read<ShellCubit>().toggleSidebar(),
          keyName: 'sidebar_expand',
        ),
        const SizedBox(height: AppSpacing.xs),
        const Divider(height: 1, thickness: 1, indent: 12, endIndent: 12, color: AppColors.outlineVariant),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: workspaces.length,
            itemBuilder: (context, index) {
              final w = workspaces[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Center(
                  child: Hoverable(
                    onTap: () => context.read<WorkspacesCubit>().setActive(w.id),
                    builder: (context, hover) => Tooltip(
                      message: w.name,
                      child: _Avatar(
                        initial: _initialFor(w.name),
                        tint: _tintFor(index),
                        active: w.id == activeId,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Hoverable(
            onTap: () => context.read<WorkspacesCubit>().openFromPicker(),
            builder: (context, hover) => Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.outlineVariant),
                color: hover ? AppColors.glassHover : Colors.transparent,
              ),
              child: const Icon(Symbols.add, size: 16, color: AppColors.primary),
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, indent: 12, endIndent: 12, color: AppColors.outlineVariant),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: ActivityMiniRail(axis: Axis.vertical),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial, required this.tint, this.active = false, this.size = 18});

  final String initial;
  final Color tint;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: active ? [const BoxShadow(color: AppColors.brandIndigo, spreadRadius: 2)] : null,
      ),
      child: Text(
        initial,
        style: TextStyle(fontSize: size * 0.5, fontWeight: FontWeight.w700, color: AppColors.surfaceContainerLowest),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.tooltip, required this.onTap, required this.keyName});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: onTap,
      builder: (context, hover) => Tooltip(
        message: tooltip,
        child: Container(
          key: ValueKey(keyName),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: hover ? AppColors.glassHover : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}
