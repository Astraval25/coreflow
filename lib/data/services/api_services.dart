import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const Duration timeout = Duration(seconds: 30);

  Future<http.Response> post(String url, Map<String, dynamic> data) async {
    try {
      print('🚀 Making POST to: $url');
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      print('✅ Response status: ${response.statusCode}');
      print('✅ Response body: ${response.body}');
      return response;
    } on SocketException catch (e) {
      print('💥 SocketException: $e');
      rethrow;
    } catch (e) {
      print('💥 Other error: $e');
      rethrow;
    }
  }
}
