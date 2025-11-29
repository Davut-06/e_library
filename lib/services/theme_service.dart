import 'package:flutter/material.dart';

// Класс для управления темой приложения.
// ChangeNotifier позволяет виджетам подписываться на изменения и перестраиваться.
class ThemeService extends ChangeNotifier {
  // Изначально устанавливаем светлый режим
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // Геттер для удобной проверки, активна ли темная тема
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Метод для переключения темы
  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    // Уведомляем всех слушателей (включая MaterialApp) о том, что тема изменилась
    notifyListeners();
  }
}
