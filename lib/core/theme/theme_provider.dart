import 'package:flutter/material.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _updateLoginColors();
    _saveTheme();
    notifyListeners();
  }

  void _updateLoginColors() {
    // Note: This relies on the system brightness or explicit mode
    // For now, we manually sync it based on our mode
    LoginColors.setBrightness(_themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0; // 0 for light, 1 for dark
    _themeMode = themeIndex == 1 ? ThemeMode.dark : ThemeMode.light;
    _updateLoginColors();
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _themeMode == ThemeMode.dark ? 1 : 0);
  }
}
