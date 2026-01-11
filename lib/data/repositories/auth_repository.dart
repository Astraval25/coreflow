import 'dart:convert';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/company/companies_response.dart';
import 'package:coreflow/domain/model/company/company.dart';
import 'package:coreflow/domain/model/customer/active_customers_response.dart';
import 'package:coreflow/domain/model/customer/create_customer_request.dart';
import 'package:coreflow/domain/model/customer/customer.dart';
import 'package:coreflow/domain/model/customer/customer_detail.dart';
import 'package:coreflow/domain/model/customer/customer_edit_request.dart';
import 'package:coreflow/domain/model/customer/customer_edit_response.dart';
import 'package:coreflow/domain/model/login/login_request.dart';
import 'package:coreflow/domain/model/refresh_token/refresh_token_response.dart';
import 'package:coreflow/domain/model/register/register_request.dart';
import 'package:coreflow/domain/model/register/register_response.dart';
import 'package:coreflow/domain/model/resend_otp/resend_otp_request.dart';
import 'package:coreflow/domain/model/resend_otp/resend_otp_response.dart';
import 'package:coreflow/domain/model/verify_otp/verify_otp_request.dart';
import 'package:coreflow/domain/model/verify_otp/verify_otp_response.dart';
import 'package:coreflow/domain/repositories/login_response.dart';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../core/storage/token_storage.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<LoginResponse?> login(LoginRequest request) async {
    try {
      final response = await _apiService.post(
        AppConfig.loginUrl,
        request.toJson(),
      );

      if (response.statusCode != 200) {
        debugPrint('Login failed: ${response.statusCode}');
        return null;
      }

      final decodedBody = jsonDecode(response.body);
      return LoginResponse.fromJson(decodedBody);
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  // ✅ FIXED: Matches TokenStorage signature
  Future<void> saveAuthData(LoginData data, String email) async {
    await TokenStorage.saveFullAuthData(
      userId: data.userId.toString(), // ✅ Convert int to String
      companyId: data.companyId,
      companyIds: data.companyIds,
      companyName: data.companyName,
      token: data.token, // ✅ Required String
      refreshToken: data.refreshToken,
      roleCode: data.roleCode,
      landingUrl: data.landingUrl ?? '/dashboard',
      email: email.trim(),
      userName: data.userName ?? email.split('@').first,
    );
  }

  Future<Map<String, dynamic>?> getAuthData() async {
    return await TokenStorage.getFullAuthData();
  }

  Future<void> clearAuthData() async {
    await TokenStorage.clearAllData();
  }

  Future<bool> isLoggedIn() async {
    return await TokenStorage.hasValidToken();
  }

  Future<RegisterResponse?> register(RegisterRequest request) async {
    try {
      final response = await _apiService.post(
        AppConfig.registerUrl,
        request.toJson(),
      );

      if (response.statusCode != 200) {
        debugPrint('Register failed: ${response.statusCode}');
        return null;
      }

      final decodedBody = jsonDecode(response.body);
      return RegisterResponse.fromJson(decodedBody);
    } catch (e) {
      debugPrint('Register error: $e');
      return null;
    }
  }

  Future<VerifyOtpResponse?> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _apiService.post(
        AppConfig.verifyOtpUrl,
        request.toJson(),
      );

      if (response.statusCode != 200) {
        debugPrint('Verify OTP failed: ${response.statusCode}');
        return null;
      }

      final decodedBody = jsonDecode(response.body);
      return VerifyOtpResponse.fromJson(decodedBody);
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      return null;
    }
  }

  Future<ResendOtpResponse?> resendOtp(ResendOtpRequest request) async {
    try {
      final response = await _apiService.post(
        AppConfig.resendOtpUrl,
        request.toJson(),
      );

      if (response.statusCode != 200) {
        debugPrint('Resend OTP failed: ${response.statusCode}');
        return null;
      }

      final decodedBody = jsonDecode(response.body);
      return ResendOtpResponse.fromJson(decodedBody);
    } catch (e) {
      debugPrint('Resend OTP error: $e');
      return null;
    }
  }

  Future<List<Company>> getMyCompanies() async {
    try {
      final response = await _apiService.get(Uri.parse(AppConfig.companyUrl));

      if (response.statusCode != 200) {
        debugPrint('Companies API error: ${response.statusCode}');
        return [];
      }

      final decodedBody = jsonDecode(response.body);
      final companiesResponse = CompaniesResponse.fromJson(decodedBody);

      return companiesResponse.responseStatus
          ? companiesResponse.responseData
          : [];
    } catch (e) {
      debugPrint('Get companies error: $e');
      return [];
    }
  }

  Future<bool> refreshToken() async {
    try {
      final authData = await TokenStorage.getFullAuthData();
      if (authData == null ||
          authData['refreshToken'] == null ||
          authData['refreshToken'].toString().isEmpty) {
        debugPrint('No refresh token available');
        return false;
      }

      final response = await _apiService.post(AppConfig.refreshTokenUrl, {
        'refreshToken': authData['refreshToken'],
      });

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        final refreshResponse = RefreshTokenResponse.fromJson(decodedBody);

        await TokenStorage.saveFullAuthData(
          userId: authData['userId']?.toString() ?? '',
          companyId: authData['companyId'],
          companyIds: authData['companyIds'] != null
              ? List<int>.from(jsonDecode(authData['companyIds']))
              : null,
          companyName: authData['companyName'],
          token: refreshResponse.token ?? authData['token']?.toString() ?? '',
          refreshToken:
              refreshResponse.refreshToken ?? authData['refreshToken'],
          roleCode: refreshResponse.roleCode ?? authData['roleCode'],
          landingUrl: authData['landingUrl'] ?? '/dashboard',
          email: authData['email'] ?? '',
          userName: authData['userName'] ?? '',
        );

        debugPrint('✅ Token refreshed successfully');
        return true;
      }

      debugPrint('❌ Refresh failed');
      return false;
    } catch (e) {
      debugPrint('Refresh token error: $e');
      return false;
    }
  }

  Future<List<Customer>> getActiveCustomers(int companyId) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getActiveCustomersUrl(companyId)),
      );

      if (response.statusCode != 200) return [];

      final decodedBody = jsonDecode(response.body);
      final activeCustomersResponse = ActiveCustomersResponse.fromJson(
        decodedBody,
      );

      return activeCustomersResponse.responseStatus
          ? activeCustomersResponse.responseData
          : [];
    } catch (e) {
      debugPrint('Get active customers error: $e');
      return [];
    }
  }

  Future<CustomerDetailData?> getCustomerDetail(
    int companyId,
    int customerId,
  ) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getCustomerDetailUrl(companyId, customerId)),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final customerResponse = CustomerDetailResponse.fromJson(data);

      return customerResponse.responseStatus
          ? customerResponse.responseData
          : null;
    } catch (e) {
      debugPrint('Get customer detail error: $e');
      return null;
    }
  }

  Future<CustomerEditResponse?> updateCustomer(
    int companyId,
    int customerId,
    CustomerEditRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        AppConfig.getCustomerEditUrl(companyId, customerId),
        request.toJson(),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      return CustomerEditResponse(
        responseStatus: data['responseStatus'] ?? false,
        responseCode: data['responseCode'],
        responseMessage: data['responseMessage'] ?? '',
        responseData: data['responseData'],
      );
    } catch (e) {
      debugPrint('Update customer error: $e');
      return null;
    }
  }

  Future<CustomerEditResponse?> createCustomer(
    int companyId,
    CreateCustomerRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        AppConfig.getCreateCustomerUrl(companyId),
        request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) return null;

      final data = jsonDecode(response.body);
      return CustomerEditResponse(
        responseStatus: data['responseStatus'] ?? false,
        responseCode: data['responseCode'],
        responseMessage: data['responseMessage'] ?? '',
        responseData: data['responseData'],
      );
    } catch (e) {
      debugPrint('Create customer error: $e');
      return null;
    }
  }
}
