import 'package:e_lib/model/book.dart';
import 'package:dio/dio.dart';
import 'package:e_lib/model/named_entity.dart';
import 'package:e_lib/model/pagination.dart';
import 'package:e_lib/services/base_api_query.dart';

class LibraryBooksApi {
  // Используем Dio-клиент, настроенный в BaseApiQuery
  final Dio _client = BaseApiQuery.libraryHttp;

  // Вспомогательный метод для преобразования типа книги (string) в индекс (int) для API
  int _mapTypeToIndex(String? type) {
    switch (type) {
      case 'audioBook':
        return 1;
      case '3dBook':
        return 2;
      case 'book':
      default:
        return 0; // 0 соответствует 'book'
    }
  }

  // Основной метод для получения списка книг с пагинацией и фильтрами
  Future<Pagination<Book>> getBooks({
    required String lang,
    int page = 1,
    String search = '',
    String type = 'book',
    int? category,
    int? author,
    int? faculty,
    int? department,
    String orderDirection = 'desc',
    String ordering = 'id',
    String genre = '',
    String subject = '',
    String language = '',
    String year = '',
  }) async {
    try {
      final response = await _client.get(
        'books/', // Путь API
        queryParameters:
            {
              'page': page,
              'search': search,
              'type': _mapTypeToIndex(type),
              'category': category,
              'author': author,
              'faculty': faculty,
              'department': department,
              'ordering': orderDirection == 'asc'
                  ? ordering
                  : '-$ordering', // Сортировка
              'genre': genre,
              'subject': subject,
              'language': language,
              'year': year,
            }..removeWhere(
              (key, value) => value == null || value == '',
            ), // Удаляем пустые/null параметры
        options: Options(
          headers: {
            'Accept-Language': lang, // Язык в заголовке
          },
        ),
      );

      // Парсинг ответа в модель Pagination, используя Book.fromMap
      return Pagination.fromMap(
        response.data as Map<String, dynamic>,
        (json) => Book.fromMap(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      rethrow;
    }
  }

  // Метод для получения информации об одной книге по ID
  Future<Book> getBook({required int id, required String lang}) async {
    try {
      final response = await _client.get(
        'books/$id/',
        options: Options(headers: {'Accept-Language': lang}),
      );
      return Book.fromMap(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      rethrow;
    }
  }

  // Методы для получения списков NamedEntity (категорий, авторов и т.д.)
  Future<List<NamedEntity>> getCategories({required String lang}) async {
    return _getNamedEntities('books/categories/', lang);
  }

  Future<List<NamedEntity>> getAuthors({required String lang}) async {
    return _getNamedEntities('books/authors/', lang);
  }

  Future<List<NamedEntity>> getGenres({required String lang}) async {
    return _getNamedEntities('books/genres/', lang);
  }

  Future<List<NamedEntity>> getSubjects({required String lang}) async {
    return _getNamedEntities('books/subjects/', lang);
  }
  // ... и так далее для Genres, Subjects

  // Методы для увеличения счетчиков
  Future<void> incrementDownload(int id) async {
    await _client.post('books/$id/download/');
  }

  Future<void> incrementLike(int id) async {
    await _client.post('books/$id/like/');
  }

  Future<void> incrementView(int id) async {
    await _client.post('books/$id/view/');
  }

  // Приватный вспомогательный метод для NamedEntity
  Future<List<NamedEntity>> _getNamedEntities(String path, String lang) async {
    try {
      final response = await _client.get(
        path,
        options: Options(headers: {'Accept-Language': lang}),
      );
      final List<dynamic> data = response.data as List<dynamic>? ?? [];
      return data
          .map((item) => NamedEntity.fromMap(item as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    }
  }
}
