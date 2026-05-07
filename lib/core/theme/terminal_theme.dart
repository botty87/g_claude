import 'package:flutter/painting.dart';
import 'package:xterm/xterm.dart';

import 'app_colors.dart';

/// Glass Graphite ANSI palette used by the embedded xterm view.
/// Kept in `core/theme/` because it inherits the same brand tokens as the
/// rest of the UI and may be shared by future terminal-adjacent surfaces.
const TerminalTheme appTerminalTheme = TerminalTheme(
  cursor: AppColors.brandIndigo,
  selection: AppColors.glassActive,
  foreground: AppColors.onSurface,
  background: AppColors.surface,

  // Normal ANSI 0–7
  black: AppColors.surfaceContainerLowest,
  red: AppColors.error,
  green: Color(0xFF87E091),
  yellow: AppColors.tertiary,
  blue: AppColors.primary,
  magenta: Color(0xFFCEC0FF),
  cyan: AppColors.secondary,
  white: AppColors.onSurface,

  // Bright ANSI 8–15
  brightBlack: AppColors.outlineVariant,
  brightRed: Color(0xFFFFB4AB),
  brightGreen: Color(0xFFA8F0B0),
  brightYellow: Color(0xFFFFCCA0),
  brightBlue: Color(0xFFD0D0FF),
  brightMagenta: Color(0xFFE0D6FF),
  brightCyan: Color(0xFFB3E0FF),
  brightWhite: Color(0xFFF4F1FF),

  searchHitBackground: AppColors.glassActive,
  searchHitBackgroundCurrent: AppColors.brandIndigo,
  searchHitForeground: AppColors.onSurface,
);
