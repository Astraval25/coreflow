import 'package:coreflow/domain/model/vendors/vendors_detail.dart';
import 'package:coreflow/domain/model/customer/customer_mapped_item.dart';
import 'package:coreflow/domain/model/vendors/vendor_orders_payments.dart';
import 'package:coreflow/domain/model/invitation/invitation_response.dart';
import 'package:coreflow/domain/model/items/item.dart';
import 'package:coreflow/domain/model/items/item_status_response.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum VendorViewState { initial, loading, loaded, error, noData }

class VendorDetailViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  VendorViewState _state = VendorViewState.initial;
  VendorsDetailData? _vendor;
  List<CustomerMappedItem> _mappedItems = [];
  String? _errorMessage;
  bool _isMappedItemsLoading = false;
  bool _isMappedItemStatusUpdating = false;
  int? _statusUpdatingItemId;
  List<VendorOrderPaymentEntry> _ordersPayments = [];
  bool _isOrdersPaymentsLoading = false;

  final int _companyId;
  final int _vendorId;

  VendorDetailViewModel({required int companyId, required int vendorId})
    : _companyId = companyId,
      _vendorId = vendorId {
    loadVendorDetail();
  }

  // ───── Getters ─────
  VendorViewState get state => _state;
  VendorsDetailData? get vendor => _vendor;
  List<CustomerMappedItem> get mappedItems => List.unmodifiable(_mappedItems);
  String? get errorMessage => _errorMessage;
  bool get isMappedItemsLoading => _isMappedItemsLoading;
  bool get isMappedItemStatusUpdating => _isMappedItemStatusUpdating;
  int? get statusUpdatingItemId => _statusUpdatingItemId;
  List<VendorOrderPaymentEntry> get ordersPayments =>
      List.unmodifiable(_ordersPayments);
  bool get isOrdersPaymentsLoading => _isOrdersPaymentsLoading;

  bool get isLoading => _state == VendorViewState.loading;
  bool get hasData => _state == VendorViewState.loaded;
  bool get isError => _state == VendorViewState.error;
  bool get isNoData => _state == VendorViewState.noData;

  int get companyId => _companyId;
  int get vendorId => _vendorId;

  bool get isActive => _vendor?.isActive ?? false;

  Future<void> loadVendorDetail() async {
    _updateState(VendorViewState.loading);

    try {
      final vendorData = await _authRepository.getVendorDetail(
        _companyId,
        _vendorId,
      );

      if (vendorData != null) {
        _vendor = vendorData;
        _updateState(VendorViewState.loaded);
        loadMappedItems();
        loadOrdersPayments();
      } else {
        _updateState(VendorViewState.noData, error: 'No Vendor data found');
      }
    } catch (e) {
      _updateState(VendorViewState.error, error: 'Failed to load Vendor: $e');
    }
  }

  Future<void> activateVendor(BuildContext context) async {
    _updateState(VendorViewState.loading);

    try {
      final response = await _authRepository.activateVendor(
        _companyId,
        _vendorId,
      );

      if (response != null && response.responseStatus == true) {
        await loadVendorDetail();
        if (context.mounted) {
          context.pop(true);
        }
      } else {
        _updateState(
          VendorViewState.error,
          error: response?.responseMessage ?? 'Activate failed',
        );
      }
    } catch (e) {
      _updateState(VendorViewState.error, error: 'Activate error: $e');
    }
  }

  Future<void> deactivateVendor(BuildContext context) async {
    _updateState(VendorViewState.loading);

    try {
      final response = await _authRepository.deactivateVendor(
        _companyId,
        _vendorId,
      );

      if (response != null && response.responseStatus == true) {
        await loadVendorDetail();
        if (context.mounted) {
          context.pop(true);
        }
      } else {
        _updateState(
          VendorViewState.error,
          error: response?.responseMessage ?? 'Deactivate failed',
        );
      }
    } catch (e) {
      _updateState(VendorViewState.error, error: 'Deactivate error: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadMappedItems() async {
    _isMappedItemsLoading = true;
    notifyListeners();

    try {
      final items = await _authRepository.getVendorMappedItems(
        _companyId,
        _vendorId,
      );
      _mappedItems = items;
    } catch (e) {
      debugPrint('Failed to load vendor mapped items: $e');
      _mappedItems = [];
    } finally {
      _isMappedItemsLoading = false;
      notifyListeners();
    }
  }

  Future<List<Item>> getActiveCompanyItems() async {
    try {
      final allItems = await _authRepository.getItems(_companyId);
      return allItems.where((item) => item.isActive).toList();
    } catch (e) {
      debugPrint('Failed to load active company items: $e');
      return [];
    }
  }

  Future<bool> createVendorItem({
    required int itemId,
    required double purchasePrice,
    String? purchaseDescription,
  }) async {
    try {
      final response = await _authRepository.createVendorItem(
        companyId: _companyId,
        vendorId: _vendorId,
        itemId: itemId,
        purchasePrice: purchasePrice,
        purchaseDescription: purchaseDescription,
      );

      if (response?.responseStatus == true) {
        await loadMappedItems();
        return true;
      }

      _errorMessage = response?.responseMessage ?? 'Create vendor item failed';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Create vendor item error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVendorItem({
    required int itemId,
    required double purchasePrice,
    String? purchaseDescription,
  }) async {
    try {
      final response = await _authRepository.updateVendorItem(
        companyId: _companyId,
        vendorId: _vendorId,
        itemId: itemId,
        purchasePrice: purchasePrice,
        purchaseDescription: purchaseDescription,
      );

      if (response?.responseStatus == true) {
        await loadMappedItems();
        return true;
      }

      _errorMessage = response?.responseMessage ?? 'Update vendor item failed';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Update vendor item error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> setMappedItemActiveStatus({
    required int itemId,
    required bool shouldActivate,
  }) async {
    _isMappedItemStatusUpdating = true;
    _statusUpdatingItemId = itemId;
    notifyListeners();

    try {
      final ItemStatusResponse? response = shouldActivate
          ? await _authRepository.activateVendorMappedItem(
              _companyId,
              _vendorId,
              itemId,
            )
          : await _authRepository.deactivateVendorMappedItem(
              _companyId,
              _vendorId,
              itemId,
            );

      if (response?.responseStatus == true) {
        await loadMappedItems();
        return true;
      }

      _errorMessage =
          response?.responseMessage ??
          (shouldActivate ? 'Activate item failed' : 'Deactivate item failed');
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Item status update failed: $e';
      notifyListeners();
      return false;
    } finally {
      _isMappedItemStatusUpdating = false;
      _statusUpdatingItemId = null;
      notifyListeners();
    }
  }

  Future<void> loadOrdersPayments() async {
    _isOrdersPaymentsLoading = true;
    notifyListeners();

    try {
      final data = await _authRepository.getVendorOrdersPayments(
        _companyId,
        _vendorId,
      );
      if (data != null) {
        final entries = <VendorOrderPaymentEntry>[
          ...data.orders.map((o) => VendorOrderPaymentEntry.fromOrder(o)),
          ...data.payments.map((p) => VendorOrderPaymentEntry.fromPayment(p)),
        ]..sort();
        _ordersPayments = entries;
      } else {
        _ordersPayments = [];
      }
    } catch (e) {
      debugPrint('Failed to load vendor orders-payments: $e');
      _ordersPayments = [];
    } finally {
      _isOrdersPaymentsLoading = false;
      notifyListeners();
    }
  }

  // ─── Invitation ───

  bool _isInvitationLoading = false;
  InvitationData? _invitationData;

  bool get isInvitationLoading => _isInvitationLoading;
  InvitationData? get invitationData => _invitationData;

  Future<InvitationResponse?> sendInvitation() async {
    _isInvitationLoading = true;
    notifyListeners();

    try {
      final response = await _authRepository.sendVendorInvitation(
        _companyId,
        _vendorId,
      );

      if (response?.responseStatus == true && response?.responseData != null) {
        _invitationData = response!.responseData;
      }
      return response;
    } catch (e) {
      debugPrint('Send vendor invitation error: $e');
      return null;
    } finally {
      _isInvitationLoading = false;
      notifyListeners();
    }
  }

  Future<InvitationResponse?> getInvitationCode() async {
    _isInvitationLoading = true;
    notifyListeners();

    try {
      final response = await _authRepository.getVendorInvitationCode(
        _companyId,
        _vendorId,
      );

      if (response?.responseStatus == true && response?.responseData != null) {
        _invitationData = response!.responseData;
      }
      return response;
    } catch (e) {
      debugPrint('Get vendor invitation code error: $e');
      return null;
    } finally {
      _isInvitationLoading = false;
      notifyListeners();
    }
  }

  Future<AcceptInvitationResponse?> acceptInvitation(String code) async {
    _isInvitationLoading = true;
    notifyListeners();

    try {
      final response = await _authRepository.acceptInvitation(
        companyId: _companyId,
        invitationCode: code,
        selectedVendorId: _vendorId,
      );
      if (response?.responseStatus == true) {
        await loadVendorDetail();
      }
      return response;
    } catch (e) {
      debugPrint('Accept vendor invitation error: $e');
      return null;
    } finally {
      _isInvitationLoading = false;
      notifyListeners();
    }
  }

  void _updateState(VendorViewState state, {String? error}) {
    _state = state;
    _errorMessage = error;
    notifyListeners();
  }
}
