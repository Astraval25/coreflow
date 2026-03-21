import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/company/companies_response.dart';
import 'package:coreflow/domain/model/company/company.dart';
import 'package:coreflow/domain/model/company/marketplace_company.dart';
import 'package:coreflow/domain/model/customer/create_customer_request.dart';
import 'package:coreflow/domain/model/invitation/invitation_response.dart';
import 'package:coreflow/domain/model/customer/customer.dart';
import 'package:coreflow/domain/model/customer/customer_detail.dart';
import 'package:coreflow/domain/model/customer/customer_edit_request.dart';
import 'package:coreflow/domain/model/customer/customer_edit_response.dart';
import 'package:coreflow/domain/model/customer/customer_mapped_item.dart';
import 'package:coreflow/domain/model/customer/customer_status_response.dart';
import 'package:coreflow/domain/model/items/create_item_request.dart';
import 'package:coreflow/domain/model/items/sellable_item.dart';
import 'package:coreflow/domain/model/items/detail_item.dart';
import 'package:coreflow/domain/model/items/item.dart';
import 'package:coreflow/domain/model/items/item_status_response.dart';
import 'package:coreflow/domain/model/items/update_item_request.dart';
import 'package:coreflow/domain/model/login/login_request.dart';
import 'package:coreflow/domain/model/payment/create_payment_received_request.dart';
import 'package:coreflow/domain/model/payment/create_payment_sent_request.dart';
import 'package:coreflow/domain/model/payment/payment_proof_response.dart';
import 'package:coreflow/domain/model/payment/payment_detail.dart';
import 'package:coreflow/domain/model/payment/payment_detail_response.dart';
import 'package:coreflow/domain/model/payment/payment_received_summary.dart';
import 'package:coreflow/domain/model/payment/payment_sent_summary.dart';
import 'package:coreflow/domain/model/payment/unpaid_order.dart';
import 'package:coreflow/domain/model/purchase/purchase_order_detail.dart';
import 'package:coreflow/domain/model/purchase/purchase_order_detail_response.dart';
import 'package:coreflow/domain/model/register/register_request.dart';
import 'package:coreflow/domain/model/register/register_response.dart';
import 'package:coreflow/domain/model/resend_otp/resend_otp_request.dart';
import 'package:coreflow/domain/model/resend_otp/resend_otp_response.dart';
import 'package:coreflow/domain/model/purchase/create_purchase_order_request.dart';
import 'package:coreflow/domain/model/purchase/purchase_order.dart';
import 'package:coreflow/domain/model/sales/create_sales_order_request.dart';
import 'package:coreflow/domain/model/sales/sales_order.dart';
import 'package:coreflow/domain/model/sales/sales_order_detail.dart'
    as sales_detail;
import 'package:coreflow/domain/model/sales/sales_order_detail_response.dart'
    as sales_detail;

