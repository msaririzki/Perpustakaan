import 'package:flutter/material.dart';
import '../services/loan_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  List<Map<String, dynamic>> _loans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLoans();
  }

  Future<void> _fetchLoans() async {
    final token = await AuthService.getToken();
    if (token == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    try {
      final user = await UserService.fetchCurrentUser(token);
      final loans = await LoanService.fetchUserLoans(user['id']);
      setState(() {
        _loans = loans;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buku yang Dipinjam')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loans.isEmpty
              ? const Center(child: Text('Belum ada pinjaman'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _loans.length,
                  itemBuilder: (context, i) {
                    final loan = _loans[i];
                    return ListTile(
                      leading: const Icon(Icons.menu_book_rounded),
                      title: Text(loan['book_title'] ?? 'Buku'),
                      subtitle:
                          Text('Dipinjam pada: ${loan['loan_date'] ?? '-'}'),
                      trailing: Chip(
                        label: Text(loan['is_returned'] == true
                            ? 'Dikembalikan'
                            : 'Belum Kembali'),
                        backgroundColor: loan['is_returned'] == true
                            ? Colors.green[100]
                            : Colors.orangeAccent,
                      ),
                    );
                  },
                ),
    );
  }
}
