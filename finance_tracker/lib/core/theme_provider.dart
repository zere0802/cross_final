import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemePreference>(
  (ref) => ThemeNotifier(),
);

enum AppThemePreference {
  system,
  light,
  dark;

  ThemeMode get themeMode {
    return switch (this) {
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
    };
  }

  String get label {
    return switch (this) {
      AppThemePreference.system => 'System',
      AppThemePreference.light => 'Light',
      AppThemePreference.dark => 'Dark',
    };
  }

  IconData get icon {
    return switch (this) {
      AppThemePreference.system => Icons.brightness_auto_outlined,
      AppThemePreference.light => Icons.light_mode_outlined,
      AppThemePreference.dark => Icons.dark_mode_outlined,
    };
  }
}

class ThemeNotifier extends StateNotifier<AppThemePreference> {
  ThemeNotifier() : super(AppThemePreference.system) {
    loadTheme();
  }

  static const _themePreferenceKey = 'themePreference';

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themePreferenceKey);

    if (savedTheme == null && prefs.containsKey('darkMode')) {
      state = prefs.getBool('darkMode') ?? false
          ? AppThemePreference.dark
          : AppThemePreference.light;
      return;
    }

    state = AppThemePreference.values.firstWhere(
      (theme) => theme.name == savedTheme,
      orElse: () => AppThemePreference.system,
    );
  }

  Future<void> setTheme(AppThemePreference theme) async {
    final prefs = await SharedPreferences.getInstance();

    state = theme;
    await prefs.setString(_themePreferenceKey, theme.name);
  }

  Future<void> toggleTheme() async {
    await setTheme(
      state == AppThemePreference.dark
          ? AppThemePreference.light
          : AppThemePreference.dark,
    );
  }
}
