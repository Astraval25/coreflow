import 'dart:convert';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/customer/customer_mapped_item.dart';
import 'package:coreflow/domain/model/items/item_status_response.dart';
import 'package:coreflow/domain/model/items/sellable_item.dart';
import 'package:coreflow/domain/model/vendors/create_vendors_request.dart';
import 'package:coreflow/domain/model/vendors/vendors.dart';
import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:coreflow/domain/model/vendors/vendors_edit_request.dart';
import 'package:coreflow/domain/model/vendors/vendors_edit_response.dart';
import 'package:coreflow/domain/model/vendors/vendor_orders_payments.dart';
import 'package:coreflow/domain/model/vendors/vendors_status_response.dart';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';

class VendorRepository {
  final ApiService _apiService = ApiService();

  Future<List<Vendor>> getActiveVendors(int companyId) async {
    try {
      final url = AppConfig.getActiveVendorsUrl(companyId);
      final response = await _apiService.get(Uri.parse(url));

      if (response.statusCode != 200) return [];

      final Map<String, dynamic> decodedBody = jsonDecode(response.body);

      if (decodedBody['responseStatus'] != true) return [];

      final List<dynamic> data = decodedBody['responseData'] ?? [];
      final vendors = data.map((json) => Vendor.fromJson(json)).toList();

      return vendors;
    } catch (e) {
      debugPrint('Get active vendors error: $e');
      return [];
    }
  }

