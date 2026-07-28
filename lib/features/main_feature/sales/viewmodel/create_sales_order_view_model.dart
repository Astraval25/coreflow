import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/customer/customer.dart';
import 'package:coreflow/domain/model/main_model/items/sellable_item.dart';
import 'package:coreflow/domain/model/main_model/sales/create_sales_order_request.dart';
import 'package:flutter/material.dart';

class OrderItemEntry {
  SellableItem item;
  double quantity;
  double updatedPrice;
  String? itemDescription;

  OrderItemEntry({
    required this.item,
    this.quantity = 1,
    double? updatedPrice,
    this.itemDescription,
  }) : updatedPrice = updatedPrice ?? item.price;

  double get lineTotal => quantity * updatedPrice;
}

class CreateSalesOrderViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;

  CreateSalesOrderViewModel({
    required AuthRepository repository,
    required this.companyId,
  }) : _repository = repository;

  // State
  Customer? _selectedCustomer;
  final List<OrderItemEntry> _orderItems = [];
  DateTime _orderDate = DateTime.now();
  DateTime _paymentDueDate = DateTime.now().add(const Duration(days: 3));
  double _taxAmount = 0;
  double _discountAmount = 0;
  double _deliveryCharge = 0;
  bool _hasBill = true;

  bool _isLoading = false;
  bool _isLoadingItems = false;
  bool _isSuccess = false;
  String? _errorMessage;
  int? _createdOrderId;

  List<SellableItem> _availableItems = [];

  // Getters
  Customer? get selectedCustomer => _selectedCustomer;
  List<OrderItemEntry> get orderItems => List.unmodifiable(_orderItems);
  DateTime get orderDate => _orderDate;
  DateTime get paymentDueDate => _paymentDueDate;
  double get taxAmount => _taxAmount;
  double get discountAmount => _discountAmount;
  double get deliveryCharge => _deliveryCharge;
  bool get hasBill => _hasBill;
  bool get isLoading => _isLoading;
  bool get isLoadingItems => _isLoadingItems;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  int? get createdOrderId => _createdOrderId;
  List<SellableItem> get availableItems => List.unmodifiable(_availableItems);

  double get subtotal =>
      _orderItems.fold(0, (sum, entry) => sum + entry.lineTotal);

  double get totalAmount =>
      subtotal + _taxAmount - _discountAmount + _deliveryCharge;

  bool get canSubmit =>
      _selectedCustomer != null && _orderItems.isNotEmpty && !_isLoading;

  // Actions
  Future<void> setCustomer(Customer customer) async {
    _selectedCustomer = customer;
    _orderItems.clear();
    _availableItems = [];
    notifyListeners();

    await _loadSellableItems(customer.customerId);
  }

  void clearCustomer() {
    _selectedCustomer = null;
    _orderItems.clear();
    _availableItems = [];
    notifyListeners();
  }

  Future<void> _loadSellableItems(int customerId) async {
    _isLoadingItems = true;
    notifyListeners();

    try {
      _availableItems = await _repository.getCustomerSellableItems(
        companyId,
        customerId,
      );
    } catch (e) {
      debugPrint('Load sellable items error: $e');
    }

    _isLoadingItems = false;
    notifyListeners();
  }

  Future<void> reloadSellableItems() async {
    final customer = _selectedCustomer;
    if (customer == null) return;
    await _loadSellableItems(customer.customerId);
  }

  void addOrderItem(SellableItem item) {
    final existing = _orderItems.indexWhere(
      (e) => e.item.itemId == item.itemId,
    );
    if (existing != -1) return;

    _orderItems.add(
      OrderItemEntry(
        item: item,
        itemDescription: item.description.isNotEmpty ? item.description : null,
      ),
    );
    notifyListeners();
  }

  void removeOrderItem(int index) {
    if (index >= 0 && index < _orderItems.length) {
      _orderItems.removeAt(index);
      notifyListeners();
    }
  }

  void updateItemQuantity(int index, double quantity) {
    if (index >= 0 && index < _orderItems.length && quantity > 0) {
      _orderItems[index].quantity = quantity;
      notifyListeners();
    }
  }

  void updateItemPrice(int index, double price) {
    if (index >= 0 && index < _orderItems.length && price >= 0) {
      _orderItems[index].updatedPrice = price;
      notifyListeners();
    }
  }

  void updateItemDescription(int index, String? description) {
    if (index >= 0 && index < _orderItems.length) {
      _orderItems[index].itemDescription = description;
    }
  }

  void setTaxAmount(double value) {
    _taxAmount = value;
    notifyListeners();
  }

  void setDiscountAmount(double value) {
    _discountAmount = value;
    notifyListeners();
  }

  void setDeliveryCharge(double value) {
    _deliveryCharge = value;
    notifyListeners();
  }

  void setHasBill(bool value) {
    _hasBill = value;
    notifyListeners();
  }

  void setOrderDate(DateTime value) {
    _orderDate = value;
    _paymentDueDate = value.add(const Duration(days: 3));
    notifyListeners();
  }

  void setPaymentDueDate(DateTime value) {
    _paymentDueDate = value;
    notifyListeners();
  }

  Future<void> submitOrder() async {
    if (!canSubmit) return;

    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final request = CreateSalesOrderRequest(
        customerId: _selectedCustomer!.customerId,
        orderDate: _orderDate,
        paymentDueDate: _paymentDueDate,
        taxAmount: _taxAmount > 0 ? _taxAmount : null,
        discountAmount: _discountAmount > 0 ? _discountAmount : null,
        deliveryCharge: _deliveryCharge > 0 ? _deliveryCharge : null,
        hasBill: _hasBill,
        orderItems: _orderItems
            .map(
              (e) => OrderItemRequest(
                itemId: e.item.itemId,
                itemDescription: e.itemDescription,
                quantity: e.quantity,
                updatedPrice: e.updatedPrice,
              ),
            )
            .toList(),
      );

      final result = await _repository.createSalesOrder(companyId, request);

      if (result['success'] == true) {
        _isSuccess = true;
        final data = result['data'];
        if (data is Map<String, dynamic>) {
          _createdOrderId = data['orderId'];
        }
      } else {
        _errorMessage = result['message'] ?? 'Failed to create order';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void resetState() {
    _selectedCustomer = null;
    _orderItems.clear();
    _availableItems = [];
    _orderDate = DateTime.now();
    _paymentDueDate = _orderDate.add(const Duration(days: 3));
    _taxAmount = 0;
    _discountAmount = 0;
    _deliveryCharge = 0;
    _hasBill = true;
    _isSuccess = false;
    _errorMessage = null;
    _createdOrderId = null;
    notifyListeners();
  }
}
