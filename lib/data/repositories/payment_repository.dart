import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/payment/create_payment_received_request.dart';
import 'package:coreflow/domain/model/payment/create_payment_sent_request.dart';
import 'package:coreflow/domain/model/payment/payment_proof_response.dart';
import 'package:coreflow/domain/model/payment/payment_detail.dart';
import 'package:coreflow/domain/model/payment/payment_detail_response.dart';
import 'package:coreflow/domain/model/payment/payment_received_summary.dart';
import 'package:coreflow/domain/model/payment/payment_sent_summary.dart';
import 'package:coreflow/domain/model/payment/unpaid_order.dart';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';

class PaymentRepository {
  final ApiService _apiService = ApiService();

  Future<PaymentDetail?> getPaymentDetail(int companyId, int paymentId) async {
    try {
      final url = AppConfig.getPaymentDetailUrl(companyId, paymentId);
      final response = await _apiService.get(Uri.parse(url));

      debugPrint(
        'GET /companies/$companyId/payments/$paymentId status: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 202) {
        return null;
      }

      final Map<String, dynamic> jsonMap =
          jsonDecode(response.body) as Map<String, dynamic>;
      final detailResponse = PaymentDetailResponse.fromJson(jsonMap);

      if (!detailResponse.responseStatus) return null;

      return detailResponse.responseData;
    } catch (e, stack) {
      debugPrint('Get payment detail error: $e\n$stack');
      return null;
    }
  }

  Future<PaymentDetail?> getSendPaymentDetail(
    int companyId,
    int paymentId,
  ) async {
    return getPaymentDetail(companyId, paymentId);
  }

  Future<PaymentDetail?> getReceivePaymentDetail(
    int companyId,
    int paymentId,
  ) async {
    return getPaymentDetail(companyId, paymentId);
  }

