import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return _base(
      brightness: Brightness.light,
      seedColor: const Color(0xFF246BFE),
      scaffoldColor: const Color(0xFFF6F7FB),
    );
  }

  static ThemeData dark() {
    return _base(
      brightness: Brightness.dark,
      seedColor: const Color(0xFF8BC4FF),
      scaffoldColor: const Color(0xFF111318),
    );
  }

  static ThemeData _base({
    required Brightness brightness,
    required Color seedColor,
    required Color scaffoldColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldColor,
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
