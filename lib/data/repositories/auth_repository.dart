import 'dart:convert';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/company/companies_response.dart';
import 'package:coreflow/domain/model/company/company.dart';
import 'package:coreflow/domain/model/login/login_request.dart';
import 'package:coreflow/domain/model/register/register_request.dart';
import 'package:coreflow/domain/model/register/register_response.dart';
import 'package:coreflow/domain/model/resend_otp/resend_otp_request.dart';
import 'package:coreflow/domain/model/resend_otp/resend_otp_response.dart';
import 'package:coreflow/domain/model/verify_otp/verify_otp_request.dart';
import 'package:coreflow/domain/model/verify_otp/verify_otp_response.dart';
import 'package:coreflow/domain/repositories/login_response.dart';
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

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      final decodedBody = jsonDecode(response.body);
      return LoginResponse.fromJson(decodedBody);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveAuthData(LoginData data, String email) async {
    await TokenStorage.saveFullAuthData(
      userId: data.userId!,
      companyId: data.companyId,
      companyIds: data.companyIds,
      companyName: data.companyName,
      token: data.token,
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

      print('Register Response status: ${response.statusCode}');
      print('Register Response body: ${response.body}');

      final decodedBody = jsonDecode(response.body);
      return RegisterResponse.fromJson(decodedBody);
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  Future<VerifyOtpResponse?> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _apiService.post(
        AppConfig.verifyOtpUrl,
        request.toJson(),
      );

      print('VerifyOTP Response status: ${response.statusCode}');
      print('VerifyOTP Response body: ${response.body}');

      final decodedBody = jsonDecode(response.body);
      return VerifyOtpResponse.fromJson(decodedBody);
    } catch (e) {
      print('VerifyOTP error: $e');
      return null;
    }
  }

  Future<ResendOtpResponse?> resendOtp(ResendOtpRequest request) async {
    try {
      final response = await _apiService.post(
        AppConfig.resendOtpUrl,
        request.toJson(),
      );

      print('ResendOTP Response status: ${response.statusCode}');
      print('ResendOTP Response body: ${response.body}');

      final decodedBody = jsonDecode(response.body);
      return ResendOtpResponse.fromJson(decodedBody);
    } catch (e) {
      print('ResendOTP error: $e');
      return null;
    }
  }

 Future<List<Company>> getMyCompanies() async {
  try {
    final uri = Uri.parse(AppConfig.companyUrl);
    final response = await _apiService.get(uri);
    
    print('My Companies Response: ${response.statusCode}');
    print('My Companies Body: ${response.body}');
    
    final Map<String, dynamic> decodedBody = jsonDecode(response.body);
    final companiesResponse = CompaniesResponse.fromJson(decodedBody);
    
    if (!companiesResponse.responseStatus) {
      print('API Error: ${companiesResponse.responseMessage}');
      return [];
    }
    
    return companiesResponse.responseData;
  } catch (e) {
    print('Get My Companies error: $e');
    return [];
  }
}

}
