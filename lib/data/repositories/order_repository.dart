import 'dart:convert';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/purchase/create_purchase_order_request.dart';
import 'package:coreflow/domain/model/purchase/purchase_order.dart';
import 'package:coreflow/domain/model/purchase/purchase_order_detail.dart';
import 'package:coreflow/domain/model/purchase/purchase_order_detail_response.dart';
import 'package:coreflow/domain/model/sales/create_sales_order_request.dart';
import 'package:coreflow/domain/model/sales/sales_order.dart';
import 'package:coreflow/domain/model/sales/sales_order_detail.dart'
    as sales_detail;
import 'package:coreflow/domain/model/sales/sales_order_detail_response.dart'
    as sales_detail;
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';

class OrderRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> createSalesOrder(
    int companyId,
    CreateSalesOrderRequest request,
  ) async {
    try {
      final url = AppConfig.getSalesOrdersUrl(companyId);
      final response = await _apiService.post(url, request.toJson());

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['responseStatus'] == true) {
        return {
          'success': true,
          'message': data['responseMessage'] ?? 'Order created',
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<List<SalesOrder>> getSalesOrders(int companyId) async {
    try {
      final url = AppConfig.getSalesOrdersUrl(companyId);
      final response = await _apiService.get(Uri.parse(url));

      // debugPrint(
      //   'GET /companies/$companyId/sales/orders status: ${response.statusCode}',
      // );

      if (response.statusCode != 200 && response.statusCode != 202) {
        debugPrint('Get sales orders failed: ${response.statusCode}');
        return [];
      }
      final Map<String, dynamic> decodedBody =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (decodedBody['responseStatus'] != true) {
        debugPrint(
          'Get sales orders responseStatus false: ${decodedBody['responseMessage']}',
        );
        return [];
      }
      final List<dynamic> data = decodedBody['responseData'] ?? [];
      return data.map((json) => SalesOrder.fromJson(json)).toList();
    } catch (e, stack) {
      debugPrint('Get sales orders error: $e\n$stack');
      return [];
    }
  }

  Future<sales_detail.SalesOrderDetail?> getSalesOrderDetail(
    int companyId,
    int orderId,
  ) async {
    try {
      final uri = Uri.parse(AppConfig.getOrderDetailUrl(companyId, orderId));

      final response = await _apiService.get(uri);

      if (response.statusCode != 200 && response.statusCode != 202) {
        return null;
      }

      final Map<String, dynamic> jsonMap =
          jsonDecode(response.body) as Map<String, dynamic>;

      final detailResponse = sales_detail.SalesOrderDetailResponse.fromJson(
        jsonMap,
      );

      if (!detailResponse.responseStatus) return null;

      return detailResponse.responseData;
    } catch (e) {
      debugPrint('Get order detail error: $e');
      return null;
    }
  }

  Future<List<PurchaseOrder>> getPurchaseOrders(int companyId) async {
    try {
      final url = AppConfig.getPurchaseOrdersUrl(companyId);
      final response = await _apiService.get(Uri.parse(url));

      // debugPrint(
      //   'GET /companies/$companyId/purchase/orders status: ${response.statusCode}',
      // );

      if (response.statusCode != 200 && response.statusCode != 202) {
        debugPrint('Get purchase orders failed: ${response.statusCode}');
        return [];
      }

      final Map<String, dynamic> decodedBody =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (decodedBody['responseStatus'] != true) {
        debugPrint(
          'Get purchase orders responseStatus false: ${decodedBody['responseMessage']}',
        );
        return [];
      }

      final List<dynamic> data = decodedBody['responseData'] ?? [];
      return data
          .map((json) => PurchaseOrder.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      debugPrint('Get purchase orders error: $e\n$stack');
      return [];
    }
  }

  Future<PurchaseOrderDetail?> getPurchaseOrderDetail(
    int companyId,
    int orderId,
  ) async {
    try {
      final uri = Uri.parse(AppConfig.getOrderDetailUrl(companyId, orderId));
      final response = await _apiService.get(uri);

      // debugPrint(
      //   'GET /companies/$companyId/orders/$orderId status: ${response.statusCode}',
      // );

      if (response.statusCode != 200 && response.statusCode != 202) {
        return null;
      }

      final Map<String, dynamic> jsonMap =
          jsonDecode(response.body) as Map<String, dynamic>;
      final detailResponse = PurchaseOrderDetailResponse.fromJson(jsonMap);

      if (!detailResponse.responseStatus) return null;

      return detailResponse.responseData;
    } catch (e, stack) {
      debugPrint('Get purchase order detail error: $e\n$stack');
      return null;
    }
  }

  Future<Map<String, dynamic>> createPurchaseOrder(
    int companyId,
    CreatePurchaseOrderRequest request,
  ) async {
    try {
      final url = AppConfig.getPurchaseOrdersUrl(companyId);
      final response = await _apiService.post(url, request.toJson());

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['responseStatus'] == true) {
        return {
          'success': true,
          'message': data['responseMessage'] ?? 'Order created',
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
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updatePurchaseOrder(
    int companyId,
    int orderId,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = AppConfig.getUpdatePurchaseOrderUrl(companyId, orderId);
      final response = await _apiService.put(url, body);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['responseStatus'] == true) {
        return {
          'success': true,
          'message': data['responseMessage'] ?? 'Order updated',
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
      debugPrint('Update purchase order error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateSalesOrder(
    int companyId,
    int orderId,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = AppConfig.getUpdateSalesOrderUrl(companyId, orderId);
      final response = await _apiService.put(url, body);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['responseStatus'] == true) {
        return {
          'success': true,
          'message': data['responseMessage'] ?? 'Order updated',
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
      debugPrint('Update sales order error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    int companyId,
    int orderId,
    String action,
  ) async {
    try {
      final url = AppConfig.getOrderStatusUrl(companyId, orderId, action);
      final response = await _apiService.put(url, {});
      debugPrint('Order status [$action][${response.statusCode}]: ${response.body}');
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
      debugPrint('Update order status error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
