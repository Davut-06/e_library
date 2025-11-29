import 'package:e_lib/screens/books_screen.dart';
import 'package:e_lib/screens/splash_screen.dart';
import 'package:e_lib/services/base_api_query.dart';
import 'package:flutter/material.dart';

void main() {
  // Инициализация API-клиента происходит здесь, что может занять время.
  // Это оправдывает использование Splash Screen.
  BaseApiQuery.initializeLibraryClient(locale: 'ru');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Library UI',
      // Устанавливаем общую тему, используя цвета и стили из первого примера
      theme: ThemeData(
        // Настройка стилей для виджетов Chip
        chipTheme: const ChipThemeData(
          // Здесь можно добавить настройки стиля Chip, например:
          // labelStyle: TextStyle(color: Color(0xFF5D87FF)),
        ),

        // Настройка стилей для полей ввода (TextField)
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              // Используйте AppColors.lightGray, если этот класс доступен
              // Если нет, нужно задать его значение явно, например:
              color: Color(0xFFE0E0E0),
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          isDense: true,
        ),

        // Настройка стилей для кнопок ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5D87FF), // primary color
            foregroundColor: Colors.white, // onPrimary color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ),

        // Настройка стилей для AppBar
        appBarTheme: const AppBarTheme(centerTitle: false),

        // Настройка стилей для карточек Card
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),

        // Переходные анимации (использовалась FadePageTransitionsBuilder)
        // Для простоты я оставлю стандартные, если не был импортирован FadePageTransitionsBuilder

        // Шрифт приложения
        fontFamily: 'Plus Jakarta Sans',

        // Настройка стилей для SnackBar
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),

        // Настройка стилей для TabBar
        tabBarTheme: const TabBarThemeData(dividerColor: Colors.transparent),

        // Полная цветовая схема (ColorScheme)
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF5D87FF), // Главный цвет (синий)
          onPrimary: Color(0xFFFFFFFF), // Цвет текста на главном цвете
          secondary: Color(0xFF9094B8), // Второстепенный цвет
          onSecondary: Color(0xFFFFFFFF), // Цвет текста на второстепенном цвете
          tertiary: Color(0xFFF5F9FD), // Третичный цвет (очень светлый фон)
          onTertiary: Color(0xFFFFFFFF),
          error: Color(0xFFFA896B), // Цвет ошибки (красный)
          onError: Color(0xFFFFFFFF),
          surface: Color(
            0xFFFFFFFF,
          ), // Цвет поверхности (фон карточек/диалогов)
          onSurface: Color(0xFF000000), // Цвет текста на поверхности
          onSurfaceVariant: Color(0xFF4E4639),
          outline: Color(0xFF807667),
          onInverseSurface: Color(0xFFF8EFE7),
          inverseSurface: Color(0xFF5D87FF),
          inversePrimary: Color(0xFF5775CD),
        ),

        useMaterial3: true,
      ),

      // Начинаем с SplashScreen
      home: const SplashScreen(),
    );
  }
}
