import 'dart:async';
import 'package:e_lib/const/text.dart';
import 'package:e_lib/model/book.dart';
import 'package:e_lib/model/named_entity.dart';
import 'package:e_lib/provider/theme_provider.dart';
import 'package:e_lib/screens/book_details_screen.dart';
import 'package:e_lib/services/base_api_query.dart';
import 'package:e_lib/services/books_api.dart';
import 'package:e_lib/widgets/ios_switch.dart';
import 'package:flutter/material.dart';
import 'package:e_lib/utils/colors.dart';
import 'package:provider/provider.dart';
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
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 0) return;
    if (index == 1) {
      // Предполагаем, что SettingsScreen существует и доступен
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const SettingsScreen()))
          .then((_) {
            setState(() {
              _selectedIndex = 0;
            });
          });
    }
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        backgroundColor:
            theme.appBarTheme.backgroundColor, // AppColors.primary,
        foregroundColor: theme.appBarTheme.foregroundColor, // Colors.white,
        actions: [
          // Удален showServerSelectionModal
          // IconButton(
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //         content: Text('Server selection (removed from cleanup)'),
          //       ),
          //    );
          //},
          //icon: const Icon(Icons.wifi_channel_outlined),
          // ),
        ],
      ),
      backgroundColor: theme.colorScheme.background, // AppColors.secondaryBg,
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
                    _buildTypeSelector(),
                    const SizedBox(height: 8),
                    _buildFiltersRow(),
                    const SizedBox(height: 8),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: UIText(
                          text: _error ?? '',
                          context: context,
                          color: Theme.of(context).colorScheme.error,
                        ).t3,
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
                      UIText(text: 'No books found', context: context).t2,
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.colorScheme.primary, // AppColors.primary,
        unselectedItemColor:
            theme.colorScheme.onSurfaceVariant, // AppColors.lightGray,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // --- ИЗМЕНЕННЫЙ МЕТОД: Строка поиска теперь соответствует стилю фильтров ---
  Widget _buildSearchField(ThemeData theme) {
    // Безопасно получаем ширину границы из темы
    final borderSideWidth =
        theme.inputDecorationTheme.enabledBorder?.borderSide.width ?? 1.0;

    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search books',
        prefixIcon: Icon(
          Icons.search,
          color: theme.colorScheme.onSurfaceVariant, // Цвет иконки
        ),
        filled: true,
        fillColor: theme.colorScheme.surface, // Фон из темы
        // 1. АКТИВНАЯ (ENABLED) ГРАНИЦА: скругленная и с цветом обводки из темы
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline, // Цвет обводки
            width: borderSideWidth,
          ),
        ),

        // 2. ГРАНИЦА ПО УМОЛЧАНИЮ/ФОКУСУ: скругленная и с цветом обводки из темы
        // Это необходимо, чтобы на фокусе не пропадало скругление
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline,
            width: borderSideWidth,
          ),
        ),

        // Контентные отступы
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        isDense: true, // Делаем поле компактным (как и фильтры)
      ),
    );
  }
  // --- КОНЕЦ ИЗМЕНЕННОГО МЕТОДА ---

  Widget _buildTypeSelector() {
    final theme = Theme.of(context);
    final items = [('book', 'Books'), ('audioBook', 'Audio'), ('3dBook', '3D')];
    return Wrap(
      spacing: 8,
      children: items
          .map(
            (item) => ChoiceChip(
              backgroundColor:
                  theme.colorScheme.tertiary, // AppColors.lightGray,
              selectedColor: AppColors.primary,
              side: BorderSide.none,
              label: Text(item.$2),
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
    // --- ПОЛУЧАЕМ ОБЪЕКТ ТЕМЫ ---
    final theme = Theme.of(context);
    // -----------------------------

    final selectedLabel = value == null
        ? 'All'
        : items
              .firstWhere(
                (e) => e.id == value,
                orElse: () => NamedEntity(id: value!, name: 'Selected'),
              )
              .name;

    // Безопасно извлекаем ширину границы из темы.
    final borderSideWidth =
        theme.inputDecorationTheme.enabledBorder?.borderSide.width ?? 1.0;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openPicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,

          // Используем цвет поверхности из темы для фона
          fillColor: theme.colorScheme.surface,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),

          // 1. ГРАНИЦА ПО УМОЛЧАНИЮ/ФОКУСУ
          // Явно создаем OutlineInputBorder для поддержки borderRadius
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            // Используем основной цвет/стиль границы из темы (или стандартный)
            borderSide:
                theme.inputDecorationTheme.border?.borderSide ??
                BorderSide(
                  color: theme.colorScheme.onSurface,
                  width: borderSideWidth,
                ),
          ),

          // 2. АКТИВНАЯ (ENABLED) ГРАНИЦА
          // Явно создаем OutlineInputBorder для поддержки borderRadius
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            // Используем цвет outline из ColorScheme (для видимой границы)
            borderSide: BorderSide(
              color: theme.colorScheme.outline,
              width: borderSideWidth,
            ),
          ),
          isDense: true, // Сохраняем компактность
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedLabel,
                overflow: TextOverflow.ellipsis,
                // Используем цвет текста на поверхности
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
            // Используем цвет иконки на поверхности
            Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurface),
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
                        color: AppColors.lightGray, // lightGray
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
    final imageUrl = _resolveUrl(book.thumbnail);
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface, // Colors.white,
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
                        color: AppColors.lightGray.withOpacity(0.5),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 76,
                        height: 104,
                        color: AppColors.lightGray.withOpacity(0.5),
                        child: const Icon(Icons.menu_book_outlined),
                      ),
                    )
                  : Container(
                      width: 76,
                      height: 104,
                      color: AppColors.lightGray.withOpacity(0.5),
                      child: const Icon(Icons.menu_book_outlined),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UIText(text: book.name, context: context).t2,
                  const SizedBox(height: 4),
                  if (book.author != null)
                    UIText(
                      text: book.author?.name ?? '',
                      context: context,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color, // AppColors.textSecondary,
                    ).t3,
                  const SizedBox(height: 8),
                  if (book.category != null)
                    UIText(
                      text: book.category?.name ?? '',
                      context: context,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color, //AppColors.textSecondary,
                    ).t3,
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
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
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        UIText(
          text: label,
          context: context,
          color: AppColors.textSecondary,
        ).t3,
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем цветовую схему для динамической адаптации UI
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          // Современный стиль: простой AppBar без elevation (теней)
          appBar: AppBar(
            title: const Text('Настройки'),
            centerTitle: true,
            // Убираем тень, чтобы UI выглядел "плоским" и современным
            elevation: 0,
            backgroundColor: colorScheme.background,
            foregroundColor: colorScheme.onSurface,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // -----------------------------------------------------------------
              // СЕКЦИЯ 1: Аккаунт и Основные
              // -----------------------------------------------------------------
              _SettingsSection(
                title: 'Аккаунт',
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline,
                    title: 'Профиль',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_none,
                    title: 'Уведомления',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Приватность и безопасность',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24), // Отступ между секциями
              // -----------------------------------------------------------------
              // СЕКЦИЯ 2: Оформление (Смена темы)
              // -----------------------------------------------------------------
              _SettingsSection(
                title: 'Оформление',
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.brightness_3,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text("Ночной режим"),
                    trailing: IOS7Switch(
                      value: themeProvider.themeMode == ThemeMode.dark,
                      onChanged: (v) {
                        themeProvider.setThemeMode(
                          v ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ],
              ),
              // -----------------------------------------------------------------
              // СЕКЦИЯ 3: Помощь
              // -----------------------------------------------------------------
              _SettingsSection(
                title: 'Помощь',
                children: [
                  _SettingsTile(
                    icon: Icons.help_outline,
                    title: 'Справка',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'О приложении',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Вспомогательные виджеты для создания современного вида
// -----------------------------------------------------------------------------

// Виджет для создания секции (заголовок + карточка с элементами)
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок секции, немного тусклый для акцента
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        // Контейнер с закругленными углами для группировки элементов
        Container(
          decoration: BoxDecoration(
            // Используем цвет поверхности (surface), который может быть светлее фона
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            // Добавляем легкую тень, если тема светлая (опционально)
            boxShadow: Theme.of(context).brightness == Brightness.light
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          // Добавляем разделители между элементами списка
          child: Column(
            children: children.map((widget) {
              final isLast = children.last == widget;
              return Column(
                children: [
                  widget,
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 52, // Отступ, чтобы разделитель был под текстом
                      color: colorScheme.onSurface.withOpacity(0.1),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// Обычный элемент настройки (аналог ListTile)
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }
}

// Специализированный виджет для выбора темы с RadioListTile
class _ThemeRadioTile extends StatelessWidget {
  final String title;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode?> onChanged;

  const _ThemeRadioTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      title: Text(title),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      // Убираем отступы, чтобы соответствовать стилю ListTile в секции
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      // Изменяем положение radio-кнопки
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
