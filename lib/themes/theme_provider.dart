// theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Устанавливаем системный режим по умолчанию
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    // Оповещаем все виджеты (включая MaterialApp) об изменении
    notifyListeners();
  }
}
