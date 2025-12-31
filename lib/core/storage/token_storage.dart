import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _companyIdKey = 'company_id';
  static const _landingUrlKey = 'landing_url';
  static const _companyIdsKey = 'company_ids';
  static const _companyNameKey = 'company_name';
  static const _roleCodeKey = 'role_code';
  static const _userEmailKey = 'user_email';
  static const _userNameKey = 'user_name';

  static Future<void> saveFullAuthData({
    required int userId,
    int? companyId,
    List<int>? companyIds,
    String? companyName,
    String? token,
    String? refreshToken,
    String? roleCode,
    required String landingUrl,
    required String email,
    required String userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token ?? '');
    await prefs.setString(_refreshTokenKey, refreshToken ?? '');
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_landingUrlKey, landingUrl);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userNameKey, userName);

    if (companyId != null) {
      await prefs.setInt(_companyIdKey, companyId);
    }

    if (companyIds != null) {
      await prefs.setString(_companyIdsKey, jsonEncode(companyIds));
    }

    if (companyName != null) {
      await prefs.setString(_companyNameKey, companyName);
    }

    if (roleCode != null) {
      await prefs.setString(_roleCodeKey, roleCode);
    }
  }

  static Future<Map<String, dynamic>?> getFullAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) return null;

    return {
      'token': token,
      'refreshToken': prefs.getString(_refreshTokenKey),
      'userId': prefs.getInt(_userIdKey),
      'companyId': prefs.getInt(_companyIdKey),
      'companyIds': prefs.getString(_companyIdsKey),
      'companyName': prefs.getString(_companyNameKey),
      'roleCode': prefs.getString(_roleCodeKey),
      'landingUrl': prefs.getString(_landingUrlKey),
      'email': prefs.getString(_userEmailKey),
      'userName': prefs.getString(_userNameKey),
    };
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token?.isNotEmpty == true ? token : null;
  }

  static Future<bool> hasValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