import 'package:coreflow/domain/model/vendors/create_vendors_request.dart';
import 'package:coreflow/domain/model/vendors/vendors.dart';
import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:coreflow/domain/model/vendors/vendors_edit_request.dart';
import 'package:coreflow/domain/model/vendors/vendors_edit_response.dart';
import 'package:coreflow/domain/model/vendors/vendors_status_response.dart';
import 'package:coreflow/domain/model/verify_otp/verify_otp_request.dart';
import 'package:coreflow/domain/model/verify_otp/verify_otp_response.dart';
import 'package:coreflow/domain/repositories/login_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

      if (response.statusCode != 200) {
        debugPrint('Login failed: ${response.statusCode}');
        return null;
      }

      final decodedBody = jsonDecode(response.body);
      return LoginResponse.fromJson(decodedBody);
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  Future<void> saveAuthData(LoginData? data, String email) async {
    if (data == null || email.isEmpty) {
      debugPrint('saveAuthData: null data or empty email');
      return;
    }

    try {
      await TokenStorage.saveFullAuthData(
        userId: data.userId.toString(),
        companyId: data.companyId,
        companyIds: data.companyIds.isNotEmpty == true ? data.companyIds : null,
        companyName: data.companyName.isNotEmpty == true
            ? data.companyName
            : null,
        token: data.token,
        refreshToken: data.refreshToken,
        roleCode: data.roleCode.isNotEmpty == true ? data.roleCode : null,
        landingUrl: data.landingUrl.isNotEmpty ? data.landingUrl : '/dashboard',
        email: email.trim(),
        userName: data.userName?.isNotEmpty == true
            ? data.userName
            : email.split('@').first.trim(),
      );

      // Verify save worked
      final verifyData = await TokenStorage.getFullAuthData();
      debugPrint(
        ' Auth data saved. Token exists: ${verifyData?['token']?.isNotEmpty == true}',
      );
    } catch (e) {
      debugPrint(' saveAuthData error: $e');
    }
  }

  Future<Map<String, dynamic>?> getAuthData() async {
    return await TokenStorage.getFullAuthData();
  }

  Future<void> clearAuthData() async {
    await TokenStorage.clearAllData();
  }

  Future<bool> isLoggedIn() async {
    return await TokenStorage.hasValidToken();
  }

  Future<RegisterResponse?> register(RegisterRequest request) async {
    try {
      final response = await _apiService.post(
        AppConfig.registerUrl,
        request.toJson(),
      );

      if (response.statusCode != 200) {
        debugPrint('Register failed: ${response.statusCode}');
        return null;
      }

      final decodedBody = jsonDecode(response.body);
      return RegisterResponse.fromJson(decodedBody);
    } catch (e) {
      debugPrint('Register error: $e');
      return null;
    }
  }

  Future<VerifyOtpResponse?> verifyOtp(VerifyOtpRequest request) async {
    try {
      final response = await _apiService.post(
        AppConfig.verifyOtpUrl,
        request.toJson(),
      );

      if (response.statusCode != 200) {
        debugPrint('Verify OTP failed: ${response.statusCode}');
        return null;
      }

      final decodedBody = jsonDecode(response.body);
      return VerifyOtpResponse.fromJson(decodedBody);
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      return null;
    }
  }

  Future<ResendOtpResponse?> resendOtp(ResendOtpRequest request) async {
    try {
      final response = await _apiService.post(
        AppConfig.resendOtpUrl,
        request.toJson(),
      );

      if (response.statusCode != 200) {
        debugPrint('Resend OTP failed: ${response.statusCode}');
        return null;
      }

      final decodedBody = jsonDecode(response.body);
      return ResendOtpResponse.fromJson(decodedBody);
    } catch (e) {
      debugPrint('Resend OTP error: $e');
      return null;
    }
  }

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

  Future<bool> refreshToken() async {
    try {
      final authData = await TokenStorage.getFullAuthData();
      if (authData == null || authData['refreshToken']?.isEmpty != false) {
        debugPrint(' No refresh token available');
        return false;
      }

      final refreshToken = authData['refreshToken']!.trim();
      List<Map<String, dynamic>> bodies = [
        {'refreshToken': refreshToken},
        {'refresh_token': refreshToken},
        {'token': refreshToken},
      ];

      for (int i = 0; i < bodies.length; i++) {
        try {
          final response = await http
              .post(
                Uri.parse(AppConfig.refreshTokenUrl),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(bodies[i]),
              )
              .timeout(const Duration(seconds: 10));

          debugPrint(
            'Refresh try ${i + 1} (${bodies[i].keys.first}): ${response.statusCode}',
          );
          debugPrint(' RAW RESPONSE: ${response.body}');

          if (response.statusCode == 200) {
            final rawData = jsonDecode(response.body);

            dynamic responseData = rawData['responseData'];
            if (responseData == null) {
              responseData = rawData;
            }

            String? newToken =
                responseData['token']?.toString().trim() ??
                rawData['token']?.toString().trim() ??
                responseData['accessToken']?.toString().trim() ??
                rawData['access_token']?.toString().trim();

            String? newRefreshToken =
                responseData['refreshToken']?.toString().trim() ??
                rawData['refreshToken']?.toString().trim() ??
                responseData['refresh_token']?.toString().trim();

            debugPrint(
              'Found token: ${newToken?.isNotEmpty ?? false}, refresh: ${newRefreshToken?.isNotEmpty ?? false}',
            );

            if (newToken?.isNotEmpty == true) {
              final saveSuccess = await TokenStorage.saveFullAuthData(
                userId: (responseData['userId'] ?? authData['userId'])
                    .toString(),
                companyId: responseData['companyId'] ?? authData['companyId'],
                companyIds: responseData['companyIds'] != null
                    ? List<int>.from(responseData['companyIds'])
                    : authData['companyIds'] != null
                    ? List<int>.from(jsonDecode(authData['companyIds']))
                    : null,
                companyName:
                    responseData['companyName']?.toString() ??
                    authData['companyName']?.toString(),
                token: newToken!,
                refreshToken: newRefreshToken ?? refreshToken,
                roleCode:
                    responseData['roleCode']?.toString() ??
                    authData['roleCode']?.toString(),
                landingUrl:
                    responseData['landingUrl']?.toString() ??
                    authData['landingUrl'] ??
                    '/dashboard',
                email: authData['email']?.toString() ?? '',
                userName: authData['userName']?.toString() ?? '',
              );

              debugPrint(' Save result: $saveSuccess');
              if (saveSuccess) {
                debugPrint(' Refresh COMPLETELY successful');
                return true;
              } else {
                debugPrint(' Save failed despite API success');
              }
            } else {
              debugPrint(' No valid token found in response ${i + 1}');
            }
          }
        } catch (e) {
          debugPrint('Refresh try ${i + 1} error: $e');
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<Customer>> getCustomers(int companyId) async {
    try {
      final url = AppConfig.getCustomersUrl(companyId);
      final response = await _apiService.get(Uri.parse(url));

      if (response.statusCode != 200) return [];

      final Map<String, dynamic> decodedBody = jsonDecode(response.body);

      if (decodedBody['responseStatus'] != true) return [];

      // Parse list of customers
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

  Future<List<Vendor>> getActiveVendors(int companyId) async {
    try {
      final url = AppConfig.getActiveVendorsUrl(companyId);
      final response = await _apiService.get(Uri.parse(url));

      if (response.statusCode != 200) return [];

      final Map<String, dynamic> decodedBody = jsonDecode(response.body);

      // Check if responseStatus is true
      if (decodedBody['responseStatus'] != true) return [];

      // Parse list of vendors
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

  Future<List<Item>> getItems(int companyId) async {
    try {
      final url = AppConfig.getItemsUrl(companyId);
      final response = await _apiService.get(Uri.parse(url));

      // Log the actual status code
      debugPrint('GET /items response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('Get items failed: ${response.statusCode}');
        return [];
      }

      final Map<String, dynamic> decodedBody =
          jsonDecode(response.body) as Map<String, dynamic>;

      final bool? responseStatus = decodedBody['responseStatus'];
      if (responseStatus != true) {
        debugPrint(
          'Get items responseStatus false: ${decodedBody['responseMessage']}',
        );
        return [];
      }

      final List<dynamic> data = decodedBody['responseData'] ?? [];
      final List<Item> items = data.map((json) => Item.fromJson(json)).toList();

      return items;
    } catch (e, stack) {
      debugPrint('Get items error: $e\n$stack');
      return [];
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

  Future<ItemResponse> fetchItemDetail(int companyId, int itemId) async {
    final url = AppConfig.getItemDetailUrl(companyId, itemId);
    final response = await _apiService.get(Uri.parse(url));

    debugPrint(
      'Item detail response: ${response.statusCode} → ${response.body}',
    );

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      return ItemResponse.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to load item detail: ${response.statusCode} - ${response.body}',
      );
    }
  }

  String getFileUrl(String fsId) => AppConfig.getFileUrl(fsId);

  Future<http.Response> createItem({
    required int companyId,
    required CreateItemRequest request,
    required String token,
    File? imageFile,
  }) async {
    final uri = Uri.parse(AppConfig.getItemsUrl(companyId));

    final multipartRequest = http.MultipartRequest('POST', uri);

    multipartRequest.headers['Authorization'] = 'Bearer $token';

    multipartRequest.fields['item'] = jsonEncode(request.toJson());

    if (imageFile != null) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
    }

    final streamedResponse = await multipartRequest.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> updateItem({
    required int companyId,
    required int itemId,
    required UpdateItemRequest request,
    required String token,
    File? imageFile,
  }) async {
    final uri = Uri.parse(AppConfig.getItemDetailUrl(companyId, itemId));

    final multipartRequest = http.MultipartRequest('PUT', uri);

    multipartRequest.headers['Authorization'] = 'Bearer $token';

    // Send JSON as single "item" part
    multipartRequest.fields['item'] = jsonEncode(request.toJson());

    if (imageFile != null) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );
    }

    final streamedResponse = await multipartRequest.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<ItemStatusResponse?> activateItem(int companyId, int itemId) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getItemActivateUrl(companyId, itemId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Activate item failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return ItemStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Activate item error: $e');
      return null;
    }
  }

  Future<ItemStatusResponse?> deactivateItem(int companyId, int itemId) async {
    try {
      final response = await _apiService.patch(
        AppConfig.getItemDeactivateUrl(companyId, itemId),
        {},
      );

      if (response.statusCode != 200 && response.statusCode != 203) {
        debugPrint('Deactivate item failed: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      return ItemStatusResponse.fromJson(data);
    } catch (e) {
      debugPrint('Deactivate item error: $e');
      return null;
    }
  }

  // getSalesOrder
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
      return data.map((json) => SellableItem.fromJson(json)).toList();
    } catch (e, stack) {
      debugPrint('Get customer sellable items error: $e\n$stack');
      return [];
    }
  }

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
      debugPrint('Create sales order error: $e');
      return {'success': false, 'message': 'Error: $e'};
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
      return data.map((json) => SellableItem.fromJson(json)).toList();
    } catch (e, stack) {
      debugPrint('Get vendor purchasable items error: $e\n$stack');
      return [];
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
      debugPrint('Create purchase order error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<List<SalesOrder>> getSalesOrders(int companyId) async {
    try {
      final url = AppConfig.getSalesOrdersUrl(companyId);
      final response = await _apiService.get(Uri.parse(url));

      debugPrint(
        'GET /companies/$companyId/sales/orders status: ${response.statusCode}',
      );

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

      debugPrint(
        'GET /companies/$companyId/purchase/orders status: ${response.statusCode}',
      );

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

      debugPrint(
        'GET /companies/$companyId/orders/$orderId status: ${response.statusCode}',
      );

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

  Future<Map<String, dynamic>> updatePaymentSent(
    int companyId,
    int paymentId,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = AppConfig.getUpdatePaymentSentUrl(companyId, paymentId);
      final response = await _apiService.put(url, body);

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

  // ─── Marketplace APIs ───

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

  // ─── Invitation APIs ───

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
