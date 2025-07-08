import 'package:flutter/material.dart';
import '../services/book_service.dart';
import 'book_detail_screen.dart';
// Tambahkan shimmer package jika ingin shimmer loading (opsional)
// import 'package:shimmer/shimmer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Map<String, dynamic>>> _booksFuture;
  List<Map<String, dynamic>> _allBooks = [];
  List<Map<String, dynamic>> _filteredBooks = [];
  final TextEditingController _searchController = TextEditingController();
  String? _selectedGenre;
  List<String> _genres = [];

  @override
  void initState() {
    super.initState();
    _booksFuture = BookService.fetchBooks();
    _booksFuture.then((books) {
      setState(() {
        _allBooks = books;
        _filteredBooks = books;
        _genres = _extractGenres(books);
      });
    });
    _searchController.addListener(_onSearchChanged);
  }

  List<String> _extractGenres(List<Map<String, dynamic>> books) {
    final genres = <String>{};
    for (var book in books) {
      if (book['genre'] != null && book['genre'].toString().isNotEmpty) {
        genres.add(book['genre'].toString());
      }
    }
    return genres.toList()..sort();
  }

  void _onSearchChanged() {
    _applyFilter();
  }

  void _onGenreChanged(String? genre) {
    setState(() {
      _selectedGenre = genre;
    });
    _applyFilter();
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBooks = _allBooks.where((book) {
        final title = (book['title'] ?? '').toLowerCase();
        final author = (book['author_name'] ?? '').toLowerCase();
        final genre = (book['genre'] ?? '').toLowerCase();
        final matchesQuery = title.contains(query) || author.contains(query);
        final matchesGenre = _selectedGenre == null ||
            _selectedGenre == '' ||
            genre == _selectedGenre!.toLowerCase();
        return matchesQuery && matchesGenre;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text('Perpustakaan Digital'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF8F7CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang di Perpustakaan Digital!',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Temukan, baca, dan pinjam buku favoritmu dengan mudah.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/hero_image.webp',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Icon(Icons.menu_book_rounded,
                          color: Colors.white, size: 64),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Search Bar & Genre Filter
            Row(
              children: [
                Expanded(
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari buku atau penulis...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (_genres.isNotEmpty)
                  DropdownButton<String>(
                    value: _selectedGenre,
                    hint: const Text('Genre'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Semua')),
                      ..._genres
                          .map(
                              (g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                    ],
                    onChanged: _onGenreChanged,
                    underline: Container(),
                    borderRadius: BorderRadius.circular(12),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Info jumlah buku ditemukan
            if (_filteredBooks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  '${_filteredBooks.length} buku ditemukan',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                ),
              ),
            // Buku Grid
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _booksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Shimmer loading (opsional, jika tidak pakai shimmer, pakai CircularProgressIndicator)
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Gagal memuat buku'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _EmptyState();
                  }
                  if (_filteredBooks.isEmpty) {
                    return _EmptyState();
                  }
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: _filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = _filteredBooks[index];
                      return BookCard(
                        title: book['title'] ?? '-',
                        author: book['author_name'] ?? '-',
                        imageUrl: book['cover_image'],
                        genre: book['genre'],
                        isNew: book['is_new'] == true,
                        bookData: book,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Pinjaman'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: 0,
        onTap: (i) {},
      ),
    );
  }
}

class BookCard extends StatefulWidget {
  final String title;
  final String author;
  final String? imageUrl;
  final String? genre;
  final bool isNew;
  final Map<String, dynamic>? bookData;
  const BookCard({
    super.key,
    required this.title,
    required this.author,
    this.imageUrl,
    this.genre,
    this.isNew = false,
    this.bookData,
  });

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.bookData != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BookDetailScreen(book: widget.bookData!),
                ),
              )
          : null,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 6,
          shadowColor: const Color(0xFF6C63FF).withOpacity(0.15),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(18)),
                      child: widget.imageUrl != null &&
                              widget.imageUrl!.isNotEmpty
                          ? Image.network(widget.imageUrl!, fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.menu_book_rounded,
                                  size: 64, color: Color(0xFF6C63FF)),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(widget.author,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13)),
                        if (widget.genre != null &&
                            widget.genre!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.genre!,
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF6C63FF)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (widget.isNew)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Baru',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/empty.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            errorBuilder: (c, e, s) => Icon(Icons.menu_book_rounded,
                color: Colors.grey[400], size: 80),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada buku ditemukan',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba cari judul lain atau ubah filter genre.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
