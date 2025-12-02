// main.dart
import 'package:e_lib/provider/theme_provider.dart';
import 'package:e_lib/screens/books_screen.dart';
import 'package:e_lib/screens/splash_screen.dart';
import 'package:e_lib/services/base_api_query.dart';
import 'package:e_lib/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- НОВЫЙ ИМПОРТ

void main() {
  BaseApiQuery.initializeLibraryClient(locale: 'ru');

  // Оборачиваем все приложение в провайдер для управления темой
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем текущее состояние темы из провайдера
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Library UI',

      // Используем ВАШИ ПЕРЕНЕСЕННЫЕ ТЕМЫ
      theme: lightTheme, // Ваша старая тема
      darkTheme: darkTheme, // Новая темная тема
      themeMode: themeProvider.themeMode, // Режим, управляемый кнопкой
      //useMaterial3: true,

      // Начинаем с SplashScreen
      home: const SplashScreen(),
    );
  }
}
