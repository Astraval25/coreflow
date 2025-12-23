import 'dart:convert';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/login/login_request.dart';
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

      if (response.statusCode == 200) {
        final decodedBody = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(decodedBody);
        
      
        if (loginResponse.responseStatus && loginResponse.responseData != null) {
          final data = loginResponse.responseData!;
                  await TokenStorage.saveTokens(
            token: data.token,
            refreshToken: data.refreshToken,
            userId: data.userId,
            companyId: data.companyId,
          );
          return loginResponse;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    return await TokenStorage.hasValidToken();
  }
}
