import 'dart:convert';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/customer/create_customer_request.dart';
import 'package:coreflow/domain/model/customer/customer.dart';
import 'package:coreflow/domain/model/customer/customer_detail.dart';
import 'package:coreflow/domain/model/customer/customer_edit_request.dart';
import 'package:coreflow/domain/model/customer/customer_edit_response.dart';
import 'package:coreflow/domain/model/customer/customer_mapped_item.dart';
import 'package:coreflow/domain/model/customer/customer_status_response.dart';
import 'package:coreflow/domain/model/items/item_status_response.dart';
import 'package:coreflow/domain/model/items/sellable_item.dart';
import 'package:flutter/material.dart';
import '../../core/config/app_config.dart';

class CustomerRepository {
  final ApiService _apiService = ApiService();

  Future<List<Customer>> getCustomers(int companyId) async {
    try {
      final url = AppConfig.getCustomersUrl(companyId);
      final response = await _apiService.get(Uri.parse(url));

      if (response.statusCode != 200) return [];

      final Map<String, dynamic> decodedBody = jsonDecode(response.body);

      if (decodedBody['responseStatus'] != true) return [];

      final List<dynamic> data = decodedBody['responseData'] ?? [];
      final customers = data.map((json) => Customer.fromJson(json)).toList();

      return customers;
    } catch (e) {
      debugPrint('Get customers error: $e');
      return [];
    }
  }

  Future<CustomerDetailData?> getCustomerDetail(
    int companyId,
    int customerId,
  ) async {
    try {
      final response = await _apiService.get(
        Uri.parse(AppConfig.getCustomerDetailUrl(companyId, customerId)),
      );

      if (response.statusCode == 420) {
        debugPrint('Customer inactive (420): ID $customerId');
        return null;
      }

      if (response.statusCode != 200) {
        debugPrint('Customer detail failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      final customerResponse = CustomerDetailResponse.fromJson(data);

      return customerResponse.responseStatus
          ? customerResponse.responseData
          : null;
    } catch (e) {
      debugPrint('Get customer detail error: $e');
      return null;
    }
  }

  Future<CustomerEditResponse?> updateCustomer(
    int companyId,
    int customerId,
    CustomerEditRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        AppConfig.getCustomerEditUrl(companyId, customerId),
        request.toJson(),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      return CustomerEditResponse(
        responseStatus: data['responseStatus'] ?? false,
        responseCode: data['responseCode'],
        responseMessage: data['responseMessage'] ?? '',
        responseData: data['responseData'],
      );
    } catch (e) {
      debugPrint('Update customer error: $e');
      return null;
    }
  }

  Future<CustomerEditResponse?> createCustomer(
    int companyId,
    CreateCustomerRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        AppConfig.getCreateCustomerUrl(companyId),
        request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) return null;

      final data = jsonDecode(response.body);
      return CustomerEditResponse(
        responseStatus: data['responseStatus'] ?? false,
        responseCode: data['responseCode'],
        responseMessage: data['responseMessage'] ?? '',
        responseData: data['responseData'],
      );
    } catch (e) {
      debugPrint('Create customer error: $e');
      return null;
    }
  }

  Future<CustomerStatusResponse?> activateCustomer(
    int companyId,
    int customerId,
  ) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getCustomerActivateUrl(companyId, customerId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Activate failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return CustomerStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Activate error: $e');
      return null;
    }
  }

  Future<CustomerStatusResponse?> deactivateCustomer(
    int companyId,
    int customerId,
  ) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getCustomerDeactivateUrl(companyId, customerId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Deactivate failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return CustomerStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Deactivate error: $e');
      return null;
    }
  }

  Future<List<CustomerMappedItem>> getCustomerMappedItems(
    int companyId,
    int customerId,
  ) async {
    try {
      final url = AppConfig.getCustomerMappedItemsUrl(companyId, customerId);
      final response = await _apiService.get(Uri.parse(url));

      debugPrint(
        'GET /customers/$customerId/items/mapped response status: ${response.statusCode}',
      );

      if (response.statusCode != 200) {
        debugPrint('Get customer mapped items failed: ${response.statusCode}');
        return [];
      }

      final Map<String, dynamic> decodedBody =
          jsonDecode(response.body) as Map<String, dynamic>;

      final bool? responseStatus = decodedBody['responseStatus'];
      if (responseStatus != true) {
        debugPrint(
          'Get customer mapped items responseStatus false: ${decodedBody['responseMessage']}',
        );
        return [];
      }

      final List<dynamic> data = decodedBody['responseData'] ?? [];
      return data.map((json) => CustomerMappedItem.fromJson(json)).toList();
    } catch (e, stack) {
      debugPrint('Get customer mapped items error: $e\n$stack');
      return [];
    }
  }

  Future<ItemStatusResponse?> createCustomerItem({
    required int companyId,
    required int customerId,
    required int itemId,
    required double salesPrice,
    String? salesDescription,
  }) async {
    try {
      final response = await _apiService
          .post(AppConfig.getCustomerItemsUrl(companyId, customerId), {
            'itemId': itemId,
            'salesPrice': salesPrice,
            if (salesDescription != null && salesDescription.trim().isNotEmpty)
              'salesDescription': salesDescription.trim(),
          });

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Create customer item failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ItemStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Create customer item error: $e');
      return null;
    }
  }

  Future<ItemStatusResponse?> updateCustomerItem({
    required int companyId,
    required int customerId,
    required int itemId,
    required double salesPrice,
    String? salesDescription,
  }) async {
    try {
      final url = AppConfig.getCustomerItemDetailUrl(
        companyId,
        customerId,
        itemId,
      );
      final body = {
        'salesPrice': salesPrice,
        if (salesDescription != null && salesDescription.trim().isNotEmpty)
          'salesDescription': salesDescription.trim(),
      };

      var response = await _apiService.put(url, body);
      if (response.statusCode == 405) {
        response = await _apiService.patch(url, body);
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Update customer item failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ItemStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Update customer item error: $e');
      return null;
    }
  }

  Future<ItemStatusResponse?> activateCustomerMappedItem(
    int companyId,
    int customerId,
    int itemId,
  ) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getCustomerItemActivateUrl(companyId, customerId, itemId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Activate customer item failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return ItemStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Activate customer item error: $e');
      return null;
    }
  }

  Future<ItemStatusResponse?> deactivateCustomerMappedItem(
    int companyId,
    int customerId,
    int itemId,
  ) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getCustomerItemDeactivateUrl(companyId, customerId, itemId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Deactivate customer item failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return ItemStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Deactivate customer item error: $e');
      return null;
    }
  }

  Future<List<SellableItem>> getCustomerSellableItems(
    int companyId,
    int customerId,
  ) async {
    try {
      final url =
          AppConfig.getCustomerSellableItemsUrl(companyId, customerId);
      final response = await _apiService.get(Uri.parse(url));

      debugPrint(
        'GET /customers/$customerId/items/sellable status: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 202) {
        debugPrint(
            'Get sellable items failed: ${response.statusCode}');
        return [];
      }

      final Map<String, dynamic> decodedBody =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (decodedBody['responseStatus'] != true) {
        debugPrint(
          'Get sellable items responseStatus false: ${decodedBody['responseMessage']}',
        );
        return [];
      }

      final List<dynamic> data = decodedBody['responseData'] ?? [];
      debugPrint('Sellable items responseData: ${jsonEncode(data)}');
      return data.map((json) => SellableItem.fromJson(json)).toList();
    } catch (e, stack) {
      debugPrint('Get customer sellable items error: $e\n$stack');
      return [];
    }
  }
}
