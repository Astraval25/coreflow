import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/sales/sales_order.dart';
import 'package:flutter/material.dart';

class SalesOrderViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;

  SalesOrderViewModel({
    required AuthRepository repository,
    required this.companyId,
  }) : _repository = repository;

  List<SalesOrder> _orders = [];
  List<SalesOrder> _filteredOrders = [];

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  bool _showActiveOnly = true;
  bool _isDisposed = false;

  List<SalesOrder> get orders => List.unmodifiable(_orders);
  List<SalesOrder> get filteredOrders => List.unmodifiable(_filteredOrders);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get showActiveOnly => _showActiveOnly;

  int get activeOrderCount => _orders.where((o) => o.isActive).length;
  int get inactiveOrderCount => _orders.where((o) => !o.isActive).length;

  Future<void> fetchSalesOrders() async {
    _setLoading(true);
    _setError(null);

    try {
      final fetchedOrders = await _repository.getSalesOrders(companyId);
      _orders = fetchedOrders;
      _applyFilters();
    } catch (e, stack) {
      debugPrint('fetchSalesOrders failed: $e\n$stack');
      _setError('Failed to load sales orders. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await fetchSalesOrders();
  }

  void toggleActiveFilter() {
    _showActiveOnly = !_showActiveOnly;
    _applyFilters();
    _notifyListenersSafely();
  }

  void filterOrders(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
    _notifyListenersSafely();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    _notifyListenersSafely();
  }

  void _applyFilters() {
    Iterable<SalesOrder> list = _orders;

    if (_searchQuery.isNotEmpty) {
      list = list.where((order) {
        final orderNumberMatch =
            order.orderNumber.toLowerCase().contains(_searchQuery);
        final buyerMatch =
            order.buyerCompanyName.toLowerCase().contains(_searchQuery);
        final vendorMatch = order.vendorName.toLowerCase().contains(_searchQuery);
        final statusMatch =
            order.orderStatus.toLowerCase().contains(_searchQuery);
        final orderIdMatch = order.orderId.toString().contains(_searchQuery);

        return orderNumberMatch ||
            buyerMatch ||
            vendorMatch ||
            statusMatch ||
            orderIdMatch;
      });
    }

    _filteredOrders = list.toList();
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
