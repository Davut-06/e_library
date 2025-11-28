import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:e_lib/const/text.dart';
import 'package:e_lib/model/book.dart';
import 'package:e_lib/services/base_api_query.dart';
import 'package:e_lib/services/books_api.dart';
import 'package:e_lib/utils/colors.dart';
import 'package:e_lib/utils/ui_extensions.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';

class BookDetailsScreen extends StatefulWidget {
  final int bookId;
  final Book? initialBook;
  final String languageCode;

  const BookDetailsScreen({
    super.key,
    required this.bookId,
    this.initialBook,
    required this.languageCode,
  });

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final LibraryBooksApi _api = LibraryBooksApi();
  Book? _book;
  bool _loading = true;
  bool _liking = false;
  bool _downloading = false;
  bool _downloadsLoading = true;
  List<_DownloadedBook> _downloadedBooks = [];

  @override
  void initState() {
    super.initState();
    _book = widget.initialBook;
    _load();
    _loadDownloadedBooks();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });
    try {
      final result = await _api.getBook(
        id: widget.bookId,
        lang: widget.languageCode,
      );
      setState(() {
        _book = result;
      });
      // Инкрементируем просмотр только после успешной загрузки книги
      await _api.incrementView(widget.bookId);
    } catch (_) {
      // Игнорируем ошибку загрузки, если она не критична
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _handleDownload() async {
    final book = _book;
    if (book == null || _downloading) return;
    final url = _resolveUrl(book.file);
    if (url == null) {
      _showSnackBar('File is not available for download.');
      return;
    }

    setState(() {
      _downloading = true;
    });

    try {
      final directory = await _getDownloadDirectory();
      final uri = Uri.parse(url);
      final fileName = _buildFileName(book, uri);
      final savePath = '${directory.path}${Platform.pathSeparator}$fileName';

      await BaseApiQuery.libraryHttp.download(url, savePath);
      await _api.incrementDownload(widget.bookId);

      final downloadedItem = _DownloadedBook(
        id: book.id,
        name: book.name,
        path: savePath,
        savedAt: DateTime.now(),
      );
      await _addDownloadedBook(downloadedItem);

      if (!mounted) return;
      setState(() {
        _book = book.copyWith(downloadCount: book.downloadCount + 1);
      });
      _showSnackBar('Saved to $savePath');
    } on DioException catch (error) {
      _showSnackBar('Download failed: ${error.message ?? 'Unknown error'}');
    } catch (error) {
      _showSnackBar('Download failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _downloading = false;
        });
      }
    }
  }

  Future<void> _handleOpenInBrowser() async {
    if (_book == null || _book!.file == null) return;
    final url = _resolveUrl(_book!.file);
    if (url == null) return;
    await _api.incrementDownload(widget.bookId);
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      _showSnackBar('Could not open the file in browser.');
    }
  }

  Future<void> _handleInteractive() async {
    if (_book?.interactiveFile == null) return;
    final url = _resolveUrl(_book!.interactiveFile!);
    if (url == null) return;
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> _handleLike() async {
    if (_book == null || _liking) return;
    setState(() {
      _liking = true;
      _book = _book!.copyWith(likeCount: _book!.likeCount + 1);
    });
    try {
      await _api.incrementLike(widget.bookId);
    } finally {
      if (mounted) {
        setState(() {
          _liking = false;
        });
      }
    }
  }

  Future<void> _loadDownloadedBooks() async {
    final items = await _DownloadedBookStorage.load();
    if (!mounted) return;
    setState(() {
      _downloadedBooks = items;
      _downloadsLoading = false;
    });
  }

  Future<void> _addDownloadedBook(_DownloadedBook item) async {
    final updated = List<_DownloadedBook>.from(_downloadedBooks);
    // Проверяем, существует ли уже книга с таким же путем
    final existingIndex = updated.indexWhere(
      (element) => element.id == item.id,
    );
    if (existingIndex >= 0) {
      // Обновляем существующую запись (например, время сохранения)
      updated[existingIndex] = item;
    } else {
      // Добавляем новую в начало
      updated.insert(0, item);
    }

    if (mounted) {
      setState(() {
        _downloadedBooks = updated;
        _downloadsLoading = false;
      });
    }

    await _DownloadedBookStorage.save(updated);
  }

  Future<void> _openDownloadedFile(_DownloadedBook item) async {
    final file = File(item.path);
    if (!await file.exists()) {
      _showSnackBar('File not found at ${item.path}');
      return;
    }
    final result = await OpenFile.open(item.path);
    if (result.type != ResultType.done &&
        result.type != ResultType.fileNotFound) {
      _showSnackBar(result.message);
    }
  }

  Future<void> _deleteDownloadedFile(_DownloadedBook item) async {
    try {
      final file = File(item.path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (error) {
      _showSnackBar('Could not delete file: $error');
      return;
    }

    final updated = _downloadedBooks
        .where((element) => element.path != item.path)
        .toList(growable: false);
    if (mounted) {
      setState(() {
        _downloadedBooks = updated;
      });
    }
    await _DownloadedBookStorage.save(updated);
    _showSnackBar('Deleted');
  }

  Widget _buildDownloadedSection() {
    // Проверяем наличие скачанной версии для текущей книги, чтобы отобразить ее первой
    final currentBookDownload = _downloadedBooks
        .where((item) => item.id == _book?.id)
        .toList();

    // Удаляем текущую книгу из основного списка для избежания дублирования
    final otherDownloads = _downloadedBooks
        .where((item) => item.id != _book?.id)
        .toList();

    // Формируем окончательный список для отображения (текущая книга, затем остальные)
    final displayList = [...currentBookDownload, ...otherDownloads];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UIText(text: 'Downloaded files', context: context).h5,
        const SizedBox(height: 8),
        if (_downloadsLoading)
          const Center(child: CircularProgressIndicator())
        else if (displayList.isEmpty)
          UIText(
            text: 'No downloaded files yet.',
            context: context,
            color: AppColors.textSecondary,
          ).t3
        else
          ...displayList.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.insert_drive_file_outlined),
                title: Text(
                  item.name.isNotEmpty ? item.name : 'Book ${item.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${_fileNameFromPath(item.path)} • Saved ${_formatSavedAt(item.savedAt)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.open_in_new_rounded),
                      onPressed: () => _openDownloadedFile(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteDownloadedFile(item),
                    ),
                  ],
                ),
                onTap: () => _openDownloadedFile(item),
              ),
            ),
          ),
      ],
    );
  }

  String _fileNameFromPath(String path) {
    final segments = path.split(Platform.pathSeparator);
    return segments.isNotEmpty ? segments.last : path;
  }

  String _formatSavedAt(DateTime savedAt) {
    final two = (int v) => v.toString().padLeft(2, '0');
    return '${savedAt.year}-${two(savedAt.month)}-${two(savedAt.day)} '
        '${two(savedAt.hour)}:${two(savedAt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final book = _book;
    return Scaffold(
      appBar: AppBar(title: Text(book?.name ?? 'Book')),
      backgroundColor: AppColors.secondaryBg,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : book == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  UIText(text: 'Unable to load book', context: context).t2,
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12) +
                  30.bottomPad,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCover(book),
                  const SizedBox(height: 16),
                  UIText(text: book.name, context: context).h4,
                  const SizedBox(height: 6),
                  if (book.author != null)
                    UIText(
                      text: book.author?.name ?? '',
                      context: context,
                      color: AppColors.textSecondary,
                    ).t2,
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        icon: Icons.remove_red_eye_outlined,
                        label: '${book.viewCount}',
                      ),
                      _StatChip(
                        icon: Icons.download_outlined,
                        label: '${book.downloadCount}',
                      ),
                      _StatChip(
                        icon: Icons.favorite_outline,
                        label: '${book.likeCount}',
                      ),
                      if (book.year != null)
                        _StatChip(
                          icon: Icons.calendar_today_outlined,
                          label: '${book.year}',
                        ),
                      if (book.category != null)
                        _StatChip(
                          icon: Icons.category_outlined,
                          label: book.category?.name ?? '',
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (book.description != null && book.description!.isNotEmpty)
                    UIText(
                      text: book.description ?? '',
                      context: context,
                      color: AppColors.textSecondary,
                    ).t2,
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _downloading ? null : _handleDownload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: _downloading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.download_rounded),
                          label: Text(_downloading ? 'Saving...' : 'Download'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleOpenInBrowser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.open_in_browser_rounded),
                          label: const Text('Open in browser'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _handleLike,
                        icon: Icon(
                          Icons.favorite,
                          color: _liking
                              ? AppColors.textSecondary
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (book.interactiveFile != null &&
                      book.interactiveFile!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _handleInteractive,
                      icon: const Icon(Icons.threed_rotation_outlined),
                      label: const Text('Open interactive version'),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildDownloadedSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildCover(Book book) {
    final imageUrl = _resolveUrl(book.thumbnail);
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: 180,
                height: 240,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 180,
                  height: 240,
                  color: AppColors.lightGray.withOpacity(0.5),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 180,
                  height: 240,
                  color: AppColors.lightGray.withOpacity(0.5),
                  child: const Icon(Icons.menu_book_outlined, size: 48),
                ),
              )
            : Container(
                width: 180,
                height: 240,
                color: AppColors.lightGray.withOpacity(0.5),
                child: const Icon(Icons.menu_book_outlined, size: 48),
              ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final dirs = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      final dir = dirs?.firstWhere(
        (d) => d.path.isNotEmpty,
        orElse: () => dirs.isNotEmpty ? dirs.first : Directory(''),
      );
      if (dir != null && dir.path.isNotEmpty) return dir;
    }
    return await getApplicationDocumentsDirectory();
  }

  String _buildFileName(Book book, Uri uri) {
    final rawSegment = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    final fallbackName = (book.slug?.isNotEmpty ?? false)
        ? book.slug!
        : (book.name.isNotEmpty ? book.name : 'book_${book.id}');
    final candidate = rawSegment.isNotEmpty
        ? '${book.name}_$rawSegment'
        : fallbackName;
    final sanitized = candidate.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return sanitized.isEmpty ? 'book_${book.id}' : sanitized;
  }

  String? _resolveUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.hasScheme) return url;
    return '${BaseApiQuery.libraryBaseUrl}$url';
  }
}

