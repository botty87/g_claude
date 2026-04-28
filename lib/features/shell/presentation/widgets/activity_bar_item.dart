import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';

class ActivityBarItem extends StatefulWidget {
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

  @override
  State<ActivityBarItem> createState() => _ActivityBarItemState();
}

class _ActivityBarItemState extends State<ActivityBarItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final iconColor = !widget.isEnabled
        ? AppColors.onSurfaceVariant.withValues(alpha: 0.25)
        : widget.isActive
            ? AppColors.primary
            : AppColors.onSurfaceVariant.withValues(alpha: _hover ? 1.0 : 0.7);
    final fill = widget.isActive
        ? AppColors.glassActive
        : (_hover && widget.isEnabled)
            ? AppColors.glassHover
            : Colors.transparent;
    final tooltipMessage = widget.isEnabled
        ? widget.tooltip
        : '${widget.tooltip} (coming later)';
    final child = Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Icon(widget.icon, size: 20, color: iconColor),
        ),
        if (widget.isActive)
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
    );
    return Tooltip(
      message: tooltipMessage,
      child: MouseRegion(
        cursor: widget.isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.isEnabled ? widget.onTap : null,
          child: child,
        ),
      ),
    );
  }
}
