import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/storage/token_storage.dart';

class ApiService {
  static const Duration timeout = Duration(seconds: 30);

  Future<http.Response> post(String url, Map<String, dynamic> data) async {
    try {
      print('Making POST to: $url');

      final token = await TokenStorage.getToken();

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return response;
    } on SocketException catch (e) {
      print('SocketException: $e');
      rethrow;
    } catch (e) {
      print('Other error: $e');
      rethrow;
    }
  }

  Future<http.Response> get(Uri url) async {
    try {
      print('Making GET to: ${url.path}');

      final token = await TokenStorage.getToken();

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeout);

      print('GET Response status: ${response.statusCode}');
      print('GET Response body: ${response.body}');
      return response;
    } on SocketException catch (e) {
      print('GET SocketException: $e');
      rethrow;
    } catch (e) {
      print('GET Error: $e');
      rethrow;
    }
  }
}
