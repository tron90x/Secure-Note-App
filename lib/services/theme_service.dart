import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _autoDarkTimeKey = 'auto_dark_time';

  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  bool _autoDarkTime = false;

  ThemeMode get themeMode => _themeMode;
  bool get autoDarkTime => _autoDarkTime;

  ThemeService() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[_prefs.getInt(_themeModeKey) ?? 0];
    _autoDarkTime = _prefs.getBool(_autoDarkTimeKey) ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  Future<void> setAutoDarkTime(bool value) async {
    _autoDarkTime = value;
    await _prefs.setBool(_autoDarkTimeKey, value);
    notifyListeners();
  }

  bool shouldUseDarkMode() {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;

    if (_autoDarkTime) {
      final now = DateTime.now();
      final hour = now.hour;
      return hour >= 19 || hour < 6;
    }

    return false;
  }
}
