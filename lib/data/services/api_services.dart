import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/storage/token_storage.dart';

class ApiService {
  static const Duration timeout = Duration(seconds: 30);
  static bool _isRefreshing = false;
  static Completer<http.Response>? _refreshCompleter;

  //  Always use stored token
  static Future<String?> _getValidToken() async {
    return await TokenStorage.getToken();
  }

  static Future<String?> _performTokenRefresh() async {
    if (_isRefreshing) {
      await _refreshCompleter?.future;
      return await TokenStorage.getToken();
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<http.Response>();

    try {
      final authRepo = AuthRepository();
      final refreshed = await authRepo.refreshToken();

      _refreshCompleter?.complete();
      return refreshed ? await TokenStorage.getToken() : null;
    } catch (e) {
      _refreshCompleter?.completeError(e);
      return null;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  //  SINGLE unified method - ALL HTTP calls use this
  Future<http.Response> _makeRequest(
    Future<http.Response> Function() request,
  ) async {
    http.Response response;

    try {
      response = await request();
    } on SocketException catch (e) {
      debugPrint('Network error: $e');
      rethrow;
    }

    // ONLY 401 triggers refresh + retry
    if (response.statusCode == 401 && !_isRefreshing) {
      debugPrint('401 detected → Token refresh');
      final newToken = await _performTokenRefresh();

      if (newToken != null) {
        try {
          response = await request();
          debugPrint('Retry success: ${response.statusCode}');
        } catch (e) {
          debugPrint('Retry failed: $e');
        }
      } else {
        debugPrint('Refresh failed → Return 401');
      }
    }

    return response;
  }

  // post() ONLY calls _makeRequest
  Future<http.Response> post(String url, Map<String, dynamic> data) async {
    debugPrint('POST to: $url');
    return _makeRequest(() async {
      final token = await _getValidToken();
      return http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          )
          .timeout(timeout);
    });
  }

  // get() ONLY calls _makeRequest
  Future<http.Response> get(Uri url) async {
    debugPrint('GET to: ${url.path}');
    return _makeRequest(() async {
      final token = await _getValidToken();
      return http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeout);
    });
  }

  // put() ONLY calls _makeRequest
  Future<http.Response> put(String url, Map<String, dynamic> data) async {
    debugPrint('PUT to: $url');
    return _makeRequest(() async {
      final token = await _getValidToken();
      return http
          .put(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          )
          .timeout(timeout);
    });
  }
}
