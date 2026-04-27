import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const TextTheme base = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
    headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  );
}
