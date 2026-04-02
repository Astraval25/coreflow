import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:coreflow/data/repositories/company_ref_repository.dart';
import 'package:coreflow/data/repositories/company_repository.dart';
import 'package:coreflow/data/repositories/config_repository.dart';
import 'package:coreflow/data/repositories/customer_repository.dart';
import 'package:coreflow/data/repositories/invitation_repository.dart';
import 'package:coreflow/data/repositories/item_repository.dart';
import 'package:coreflow/data/repositories/order_repository.dart';
import 'package:coreflow/data/repositories/payment_repository.dart';
import 'package:coreflow/data/repositories/vendor_repository.dart';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/company/company.dart';
import 'package:coreflow/domain/model/company/marketplace_company.dart';
import 'package:coreflow/domain/model/company_ref/order_ref.dart';
import 'package:coreflow/domain/model/company_ref/payment_ref.dart';
import 'package:coreflow/domain/model/config/company_config.dart';
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
import 'package:coreflow/domain/model/payment/payment_received_summary.dart';
import 'package:coreflow/domain/model/payment/payment_sent_summary.dart';
import 'package:coreflow/domain/model/payment/unpaid_order.dart';
import 'package:coreflow/domain/model/purchase/purchase_order_detail.dart';
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
import 'package:coreflow/domain/model/vendors/create_vendors_request.dart';
import 'package:coreflow/domain/model/vendors/vendors.dart';
import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:coreflow/domain/model/vendors/vendors_edit_request.dart';
import 'package:coreflow/domain/model/notification/app_notification.dart';
import 'package:coreflow/domain/model/advertisement/advertisement.dart';
import 'package:coreflow/domain/model/analytics/dashboard_kpi.dart';
import 'package:coreflow/domain/model/analytics/cash_flow.dart';
import 'package:coreflow/domain/model/analytics/revenue_expense.dart';
import 'package:coreflow/domain/model/analytics/sales_summary.dart';
import 'package:coreflow/domain/model/analytics/order_frequency.dart';
import 'package:coreflow/domain/model/analytics/item_frequency.dart';
import 'package:coreflow/domain/model/analytics/running_amount.dart';
import 'package:coreflow/domain/model/analytics/party_analytics.dart';
import 'package:coreflow/domain/model/analytics/item_analytics.dart';
import 'package:coreflow/domain/model/analytics/payment_mode.dart';
import 'package:coreflow/domain/model/analytics/monthly_trend.dart';
import 'package:coreflow/domain/model/vendors/vendors_edit_response.dart';
import 'package:coreflow/domain/model/vendors/vendors_status_response.dart';
import 'package:coreflow/domain/model/verify_otp/verify_otp_request.dart';
import 'package:coreflow/domain/model/verify_otp/verify_otp_response.dart';
import 'package:coreflow/domain/repositories/login_response.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';
import '../../core/storage/token_storage.dart';

/// Facade that keeps backward compatibility with all existing consumers.
///
/// New code should prefer using the domain-specific repositories directly:
///   - [CompanyRepository]   – company CRUD, marketplace
///   - [CustomerRepository]  – customer CRUD, mapped items, sellable items
///   - [VendorRepository]    – vendor CRUD, mapped items, purchasable items
///   - [ItemRepository]      – item CRUD, activate/deactivate
///   - [OrderRepository]     – sales & purchase orders
///   - [PaymentRepository]   – payments sent/received, proof, unpaid orders
///   - [InvitationRepository]– invitations
class AuthRepository {
  final ApiService _apiService = ApiService();

  // Domain-specific repositories
  final CompanyRefRepository _companyRefRepo = CompanyRefRepository();
  final CompanyRepository _companyRepo = CompanyRepository();
  final ConfigRepository _configRepo = ConfigRepository();
  final CustomerRepository _customerRepo = CustomerRepository();
  final VendorRepository _vendorRepo = VendorRepository();
  final ItemRepository _itemRepo = ItemRepository();
  final OrderRepository _orderRepo = OrderRepository();
  final PaymentRepository _paymentRepo = PaymentRepository();
  final InvitationRepository _invitationRepo = InvitationRepository();

  // ─── Auth ───

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
              .timeout(Duration(seconds: 10));

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

  // ─── Company (delegates to CompanyRepository) ───

