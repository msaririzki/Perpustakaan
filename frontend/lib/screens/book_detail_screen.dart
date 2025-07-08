import 'package:flutter/material.dart';
import '../services/loan_service.dart';
import '../services/review_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool isLoading = false;
  bool pinjamSuccess = false;
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final reviews = await ReviewService.fetchBookReviews(widget.book['id']);
      setState(() {
        _reviews = reviews;
      });
    } catch (e) {}
  }

  Future<void> _pinjamBuku() async {
    setState(() => isLoading = true);
    final token = await AuthService.getToken();
    if (token == null) return;
    final user = await UserService.fetchCurrentUser(token);
    final success = await LoanService.pinjamBuku(widget.book['id'], user['id']);
    setState(() {
      isLoading = false;
      pinjamSuccess = success;
    });
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil meminjam buku!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Gagal meminjam buku!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title'] ?? 'Detail Buku'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: book['cover_image'] != null &&
                        book['cover_image'].toString().isNotEmpty
                    ? Image.network(book['cover_image'],
                        height: 200, fit: BoxFit.cover)
                    : Container(
                        height: 200,
                        width: 140,
                        color: Colors.grey[200],
                        child: const Icon(Icons.menu_book_rounded,
                            size: 64, color: Color(0xFF6C63FF)),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text(book['title'] ?? '-',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Penulis: ${book['author_name'] ?? '-'}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Kategori: ${book['category_name'] ?? '-'}',
                style: const TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 16),
            Text(book['description'] ?? '-',
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 24),
            Row(
              children: [
                Chip(
                  label: Text('Stok: ${book['stock'] ?? 0}'),
                  backgroundColor: (book['stock'] ?? 0) > 0
                      ? Colors.green[100]
                      : Colors.red[100],
                  labelStyle: TextStyle(
                      color:
                          (book['stock'] ?? 0) > 0 ? Colors.green : Colors.red),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed:
                      (book['stock'] ?? 0) > 0 && !isLoading && !pinjamSuccess
                          ? _pinjamBuku
                          : null,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.shopping_bag),
                  label: Text(pinjamSuccess ? 'Sudah Dipinjam' : 'Pinjam Buku'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Ulasan Buku',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _reviews.isEmpty
                ? const Text('Belum ada ulasan.')
                : Column(
                    children: _reviews
                        .map((r) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: const Icon(Icons.person),
                                title: Text(r['user_name'] ?? '-'),
                                subtitle: Text(r['comment'] ?? '-'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(
                                      5,
                                      (i) => Icon(
                                            i < (r['rating'] ?? 0)
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                            size: 20,
                                          )),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
