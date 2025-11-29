// theme_provider.dart
import 'package:flutter/material.dart';

// 1. Создаем класс, который уведомляет об изменениях
class ThemeProvider extends ChangeNotifier {
  // Изначально используем системную тему, если не сохранено иное
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // Функция для установки режима темы
  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners(); // Сообщаем всем слушателям о необходимости перерисовки
    // Здесь также можно добавить логику для сохранения выбора пользователя
  }

  // Метод для удобного переключения между светлым и темным
  void toggleTheme(bool isDark) {
    setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