  Future<List<Company>> getMyCompanies() => _companyRepo.getMyCompanies();
  Future<Company?> createCompany(Map<String, dynamic> data) => _companyRepo.createCompany(data);
  Future<Company?> updateCompany(int companyId, Map<String, dynamic> data) => _companyRepo.updateCompany(companyId, data);
  Future<bool> activateCompany(int companyId) => _companyRepo.activateCompany(companyId);
  Future<bool> deactivateCompany(int companyId) => _companyRepo.deactivateCompany(companyId);
  Future<List<MarketplaceCompany>> getAllCompanies() => _companyRepo.getAllCompanies();

  // ─── Customer (delegates to CustomerRepository) ───

  Future<List<Customer>> getCustomers(int companyId) => _customerRepo.getCustomers(companyId);
  Future<CustomerDetailData?> getCustomerDetail(int companyId, int customerId) => _customerRepo.getCustomerDetail(companyId, customerId);
  Future<CustomerEditResponse?> updateCustomer(int companyId, int customerId, CustomerEditRequest request) => _customerRepo.updateCustomer(companyId, customerId, request);
  Future<CustomerEditResponse?> createCustomer(int companyId, CreateCustomerRequest request) => _customerRepo.createCustomer(companyId, request);
  Future<CustomerStatusResponse?> activateCustomer(int companyId, int customerId) => _customerRepo.activateCustomer(companyId, customerId);
  Future<CustomerStatusResponse?> deactivateCustomer(int companyId, int customerId) => _customerRepo.deactivateCustomer(companyId, customerId);
  Future<List<CustomerMappedItem>> getCustomerMappedItems(int companyId, int customerId) => _customerRepo.getCustomerMappedItems(companyId, customerId);
  Future<ItemStatusResponse?> createCustomerItem({required int companyId, required int customerId, required int itemId, required double salesPrice, String? salesDescription}) => _customerRepo.createCustomerItem(companyId: companyId, customerId: customerId, itemId: itemId, salesPrice: salesPrice, salesDescription: salesDescription);
  Future<ItemStatusResponse?> updateCustomerItem({required int companyId, required int customerId, required int itemId, required double salesPrice, String? salesDescription}) => _customerRepo.updateCustomerItem(companyId: companyId, customerId: customerId, itemId: itemId, salesPrice: salesPrice, salesDescription: salesDescription);
  Future<ItemStatusResponse?> activateCustomerMappedItem(int companyId, int customerId, int itemId) => _customerRepo.activateCustomerMappedItem(companyId, customerId, itemId);
  Future<ItemStatusResponse?> deactivateCustomerMappedItem(int companyId, int customerId, int itemId) => _customerRepo.deactivateCustomerMappedItem(companyId, customerId, itemId);
  Future<List<SellableItem>> getCustomerSellableItems(int companyId, int customerId) => _customerRepo.getCustomerSellableItems(companyId, customerId);

  // ─── Vendor (delegates to VendorRepository) ───

  Future<List<Vendor>> getActiveVendors(int companyId) => _vendorRepo.getActiveVendors(companyId);
  Future<VendorsDetailData?> getVendorDetail(int companyId, int vendorId) => _vendorRepo.getVendorDetail(companyId, vendorId);
  Future<VendorsEditResponse?> updateVendor(int companyId, int vendorId, VendorsEditRequest request) => _vendorRepo.updateVendor(companyId, vendorId, request);
  Future<VendorsEditResponse?> createVendor(int companyId, CreateVendorsRequest request) => _vendorRepo.createVendor(companyId, request);
  Future<VendorsStatusResponse?> activateVendor(int companyId, int vendorId) => _vendorRepo.activateVendor(companyId, vendorId);
  Future<VendorsStatusResponse?> deactivateVendor(int companyId, int vendorId) => _vendorRepo.deactivateVendor(companyId, vendorId);
  Future<List<CustomerMappedItem>> getVendorMappedItems(int companyId, int vendorId) => _vendorRepo.getVendorMappedItems(companyId, vendorId);
  Future<ItemStatusResponse?> createVendorItem({required int companyId, required int vendorId, required int itemId, required double purchasePrice, String? purchaseDescription}) => _vendorRepo.createVendorItem(companyId: companyId, vendorId: vendorId, itemId: itemId, purchasePrice: purchasePrice, purchaseDescription: purchaseDescription);
  Future<ItemStatusResponse?> updateVendorItem({required int companyId, required int vendorId, required int itemId, required double purchasePrice, String? purchaseDescription}) => _vendorRepo.updateVendorItem(companyId: companyId, vendorId: vendorId, itemId: itemId, purchasePrice: purchasePrice, purchaseDescription: purchaseDescription);
  Future<ItemStatusResponse?> activateVendorMappedItem(int companyId, int vendorId, int itemId) => _vendorRepo.activateVendorMappedItem(companyId, vendorId, itemId);
  Future<ItemStatusResponse?> deactivateVendorMappedItem(int companyId, int vendorId, int itemId) => _vendorRepo.deactivateVendorMappedItem(companyId, vendorId, itemId);
  Future<List<SellableItem>> getVendorPurchasableItems(int companyId, int vendorId) => _vendorRepo.getVendorPurchasableItems(companyId, vendorId);

