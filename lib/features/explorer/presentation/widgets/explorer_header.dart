import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

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
            'shell.sidePanel.explorerLabel'.tr(),
            style: AppTypography.sidebarLabel.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          BlocSelector<ExplorerCubit, ExplorerState, bool>(
            selector: (state) => state.showHidden,
            builder: (context, showHidden) {
              return Tooltip(
                message: showHidden
                    ? 'shell.sidePanel.toggleHiddenHide'.tr()
                    : 'shell.sidePanel.toggleHiddenShow'.tr(),
                child: _HeaderIconButton(
                  icon: showHidden ? Symbols.visibility_off : Symbols.visibility,
                  onTap: () => context.read<ExplorerCubit>().toggleHidden(),
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.xs),
          Tooltip(
            message: 'shell.sidePanel.refresh'.tr(),
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
