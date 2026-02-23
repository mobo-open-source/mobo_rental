import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing the application's theme mode (Light/Dark).
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  /// Returns true if the current theme is dark, false otherwise.
  bool get isDarkMode => _isDarkMode;

  /// Returns the current theme mode (dark or light).
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Constructor for ThemeProvider.
  /// Initializes the theme by loading the saved preference.
  ThemeProvider() {
    _loadTheme();
  }

  /// Loads the saved theme preference from SharedPreferences.
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  /// Toggles between light and dark theme and persists the choice.
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  /// Sets the theme mode to dark if [isDark] is true, light otherwise.
  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }
}
