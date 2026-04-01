import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/purchase/purchase_order.dart';
import 'package:flutter/material.dart';

class PurchaseOrderViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;

  PurchaseOrderViewModel({
    required AuthRepository repository,
    required this.companyId,
  }) : _repository = repository;

  List<PurchaseOrder> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  List<PurchaseOrder> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPurchaseOrders() async {
    _setLoading(true);
    _setError(null);

    try {
      _orders = await _repository.getPurchaseOrders(companyId);
    } catch (e, stack) {
      debugPrint('fetchPurchaseOrders failed: $e\n$stack');
      _setError('Failed to load purchase orders. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await fetchPurchaseOrders();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _notifyListenersSafely();
  }

  void _setError(String? message) {
    _errorMessage = message;
    _notifyListenersSafely();
  }

  void _notifyListenersSafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
