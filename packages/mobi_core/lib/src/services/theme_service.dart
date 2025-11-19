import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app theme (Light/Dark mode)
class ThemeService {
  static const String _themeKey = 'theme_mode';

  final SharedPreferences _prefs;

  ThemeService(this._prefs);

  /// Get current theme mode
  ThemeMode getThemeMode() {
    final themeIndex = _prefs.getInt(_themeKey) ?? 0;
    return ThemeMode.values[themeIndex];
  }

  /// Save theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_themeKey, mode.index);
  }

  /// Check if dark mode is enabled
  bool isDarkMode() {
    return getThemeMode() == ThemeMode.dark;
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final currentMode = getThemeMode();
    final newMode = currentMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await setThemeMode(newMode);
  }
}