  Future<VendorsDetailData?> getVendorDetail(
    int companyId,
    int vendorId,
  ) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getVendorDetailUrl(companyId, vendorId)),
      );

      if (response.statusCode == 420) {
        debugPrint('Vendor inactive (420): ID $vendorId');
        return null;
      }

      if (response.statusCode != 200) {
        debugPrint('Vendor detail failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      final vendorResponse = VendorsDetailResponse.fromJson(data);

      return vendorResponse.responseStatus ? vendorResponse.responseData : null;
    } catch (e) {
      debugPrint('Get vendor detail error: $e');
      return null;
    }
  }

  Future<VendorsEditResponse?> updateVendor(
    int companyId,
    int vendorId,
    VendorsEditRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        AppConfig.getVendorEditUrl(companyId, vendorId),
        request.toJson(),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      return VendorsEditResponse(
        responseStatus: data['responseStatus'] ?? false,
        responseCode: data['responseCode'],
        responseMessage: data['responseMessage'] ?? '',
        responseData: data['responseData'],
      );
    } catch (e) {
      debugPrint('Update vendor error: $e');
      return null;
    }
  }

  Future<VendorsEditResponse?> createVendor(
    int companyId,
    CreateVendorsRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        AppConfig.getCreateVendorUrl(companyId),
        request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) return null;

      final data = jsonDecode(response.body);
      return VendorsEditResponse(
        responseStatus: data['responseStatus'] ?? false,
        responseCode: data['responseCode'],
        responseMessage: data['responseMessage'] ?? '',
        responseData: data['responseData'],
      );
    } catch (e) {
      debugPrint('Create vendor error: $e');
      return null;
    }
  }

  Future<VendorsStatusResponse?> activateVendor(
    int companyId,
    int vendorId,
  ) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getVendorActivateUrl(companyId, vendorId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Activate vendor failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return VendorsStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Activate vendor error: $e');
      return null;
    }
  }

  Future<VendorsStatusResponse?> deactivateVendor(
    int companyId,
    int vendorId,
  ) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getVendorDeactivateUrl(companyId, vendorId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Deactivate vendor failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return VendorsStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Deactivate vendor error: $e');
      return null;
    }
  }

  Future<List<CustomerMappedItem>> getVendorMappedItems(
    int companyId,
    int vendorId,
  ) async {
    try {
      final url = AppConfig.getVendorMappedItemsUrl(companyId, vendorId);
      final response = await _apiService.get(Uri.parse(url));

      if (response.statusCode != 200) {
        debugPrint('Get vendor mapped items failed: ${response.statusCode}');
        return [];
      }

      final Map<String, dynamic> decodedBody =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (decodedBody['responseStatus'] != true) {
        debugPrint(
          'Get vendor mapped items responseStatus false: ${decodedBody['responseMessage']}',
        );
        return [];
      }

      final List<dynamic> data = decodedBody['responseData'] ?? [];
      return data.map((json) => CustomerMappedItem.fromJson(json)).toList();
    } catch (e, stack) {
      debugPrint('Get vendor mapped items error: $e\n$stack');
      return [];
    }
  }

  Future<ItemStatusResponse?> createVendorItem({
    required int companyId,
    required int vendorId,
    required int itemId,
    required double purchasePrice,
    String? purchaseDescription,
  }) async {
    try {
      final response = await _apiService
          .post(AppConfig.getVendorItemsUrl(companyId, vendorId), {
            'itemId': itemId,
            'purchasePrice': purchasePrice,
            if (purchaseDescription != null &&
                purchaseDescription.trim().isNotEmpty)
              'purchaseDescription': purchaseDescription.trim(),
          });

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Create vendor item failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ItemStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Create vendor item error: $e');
      return null;
    }
  }

  Future<ItemStatusResponse?> updateVendorItem({
    required int companyId,
    required int vendorId,
    required int itemId,
    required double purchasePrice,
    String? purchaseDescription,
  }) async {
    try {
      final url = AppConfig.getVendorItemDetailUrl(companyId, vendorId, itemId);
      final body = {
        'purchasePrice': purchasePrice,
        if (purchaseDescription != null &&
            purchaseDescription.trim().isNotEmpty)
          'purchaseDescription': purchaseDescription.trim(),
      };

      var response = await _apiService.put(url, body);
      if (response.statusCode == 405) {
        response = await _apiService.patch(url, body);
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Update vendor item failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ItemStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Update vendor item error: $e');
      return null;
    }
  }

  Future<ItemStatusResponse?> activateVendorMappedItem(
    int companyId,
    int vendorId,
    int itemId,
  ) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getVendorItemActivateUrl(companyId, vendorId, itemId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Activate vendor item failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return ItemStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Activate vendor item error: $e');
      return null;
    }
  }

  Future<ItemStatusResponse?> deactivateVendorMappedItem(
    int companyId,
    int vendorId,
    int itemId,
  ) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getVendorItemDeactivateUrl(companyId, vendorId, itemId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Deactivate vendor item failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return ItemStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Deactivate vendor item error: $e');
      return null;
    }
  }

  Future<List<SellableItem>> getVendorPurchasableItems(
    int companyId,
    int vendorId,
  ) async {
    try {
      final url =
          AppConfig.getVendorPurchasableItemsUrl(companyId, vendorId);
      final response = await _apiService.get(Uri.parse(url));

      final Map<String, dynamic> decodedBody =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (decodedBody['responseStatus'] != true) {
        debugPrint(
          'Get purchasable items responseStatus false: ${decodedBody['responseMessage']}',
        );
        return [];
      }

      final List<dynamic> data = decodedBody['responseData'] ?? [];
      debugPrint('Purchasable items responseData: ${jsonEncode(data)}');
      return data.map((json) => SellableItem.fromJson(json)).toList();
    } catch (e, stack) {
      debugPrint('Get vendor purchasable items error: $e\n$stack');
      return [];
    }
  }

  Future<VendorOrdersPaymentsData?> getVendorOrdersPayments(
    int companyId,
    int vendorId,
  ) async {
    try {
      final url = AppConfig.getVendorOrdersPaymentsUrl(companyId, vendorId);
      final response = await _apiService.get(Uri.parse(url));

      if (response.statusCode != 200 && response.statusCode != 202) {
        debugPrint('Get vendor orders-payments failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final parsed = VendorOrdersPaymentsResponse.fromJson(data);
      if (!parsed.responseStatus) {
        debugPrint(
          'Get vendor orders-payments responseStatus false: ${parsed.responseMessage}',
        );
        return null;
      }

      return parsed.responseData ??
          VendorOrdersPaymentsData(orders: const [], payments: const []);
    } catch (e) {
      debugPrint('Get vendor orders-payments error: $e');
      return null;
    }
  }
}
