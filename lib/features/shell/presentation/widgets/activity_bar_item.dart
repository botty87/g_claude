import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../shared/widgets/hoverable.dart';

class ActivityBarItem extends StatelessWidget {
  const ActivityBarItem({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.isEnabled,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool isActive;
  final bool isEnabled;
  final VoidCallback? onTap;

  Color _iconColor(bool hover) {
    if (!isEnabled) return AppColors.onSurfaceVariant.withValues(alpha: 0.25);
    if (isActive) return AppColors.primary;
    return AppColors.onSurfaceVariant.withValues(alpha: hover ? 1.0 : 0.7);
  }

  Color _fillColor(bool hover) {
    if (isActive) return AppColors.glassActive;
    if (hover && isEnabled) return AppColors.glassHover;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final tooltipMessage = isEnabled
        ? tooltip
        : '$tooltip${Locales.Shell.Activity.comingLaterSuffix}';
    return Tooltip(
      message: tooltipMessage,
      child: Hoverable(
        cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onTap: isEnabled ? onTap : null,
        builder: (context, hover) => Stack(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _fillColor(hover),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(icon, size: 20, color: _iconColor(hover)),
            ),
            if (isActive)
              Positioned(
                left: 0,
                top: 6,
                bottom: 6,
                child: Container(
                  width: 2,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(2)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