  // ─── Item (delegates to ItemRepository) ───

  Future<List<Item>> getItems(int companyId) => _itemRepo.getItems(companyId);
  Future<ItemResponse> fetchItemDetail(int companyId, int itemId) => _itemRepo.fetchItemDetail(companyId, itemId);
  String getFileUrl(String fsId) => _itemRepo.getFileUrl(fsId);
  Future<http.Response> createItem({required int companyId, required CreateItemRequest request, required String token, File? imageFile}) => _itemRepo.createItem(companyId: companyId, request: request, token: token, imageFile: imageFile);
  Future<http.Response> updateItem({required int companyId, required int itemId, required UpdateItemRequest request, required String token, File? imageFile}) => _itemRepo.updateItem(companyId: companyId, itemId: itemId, request: request, token: token, imageFile: imageFile);
  Future<ItemStatusResponse?> activateItem(int companyId, int itemId) => _itemRepo.activateItem(companyId, itemId);
  Future<ItemStatusResponse?> deactivateItem(int companyId, int itemId) => _itemRepo.deactivateItem(companyId, itemId);

  // ─── Order (delegates to OrderRepository) ───

  Future<Map<String, dynamic>> createSalesOrder(int companyId, CreateSalesOrderRequest request) => _orderRepo.createSalesOrder(companyId, request);
  Future<List<SalesOrder>> getSalesOrders(int companyId) => _orderRepo.getSalesOrders(companyId);
  Future<sales_detail.SalesOrderDetail?> getSalesOrderDetail(int companyId, int orderId) => _orderRepo.getSalesOrderDetail(companyId, orderId);
  Future<List<PurchaseOrder>> getPurchaseOrders(int companyId) => _orderRepo.getPurchaseOrders(companyId);
  Future<PurchaseOrderDetail?> getPurchaseOrderDetail(int companyId, int orderId) => _orderRepo.getPurchaseOrderDetail(companyId, orderId);
  Future<Map<String, dynamic>> createPurchaseOrder(int companyId, CreatePurchaseOrderRequest request) => _orderRepo.createPurchaseOrder(companyId, request);
  Future<Map<String, dynamic>> updatePurchaseOrder(int companyId, int orderId, Map<String, dynamic> body) => _orderRepo.updatePurchaseOrder(companyId, orderId, body);
  Future<Map<String, dynamic>> updateSalesOrder(int companyId, int orderId, Map<String, dynamic> body) => _orderRepo.updateSalesOrder(companyId, orderId, body);
  Future<Map<String, dynamic>> updateOrderStatus(int companyId, int orderId, String action) => _orderRepo.updateOrderStatus(companyId, orderId, action);
  Future<Map<String, dynamic>> cancelOrder(int companyId, int orderId) => _orderRepo.cancelOrder(companyId, orderId);

  // ─── Payment (delegates to PaymentRepository) ───

