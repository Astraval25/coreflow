import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/customer/customer.dart';
import 'package:flutter/material.dart';

class ActiveCustomersViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  ActiveCustomersViewModel(this._authRepository);

  int _companyId = 0;

  final List<Customer> _activeCustomers = [];
  final List<Customer> _inactiveCustomers = [];

  bool _isLoading = false;
  String? _error;
  bool _showActiveOnly = true;

  // =======================
  // GETTERS
  // =======================

  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;

  bool get showActiveOnly => _showActiveOnly;

  List<Customer> get customers =>
      _showActiveOnly ? _activeCustomers : _inactiveCustomers;

  bool get hasData =>
      _activeCustomers.isNotEmpty || _inactiveCustomers.isNotEmpty;

  int get activeCustomersCount => _activeCustomers.length;
  int get inactiveCustomersCount => _inactiveCustomers.length;

  List<Customer> get activeCustomers => List.unmodifiable(_activeCustomers);
  List<Customer> get inactiveCustomers => List.unmodifiable(_inactiveCustomers);

  // =======================
  // CORE METHODS
  // =======================

  Future<void> loadCustomers(int companyId) async {
    _companyId = companyId;
    _setLoading(true);
    _clearError();

    try {
      final allCustomers = await _authRepository.getCustomers(companyId);

      _activeCustomers
        ..clear()
        ..addAll(allCustomers.where((c) => c.isActive));

      _inactiveCustomers
        ..clear()
        ..addAll(allCustomers.where((c) => !c.isActive));
    } catch (e) {
      _setError('Failed to load customers');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> toggleCustomerStatus(int customerId) async {
    if (_companyId == 0) return false;

    _setLoading(true);
    _clearError();

    try {
      final isActive = _activeCustomers.any((c) => c.customerId == customerId);

      final response = isActive
          ? await _authRepository.deactivateCustomer(_companyId, customerId)
          : await _authRepository.activateCustomer(_companyId, customerId);

      if (response?.responseStatus == true) {
        await loadCustomers(_companyId);
        return true;
      }

      _setError(response?.responseMessage ?? 'Operation failed');
      return false;
    } catch (e) {
      _setError('Failed to update customer status');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void toggleActiveFilter() {
    _showActiveOnly = !_showActiveOnly;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_companyId > 0) {
      await loadCustomers(_companyId);
    }
  }

  // =======================
  // PRIVATE HELPERS
  // =======================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
