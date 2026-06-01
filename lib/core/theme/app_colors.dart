import 'package:flutter/material.dart';

class AppColors {
  // BRImo Vibrant Royal Blue Brand Palette
  static const Color primary = Color(0xFF0070C0);     // BRImo Classic Royal Blue
  static const Color secondary = Color(0xFF0A2540);   // Deep Navy (used in dark text/appbars)
  static const Color lightBlueBackground = Color(0xFFE8F1FF); // Soft blue accents
  static const Color premiumGold = Color(0xFFD4AF37); // Gold accent

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC);  // Soft slate / Platinum off-white
  static const Color surface = Color(0xFFFFFFFF);     // Pure White
  static const Color textDark = Color(0xFF0F172A);    // Dark Slate
  static const Color textMuted = Color(0xFF64748B);   // Slate Gray
  static const Color border = Color(0xFFE2E8F0);      // Very light gray border
  
  // Status Theme Colors
  static const Color success = Color(0xFF22C55E);     // Vibrant Green
  static const Color successBg = Color(0xFFDCFCE7);   // Green tint
  static const Color danger = Color(0xFFEF4444);      // Vibrant Red
  static const Color dangerBg = Color(0xFFFEE2E2);    // Red tint
  static const Color warning = Color(0xFFF59E0B);     // Amber warning
  static const Color warningBg = Color(0xFFFEF3C7);   // Amber tint

  // Backward compatibility aliases
  static const Color primaryNavy = secondary;
  static const Color accentBlue = primary;

  // Card Gradients
  static const List<Color> navyGradient = [
    Color(0xFF0070C0),
    Color(0xFF004B87),
  ];

  static const List<Color> primaryGradient = [
    Color(0xFF0070C0),
    Color(0xFF1E88E5),
    Color(0xFF42A5F5),
  ];
}
