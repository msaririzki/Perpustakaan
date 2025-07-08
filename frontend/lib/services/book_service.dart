import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class BookService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<Map<String, dynamic>>> fetchBooks() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/books/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load books');
    }
  }
}
