import 'package:flutter/material.dart';

class AppTheme {
  static const bg = Color(0xFF121212);
  static const surface = Color(0xFF1E1E1E);
  static const surfaceLight = Color(0xFF2A2A2A);
  static const accent = Color(0xFFFF6A00);
  static const accentLight = Color(0xFFFF8533);
  static const danger = Color(0xFFE53935);
  static const warning = Color(0xFFFFC107);
  static const safe = Color(0xFF4CAF50);
  static const text = Color(0xFFF5F5F5);
  static const textDim = Color(0xFF9E9E9E);
  static const border = Color(0xFF333333);

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accentLight,
      surface: surface,
      error: danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w600),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: border)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
