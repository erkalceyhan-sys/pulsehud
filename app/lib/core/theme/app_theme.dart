import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF0A0F1D);
  static const Color cardDark = Color(0xFF121B2F);
  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonGreen = Color(0xFF00FF9D);
  static const Color neonMagenta = Color(0xFFFF007A);
  static const Color neonYellow = Color(0xFFFFE600);
  
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonGreen,
        surface: cardDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
      ),
      useMaterial3: true,
    );
  }
}
