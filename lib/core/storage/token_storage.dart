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
  static const _employeeIdKey = 'employee_id';
  static const _employeeCodeKey = 'employee_code';
  static const _designationKey = 'designation';
  static const _authTypeKey = 'auth_type';
  static const _fcmTokenKey = 'fcm_token';

  static Future<void> saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
  }

  static Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmTokenKey);
  }

  static Future<void> clearFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fcmTokenKey);
  }

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
    int? employeeId,
    String? employeeCode,
    String? designation,
    String? authType,
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
    if (employeeId != null) await prefs.setInt(_employeeIdKey, employeeId);
    if (employeeCode?.isNotEmpty == true) {
      await prefs.setString(_employeeCodeKey, employeeCode!);
    }
    if (designation?.isNotEmpty == true) {
      await prefs.setString(_designationKey, designation!);
    }
    if (authType?.isNotEmpty == true) {
      await prefs.setString(_authTypeKey, authType!);
    }

    await Future.delayed(Duration(milliseconds: 50));
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
      'employeeId': prefs.getInt(_employeeIdKey),
      'employeeCode': prefs.getString(_employeeCodeKey),
      'designation': prefs.getString(_designationKey),
      'authType': prefs.getString(_authTypeKey),
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

  static Future<void> saveSelectedCompany(
    int companyId,
    String companyName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_companyIdKey, companyId);
    await prefs.setString(_companyNameKey, companyName);
    debugPrint('Saved selected company: $companyId - $companyName');
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint(' All auth data cleared');
  }
}
