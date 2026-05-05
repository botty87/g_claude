import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../cubit/explorer_cubit.dart';

class ExplorerHeader extends StatelessWidget {
  const ExplorerHeader({
    super.key,
    this.onRefresh,
  });

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Text(
            Locales.Shell.SidePanel.explorerLabel,
            style: AppTypography.sidebarLabel.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          const _ToggleHiddenButton(),
          const SizedBox(width: AppSpacing.xs),
          Tooltip(
            message: Locales.Shell.SidePanel.refresh,
            child: _HeaderIconButton(
              icon: Symbols.refresh,
              onTap: onRefresh,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleHiddenButton extends StatelessWidget {
  const _ToggleHiddenButton();

  @override
  Widget build(BuildContext context) {
    final showHidden = context.select<ExplorerCubit, bool>(
      (c) => c.state.showHidden,
    );
    return Tooltip(
      message: showHidden
          ? Locales.Shell.SidePanel.toggleHiddenHide
          : Locales.Shell.SidePanel.toggleHiddenShow,
      child: _HeaderIconButton(
        icon: showHidden ? Symbols.visibility_off : Symbols.visibility,
        onTap: () => context.read<ExplorerCubit>().toggleHidden(),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: onTap,
      builder: (context, hover) {
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: hover ? AppColors.glassHover : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Icon(
            icon,
            size: 14,
            color: hover
                ? AppColors.onSurface
                : AppColors.onSurfaceVariant,
          ),
        );
      },
    );
  }
}
