import 'package:e_lib/utils/assets_manager.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:e_lib/screens/books_screen.dart'; // Импортируем ваш главный экран
import 'package:e_lib/utils/colors.dart'; // Предполагается, что у вас есть класс цветов

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Вызываем функцию запуска таймера сразу после инициализации виджета
    _startTimer();
  }

  // Функция для запуска таймера и навигации
  void _startTimer() {
    // Устанавливаем задержку. Вы можете изменить Duration в зависимости от
    // длительности вашей анимации или времени, необходимого для загрузки данных.
    Timer(const Duration(seconds: 5), () {
      // Переход на BooksScreen, используя pushReplacement, чтобы пользователь
      // не мог вернуться назад к экрану загрузки с помощью кнопки "Назад".
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BooksScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Задаем фон для экрана загрузки
      backgroundColor: AppColors.backgroundColor,
      body: Center(child: Lottie.asset(AnimationManager.splash)),
    );
  }
}
