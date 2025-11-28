import 'dart:async';
import 'package:e_lib/model/book.dart';
import 'package:e_lib/model/named_entity.dart';
import 'package:e_lib/screens/book_details_screen.dart';
import 'package:e_lib/services/base_api_query.dart';
import 'package:e_lib/services/books_api.dart';
import 'package:flutter/material.dart';
import 'package:e_lib/utils/colors.dart';
// Используем стандартные Material-цвета
// import 'package:e_university/utils/colors.dart';

// Эти импорты необходимы для работы логики API и моделей.
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:e_university/presentation/library/book_details_screen.dart'; // Предполагаем, что этот экран существует

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final LibraryBooksApi _api = LibraryBooksApi();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Book> _books = [];
  int _totalCount = 0;
  int _page = 1;
  bool _initialLoading = true;
  bool _fetchingMore = false;
  String? _error;

  String _type = 'book';
  int? _selectedCategory;
  int? _selectedAuthor;
  int? _selectedGenre;
  int? _selectedSubject;

  List<NamedEntity> _categories = [];
  List<NamedEntity> _authors = [];
  List<NamedEntity> _genres = [];
  List<NamedEntity> _subjects = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Используем хардкод 'en' в соответствии с вашим кодом,
  // но в реальном приложении это должна быть переменная локали.
  String get _lang => 'en';

  Future<void> _loadInitial() async {
    setState(() {
      _initialLoading = true;
      _error = null;
    });
    try {
      await Future.wait([_loadFilters(), _fetchBooks(reset: true)]);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _initialLoading = false;
        });
      }
    }
  }

  Future<void> _loadFilters() async {
    final lang = _lang;
    final responses = await Future.wait([
      _api.getCategories(lang: lang),
      _api.getAuthors(lang: lang),
      _api.getGenres(lang: lang),
      _api.getSubjects(lang: lang),
    ]);

    _categories = responses[0];
    _authors = responses[1];
    _genres = responses[2];
    _subjects = responses[3];
  }

  Future<void> _fetchBooks({bool reset = false}) async {
    if (_fetchingMore && !reset) return;
    setState(() {
      if (reset) {
        _page = 1;
        _books = [];
        _totalCount = 0;
      }
      _error = null;
      _fetchingMore = !reset;
      if (reset) _initialLoading = true;
    });

    try {
      final result = await _api.getBooks(
        lang: _lang,
        page: _page,
        search: _searchController.text.trim(),
        type: _type,
        category: _selectedCategory,
        author: _selectedAuthor,
        // API ожидает строковые представления ID для Genre/Subject
        genre: _selectedGenre?.toString() ?? '',
        subject: _selectedSubject?.toString() ?? '',
      );

      setState(() {
        _totalCount = result.count;
        _books = [..._books, ...result.results];
        _page += 1;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _fetchingMore = false;
          _initialLoading = false;
        });
      }
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent * 0.95 &&
        _books.length < _totalCount &&
        !_fetchingMore) {
      _fetchBooks();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchBooks(reset: true);
    });
  }

  void _resetFilters() {
    setState(() {
      _type = 'book';
      _selectedCategory = null;
      _selectedAuthor = null;
      _selectedGenre = null;
      _selectedSubject = null;
      _searchController.clear();
    });
    _fetchBooks(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Используем стандартные цвета Flutter
    const Color primaryColor = Colors.blue;
    const Color secondaryBg = Color(0xFFF5F5F5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Удален showServerSelectionModal
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Server selection (removed from cleanup)'),
                ),
              );
            },
            icon: const Icon(Icons.wifi_channel_outlined),
          ),
        ],
      ),
      backgroundColor: secondaryBg,
      body: RefreshIndicator(
        onRefresh: () => _fetchBooks(reset: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchField(theme),
                    const SizedBox(height: 12),
                    _buildTypeSelector(primaryColor),
                    const SizedBox(height: 8),
                    _buildFiltersRow(),
                    const SizedBox(height: 8),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          // UIText заменен на Text
                          _error ?? '',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_initialLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!_initialLoading && _books.isEmpty && _error == null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_outlined, size: 48),
                      const SizedBox(height: 8),
                      const Text(
                        'No books found',
                        style: TextStyle(fontSize: 16),
                      ), // UIText заменен на Text
                      TextButton(
                        onPressed: () => _fetchBooks(reset: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            if (_books.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemBuilder: (context, index) {
                    if (_fetchingMore && index == _books.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final book = _books[index];
                    return _BookTile(
                      book: book,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BookDetailsScreen(
                              bookId: book.id,
                              initialBook: book,
                              languageCode: _lang,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemCount:
                      _books.length +
                      ((_fetchingMore && _books.isNotEmpty) ? 1 : 0),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton:
          (_selectedCategory != null ||
              _selectedAuthor != null ||
              _selectedGenre != null ||
              _selectedSubject != null ||
              _searchController.text.isNotEmpty ||
              _type != 'book')
          ? FloatingActionButton.extended(
              onPressed: _resetFilters,
              icon: const Icon(Icons.clear),
              label: const Text('Reset'),
            )
          : null,
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search books',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.dividerColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }

  Widget _buildTypeSelector(Color primaryColor) {
    // Используем простой светлый фон
    const Color lightGray = Color(0xFFE0E0E0);

    final items = [('book', 'Books'), ('audioBook', 'Audio'), ('3dBook', '3D')];
    return Wrap(
      spacing: 8,
      children: items
          .map(
            (item) => ChoiceChip(
              backgroundColor: lightGray,
              selectedColor: primaryColor,
              side: BorderSide.none,
              label: Text(
                item.$2,
                style: TextStyle(
                  color: _type == item.$1 ? Colors.white : Colors.black87,
                ),
              ),
              selected: _type == item.$1,
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _type = item.$1;
                  });
                  _fetchBooks(reset: true);
                }
              },
            ),
          )
          .toList(),
    );
  }

  Widget _buildFiltersRow() {
    return Column(
      children: [
        _DropdownFilter(
          label: 'Category',
          value: _selectedCategory,
          items: _categories,
          onChanged: (val) {
            setState(() => _selectedCategory = val);
            _fetchBooks(reset: true);
          },
        ),
        const SizedBox(height: 8),
        _DropdownFilter(
          label: 'Author',
          value: _selectedAuthor,
          items: _authors,
          onChanged: (val) {
            setState(() => _selectedAuthor = val);
            _fetchBooks(reset: true);
          },
        ),
        const SizedBox(height: 8),
        _DropdownFilter(
          label: 'Genre',
          value: _selectedGenre,
          items: _genres,
          onChanged: (val) {
            setState(() => _selectedGenre = val);
            _fetchBooks(reset: true);
          },
        ),
        const SizedBox(height: 8),
        _DropdownFilter(
          label: 'Subject',
          value: _selectedSubject,
          items: _subjects,
          onChanged: (val) {
            setState(() => _selectedSubject = val);
            _fetchBooks(reset: true);
          },
        ),
      ],
    );
  }
}

class _DropdownFilter extends StatelessWidget {
  final String label;
  final int? value;
  final List<NamedEntity> items;
  final ValueChanged<int?> onChanged;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Используем простой светлый фон
    const Color lightGray = Color(0xFFE0E0E0);

    final selectedLabel = value == null
        ? 'All'
        : items
              .firstWhere(
                (e) => e.id == value,
                orElse: () => NamedEntity(id: value!, name: 'Selected'),
              )
              .name;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openPicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(selectedLabel, overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final searchController = TextEditingController();
    final result = await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final mq = MediaQuery.of(ctx).size;
        final sheetHeight = mq.height * 0.85;

        List<NamedEntity> filtered = List.from(items);
        return StatefulBuilder(
          builder: (ctx, setState) {
            void filter(String query) {
              setState(() {
                filtered = items
                    .where(
                      (e) => e.name.toLowerCase().contains(query.toLowerCase()),
                    )
                    .toList();
              });
            }

            return Container(
              height: sheetHeight,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                left: 16,
                right: 16,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search $label',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: filter,
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length + 1,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        color: Color(0xFFE0E0E0), // lightGray
                      ),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            title: const Text('All'),
                            trailing: value == null
                                ? const Icon(Icons.check)
                                : null,
                            onTap: () => Navigator.of(context).pop(null),
                          );
                        }
                        final item = filtered[index - 1];
                        final selected = value == item.id;
                        return ListTile(
                          title: Text(item.name),
                          trailing: selected
                              ? const Icon(Icons.check)
                              : const SizedBox.shrink(),
                          onTap: () => Navigator.of(context).pop(item.id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    onChanged(result);
  }
}

class _BookTile extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const _BookTile({required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color textSecondary = Colors.grey;
    final imageUrl = _resolveUrl(book.thumbnail);
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 76,
                      height: 104,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 76,
                        height: 104,
                        color: Colors.grey.withOpacity(0.5), // lightGray
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 76,
                        height: 104,
                        color: Colors.grey.withOpacity(0.5), // lightGray
                        child: const Icon(Icons.menu_book_outlined),
                      ),
                    )
                  : Container(
                      width: 76,
                      height: 104,
                      color: Colors.grey.withOpacity(0.5), // lightGray
                      child: const Icon(Icons.menu_book_outlined),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // UIText заменен на Text
                  Text(
                    book.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (book.author != null)
                    Text(
                      // UIText заменен на Text
                      book.author?.name ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (book.category != null)
                    Text(
                      // UIText заменен на Text
                      book.category?.name ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _StatChip(
                        icon: Icons.remove_red_eye_outlined,
                        label: '${book.viewCount}',
                        textSecondary: textSecondary,
                      ),
                      _StatChip(
                        icon: Icons.download_outlined,
                        label: '${book.downloadCount}',
                        textSecondary: textSecondary,
                      ),
                      _StatChip(
                        icon: Icons.favorite_outline,
                        label: '${book.likeCount}',
                        textSecondary: textSecondary,
                      ),
                      if (book.year != null)
                        _StatChip(
                          icon: Icons.calendar_today_outlined,
                          label: '${book.year}',
                          textSecondary: textSecondary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _resolveUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.hasScheme) return url;
    // BaseApiQuery должен быть корректно импортирован
    return '${BaseApiQuery.libraryBaseUrl}$url';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color
  textSecondary; // Передача цвета для замены AppColors.textSecondary
  const _StatChip({
    required this.icon,
    required this.label,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: textSecondary),
        const SizedBox(width: 4),
        Text(
          // UIText заменен на Text
          label,
          style: TextStyle(fontSize: 14, color: textSecondary),
        ),
      ],
    );
  }
}
