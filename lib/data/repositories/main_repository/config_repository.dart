import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../domain/model/main_model/config/company_config.dart';
import '../../services/api_services.dart';

class ConfigRepository {
  final ApiService _apiService = ApiService();

  Future<CompanyConfig?> getCompanyConfig(int companyId) async {
    try {
      final url = AppConfig.getCompanyConfigUrl(companyId);
      final response = await _apiService.get(Uri.parse(url));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final configData = data['data'] ?? data['responseData'];
      if (configData == null) return null;

      return CompanyConfig.fromJson(configData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Get company config error: $e');
      return null;
    }
  }

  Future<bool> setConfigOverride(
    int companyId,
    String configKey,
    String configValue,
  ) async {
    try {
      final url = AppConfig.getCompanyConfigKeyUrl(companyId, configKey);
      final response = await _apiService.put(url, {'configValue': configValue});

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['status'] == 200 ||
          data['responseStatus'] == true;
    } catch (e) {
      debugPrint('Set config override error: $e');
      return false;
    }
  }

  Future<bool> resetConfigToDefault(int companyId, String configKey) async {
    try {
      final url = AppConfig.getCompanyConfigKeyUrl(companyId, configKey);
      final response = await _apiService.delete(url);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['status'] == 200 ||
          data['responseStatus'] == true;
    } catch (e) {
      debugPrint('Reset config error: $e');
      return false;
    }
  }
}
