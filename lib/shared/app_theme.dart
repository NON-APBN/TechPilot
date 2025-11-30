import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    primaryColor: const Color(0xFF6A5AE0),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6A5AE0),
      primary: const Color(0xFF6A5AE0),
      secondary: const Color(0xFF9461F8),
      surface: Colors.white,
      background: const Color(0xFFF7F7FB),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF7F7FB),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF333333),
      elevation: 1,
      surfaceTintColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF333333), fontSize: 24),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF333333), fontSize: 20),
      bodyMedium: TextStyle(color: Color(0xFF555555), height: 1.6, fontSize: 16),
      bodySmall: TextStyle(color: Color(0xFF777777), fontSize: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF6A5AE0),
        side: const BorderSide(color: Color(0xFF6A5AE0)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      },
    ),
  );

  static final dark = ThemeData(
    primaryColor: const Color(0xFF8B7EF0), // Lighter purple for dark mode
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6A5AE0),
      primary: const Color(0xFF8B7EF0),
      secondary: const Color(0xFFA985F8),
      surface: const Color(0xFF27272A), // Zinc-800: Lighter than black, premium feel
      onSurface: Colors.white,
      background: const Color(0xFF18181B), // Zinc-900: Soft dark background
      onBackground: Colors.white,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF18181B),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF27272A),
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Color(0xFF27272A),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF27272A),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 24),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 20),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFFE4E4E7), height: 1.6, fontSize: 16), // Zinc-200
      bodySmall: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14), // Zinc-400
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF6A5AE0),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF8B7EF0),
        side: const BorderSide(color: Color(0xFF8B7EF0)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
      },
    ),
  );
}
