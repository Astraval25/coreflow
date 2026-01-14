import 'dart:convert';
import 'package:flutter/material.dart';
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

  static Future<bool> saveFullAuthData({
    required String userId,
    int? companyId,
    List<int>? companyIds,
    String? companyName,
    required String token,
    required String refreshToken,
    String? roleCode,
    required String landingUrl,
    required String email,
    required String userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Save all data atomically
    await prefs.setString(_tokenKey, token.trim());
    await prefs.setString(_refreshTokenKey, refreshToken.trim());
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_landingUrlKey, landingUrl);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userNameKey, userName);

    if (companyId != null) await prefs.setInt(_companyIdKey, companyId);
    if (companyIds != null && companyIds.isNotEmpty) {
      await prefs.setString(_companyIdsKey, jsonEncode(companyIds));
    }
    if (companyName?.isNotEmpty == true) {
      await prefs.setString(_companyNameKey, companyName!);
    }
    if (roleCode?.isNotEmpty == true) {
      await prefs.setString(_roleCodeKey, roleCode!);
    }

    await Future.delayed(const Duration(milliseconds: 50));
    final verifyPrefs = await SharedPreferences.getInstance(); 
    final savedToken = verifyPrefs.getString(_tokenKey);
    final savedRefresh = verifyPrefs.getString(_refreshTokenKey);
    final saveSuccess =
        savedToken?.isNotEmpty == true && savedRefresh?.isNotEmpty == true;

    debugPrint(
      'Save verify - Token: ${savedToken?.length ?? 0}c, Refresh: ${savedRefresh?.length ?? 0}c, Success: $saveSuccess',
    );
    return saveSuccess;
  }

  static Future<Map<String, dynamic>?> getFullAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final refreshToken = prefs.getString(_refreshTokenKey);

    if ((token?.isEmpty ?? true) && (refreshToken?.isEmpty ?? true)) {
      debugPrint('🔍 getFullAuthData: No tokens found');
      return null;
    }

    final data = {
      'token': token ?? '',
      'refreshToken': refreshToken ?? '',
      'userId': prefs.getString(_userIdKey),
      'companyId': prefs.getInt(_companyIdKey),
      'companyIds': prefs.getString(_companyIdsKey),
      'companyName': prefs.getString(_companyNameKey),
      'roleCode': prefs.getString(_roleCodeKey),
      'landingUrl': prefs.getString(_landingUrlKey),
      'email': prefs.getString(_userEmailKey),
      'userName': prefs.getString(_userNameKey),
    };

    final tokenExists = token?.isNotEmpty == true;
    debugPrint('getFullAuthData: Token exists: $tokenExists');

    return data;
  } //

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final result = token?.trim().isNotEmpty == true ? token!.trim() : null;
    debugPrint(' getToken: ${result?.length ?? 0} chars');
    return result;
  }

  static Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null;
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint(' All auth data cleared');
  }
}