  Future<PaymentDetail?> getPaymentDetail(int companyId, int paymentId) => _paymentRepo.getPaymentDetail(companyId, paymentId);
  Future<PaymentDetail?> getSendPaymentDetail(int companyId, int paymentId) => _paymentRepo.getSendPaymentDetail(companyId, paymentId);
  Future<PaymentDetail?> getReceivePaymentDetail(int companyId, int paymentId) => _paymentRepo.getReceivePaymentDetail(companyId, paymentId);
  Future<List<PaymentSentSummary>> getPaymentsSentSummary(int companyId) => _paymentRepo.getPaymentsSentSummary(companyId);
  Future<List<PaymentReceivedSummary>> getPaymentsReceivedSummary(int companyId) => _paymentRepo.getPaymentsReceivedSummary(companyId);
  Future<List<UnpaidOrder>> getVendorUnpaidOrders(int companyId, int vendorId) => _paymentRepo.getVendorUnpaidOrders(companyId, vendorId);
  Future<Map<String, dynamic>> createPaymentSent(int companyId, CreatePaymentSentRequest request) => _paymentRepo.createPaymentSent(companyId, request);
  Future<Uint8List?> fetchPaymentProofBytes(int companyId, String fsId) => _paymentRepo.fetchPaymentProofBytes(companyId, fsId);
  Future<PaymentProofData?> uploadPaymentProof(int companyId, File file) => _paymentRepo.uploadPaymentProof(companyId, file);
  Future<List<UnpaidOrder>> getCustomerUnpaidOrders(int companyId, int customerId) => _paymentRepo.getCustomerUnpaidOrders(companyId, customerId);
  Future<Map<String, dynamic>> createPaymentReceived(int companyId, CreatePaymentReceivedRequest request) => _paymentRepo.createPaymentReceived(companyId, request);
  Future<Map<String, dynamic>> updatePaymentSent(int companyId, int paymentId, Map<String, dynamic> body) => _paymentRepo.updatePaymentSent(companyId, paymentId, body);
  Future<Map<String, dynamic>> updatePaymentReceived(int companyId, int paymentId, Map<String, dynamic> body) => _paymentRepo.updatePaymentReceived(companyId, paymentId, body);
  Future<Map<String, dynamic>> updatePaymentStatus(int companyId, int paymentId, String action) => _paymentRepo.updatePaymentStatus(companyId, paymentId, action);

  // ─── Invitation (delegates to InvitationRepository) ───

  Future<InvitationResponse?> sendCustomerInvitation(int companyId, int customerId) => _invitationRepo.sendCustomerInvitation(companyId, customerId);
  Future<InvitationResponse?> getCustomerInvitationCode(int companyId, int customerId) => _invitationRepo.getCustomerInvitationCode(companyId, customerId);
  Future<InvitationResponse?> sendVendorInvitation(int companyId, int vendorId) => _invitationRepo.sendVendorInvitation(companyId, vendorId);
  Future<InvitationResponse?> getVendorInvitationCode(int companyId, int vendorId) => _invitationRepo.getVendorInvitationCode(companyId, vendorId);
  Future<AcceptInvitationResponse?> acceptInvitation({required int companyId, required String invitationCode, int? selectedVendorId, int? selectedCustomerId}) => _invitationRepo.acceptInvitation(companyId: companyId, invitationCode: invitationCode, selectedVendorId: selectedVendorId, selectedCustomerId: selectedCustomerId);

  // ─── Company Ref (delegates to CompanyRefRepository) ───

  Future<OrderRef?> getOrderRef(int companyId, int orderId) => _companyRefRepo.getOrderRef(companyId, orderId);
  Future<bool> updateOrderRef(int companyId, int orderId, Map<String, dynamic> body) => _companyRefRepo.updateOrderRef(companyId, orderId, body);
  Future<PaymentRef?> getPaymentRef(int companyId, int paymentId) => _companyRefRepo.getPaymentRef(companyId, paymentId);
  Future<bool> updatePaymentRef(int companyId, int paymentId, Map<String, dynamic> body) => _companyRefRepo.updatePaymentRef(companyId, paymentId, body);

  // ─── Config (delegates to ConfigRepository) ───

  Future<CompanyConfig?> getCompanyConfig(int companyId) => _configRepo.getCompanyConfig(companyId);
  Future<bool> setConfigOverride(int companyId, String configKey, String configValue) => _configRepo.setConfigOverride(companyId, configKey, configValue);
  Future<bool> resetConfigToDefault(int companyId, String configKey) => _configRepo.resetConfigToDefault(companyId, configKey);

  // ─── Notification APIs ───

  Future<({List<AppNotification> notifications, bool hasNext})> getNotifications(
    int companyId, {
    int page = 0,
  }) async {
    try {
      final url = AppConfig.getNotificationsUrl(companyId, page: page);
      final response = await _apiService.get(Uri.parse(url));

      if (response.statusCode != 200) return (notifications: <AppNotification>[], hasNext: false);

      final data = jsonDecode(response.body);
      if (data['responseStatus'] != true) return (notifications: <AppNotification>[], hasNext: false);

      final responseData = data['responseData'] as Map<String, dynamic>;
      final list = (responseData['notifications'] as List<dynamic>?) ?? [];
      final hasNext = responseData['hasNext'] as bool? ?? false;

      return (
        notifications: list
            .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
            .toList(),
        hasNext: hasNext,
      );
    } catch (e) {
      debugPrint('Get notifications error: $e');
      return (notifications: <AppNotification>[], hasNext: false);
    }
  }

