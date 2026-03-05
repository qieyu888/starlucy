import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPink = Color(0xFFFDF2F8);
  static const Color primaryPurple = Color(0xFFF5F3FF);
  static const Color accentPurple = Color(0xFFA78BFA);
  static const Color accentPink = Color(0xFFF472B6);
  static const Color textMain = Color(0xFF4B5563);
  static const Color textLight = Color(0xFF94A3B8);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentPurple,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textMain,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textMain,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textMain,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textLight,
      ),
    ),
  );
}
