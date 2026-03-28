import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ultra-Luxury Palette: Shattered Obsidian & Golden Dawn
  static const Color obsidianBlack = Color(0xFF0F0F0F);
  static const Color charcoalDeep = Color(0xFF1A1A1A);
  static const Color midnightBlue = Color(0xFF0A1128);
  static const Color royalBlue = Color(0xFF1E3A8A);
  static const Color goldenDawn = Color(0xFFFFD700);
  static const Color luxuryGold = Color(0xFFD4AF37);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F9FE),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6C63FF),
      secondary: Color(0xFF2EC4B6),
      background: Color(0xFFF8F9FE),
      surface: Colors.white,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: obsidianBlack,
    colorScheme: const ColorScheme.dark(
      primary: goldenDawn,
      secondary: royalBlue,
      background: obsidianBlack,
      surface: charcoalDeep,
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      headlineMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
      titleLarge: const TextStyle(color: goldenDawn, fontWeight: FontWeight.bold),
      bodyLarge: const TextStyle(color: Colors.white),
      bodyMedium: const TextStyle(color: Colors.white70),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: charcoalDeep,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      prefixIconColor: goldenDawn,
      suffixIconColor: goldenDawn,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
