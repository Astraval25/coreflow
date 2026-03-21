import 'package:flutter/foundation.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/customer/customer_detail.dart';
import 'package:coreflow/domain/model/customer/customer_mapped_item.dart';
import 'package:coreflow/domain/model/invitation/invitation_response.dart';
import 'package:coreflow/domain/model/items/item.dart';
import 'package:coreflow/domain/model/items/item_status_response.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 

enum CustomerViewState { initial, loading, loaded, error, noData }

class CustomerDetailViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  CustomerViewState _state = CustomerViewState.initial;
  CustomerDetailData? _customer;
  List<CustomerMappedItem> _mappedItems = [];
  String? _errorMessage;
  bool _isMappedItemsLoading = false;
  bool _isMappedItemStatusUpdating = false;
  int? _statusUpdatingItemId;

  final int _companyId;
  final int _customerId;

  CustomerDetailViewModel({required int companyId, required int customerId})
    : _companyId = companyId,
      _customerId = customerId {
    loadCustomerDetail();
  }

  CustomerViewState get state => _state;
  CustomerDetailData? get customer => _customer;
  List<CustomerMappedItem> get mappedItems => List.unmodifiable(_mappedItems);
  String? get errorMessage => _errorMessage;
  bool get isMappedItemsLoading => _isMappedItemsLoading;
  bool get isMappedItemStatusUpdating => _isMappedItemStatusUpdating;
  int? get statusUpdatingItemId => _statusUpdatingItemId;

  bool get isLoading => _state == CustomerViewState.loading;
  bool get hasData => _state == CustomerViewState.loaded;
  bool get isError => _state == CustomerViewState.error;
  bool get isNoData => _state == CustomerViewState.noData;

  int get companyId => _companyId;
  int get customerId => _customerId;

  bool get isActive => _customer?.isActive ?? false;

  Future<void> loadCustomerDetail() async {
    _updateState(CustomerViewState.loading);

    try {
      final customerData = await _authRepository.getCustomerDetail(
        _companyId,
        _customerId,
      );

      if (customerData != null) {
        _customer = customerData;
        _updateState(CustomerViewState.loaded);
        await loadMappedItems();
      } else {
        _updateState(CustomerViewState.noData, error: 'No customer data found');
      }
    } catch (e) {
      _updateState(
        CustomerViewState.error,
        error: 'Failed to load customer: $e',
      );
    }
  }

  Future<void> activateCustomer(BuildContext context) async {

    _updateState(CustomerViewState.loading);

    try {
      final response = await _authRepository.activateCustomer(
        _companyId,
        _customerId,
      );

      if (response != null && response.responseStatus == true) {
        await loadCustomerDetail();
        if (context.mounted) {
          context.pop(true); 
        }
      } else {
        _updateState(
          CustomerViewState.error,
          error: response?.responseMessage ?? 'Activate failed',
        );
      }
    } catch (e) {
      _updateState(CustomerViewState.error, error: 'Activate error: $e');
    }
  }

  Future<void> deactivateCustomer(BuildContext context) async {
    _updateState(CustomerViewState.loading);

    try {
      final response = await _authRepository.deactivateCustomer(
        _companyId,
        _customerId,
      );

      if (response != null && response.responseStatus == true) {
        await loadCustomerDetail();
        if (context.mounted) {
          context.pop(true); 
        }
      } else {
        _updateState(
          CustomerViewState.error,
          error: response?.responseMessage ?? 'Deactivate failed',
        );
      }
    } catch (e) {
      _updateState(CustomerViewState.error, error: 'Deactivate error: $e');
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
      final items = await _authRepository.getCustomerMappedItems(
        _companyId,
        _customerId,
      );
      _mappedItems = items;
    } catch (e) {
      debugPrint('Failed to load mapped items: $e');
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

  Future<bool> createCustomerItem({
    required int itemId,
    required double salesPrice,
    String? salesDescription,
  }) async {
    try {
      final response = await _authRepository.createCustomerItem(
        companyId: _companyId,
        customerId: _customerId,
        itemId: itemId,
        salesPrice: salesPrice,
        salesDescription: salesDescription,
      );

      if (response?.responseStatus == true) {
        await loadMappedItems();
        return true;
      }

      _errorMessage = response?.responseMessage ?? 'Create customer item failed';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Create customer item error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomerItem({
    required int itemId,
    required double salesPrice,
    String? salesDescription,
  }) async {
    try {
      final response = await _authRepository.updateCustomerItem(
        companyId: _companyId,
        customerId: _customerId,
        itemId: itemId,
        salesPrice: salesPrice,
        salesDescription: salesDescription,
      );

      if (response?.responseStatus == true) {
        await loadMappedItems();
        return true;
      }

      _errorMessage = response?.responseMessage ?? 'Update customer item failed';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Update customer item error: $e';
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
          ? await _authRepository.activateCustomerMappedItem(
              _companyId,
              _customerId,
              itemId,
            )
          : await _authRepository.deactivateCustomerMappedItem(
              _companyId,
              _customerId,
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

  // ─── Invitation ───

  bool _isInvitationLoading = false;
  InvitationData? _invitationData;

  bool get isInvitationLoading => _isInvitationLoading;
  InvitationData? get invitationData => _invitationData;

  Future<InvitationResponse?> sendInvitation() async {
    _isInvitationLoading = true;
    notifyListeners();

    try {
      final response = await _authRepository.sendCustomerInvitation(
        _companyId,
        _customerId,
      );

      if (response?.responseStatus == true && response?.responseData != null) {
        _invitationData = response!.responseData;
      }
      return response;
    } catch (e) {
      debugPrint('Send invitation error: $e');
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
      final response = await _authRepository.getCustomerInvitationCode(
        _companyId,
        _customerId,
      );

      if (response?.responseStatus == true && response?.responseData != null) {
        _invitationData = response!.responseData;
      }
      return response;
    } catch (e) {
      debugPrint('Get invitation code error: $e');
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
        selectedCustomerId: _customerId,
      );
      if (response?.responseStatus == true) {
        await loadCustomerDetail();
      }
      return response;
    } catch (e) {
      debugPrint('Accept invitation error: $e');
      return null;
    } finally {
      _isInvitationLoading = false;
      notifyListeners();
    }
  }

  void _updateState(CustomerViewState state, {String? error}) {
    _state = state;
    _errorMessage = error;
    notifyListeners();
  }
}
