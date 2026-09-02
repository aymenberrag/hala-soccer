import 'package:flutter/material.dart';

/// Hala Soccer brand palette.
///
/// The teal→green gradient and dark navy accent are lifted directly from
/// the original app (`customwidgets.dart`, `halasoccerwidgets.dart`) so
/// "Hala Soccer 2.0" stays visually recognizable as the same product.
class AppColors {
  AppColors._();

  // --- Brand (unchanged from v1) ---
  static const Color brandTealDark = Color.fromARGB(255, 8, 107, 102); // #086B66
  static const Color brandGreenBright = Color.fromARGB(255, 26, 218, 154); // #1ADA9A
  static const Color brandNavyDark = Color.fromARGB(255, 5, 37, 32); // #052520

  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandTealDark, brandGreenBright],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradientVertical = LinearGradient(
    colors: [brandNavyDark, brandTealDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // --- Surfaces (new, for the 2.0 "premium dark" look) ---
  static const Color background = Color(0xFF071A17);
  static const Color surface = Color(0xFF0E2A25);
  static const Color surfaceElevated = Color(0xFF123A33);
  static const Color surfaceCard = Color(0xFF102E28);

  // --- Text ---
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB7CFC9);
  static const Color textMuted = Color(0xFF7C9891);

  // --- Semantic ---
  static const Color live = Color(0xFFE23F3F);
  static const Color success = brandGreenBright;
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFE23F3F);
  static const Color divider = Color(0x1FFFFFFF); // white @ 12%
}
