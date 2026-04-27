import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.seed, brightness: Brightness.light),
    scaffoldBackgroundColor: AppColors.lightBg,
    textTheme: AppTypography.base,
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.seed, brightness: Brightness.dark),
    scaffoldBackgroundColor: AppColors.darkBg,
    textTheme: AppTypography.base,
  );
}
