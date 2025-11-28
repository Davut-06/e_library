import 'package:e_lib/model/named_entity.dart';

class Book {
  final int id;
  final String name;
  final String? slug;
  final String? thumbnail; // URL обложки
  final String? description;
  final String file;
  final int? year;
  final int viewCount;
  final int downloadCount;
  final int likeCount;

  // Связанные сущности, использующие NamedEntity
  final NamedEntity? author;
  final NamedEntity? category;
  final NamedEntity? department;

  final String? interactiveFile;

  Book({
    required this.id,
    required this.name,
    required this.slug,
    required this.thumbnail,
    required this.description,
    required this.file,
    required this.year,
    required this.viewCount,
    required this.downloadCount,
    required this.likeCount,
    required this.author,
    required this.category,
    required this.department,
    required this.interactiveFile,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      // Надёжный парсинг числовых полей
      id: map['id'] is int
          ? map['id'] as int
          : int.tryParse('${map['id']}') ?? 0,
      name: map['name']?.toString() ?? '',
      slug: map['slug']?.toString(),
      thumbnail: map['thumbnail']?.toString(),
      description: map['description']?.toString(),
      file: map['file']?.toString() ?? '',
      year: map['year'] is int
          ? map['year'] as int
          : int.tryParse('${map['year']}'),
      viewCount: map['view_count'] is int
          ? map['view_count'] as int
          : int.tryParse('${map['view_count']}') ?? 0,
      downloadCount: map['download_count'] is int
          ? map['download_count'] as int
          : int.tryParse('${map['download_count']}') ?? 0,
      likeCount: map['like_count'] is int
          ? map['like_count'] as int
          : int.tryParse('${map['like_count']}') ?? 0,

      // Парсинг связанных сущностей
      author: map['author'] != null ? NamedEntity.fromMap(map['author']) : null,
      category: map['category'] != null
          ? NamedEntity.fromMap(map['category'])
          : null,
      department: map['department'] != null
          ? NamedEntity.fromMap(map['department'])
          : null,
      interactiveFile: map['interactive_file']?.toString(),
    );
  }

  Book copyWith({int? viewCount, int? downloadCount, int? likeCount}) {
    return Book(
      id: id,
      name: name,
      slug: slug,
      thumbnail: thumbnail,
      description: description,
      file: file,
      year: year,
      viewCount: viewCount ?? this.viewCount,
      downloadCount: downloadCount ?? this.downloadCount,
      likeCount: likeCount ?? this.likeCount,
      author: author,
      category: category,
      department: department,
      interactiveFile: interactiveFile,
    );
  }
}
