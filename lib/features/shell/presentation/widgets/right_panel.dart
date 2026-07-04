import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../../explorer/presentation/widgets/explorer_view.dart';
import '../cubit/shell_cubit.dart';
import 'diff_panel_view.dart';
import 'workspace_sidebar.dart' show kSidebarAnimDuration, kSidebarAnimCurve;

const double kRightPanelCollapsedWidth = 52;

enum _RightTab { files, diff }

/// Right-hand navigation panel: Files tree and Diff. Pure navigation — clicking
/// a file opens it in the center (peek / Code view), not here. Collapsible to an
/// icon rail exactly like the left [WorkspaceSidebar]; its width is animated by
/// the enclosing split (see `app_shell.dart`).
class RightPanel extends HookWidget {
  const RightPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final tab = useState(_RightTab.files);
    final collapsed = context.select<ShellCubit, bool>((c) => c.state.rightPanelCollapsed);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(left: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: kSidebarAnimDuration,
          switchInCurve: kSidebarAnimCurve,
          switchOutCurve: kSidebarAnimCurve,
          child: collapsed
              ? _PinnedWidth(
                  key: const ValueKey('right_collapsed'),
                  width: kRightPanelCollapsedWidth,
                  child: _CollapsedRail(
                    onSelect: (t) {
                      tab.value = t;
                      context.read<ShellCubit>().toggleRightPanel();
                    },
                    onExpand: () => context.read<ShellCubit>().toggleRightPanel(),
                  ),
                )
              : KeyedSubtree(
                  key: const ValueKey('right_expanded'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TabBar(
                        current: tab.value,
                        onSelect: (t) => tab.value = t,
                        onCollapse: () => context.read<ShellCubit>().toggleRightPanel(),
                      ),
                      Expanded(
                        child: switch (tab.value) {
                          _RightTab.files => const ExplorerView(),
                          _RightTab.diff => const DiffPanelView(),
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// Pins [child] to a fixed [width] while the panel width tweens — mirrors the
/// sidebar's `_PinnedWidth` so the icon rail never reflows during the animation.
class _PinnedWidth extends StatelessWidget {
  const _PinnedWidth({super.key, required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      alignment: Alignment.topCenter,
      minWidth: width,
      maxWidth: width,
      child: SizedBox(width: width, child: child),
    );
  }
}

class _CollapsedRail extends StatelessWidget {
  const _CollapsedRail({required this.onSelect, required this.onExpand});

  final ValueChanged<_RightTab> onSelect;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        _RailButton(
          keyName: 'right_expand',
          icon: Symbols.chevron_left,
          tooltip: Locales.Shell.RightPanel.expand,
          onTap: onExpand,
        ),
        const SizedBox(height: AppSpacing.sm),
        _RailButton(
          keyName: 'right_rail_files',
          icon: Symbols.folder,
          tooltip: Locales.Shell.RightPanel.files,
          onTap: () => onSelect(_RightTab.files),
        ),
        _RailButton(
          keyName: 'right_rail_diff',
          icon: Symbols.difference,
          tooltip: Locales.Shell.RightPanel.diff,
          onTap: () => onSelect(_RightTab.diff),
        ),
      ],
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({required this.keyName, required this.icon, required this.tooltip, required this.onTap});

  final String keyName;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Hoverable(
        onTap: onTap,
        builder: (context, hover) => Container(
          key: ValueKey(keyName),
          width: 36,
          height: 36,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: hover ? AppColors.glassHover : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.current, required this.onSelect, required this.onCollapse});

  final _RightTab current;
  final ValueChanged<_RightTab> onSelect;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TabButton(
            keyName: 'right_tab_files',
            icon: Symbols.folder,
            label: Locales.Shell.RightPanel.files,
            isActive: current == _RightTab.files,
            onTap: () => onSelect(_RightTab.files),
          ),
          _TabButton(
            keyName: 'right_tab_diff',
            icon: Symbols.difference,
            label: Locales.Shell.RightPanel.diff,
            isActive: current == _RightTab.diff,
            onTap: () => onSelect(_RightTab.diff),
          ),
          const Spacer(),
          Tooltip(
            message: Locales.Shell.RightPanel.collapse,
            child: Hoverable(
              onTap: onCollapse,
              builder: (context, hover) => Container(
                key: const ValueKey('right_collapse'),
                width: 30,
                alignment: Alignment.center,
                child: Icon(Symbols.chevron_right, size: 18, color: hover ? AppColors.onSurface : AppColors.outline),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.keyName,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String keyName;
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.onSurface : AppColors.outline;
    return GestureDetector(
      key: ValueKey(keyName),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: isActive ? AppColors.brandIndigo : Colors.transparent, width: 2)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label, style: AppTypography.navTab.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