  Future<int> getUnreadNotificationCount(int companyId) async {
    try {
      final url = AppConfig.getUnreadCountUrl(companyId);
      final response = await _apiService.get(Uri.parse(url));

      if (response.statusCode != 200) return 0;

      final data = jsonDecode(response.body);
      if (data['responseStatus'] != true) return 0;

      final responseData = data['responseData'];
      if (responseData is int) return responseData;
      if (responseData is Map<String, dynamic>) {
        return (responseData['unreadCount'] as int?) ??
            (responseData['count'] as int?) ??
            0;
      }
      return 0;
    } catch (e) {
      debugPrint('Get unread count error: $e');
      return 0;
    }
  }

  Future<bool> markNotificationRead(int companyId, int notificationId) async {
    try {
      final url = AppConfig.getMarkReadUrl(companyId, notificationId);
      final response = await _apiService.patch(url, {});
      final data = jsonDecode(response.body);
      return data['responseStatus'] == true;
    } catch (e) {
      debugPrint('Mark notification read error: $e');
      return false;
    }
  }

  Future<bool> markAllNotificationsRead(int companyId) async {
    try {
      final url = AppConfig.getMarkAllReadUrl(companyId);
      final response = await _apiService.patch(url, {});
      final data = jsonDecode(response.body);
      return data['responseStatus'] == true;
    } catch (e) {
      debugPrint('Mark all read error: $e');
      return false;
    }
  }

  // ─── Advertisement APIs ───

