import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/app_log_entry.dart';
import 'log_level_filter_chip.dart' show colorFor, labelFor;

class LogEntryTile extends StatefulWidget {
  const LogEntryTile({super.key, required this.entry});

  final AppLogEntry entry;

  @override
  State<LogEntryTile> createState() => _LogEntryTileState();
}

// Stateful kept here intentionally: ExpansionTile requires its own controller
// state to persist expanded flag across rebuilds in long lists.
class _LogEntryTileState extends State<LogEntryTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final color = colorFor(e.level);
    final hasDetails = e.exception != null || e.stackTrace != null;

    return InkWell(
      onTap: hasDetails ? () => setState(() => _expanded = !_expanded) : null,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    _formatTime(e.time),
                    style: AppTypography.terminalCode.copyWith(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labelFor(e.level).toUpperCase(),
                    style: AppTypography.terminalCode.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (e.title != null && e.title!.isNotEmpty)
                        Text(
                          e.title!,
                          style: AppTypography.terminalCode.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      Text(
                        e.message,
                        maxLines: _expanded ? null : 4,
                        overflow:
                            _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: AppTypography.terminalCode.copyWith(
                          fontSize: 11,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_expanded && hasDetails)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 64),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (e.exception != null) ...[
                      Text(
                        Locales.AppLogs.Detail.exception,
                        style: AppTypography.sidebarLabel.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SelectableText(
                        e.exception!,
                        style: AppTypography.terminalCode.copyWith(
                          fontSize: 10,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    if (e.stackTrace != null) ...[
                      Text(
                        Locales.AppLogs.Detail.stackTrace,
                        style: AppTypography.sidebarLabel.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SelectableText(
                        e.stackTrace!,
                        style: AppTypography.terminalCode.copyWith(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final ms = dt.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }
}
