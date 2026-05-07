import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/app_log_entry.dart';
import '../cubit/app_log_detail_cubit.dart';

class LogLevelFilterChips extends StatelessWidget {
  const LogLevelFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.select<AppLogDetailCubit, Set<AppLogLevel>>((c) => c.state.levelFilter);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      child: Row(
        children: [
          for (final lvl in AppLogLevel.values) ...[
            _Chip(
              level: lvl,
              isSelected: selected.contains(lvl),
              onTap: () {
                final next = Set<AppLogLevel>.from(selected);
                if (!next.add(lvl)) next.remove(lvl);
                context.read<AppLogDetailCubit>().setLevelFilter(next);
              },
            ),
            const SizedBox(width: 4),
          ],
          if (selected.isNotEmpty)
            TextButton(
              onPressed: () => context.read<AppLogDetailCubit>().setLevelFilter(const {}),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(0, 22),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'all',
                style: AppTypography.bodyMain.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.level, required this.isSelected, required this.onTap});

  final AppLogLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = colorFor(level);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.18) : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : AppColors.outlineVariant, width: 1),
        ),
        child: Text(
          labelFor(level),
          style: AppTypography.bodyMain.copyWith(
            fontSize: 11,
            color: isSelected ? color : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

String labelFor(AppLogLevel l) {
  switch (l) {
    case AppLogLevel.debug:
      return Locales.AppLogs.Detail.Level.debug;
    case AppLogLevel.info:
      return Locales.AppLogs.Detail.Level.info;
    case AppLogLevel.warning:
      return Locales.AppLogs.Detail.Level.warning;
    case AppLogLevel.error:
      return Locales.AppLogs.Detail.Level.error;
    case AppLogLevel.critical:
      return Locales.AppLogs.Detail.Level.critical;
    case AppLogLevel.verbose:
      return Locales.AppLogs.Detail.Level.verbose;
  }
}

Color colorFor(AppLogLevel l) {
  switch (l) {
    case AppLogLevel.debug:
      return AppColors.onSurfaceVariant;
    case AppLogLevel.info:
      return AppColors.secondary;
    case AppLogLevel.warning:
      return AppColors.tertiary;
    case AppLogLevel.error:
    case AppLogLevel.critical:
      return AppColors.error;
    case AppLogLevel.verbose:
      return AppColors.outline;
  }
}
