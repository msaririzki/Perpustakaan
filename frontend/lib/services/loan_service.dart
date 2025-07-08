import 'dart:convert';
import 'package:http/http.dart' as http;

class LoanService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<Map<String, dynamic>>> fetchUserLoans(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/loans/'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      // Filter loan milik user
      return data
          .where((e) => e['user_id'] == userId)
          .cast<Map<String, dynamic>>()
          .toList();
    } else {
      throw Exception('Failed to load loans');
    }
  }

  static Future<bool> pinjamBuku(int bookId, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/loans/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'book_id': bookId,
        'user_id': userId,
      }),
    );
    return response.statusCode == 201;
  }
}
