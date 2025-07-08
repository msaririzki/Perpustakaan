import 'dart:convert';
import 'package:http/http.dart' as http;

class ReviewService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<List<Map<String, dynamic>>> fetchBookReviews(int bookId) async {
    final response = await http.get(Uri.parse('$baseUrl/reviews/'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .where((e) => e['book_id'] == bookId)
          .cast<Map<String, dynamic>>()
          .toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }
}
