import 'dart:convert';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/company/companies_response.dart';
import 'package:coreflow/domain/model/company/company.dart';
import 'package:coreflow/domain/model/company/marketplace_company.dart';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';

class CompanyRepository {
  final ApiService _apiService = ApiService();

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

  Future<Company?> createCompany(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post(
        AppConfig.createCompanyUrl,
        data,
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Create company failed: ${response.statusCode}');
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded['responseStatus'] == true && decoded['responseData'] != null) {
        return Company.fromJson(decoded['responseData']);
      }
      return null;
    } catch (e) {
      debugPrint('Create company error: $e');
      return null;
    }
  }

  Future<Company?> updateCompany(int companyId, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put(
        AppConfig.getCompanyDetailUrl(companyId),
        data,
      );
      if (response.statusCode != 200) {
        debugPrint('Update company failed: ${response.statusCode}');
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded['responseStatus'] == true && decoded['responseData'] != null) {
        return Company.fromJson(decoded['responseData']);
      }
      return null;
    } catch (e) {
      debugPrint('Update company error: $e');
      return null;
    }
  }

  Future<bool> activateCompany(int companyId) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getCompanyActivateUrl(companyId),
        {},
      );
      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Activate company failed: ${response.statusCode}');
        return false;
      }
      final decoded = jsonDecode(response.body);
      return decoded['responseStatus'] == true;
    } catch (e) {
      debugPrint('Activate company error: $e');
      return false;
    }
  }

  Future<bool> deactivateCompany(int companyId) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getCompanyDeactivateUrl(companyId),
        {},
      );
      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Deactivate company failed: ${response.statusCode}');
        return false;
      }
      final decoded = jsonDecode(response.body);
      return decoded['responseStatus'] == true;
    } catch (e) {
      debugPrint('Deactivate company error: $e');
      return false;
    }
  }

  Future<List<MarketplaceCompany>> getAllCompanies() async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.allCompaniesUrl),
      );

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      if (data['responseStatus'] != true) return [];

      final List<dynamic> list = data['responseData'] ?? [];
      return list
          .map((json) => MarketplaceCompany.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get all companies error: $e');
      return [];
    }
  }
}