class _DownloadedBook {
  final int id;
  final String name;
  final String path;
  final DateTime savedAt;

  const _DownloadedBook({
    required this.id,
    required this.name,
    required this.path,
    required this.savedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'path': path,
    'savedAt': savedAt.toIso8601String(),
  };

  factory _DownloadedBook.fromMap(Map<String, dynamic> map) {
    return _DownloadedBook(
      id: map['id'] is int
          ? map['id'] as int
          : int.tryParse('${map['id']}') ?? 0,
      name: map['name']?.toString() ?? '',
      path: map['path']?.toString() ?? '',
      savedAt:
          DateTime.tryParse(map['savedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

class _DownloadedBookStorage {
  static const _key = 'downloaded_books';

  static Future<List<_DownloadedBook>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<
              Map<String, dynamic>
            >() // Убедимся, что это Map<String, dynamic>
            .map((item) {
              try {
                return _DownloadedBook.fromMap(item);
              } catch (_) {
                // Игнорируем некорректно сформированные элементы
                return null;
              }
            })
            .whereType<_DownloadedBook>()
            .toList();
      }
    } catch (_) {
      // Игнорируем некорректно сформированное хранилище, возвращаем пустой список
    }
    return [];
  }

  static Future<void> save(List<_DownloadedBook> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((e) => e.toMap()).toList());
    await prefs.setString(_key, encoded);
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightGray.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          UIText(
            text: label,
            context: context,
            color: AppColors.textSecondary,
          ).t3,
        ],
      ),
    );
  }
}
