import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';

/// In-window translucent pane — radius 12, blur 20, fill rgba(0,0,0,0.5),
/// border 1px white/10. When [isActive], border becomes brand indigo with a
/// 20px glow.
class GlassPane extends StatelessWidget {
  const GlassPane({super.key, required this.child, this.isActive = false});

  final Widget child;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final borderColor = isActive ? AppColors.brandIndigo : AppColors.glassBorder;
    final shadows = isActive
        ? const [BoxShadow(color: Color(0x265C5AE7), blurRadius: 20)] // 0.15 alpha
        : const <BoxShadow>[];
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(AppRadii.lg)), boxShadow: shadows),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.lg)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.glassPaneFill,
              border: Border.all(color: borderColor, width: isActive ? 1.5 : 1),
              borderRadius: const BorderRadius.all(Radius.circular(AppRadii.lg)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
