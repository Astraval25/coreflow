import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _companyIdKey = 'company_id';

  static Future<void> saveTokens({
    required String token,
    required String refreshToken,
    required int userId,
    required int companyId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setInt(_companyIdKey, companyId);
  }

  static Future<Map<String, dynamic>?> getTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);
    final userId = prefs.getInt(_userIdKey);
    final companyId = prefs.getInt(_companyIdKey);

    if (token != null && refreshToken != null && userId != null && companyId != null) {
      return {
        'token': token,
        'refreshToken': refreshToken,
        'userId': userId,
        'companyId': companyId,
      };
    }
    return null;
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_companyIdKey);
  }

  static Future<bool> hasValidToken() async {
    final tokens = await getTokens();
    return tokens != null;
  }
}
