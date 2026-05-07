import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Glass Graphite typography. Inter for UI chrome, JetBrains Mono for code.
abstract final class AppTypography {
  /// Inter — UI base. 14/20 w400.
  static TextStyle bodyMain = GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  /// Inter — nav tabs. 12/16 w500.
  static TextStyle navTab = GoogleFonts.inter(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500);

  /// Inter — sidebar labels (uppercase). 11/16 w600 letter-spacing 0.05em.
  static TextStyle sidebarLabel = GoogleFonts.inter(
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.55, // 0.05em ≈ 0.05 * 11 = 0.55
  );

  /// JetBrains Mono — terminal/code body. 13/1.6 w400.
  static TextStyle terminalCode = GoogleFonts.jetBrainsMono(fontSize: 13, height: 1.6, fontWeight: FontWeight.w400);

  /// JetBrains Mono — terminal prompt / "You" / "Claude" labels. 13/1.6 w700.
  static TextStyle terminalPrompt = GoogleFonts.jetBrainsMono(fontSize: 13, height: 1.6, fontWeight: FontWeight.w700);

  /// Brand wordmark (top header). Inter 11 w700 wide-tracking uppercase.
  static TextStyle brand = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.65, // wide-tracking
    color: const Color(0xE6FFFFFF),
  );

  /// Material 3 [TextTheme] — most slots map to Inter; monospaced styles
  /// are kept opt-in via the named getters above.
  static TextTheme get textTheme {
    final base = GoogleFonts.interTextTheme();
    return base.apply(bodyColor: AppColors.onSurface, displayColor: AppColors.onSurface);
  }
}
