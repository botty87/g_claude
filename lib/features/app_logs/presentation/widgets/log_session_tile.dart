import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hoverable.dart';
import '../../domain/entities/app_log_session.dart';
import '../cubit/app_logs_cubit.dart';

class LogSessionTile extends StatelessWidget {
  const LogSessionTile({super.key, required this.session, required this.isSelected});

  final AppLogSession session;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      onTap: () => context.read<AppLogsCubit>().selectSession(session.id),
      builder: (context, hover) {
        Color? bg;
        if (isSelected) {
          bg = AppColors.surfaceContainer;
        } else if (hover) {
          bg = AppColors.glassHover;
        }

        return Container(
          constraints: const BoxConstraints(minHeight: 56),
          color: bg,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatRange(session),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMain.copyWith(fontSize: 12, color: AppColors.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (session.errorCount > 0)
                          _CountBadge(
                            label: Locales.AppLogs.Session.errors(count: '${session.errorCount}'),
                            color: AppColors.error,
                          ),
                        if (session.errorCount > 0) const SizedBox(width: 4),
                        if (session.warningCount > 0)
                          _CountBadge(
                            label: Locales.AppLogs.Session.warnings(count: '${session.warningCount}'),
                            color: AppColors.tertiary,
                          ),
                        if (session.warningCount > 0) const SizedBox(width: 4),
                        _CountBadge(
                          label: Locales.AppLogs.Session.total(count: '${session.totalCount}'),
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Tooltip(
                message: Locales.AppLogs.Session.delete,
                child: Hoverable(
                  onTap: () => _confirmDelete(context),
                  builder: (context, hover) => Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: hover ? AppColors.glassHover : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Icon(Symbols.delete, size: 14, color: hover ? AppColors.error : AppColors.onSurfaceVariant),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final cubit = context.read<AppLogsCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(Locales.AppLogs.Session.deleteConfirmTitle),
        content: Text(Locales.AppLogs.Session.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(Locales.AppLogs.Session.deleteConfirmCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(Locales.AppLogs.Session.deleteConfirmOk),
          ),
        ],
      ),
    );
    if (ok == true) {
      await cubit.deleteSession(session.id);
    }
  }

  String _formatRange(AppLogSession s) {
    final start = _formatTime(s.startedAt);
    if (s.endedAt == null) {
      return '$start  ·  ${Locales.AppLogs.Session.inProgress}';
    }
    final end = _sameDay(s.startedAt, s.endedAt!) ? _formatHMS(s.endedAt!) : _formatTime(s.endedAt!);
    return '$start  →  $end';
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatTime(DateTime dt) {
    final d = '${_pad2(dt.day)}/${_pad2(dt.month)}';
    return '$d ${_formatHMS(dt)}';
  }

  String _formatHMS(DateTime dt) => '${_pad2(dt.hour)}:${_pad2(dt.minute)}:${_pad2(dt.second)}';

  String _pad2(int n) => n.toString().padLeft(2, '0');
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Text(label, style: AppTypography.bodyMain.copyWith(fontSize: 10, color: color)),
    );
  }
}
