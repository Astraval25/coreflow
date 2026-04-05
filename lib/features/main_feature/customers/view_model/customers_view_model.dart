import 'package:coreflow/core/storage/customer_pin_storage.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/customer/customer.dart';
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
  Set<int> _pinnedCustomerIds = <int>{};


  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  String? get error => _error;

  bool get showActiveOnly => _showActiveOnly;

  List<Customer> get customers => _sortCustomersByPinned(
    _showActiveOnly ? _activeCustomers : _inactiveCustomers,
  );

  bool get hasData =>
      _activeCustomers.isNotEmpty || _inactiveCustomers.isNotEmpty;

  int get activeCustomersCount => _activeCustomers.length;
  int get inactiveCustomersCount => _inactiveCustomers.length;

  List<Customer> get activeCustomers => List.unmodifiable(_activeCustomers);
  List<Customer> get inactiveCustomers => List.unmodifiable(_inactiveCustomers);
  Set<int> get pinnedCustomerIds => Set.unmodifiable(_pinnedCustomerIds);

  bool isCustomerPinned(int customerId) => _pinnedCustomerIds.contains(customerId);


  Future<void> loadCustomers(int companyId) async {
    _companyId = companyId;
    _setLoading(true);
    _clearError();

    try {
      _pinnedCustomerIds = await CustomerPinStorage.loadPinnedCustomerIds(
        companyId,
      );
      final allCustomers = await _authRepository.getCustomers(companyId);

      _activeCustomers
        ..clear()
        ..addAll(allCustomers.where((c) => c.isActive));

      _inactiveCustomers
        ..clear()
        ..addAll(allCustomers.where((c) => !c.isActive));

      final validIds = allCustomers.map((c) => c.customerId).toSet();
      final stalePins = _pinnedCustomerIds.difference(validIds);
      if (stalePins.isNotEmpty) {
        _pinnedCustomerIds.removeAll(stalePins);
        await CustomerPinStorage.savePinnedCustomerIds(
          _companyId,
          _pinnedCustomerIds,
        );
      }
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

  Future<void> togglePinCustomer(int customerId) async {
    if (_companyId == 0) return;

    if (_pinnedCustomerIds.contains(customerId)) {
      _pinnedCustomerIds.remove(customerId);
    } else {
      _pinnedCustomerIds.add(customerId);
    }

    await CustomerPinStorage.savePinnedCustomerIds(_companyId, _pinnedCustomerIds);
    notifyListeners();
  }

  List<Customer> _sortCustomersByPinned(List<Customer> source) {
    final sorted = List<Customer>.from(source);
    sorted.sort((a, b) {
      final aPinned = _pinnedCustomerIds.contains(a.customerId);
      final bPinned = _pinnedCustomerIds.contains(b.customerId);
      if (aPinned != bPinned) return aPinned ? -1 : 1;
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });
    return sorted;
  }


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
