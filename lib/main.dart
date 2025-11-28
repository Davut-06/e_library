import 'package:e_lib/screens/books_screen.dart';
import 'package:e_lib/screens/splash_screen.dart'; // Новый импорт!
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
      theme: ThemeData(
        fontFamily: 'Plus Jakarta Sans',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      // --- Ключевое изменение: Начинаем с SplashScreen ---
      home: const SplashScreen(),
    );
  }
}
