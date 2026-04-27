import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Decorative macOS-style window controls. Non-functional for now;
/// real window control comes via window_manager later.
class MacTrafficLights extends StatelessWidget {
  const MacTrafficLights({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Light(color: AppColors.trafficClose),
        SizedBox(width: 8),
        _Light(color: AppColors.trafficMinimize),
        SizedBox(width: 8),
        _Light(color: AppColors.trafficMaximize),
      ],
    );
  }
}

class _Light extends StatelessWidget {
  const _Light({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
      ),
    );
  }
}