  Future<List<PaymentSentSummary>> getPaymentsSentSummary(int companyId) async {
    try {
      final url = AppConfig.getPaymentsSentSummaryUrl(companyId);
      final response = await _apiService.get(Uri.parse(url));

      debugPrint(
        'GET /companies/$companyId/payments-sent/summary status: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 202) {
        debugPrint('Get payments sent summary failed: ${response.statusCode}');
        return [];
      }

      final Map<String, dynamic> decodedBody =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (decodedBody['responseStatus'] != true) {
        debugPrint(
          'Get payments sent summary responseStatus false: ${decodedBody['responseMessage']}',
        );
        return [];
      }

      final List<dynamic> data = decodedBody['responseData'] ?? [];
      return data
          .map(
            (json) => PaymentSentSummary.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e, stack) {
      debugPrint('Get payments sent summary error: $e\n$stack');
      return [];
    }
  }

  Future<List<PaymentReceivedSummary>> getPaymentsReceivedSummary(
    int companyId,
  ) async {
    try {
      final url = AppConfig.getPaymentsReceivedSummaryUrl(companyId);
      final response = await _apiService.get(Uri.parse(url));

      debugPrint(
        'GET /companies/$companyId/payments-received/summary status: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 202) {
        debugPrint(
          'Get payments received summary failed: ${response.statusCode}',
        );
        return [];
      }

      final Map<String, dynamic> decodedBody =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (decodedBody['responseStatus'] != true) {
        debugPrint(
          'Get payments received summary responseStatus false: ${decodedBody['responseMessage']}',
        );
        return [];
      }

      final List<dynamic> data = decodedBody['responseData'] ?? [];
      return data
          .map(
            (json) =>
                PaymentReceivedSummary.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e, stack) {
      debugPrint('Get payments received summary error: $e\n$stack');
      return [];
    }
  }

  Future<List<UnpaidOrder>> getVendorUnpaidOrders(
    int companyId,
    int vendorId,
  ) async {
    try {
      final url = AppConfig.getVendorUnpaidOrdersUrl(companyId, vendorId);
      final response = await _apiService.get(Uri.parse(url));

      debugPrint(
        'GET /companies/$companyId/vendor/$vendorId/unpaid-orders status: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 202) {
        return [];
      }

      final Map<String, dynamic> decodedBody =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (decodedBody['responseStatus'] != true) {
        return [];
      }

      final List<dynamic> data = decodedBody['responseData'] ?? [];
      return data
          .map((json) => UnpaidOrder.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      debugPrint('Get vendor unpaid orders error: $e\n$stack');
      return [];
    }
  }

  Future<Map<String, dynamic>> createPaymentSent(
    int companyId,
    CreatePaymentSentRequest request,
  ) async {
    try {
      final url = AppConfig.getCreatePaymentSentUrl(companyId);
      final response = await _apiService.post(url, request.toJson());

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['responseStatus'] == true) {
        return {
          'success': true,
          'message': data['responseMessage'] ?? 'Payment created',
          'data': data['responseData'],
        };
      }

      return {
        'success': false,
        'message':
            data['responseMessage'] ??
            'Failed with status ${response.statusCode}',
      };
    } catch (e) {
      debugPrint('Create payment sent error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Uint8List?> fetchPaymentProofBytes(
    int companyId,
    String fsId,
  ) async {
    try {
      final url = Uri.parse(AppConfig.getFileUrl(fsId));
      final response = await _apiService.get(url);
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      debugPrint('Fetch proof file failed: ${response.statusCode}');
      return null;
    } catch (e, stack) {
      debugPrint('Fetch proof file error: $e\n$stack');
      return null;
    }
  }

  Future<PaymentProofData?> uploadPaymentProof(
    int companyId,
    File file,
  ) async {
    try {
      final url = AppConfig.getPaymentProofUrl(companyId);
      final response = await _apiService.multipartPost(
        url: url,
        fields: {},
        file: file,
        fileFieldName: 'file',
      );

      debugPrint(
        'POST /companies/$companyId/payments/payment-proof status: ${response.statusCode}',
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final proofResponse = PaymentProofResponse.fromJson(data);

      if (proofResponse.responseStatus && proofResponse.responseData != null) {
        return proofResponse.responseData;
      }

      debugPrint('Upload payment proof failed: ${proofResponse.responseMessage}');
      return null;
    } catch (e, stack) {
      debugPrint('Upload payment proof error: $e\n$stack');
      return null;
    }
  }

  Future<List<UnpaidOrder>> getCustomerUnpaidOrders(
    int companyId,
    int customerId,
  ) async {
    try {
      final url = AppConfig.getCustomerUnpaidOrdersUrl(companyId, customerId);
      final response = await _apiService.get(Uri.parse(url));

      debugPrint(
        'GET /companies/$companyId/customer/$customerId/unpaid-orders status: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 202) {
        return [];
      }

      final Map<String, dynamic> decodedBody =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (decodedBody['responseStatus'] != true) {
        return [];
      }

      final List<dynamic> data = decodedBody['responseData'] ?? [];
      return data
          .map((json) => UnpaidOrder.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      debugPrint('Get customer unpaid orders error: $e\n$stack');
      return [];
    }
  }

  Future<Map<String, dynamic>> createPaymentReceived(
    int companyId,
    CreatePaymentReceivedRequest request,
  ) async {
    try {
      final url = AppConfig.getCreatePaymentReceivedUrl(companyId);
      final response = await _apiService.post(url, request.toJson());

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['responseStatus'] == true) {
        return {
          'success': true,
          'message': data['responseMessage'] ?? 'Payment created',
          'data': data['responseData'],
        };
      }

      return {
        'success': false,
        'message':
            data['responseMessage'] ??
            'Failed with status ${response.statusCode}',
      };
    } catch (e) {
      debugPrint('Create payment received error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updatePaymentSent(
    int companyId,
    int paymentId,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = AppConfig.getUpdatePaymentSentUrl(companyId, paymentId);
      final response = await _apiService.put(url, body);
      debugPrint('Update payment sent [${response.statusCode}]: ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['responseStatus'] == true) {
        return {
          'success': true,
          'message': data['responseMessage'] ?? 'Payment updated',
          'data': data['responseData'],
        };
      }

      return {
        'success': false,
        'message':
            data['responseMessage'] ??
            'Failed with status ${response.statusCode}',
      };
    } catch (e) {
      debugPrint('Update payment sent error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updatePaymentReceived(
    int companyId,
    int paymentId,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = AppConfig.getUpdatePaymentReceivedUrl(companyId, paymentId);
      final response = await _apiService.put(url, body);
      debugPrint('Update payment received [${response.statusCode}]: ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['responseStatus'] == true) {
        return {
          'success': true,
          'message': data['responseMessage'] ?? 'Payment updated',
          'data': data['responseData'],
        };
      }

      return {
        'success': false,
        'message':
            data['responseMessage'] ??
            'Failed with status ${response.statusCode}',
      };
    } catch (e) {
      debugPrint('Update payment received error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updatePaymentStatus(
    int companyId,
    int paymentId,
    String action,
  ) async {
    try {
      final url = AppConfig.getPaymentStatusUrl(companyId, paymentId, action);
      final response = await _apiService.put(url, {});
      debugPrint('Payment status [$action][${response.statusCode}]: ${response.body}');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['responseStatus'] == true) {
        return {
          'success': true,
          'message': data['responseMessage'] ?? 'Status updated',
        };
      }
      return {
        'success': false,
        'message': data['responseMessage'] ?? 'Failed to update status',
      };
    } catch (e) {
      debugPrint('Update payment status error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
