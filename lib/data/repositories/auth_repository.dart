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
import 'package:coreflow/domain/model/customer/customer_status_response.dart';
import 'package:coreflow/domain/model/login/login_request.dart';
import 'package:coreflow/domain/model/register/register_request.dart';
import 'package:coreflow/domain/model/register/register_response.dart';
import 'package:coreflow/domain/model/resend_otp/resend_otp_request.dart';
import 'package:coreflow/domain/model/resend_otp/resend_otp_response.dart';
import 'package:coreflow/domain/model/verify_otp/verify_otp_request.dart';
import 'package:coreflow/domain/model/verify_otp/verify_otp_response.dart';
import 'package:coreflow/domain/repositories/login_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  Future<void> saveAuthData(LoginData? data, String email) async {
    if (data == null || email.isEmpty) {
      debugPrint('saveAuthData: null data or empty email');
      return;
    }

    try {
      await TokenStorage.saveFullAuthData(
        userId: data.userId.toString(),
        companyId: data.companyId,
        companyIds: data.companyIds.isNotEmpty == true ? data.companyIds : null,
        companyName: data.companyName.isNotEmpty == true
            ? data.companyName
            : null,
        token: data.token,
        refreshToken: data.refreshToken,
        roleCode: data.roleCode.isNotEmpty == true ? data.roleCode : null,
        landingUrl: data.landingUrl.isNotEmpty ? data.landingUrl : '/dashboard',
        email: email.trim(),
        userName: data.userName?.isNotEmpty == true
            ? data.userName
            : email.split('@').first.trim(),
      );

      // Verify save worked
      final verifyData = await TokenStorage.getFullAuthData();
      debugPrint(
        ' Auth data saved. Token exists: ${verifyData?['token']?.isNotEmpty == true}',
      );
    } catch (e) {
      debugPrint(' saveAuthData error: $e');
    }
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
      if (authData == null || authData['refreshToken']?.isEmpty != false) {
        debugPrint(' No refresh token available');
        return false;
      }

      final refreshToken = authData['refreshToken']!.trim();
      List<Map<String, dynamic>> bodies = [
        {'refreshToken': refreshToken},
        {'refresh_token': refreshToken},
        {'token': refreshToken},
      ];

      for (int i = 0; i < bodies.length; i++) {
        try {
          final response = await http
              .post(
                Uri.parse(AppConfig.refreshTokenUrl),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(bodies[i]),
              )
              .timeout(const Duration(seconds: 10));

          debugPrint(
            'Refresh try ${i + 1} (${bodies[i].keys.first}): ${response.statusCode}',
          );
          debugPrint(' RAW RESPONSE: ${response.body}');

          if (response.statusCode == 200) {
            final rawData = jsonDecode(response.body);

            dynamic responseData = rawData['responseData'];
            if (responseData == null) {
              responseData = rawData;
            }

            String? newToken =
                responseData['token']?.toString().trim() ??
                rawData['token']?.toString().trim() ??
                responseData['accessToken']?.toString().trim() ??
                rawData['access_token']?.toString().trim();

            String? newRefreshToken =
                responseData['refreshToken']?.toString().trim() ??
                rawData['refreshToken']?.toString().trim() ??
                responseData['refresh_token']?.toString().trim();

            debugPrint(
              'Found token: ${newToken?.isNotEmpty ?? false}, refresh: ${newRefreshToken?.isNotEmpty ?? false}',
            );

            if (newToken?.isNotEmpty == true) {
              final saveSuccess = await TokenStorage.saveFullAuthData(
                userId: (responseData['userId'] ?? authData['userId'])
                    .toString(),
                companyId: responseData['companyId'] ?? authData['companyId'],
                companyIds: responseData['companyIds'] != null
                    ? List<int>.from(responseData['companyIds'])
                    : authData['companyIds'] != null
                    ? List<int>.from(jsonDecode(authData['companyIds']))
                    : null,
                companyName:
                    responseData['companyName']?.toString() ??
                    authData['companyName']?.toString(),
                token: newToken!,
                refreshToken: newRefreshToken ?? refreshToken,
                roleCode:
                    responseData['roleCode']?.toString() ??
                    authData['roleCode']?.toString(),
                landingUrl:
                    responseData['landingUrl']?.toString() ??
                    authData['landingUrl'] ??
                    '/dashboard',
                email: authData['email']?.toString() ?? '',
                userName: authData['userName']?.toString() ?? '',
              );

              debugPrint(' Save result: $saveSuccess');
              if (saveSuccess) {
                debugPrint(' Refresh COMPLETELY successful');
                return true;
              } else {
                debugPrint(' Save failed despite API success');
              }
            } else {
              debugPrint(' No valid token found in response ${i + 1}');
            }
          }
        } catch (e) {
          debugPrint('Refresh try ${i + 1} error: $e');
        }
      }

      return false;
    } catch (e) {
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

  Future<CustomerStatusResponse?> activateCustomer(
    int companyId,
    int customerId,
  ) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getCustomerActivateUrl(companyId, customerId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Activate failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return CustomerStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Activate error: $e');
      return null;
    }
  }

  Future<CustomerStatusResponse?> deactivateCustomer(
    int companyId,
    int customerId,
  ) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getCustomerDeactivateUrl(companyId, customerId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Deactivate failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return CustomerStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Deactivate error: $e');
      return null;
    }
  }

  Future<List<Customer>> getActiveVendors(int companyId) async {
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

  Future<CustomerDetailData?> getVendorsDetail(
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

  Future<CustomerEditResponse?> updateVendors(
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

  Future<CustomerEditResponse?> createVendors(
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

  Future<CustomerStatusResponse?> activateVendors(
    int companyId,
    int customerId,
  ) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getCustomerActivateUrl(companyId, customerId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Activate failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return CustomerStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Activate error: $e');
      return null;
    }
  }

  Future<CustomerStatusResponse?> deactivateVendors(
    int companyId,
    int customerId,
  ) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getCustomerDeactivateUrl(companyId, customerId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Deactivate failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return CustomerStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Deactivate error: $e');
      return null;
    }
  }
}
