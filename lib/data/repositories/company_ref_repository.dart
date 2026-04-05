import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';
import '../../domain/model/main_model/company_ref/order_ref.dart';
import '../../domain/model/main_model/company_ref/payment_ref.dart';
import '../services/api_services.dart';

class CompanyRefRepository {
  final ApiService _apiService = ApiService();

  // ─── Order Ref ───

  Future<OrderRef?> getOrderRef(int companyId, int orderId) async {
    try {
      final url = AppConfig.getOrderRefUrl(companyId, orderId);
      final response = await _apiService.get(Uri.parse(url));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final refData = data['data'] ?? data['responseData'];
      if (refData == null) return null;

      return OrderRef.fromJson(refData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Get order ref error: $e');
      return null;
    }
  }

  Future<bool> updateOrderRef(
    int companyId,
    int orderId,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = AppConfig.getOrderRefUrl(companyId, orderId);
      final response = await _apiService.put(url, body);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['status'] == 200 ||
          data['responseStatus'] == true;
    } catch (e) {
      debugPrint('Update order ref error: $e');
      return false;
    }
  }

  // ─── Payment Ref ───

  Future<PaymentRef?> getPaymentRef(int companyId, int paymentId) async {
    try {
      final url = AppConfig.getPaymentRefUrl(companyId, paymentId);
      final response = await _apiService.get(Uri.parse(url));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final refData = data['data'] ?? data['responseData'];
      if (refData == null) return null;

      return PaymentRef.fromJson(refData as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Get payment ref error: $e');
      return null;
    }
  }

  Future<bool> updatePaymentRef(
    int companyId,
    int paymentId,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = AppConfig.getPaymentRefUrl(companyId, paymentId);
      final response = await _apiService.put(url, body);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['status'] == 200 ||
          data['responseStatus'] == true;
    } catch (e) {
      debugPrint('Update payment ref error: $e');
      return false;
    }
  }
}
