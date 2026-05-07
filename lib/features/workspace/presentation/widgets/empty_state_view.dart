import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../cubit/workspaces_cubit.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.folder_open, size: 56, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            key: const ValueKey('empty_state_open_folder'),
            onPressed: () => context.read<WorkspacesCubit>().openFromPicker(),
            icon: const Icon(Symbols.folder_open, size: 18),
            label: Text(Locales.Workspace.EmptyState.openFolder),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: AppColors.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            Locales.Workspace.EmptyState.hint,
            style: AppTypography.bodyMain.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
