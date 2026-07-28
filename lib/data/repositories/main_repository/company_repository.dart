import 'dart:convert';
import 'dart:io';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/main_model/company/companies_response.dart';
import 'package:coreflow/domain/model/main_model/company/company.dart';
import 'package:coreflow/domain/model/main_model/company/marketplace_company.dart';
import 'package:coreflow/domain/model/main_model/company/marketplace_item.dart';
import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';

class CompanyRepository {
  final ApiService _apiService = ApiService();

  Future<List<Company>> getMyCompanies() async {
    try {
      final response = await _apiService.get(Uri.parse(AppConfig.companyUrl));

      if (response.statusCode != 200 && response.statusCode != 202) {
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
      final response = await _apiService.post(AppConfig.createCompanyUrl, data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Create company failed: ${response.statusCode}');
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded['responseStatus'] == true &&
          decoded['responseData'] != null) {
        return Company.fromJson(decoded['responseData']);
      }
      return null;
    } catch (e) {
      debugPrint('Create company error: $e');
      return null;
    }
  }

  Future<bool> updateCompany(
    int companyId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.put(
        AppConfig.getCompanyDetailUrl(companyId),
        data,
      );
      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Update company failed: ${response.statusCode}');
        return false;
      }
      final decoded = jsonDecode(response.body);
      return decoded['responseStatus'] == true;
    } catch (e) {
      debugPrint('Update company error: $e');
      return false;
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

  Future<Company?> getCompanyById(int companyId) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getCompanyDetailUrl(companyId)),
      );
      if (response.statusCode != 200 && response.statusCode != 202) {
        debugPrint('Get company detail failed: ${response.statusCode}');
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded['responseStatus'] == true &&
          decoded['responseData'] != null) {
        return Company.fromJson(decoded['responseData']);
      }
      return null;
    } catch (e) {
      debugPrint('Get company detail error: $e');
      return null;
    }
  }

  Future<String?> uploadCompanyLogo(int companyId, File file) async {
    try {
      final response = await _apiService.multipartPost(
        url: AppConfig.getCompanyLogoUploadUrl(companyId),
        fields: {},
        file: file,
        fileFieldName: 'file',
      );
      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Upload company logo failed: ${response.statusCode}');
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded['responseStatus'] == true &&
          decoded['responseData'] != null) {
        return decoded['responseData']['fsId'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Upload company logo error: $e');
      return null;
    }
  }

  Future<List<MarketplaceCompany>> getAllCompanies() async {
    return getMarketplaceCompanies();
  }

  Future<List<MarketplaceCompany>> getMarketplaceCompanies() async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.marketplaceCompaniesUrl),
      );

      if (response.statusCode != 200 && response.statusCode != 202) {
        return [];
      }

      final data = jsonDecode(response.body);
      if (data['responseStatus'] != true) return [];

      final List<dynamic> list = data['responseData'] ?? [];
      return list
          .map(
            (json) => MarketplaceCompany.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('Get all companies error: $e');
      return [];
    }
  }

  Future<MarketplaceCompany?> getMarketplaceCompanyById(int companyId) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getMarketplaceCompanyDetailUrl(companyId)),
      );

      if (response.statusCode != 200 && response.statusCode != 202) {
        debugPrint(
          'Get marketplace company detail failed: ${response.statusCode}',
        );
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['responseStatus'] != true || data['responseData'] == null) {
        return null;
      }

      return MarketplaceCompany.fromJson(
        data['responseData'] as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('Get marketplace company detail error: $e');
      return null;
    }
  }

  Future<List<MarketplaceItem>> getMarketplaceCompanyItems(
    int companyId,
  ) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getMarketplaceCompanyItemsUrl(companyId)),
      );

      if (response.statusCode != 200 && response.statusCode != 202) {
        debugPrint(
          'Get marketplace company items failed: ${response.statusCode}',
        );
        return [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['responseStatus'] != true) return [];

      final raw = data['responseData'];
      if (raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(MarketplaceItem.fromJson)
          .toList(growable: false);
    } catch (e) {
      debugPrint('Get marketplace company items error: $e');
      return [];
    }
  }
}