  Future<List<Advertisement>> getAdvertisements() async {
    try {
      final response = await _apiService.get(Uri.parse(AppConfig.adsUrl));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      if (data['responseStatus'] != true) return [];

      final responseData = data['responseData'] as Map<String, dynamic>;
      final list = (responseData['advertisements'] as List<dynamic>?) ?? [];
      return list
          .map((json) => Advertisement.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get advertisements error: $e');
      return [];
    }
  }

  // ─── Analytics ───

  Future<DashboardKpi?> getDashboardKpi(
    int companyId,
    String startDate,
    String endDate,
  ) async {
    try {
      final url = AppConfig.getDashboardKpiUrl(companyId, startDate, endDate);
      final response = await _apiService.get(Uri.parse(url));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body);
      if (data['responseStatus'] != true) return null;
      return DashboardKpi.fromJson(
        data['responseData'] as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('Get dashboard KPI error: $e');
      return null;
    }
  }

  Future<List<CashFlowEntry>> getCashFlow(
    int companyId,
    String startDate,
    String endDate,
  ) async {
    try {
      final url = AppConfig.getCashFlowUrl(companyId, startDate, endDate);
      final response = await _apiService.get(Uri.parse(url));
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body);
      if (data['responseStatus'] != true) return [];
      final list = data['responseData'] as List<dynamic>;
      return list
          .map((e) => CashFlowEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get cash flow error: $e');
      return [];
    }
  }

  Future<List<RevenueExpenseEntry>> getRevenueExpense(
    int companyId,
    String startDate,
    String endDate,
  ) async {
    try {
      final url =
          AppConfig.getRevenueExpenseUrl(companyId, startDate, endDate);
      final response = await _apiService.get(Uri.parse(url));
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body);
      if (data['responseStatus'] != true) return [];
      final list = data['responseData'] as List<dynamic>;
      return list
          .map((e) => RevenueExpenseEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Get revenue vs expense error: $e');
      return [];
    }
  }

  Future<SalesSummary?> getSalesSummary(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getSalesSummaryUrl(c, s, e)));
      if (r.statusCode != 200) return null;
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return null;
      return SalesSummary.fromJson(d['responseData'] as Map<String, dynamic>);
    } catch (err) { debugPrint('getSalesSummary: $err'); return null; }
  }

  Future<PurchaseSummary?> getPurchaseSummary(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getPurchaseSummaryUrl(c, s, e)));
      if (r.statusCode != 200) return null;
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return null;
      return PurchaseSummary.fromJson(d['responseData'] as Map<String, dynamic>);
    } catch (err) { debugPrint('getPurchaseSummary: $err'); return null; }
  }

  Future<List<OrderFrequencyEntry>> getSalesOrderFrequency(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getSalesOrderFrequencyUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => OrderFrequencyEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getSalesOrderFrequency: $err'); return []; }
  }

  Future<List<OrderFrequencyEntry>> getPurchaseOrderFrequency(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getPurchaseOrderFrequencyUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => OrderFrequencyEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getPurchaseOrderFrequency: $err'); return []; }
  }

  Future<List<PaymentFrequencyEntry>> getSalesPaymentFrequency(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getSalesPaymentFrequencyUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => PaymentFrequencyEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getSalesPaymentFrequency: $err'); return []; }
  }

  Future<List<PaymentFrequencyEntry>> getPurchasePaymentFrequency(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getPurchasePaymentFrequencyUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => PaymentFrequencyEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getPurchasePaymentFrequency: $err'); return []; }
  }

  Future<List<ItemFrequencyEntry>> getSalesItemFrequency(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getSalesItemFrequencyUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => ItemFrequencyEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getSalesItemFrequency: $err'); return []; }
  }

  Future<List<ItemFrequencyEntry>> getPurchaseItemFrequency(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getPurchaseItemFrequencyUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => ItemFrequencyEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getPurchaseItemFrequency: $err'); return []; }
  }

  Future<List<RunningAmountEntry>> getSalesRunningOrderAmount(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getSalesRunningOrderAmountUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => RunningAmountEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getSalesRunningOrderAmount: $err'); return []; }
  }

  Future<List<RunningAmountEntry>> getPurchaseRunningOrderAmount(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getPurchaseRunningOrderAmountUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => RunningAmountEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getPurchaseRunningOrderAmount: $err'); return []; }
  }

  Future<List<RunningAmountEntry>> getSalesRunningPaymentAmount(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getSalesRunningPaymentAmountUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => RunningAmountEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getSalesRunningPaymentAmount: $err'); return []; }
  }

  Future<List<RunningAmountEntry>> getPurchaseRunningPaymentAmount(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getPurchaseRunningPaymentAmountUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => RunningAmountEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getPurchaseRunningPaymentAmount: $err'); return []; }
  }

  Future<List<PartyAnalyticsEntry>> getSalesByCustomer(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getSalesByCustomerUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => PartyAnalyticsEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getSalesByCustomer: $err'); return []; }
  }

  Future<List<PartyAnalyticsEntry>> getPurchaseByVendor(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getPurchaseByVendorUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => PartyAnalyticsEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getPurchaseByVendor: $err'); return []; }
  }

  Future<List<ItemAnalyticsEntry>> getSalesByItem(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getSalesByItemUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => ItemAnalyticsEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getSalesByItem: $err'); return []; }
  }

  Future<List<ItemAnalyticsEntry>> getPurchaseByItem(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getPurchaseByItemUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => ItemAnalyticsEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getPurchaseByItem: $err'); return []; }
  }

  Future<List<ProfitByItemEntry>> getProfitByItem(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getProfitByItemUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => ProfitByItemEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getProfitByItem: $err'); return []; }
  }

  Future<List<ItemAnalyticsEntry>> getTopSellingItems(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getTopSellingItemsUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => ItemAnalyticsEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getTopSellingItems: $err'); return []; }
  }

  Future<List<ItemAnalyticsEntry>> getTopProfitableItems(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getTopProfitableItemsUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => ItemAnalyticsEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getTopProfitableItems: $err'); return []; }
  }

  Future<List<PaymentModeEntry>> getPaymentModeDistribution(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getPaymentModeDistributionUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => PaymentModeEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getPaymentModeDistribution: $err'); return []; }
  }

  Future<List<MonthlyTrendEntry>> getMonthlyTrend(int c, String s, String e) async {
    try {
      final r = await _apiService.get(Uri.parse(AppConfig.getMonthlyTrendUrl(c, s, e)));
      if (r.statusCode != 200) return [];
      final d = jsonDecode(r.body);
      if (d['responseStatus'] != true) return [];
      return (d['responseData'] as List).map((x) => MonthlyTrendEntry.fromJson(x)).toList();
    } catch (err) { debugPrint('getMonthlyTrend: $err'); return []; }
  }
}
