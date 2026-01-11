import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/customer/customer.dart';
import 'package:flutter/material.dart';

class ActiveCustomersViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  int _companyId = 0;

  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _customers.isNotEmpty;
  bool get hasError => _error != null;

  ActiveCustomersViewModel(this._authRepository);

  Future<void> loadActiveCustomers(int companyId) async {
    _companyId = companyId;
    try {
      _setLoading(true);
      _clearError();

      final customers = await _authRepository.getActiveCustomers(companyId);
      _customers = customers;
    } catch (e) {
      _setError('Failed to load customers: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    if (_companyId > 0) {
      await loadActiveCustomers(_companyId);
    }
  }

  void clearError() => _clearError();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
