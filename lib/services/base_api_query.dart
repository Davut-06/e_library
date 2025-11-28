import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

// ⚠️ ВАЖНО: Мы сохраняем логику IOHttpClientAdapter для обработки SSL-сертификатов,
// так как вы используете IP-адреса (https://217...)
// В реальном приложении Flutter эта логика должна быть обработана
// в главном месте инициализации Dio.

class BaseApiQuery {
  // Статический Dio клиент для запросов к библиотеке
  static Dio libraryHttp = Dio();

  // Базовый URL для библиотеки, взятый из вашего кода
  static const String libraryBaseUrl = 'http://217.174.233.210:20001/api/';
  static const int _connectTimeout = 10000;
  static const int _receiveTimeout = 20000;

  /// Инициализирует Dio клиент для библиотеки
  static void initializeLibraryClient({required String locale}) {
    // Настройка IOHttpClientAdapter для обхода проверки SSL-сертификатов (если используется самоподписанный сертификат)
    (libraryHttp.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };

    // Настройка заголовков и таймаутов
    var libraryHeaders = {
      'Content-Type': 'application/json',
      // Язык, необходимый для всех запросов
      'Accept-Language': locale,
    };

    libraryHttp.options.baseUrl = libraryBaseUrl;
    libraryHttp.options.headers = libraryHeaders;
    libraryHttp.options.connectTimeout = const Duration(
      milliseconds: _connectTimeout,
    );
    libraryHttp.options.receiveTimeout = const Duration(
      milliseconds: _receiveTimeout,
    );

    // Интерцептор для логирования или обработки ошибок, специфичных для библиотеки,
    // если они не требуют перенаправления на экран логина.
    libraryHttp.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) {
          // Здесь можно добавить обработку ошибок сети/таймаута,
          // если она отличается от логики основного API (http)
          return handler.next(error);
        },
      ),
    );
  }
}
