import 'dart:convert';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/invitation/invitation_response.dart';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';

class InvitationRepository {
  final ApiService _apiService = ApiService();

  Future<InvitationResponse?> sendCustomerInvitation(
    int companyId,
    int customerId,
  ) async {
    try {
      final url = AppConfig.getCustomerInvitationUrl(companyId, customerId);
      final response = await _apiService.post(url, {});

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Send customer invitation failed: ${response.statusCode}');
        final data = jsonDecode(response.body);
        return InvitationResponse.fromJson(data);
      }

      final data = jsonDecode(response.body);
      return InvitationResponse.fromJson(data);
    } catch (e) {
      debugPrint('Send customer invitation error: $e');
      return null;
    }
  }

  Future<InvitationResponse?> getCustomerInvitationCode(
    int companyId,
    int customerId,
  ) async {
    try {
      final url = AppConfig.getCustomerInvitationCodeUrl(companyId, customerId);
      final response = await _apiService.get(Uri.parse(url));

      if (response.statusCode != 200 && response.statusCode != 202) {
        return null;
      }

      final data = jsonDecode(response.body);
      return InvitationResponse.fromJson(data);
    } catch (e) {
      debugPrint('Get customer invitation code error: $e');
      return null;
    }
  }

  Future<InvitationResponse?> sendVendorInvitation(
    int companyId,
    int vendorId,
  ) async {
    try {
      final url = AppConfig.getVendorInvitationUrl(companyId, vendorId);
      final response = await _apiService.post(url, {});

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Send vendor invitation failed: ${response.statusCode}');
        final data = jsonDecode(response.body);
        return InvitationResponse.fromJson(data);
      }

      final data = jsonDecode(response.body);
      return InvitationResponse.fromJson(data);
    } catch (e) {
      debugPrint('Send vendor invitation error: $e');
      return null;
    }
  }

  Future<InvitationResponse?> getVendorInvitationCode(
    int companyId,
    int vendorId,
  ) async {
    try {
      final url = AppConfig.getVendorInvitationCodeUrl(companyId, vendorId);
      final response = await _apiService.get(Uri.parse(url));

      if (response.statusCode != 200 && response.statusCode != 202) {
        return null;
      }

      final data = jsonDecode(response.body);
      return InvitationResponse.fromJson(data);
    } catch (e) {
      debugPrint('Get vendor invitation code error: $e');
      return null;
    }
  }

  Future<AcceptInvitationResponse?> acceptInvitation({
    required int companyId,
    required String invitationCode,
    int? selectedVendorId,
    int? selectedCustomerId,
  }) async {
    try {
      final url = AppConfig.getAcceptInvitationUrl(companyId, invitationCode);
      final body = <String, dynamic>{};
      if (selectedVendorId != null) body['selectedVendorId'] = selectedVendorId;
      if (selectedCustomerId != null) body['selectedCustomerId'] = selectedCustomerId;

      final response = await _apiService.post(url, body);

      final data = jsonDecode(response.body);
      return AcceptInvitationResponse.fromJson(data);
    } catch (e) {
      debugPrint('Accept invitation error: $e');
      return null;
    }
  }
}
