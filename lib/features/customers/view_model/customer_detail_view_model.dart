import 'package:flutter/foundation.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/customer/customer_detail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 

enum CustomerViewState { initial, loading, loaded, error, noData }

class CustomerDetailViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  CustomerViewState _state = CustomerViewState.initial;
  CustomerDetailData? _customer;
  String? _errorMessage;

  final int _companyId;
  final int _customerId;

  CustomerDetailViewModel({required int companyId, required int customerId})
    : _companyId = companyId,
      _customerId = customerId {
    loadCustomerDetail();
  }

  // ───── Getters ─────
  CustomerViewState get state => _state;
  CustomerDetailData? get customer => _customer;
  String? get errorMessage => _errorMessage;

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

  // ───── Helpers ─────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _updateState(CustomerViewState state, {String? error}) {
    _state = state;
    _errorMessage = error;
    notifyListeners();
  }
}
