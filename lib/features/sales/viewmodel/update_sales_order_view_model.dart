import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/customer/customer.dart';
import 'package:coreflow/domain/model/items/sellable_item.dart';
import 'package:coreflow/domain/model/sales/sales_order_detail.dart';
import 'package:flutter/material.dart';

class UpdateSalesOrderItemEntry {
  final int itemId;
  final String itemName;
  double quantity;
  double updatedPrice;
  String? itemDescription;

  UpdateSalesOrderItemEntry({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.updatedPrice,
    this.itemDescription,
  });

  double get lineTotal => quantity * updatedPrice;
}

class UpdateSalesOrderViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;
  final int orderId;

  UpdateSalesOrderViewModel({
    required AuthRepository repository,
    required this.companyId,
    required this.orderId,
    required SalesOrderDetail initialOrder,
  }) : _repository = repository {
    _initFromOrder(initialOrder);
  }

  // State
  Customer? _selectedCustomer;
  final List<UpdateSalesOrderItemEntry> _orderItems = [];
  DateTime _orderDate = DateTime.now();
  double _taxAmount = 0;
  double _discountAmount = 0;
  double _deliveryCharge = 0;
  bool _hasBill = false;

  bool _isLoading = false;
  bool _isLoadingItems = false;
  bool _isSuccess = false;
  String? _errorMessage;

  List<SellableItem> _availableItems = [];

  // Getters
  Customer? get selectedCustomer => _selectedCustomer;
  List<UpdateSalesOrderItemEntry> get orderItems =>
      List.unmodifiable(_orderItems);
  DateTime get orderDate => _orderDate;
  double get taxAmount => _taxAmount;
  double get discountAmount => _discountAmount;
  double get deliveryCharge => _deliveryCharge;
  bool get hasBill => _hasBill;
  bool get isLoading => _isLoading;
  bool get isLoadingItems => _isLoadingItems;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  List<SellableItem> get availableItems => List.unmodifiable(_availableItems);

  double get subtotal =>
      _orderItems.fold(0, (sum, entry) => sum + entry.lineTotal);

  double get totalAmount =>
      subtotal + _taxAmount - _discountAmount + _deliveryCharge;

  bool get canSubmit =>
      _selectedCustomer != null && _orderItems.isNotEmpty && !_isLoading;

  void _initFromOrder(SalesOrderDetail order) {
    _selectedCustomer = Customer(
      customerId: order.customerId,
      displayName: order.customerDisplayName.isNotEmpty
          ? order.customerDisplayName
          : order.customerName,
      customerCompanyName: order.buyerCompanyName,
    );

    for (final item in order.orderItems) {
      _orderItems.add(UpdateSalesOrderItemEntry(
        itemId: item.itemId,
        itemName: item.itemName,
        quantity: item.quantity,
        updatedPrice: item.unitPrice,
        itemDescription: item.itemDescription,
      ));
    }

    _orderDate = order.orderDate;
    _taxAmount = order.taxAmount;
    _discountAmount = order.discountAmount;
    _deliveryCharge = order.deliveryCharge;
    _hasBill = order.hasBill;

    _loadSellableItems(order.customerId);
  }

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

  void addItemFromCatalog(SellableItem item) {
    final existing = _orderItems.indexWhere((e) => e.itemId == item.itemId);
    if (existing != -1) return;

    _orderItems.add(UpdateSalesOrderItemEntry(
      itemId: item.itemId,
      itemName: item.itemName,
      quantity: 1,
      updatedPrice: item.price,
      itemDescription: item.description.isNotEmpty ? item.description : null,
    ));
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
    notifyListeners();
  }

  Future<void> submitUpdate() async {
    if (!canSubmit) return;

    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final body = {
        'customerId': _selectedCustomer!.customerId,
        'orderDate': _orderDate.toIso8601String(),
        'taxAmount': _taxAmount,
        'discountAmount': _discountAmount,
        'deliveryCharge': _deliveryCharge,
        'hasBill': _hasBill,
        'orderItems': _orderItems
            .map((e) => {
                  'itemId': e.itemId,
                  if (e.itemDescription != null &&
                      e.itemDescription!.trim().isNotEmpty)
                    'itemDescription': e.itemDescription!.trim(),
                  'quantity': e.quantity,
                  'updatedPrice': e.updatedPrice,
                })
            .toList(),
      };

      final result = await _repository.updateSalesOrder(
        companyId,
        orderId,
        body,
      );

      if (result['success'] == true) {
        _isSuccess = true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to update order';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
