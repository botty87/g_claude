import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';

/// Outermost translucent shell — radius 16, blur 40, fill rgba(19,19,27,0.65),
/// border 1px white/10. Hosts the chrome (TopHeader + Sidebar + Workspace).
class GlassWindow extends StatelessWidget {
  const GlassWindow({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.xl)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.glassWindowFill,
            border: Border.all(color: AppColors.glassBorder),
            borderRadius: const BorderRadius.all(Radius.circular(AppRadii.xl)),
          ),
          child: child,
        ),
      ),
    );
  }
}
