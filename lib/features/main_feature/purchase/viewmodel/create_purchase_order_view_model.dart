import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/items/sellable_item.dart';
import 'package:coreflow/domain/model/main_model/purchase/create_purchase_order_request.dart';
import 'package:coreflow/domain/model/main_model/vendors/vendors.dart';
import 'package:flutter/material.dart';

class PurchaseOrderItemEntry {
  SellableItem item;
  double quantity;
  double updatedPrice;
  String? itemDescription;
  final bool canEditPriceAndDesc;

  PurchaseOrderItemEntry({
    required this.item,
    this.quantity = 1,
    double? updatedPrice,
    this.itemDescription,
    required this.canEditPriceAndDesc,
  }) : updatedPrice = updatedPrice ?? item.price;

  double get lineTotal => quantity * updatedPrice;
}

class CreatePurchaseOrderViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;

  CreatePurchaseOrderViewModel({
    required AuthRepository repository,
    required this.companyId,
  }) : _repository = repository;

  // State
  Vendor? _selectedVendor;
  final List<PurchaseOrderItemEntry> _orderItems = [];
  DateTime _orderDate = DateTime.now();
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
  Vendor? get selectedVendor => _selectedVendor;
  List<PurchaseOrderItemEntry> get orderItems =>
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
  int? get createdOrderId => _createdOrderId;
  List<SellableItem> get availableItems => List.unmodifiable(_availableItems);

  /// Whether the selected vendor has a company name.
  /// If null (no company), user can edit price & description on items.
  bool get vendorHasCompany =>
      _selectedVendor != null &&
      _selectedVendor!.vendorCompanyName.isNotEmpty;

  double get subtotal =>
      _orderItems.fold(0, (sum, entry) => sum + entry.lineTotal);

  double get totalAmount =>
      subtotal + _taxAmount - _discountAmount + _deliveryCharge;

  bool get canSubmit =>
      _selectedVendor != null && _orderItems.isNotEmpty && !_isLoading;

  // Actions
  Future<void> setVendor(Vendor vendor) async {
    _selectedVendor = vendor;
    _orderItems.clear();
    _availableItems = [];
    notifyListeners();

    await _loadPurchasableItems(vendor.vendorId);
  }

  void clearVendor() {
    _selectedVendor = null;
    _orderItems.clear();
    _availableItems = [];
    notifyListeners();
  }

  Future<void> _loadPurchasableItems(int vendorId) async {
    _isLoadingItems = true;
    notifyListeners();

    try {
      _availableItems = await _repository.getVendorPurchasableItems(
        companyId,
        vendorId,
      );
    } catch (e) {
      debugPrint('Load purchasable items error: $e');
    }

    _isLoadingItems = false;
    notifyListeners();
  }

  Future<void> reloadPurchasableItems() async {
    final vendor = _selectedVendor;
    if (vendor == null) return;
    await _loadPurchasableItems(vendor.vendorId);
  }

  void addOrderItem(SellableItem item) {
    final existing =
        _orderItems.indexWhere((e) => e.item.itemId == item.itemId);
    if (existing != -1) return;

    _orderItems.add(PurchaseOrderItemEntry(
      item: item,
      itemDescription: item.description.isNotEmpty ? item.description : null,
      canEditPriceAndDesc: !vendorHasCompany,
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

  Future<void> submitOrder() async {
    if (!canSubmit) return;

    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final request = CreatePurchaseOrderRequest(
        vendorId: _selectedVendor!.vendorId,
        orderDate: _orderDate,
        taxAmount: _taxAmount > 0 ? _taxAmount : null,
        discountAmount: _discountAmount > 0 ? _discountAmount : null,
        deliveryCharge: _deliveryCharge > 0 ? _deliveryCharge : null,
        hasBill: _hasBill,
        orderItems: _orderItems
            .map((e) => PurchaseOrderItemRequest(
                  itemId: e.item.itemId,
                  itemDescription: e.itemDescription,
                  quantity: e.quantity,
                  updatedPrice: e.updatedPrice,
                ))
            .toList(),
      );

      final result =
          await _repository.createPurchaseOrder(companyId, request);

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
    _selectedVendor = null;
    _orderItems.clear();
    _availableItems = [];
    _orderDate = DateTime.now();
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
