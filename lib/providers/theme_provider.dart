import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _settingsBox = 'settings';
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() {
    final box = Hive.box(_settingsBox);
    final saved = box.get(_themeKey, defaultValue: 'system');
    
    _themeMode = {
      'light': ThemeMode.light,
      'dark': ThemeMode.dark,
      'system': ThemeMode.system,
    }[saved] ?? ThemeMode.system;
    
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    
    final box = Hive.box(_settingsBox);
    box.put(_themeKey, mode.name);
  }
}
