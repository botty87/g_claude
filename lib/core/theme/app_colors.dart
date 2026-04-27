import 'package:flutter/material.dart';

/// Glass Graphite color tokens (Material 3 dark scheme + accents).
abstract final class AppColors {
  // Brand
  static const brandIndigo = Color(0xFF5C5AE7);

  // Surfaces (deep space)
  static const surface = Color(0xFF13131B);
  static const surfaceContainerLowest = Color(0xFF0E0D15);
  static const surfaceContainerLow = Color(0xFF1B1B23);
  static const surfaceContainer = Color(0xFF1F1F27);
  static const surfaceContainerHigh = Color(0xFF2A2932);
  static const surfaceContainerHighest = Color(0xFF34343D);
  static const surfaceBright = Color(0xFF393841);
  static const surfaceVariant = Color(0xFF34343D);

  // On-surface
  static const onSurface = Color(0xFFE4E1ED);
  static const onSurfaceVariant = Color(0xFFC7C4D7);

  // Outlines
  static const outline = Color(0xFF918FA0);
  static const outlineVariant = Color(0xFF464554);

  // Primary (light indigo for use on dark)
  static const primary = Color(0xFFC2C1FF);
  static const onPrimary = Color(0xFF1800A7);
  static const primaryContainer = Color(0xFF5C5AE7);
  static const onPrimaryContainer = Color(0xFFF2EFFF);

  // Secondary (sky)
  static const secondary = Color(0xFF87CEFF);
  static const onSecondary = Color(0xFF00344D);
  static const secondaryContainer = Color(0xFF027CB0);
  static const onSecondaryContainer = Color(0xFFFCFCFF);

  // Tertiary (peach)
  static const tertiary = Color(0xFFFFB688);
  static const onTertiary = Color(0xFF512400);
  static const tertiaryContainer = Color(0xFFAE5400);
  static const onTertiaryContainer = Color(0xFFFFEDE4);

  // Error
  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF93000A);
  static const onErrorContainer = Color(0xFFFFDAD6);

  // Glass overlays — used by [GlassWindow] / [GlassPane]
  static const glassWindowFill = Color(0xA6131B1B); // rgba(19,19,27,0.65) — alpha 0xA6
  static const glassPaneFill = Color(0x80000000); // rgba(0,0,0,0.5)
  static const glassBorder = Color(0x1AFFFFFF); // white 10%
  static const glassHover = Color(0x0DFFFFFF); // white 5%
  static const glassActive = Color(0x1AFFFFFF); // white 10%

  // Mac traffic lights
  static const trafficClose = Color(0xFFFF5F56);
  static const trafficMinimize = Color(0xFFFFBD2E);
  static const trafficMaximize = Color(0xFF27C93F);
}
