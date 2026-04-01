import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:coreflow/core/config/app_config.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/storage/token_storage.dart';

class ApiService {
  static Duration timeout = Duration(seconds: 30);
  static bool _isRefreshing = false;
  static Completer<String?>? _tokenRefreshCompleter;

  static Future<Map<String?, String?>> _getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('auth_token'),
      'refreshToken': prefs.getString('refresh_token'),
    };
  }

  static Future<String?> _performTokenRefresh() async {
    if (_isRefreshing) {
      return await _tokenRefreshCompleter?.future;
    }

    _isRefreshing = true;
    _tokenRefreshCompleter = Completer<String?>();

    try {
      final authRepo = AuthRepository();
      final refreshed = await authRepo.refreshToken();

      await Future.delayed(Duration(milliseconds: 50));
      String? newToken = await TokenStorage.getToken();

      if (newToken == null || newToken.isEmpty) {
        final fullData = await TokenStorage.getFullAuthData();
        newToken = fullData?['token'];
      }

      debugPrint('Refresh: $refreshed, Token: ${newToken?.isNotEmpty == true}');
      _tokenRefreshCompleter?.complete(newToken);
      return newToken;
    } catch (e) {
      _tokenRefreshCompleter?.complete(null);
      return null;
    } finally {
      _isRefreshing = false;
      _tokenRefreshCompleter = null;
    }
  }

  Future<http.Response> _makeRequest(
    Future<http.Response> Function(String?) request,
  ) async {
    http.Response response;

    final initialTokens = await _getTokens();
    response = await request(initialTokens['token']);

    if (response.statusCode == 401 && !_isRefreshing) {
      // debugPrint('401 → Refresh token');

      final newToken = await _performTokenRefresh();

      if (newToken != null && newToken.isNotEmpty) {
        // debugPrint('Retrying with new token');
        response = await request(newToken);
        // debugPrint('Retry: ${response.statusCode}');
        return response;
      } else {
        // debugPrint('Refresh failed - no new token');
      }
    }

    return response;
  }

  Future<http.Response> post(String url, Map<String, dynamic> data) async {
    debugPrint('POST to: $url');
    return _makeRequest((token) async {
      return http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          )
          .timeout(timeout);
    });
  }

  Future<http.Response> get(Uri url) async {
    debugPrint('GET to: ${url.path}');
    return _makeRequest((token) async {
      return http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeout);
    });
  }

  Future<http.Response> put(String url, Map<String, dynamic> data) async {
    debugPrint('PUT to: $url');
    return _makeRequest((token) async {
      return http
          .put(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          )
          .timeout(timeout);
    });
  }

  Future<http.Response> patch(String url, Map<String, dynamic> data) async {
    debugPrint('PATCH to: $url');
    return _makeRequest((token) async {
      return http
          .patch(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
            body: jsonEncode(data),
          )
          .timeout(timeout);
    });
  }

  Future<http.Response> delete(String url) async {
    debugPrint ('DELETE to: $url');
    return _makeRequest((token) async {
      return http
          .delete(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(timeout);
    });
  }

  Future<http.Response> multipartPost({
    required String url,
    required Map<String, String> fields,
    File? file,
    String fileFieldName = 'file',
  }) async {
    // debugPrint('MULTIPART POST → $url');
    // debugPrint('FIELDS → $fields');
    // debugPrint('FILE → ${file?.path}');

    return _makeRequest((token) async {
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);

      // ✅ Authorization
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // ❗ DO NOT set Content-Type manually

      // ✅ Add text fields
      fields.forEach((key, value) {
        if (value.trim().isNotEmpty) {
          request.fields[key] = value;
        }
      });

      // ✅ Add file
      if (file != null && await file.exists()) {
        final fileName = file.path.split('/').last;

        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            file.path,
            filename: fileName,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(timeout);
      return await http.Response.fromStream(streamedResponse);
    });
  }

  Future<http.Response> multipartPut({
    required String url,
    required Map<String, String> fields,
    File? file,
    String fileFieldName = 'file',
  }) async {
    // debugPrint('MULTIPART PUT → $url');
    // debugPrint('FIELDS → $fields');
    // debugPrint('FILE → ${file?.path}');

    return _makeRequest((token) async {
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('PUT', uri);

      // ✅ Authorization
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // ❗ DO NOT set Content-Type manually

      // ✅ Add text fields
      fields.forEach((key, value) {
        if (value.trim().isNotEmpty) {
          request.fields[key] = value;
        }
      });

      // ✅ Add file
      if (file != null && await file.exists()) {
        final fileName = file.path.split('/').last;

        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            file.path,
            filename: fileName,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(timeout);
      return await http.Response.fromStream(streamedResponse);
    });
  }

  Future<http.Response> createItem({
    required int companyId,
    required Map<String, dynamic> itemData,
    File? imageFile,
  }) async {
    final url = AppConfig.getItemsUrl(companyId);

    return multipartPost(
      url: url,
      fields: {"item": jsonEncode(itemData)},
      file: imageFile,
      fileFieldName: "file",
    );
  }

  Future<http.Response> updateItem({
    required int companyId,
    required int itemId,
    required Map<String, dynamic> itemData,
    File? imageFile,
  }) async {
    final url = '${AppConfig.getItemsUrl(companyId)}/$itemId';

    return multipartPut(
      url: url,
      fields: {"item": jsonEncode(itemData)},
      file: imageFile,
      fileFieldName: "file",
    );
  }

  
}
