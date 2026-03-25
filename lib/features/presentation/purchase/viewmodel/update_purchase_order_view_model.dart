import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/items/sellable_item.dart';
import 'package:coreflow/domain/model/purchase/purchase_order_detail.dart';
import 'package:coreflow/domain/model/vendors/vendors.dart';
import 'package:flutter/material.dart';

class UpdateOrderItemEntry {
  final int itemId;
  final String itemName;
  double quantity;
  double updatedPrice;
  String? itemDescription;
  final bool canEditPriceAndDesc;

  UpdateOrderItemEntry({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.updatedPrice,
    this.itemDescription,
    this.canEditPriceAndDesc = true,
  });

  double get lineTotal => quantity * updatedPrice;
}

class UpdatePurchaseOrderViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;
  final int orderId;

  UpdatePurchaseOrderViewModel({
    required AuthRepository repository,
    required this.companyId,
    required this.orderId,
    required PurchaseOrderDetail initialOrder,
  }) : _repository = repository {
    _initFromOrder(initialOrder);
  }

  // State
  Vendor? _selectedVendor;
  final List<UpdateOrderItemEntry> _orderItems = [];
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
  Vendor? get selectedVendor => _selectedVendor;
  List<UpdateOrderItemEntry> get orderItems => List.unmodifiable(_orderItems);
  double get taxAmount => _taxAmount;
  double get discountAmount => _discountAmount;
  double get deliveryCharge => _deliveryCharge;
  bool get hasBill => _hasBill;
  bool get isLoading => _isLoading;
  bool get isLoadingItems => _isLoadingItems;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  List<SellableItem> get availableItems => List.unmodifiable(_availableItems);

  bool get vendorHasCompany =>
      _selectedVendor != null &&
      _selectedVendor!.vendorCompanyName.isNotEmpty;

  double get subtotal =>
      _orderItems.fold(0, (sum, entry) => sum + entry.lineTotal);

  double get totalAmount =>
      subtotal + _taxAmount - _discountAmount + _deliveryCharge;

  bool get canSubmit =>
      _selectedVendor != null && _orderItems.isNotEmpty && !_isLoading;

  void _initFromOrder(PurchaseOrderDetail order) {
    _selectedVendor = Vendor(
      vendorId: order.vendorId,
      displayName: order.vendorDisplayName.isNotEmpty
          ? order.vendorDisplayName
          : order.vendorName,
      vendorCompanyName: order.sellerCompanyName,
    );

    for (final item in order.orderItems) {
      _orderItems.add(UpdateOrderItemEntry(
        itemId: item.itemId,
        itemName: item.itemName,
        quantity: item.quantity,
        updatedPrice: item.unitPrice,
        itemDescription: item.itemDescription,
        canEditPriceAndDesc: order.sellerCompanyName.isEmpty,
      ));
    }

    _taxAmount = order.taxAmount;
    _discountAmount = order.discountAmount;
    _deliveryCharge = order.deliveryCharge;
    _hasBill = order.hasBill;

    _loadPurchasableItems(order.vendorId);
  }

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

  void addItemFromCatalog(SellableItem item) {
    final existing = _orderItems.indexWhere((e) => e.itemId == item.itemId);
    if (existing != -1) return;

    _orderItems.add(UpdateOrderItemEntry(
      itemId: item.itemId,
      itemName: item.itemName,
      quantity: 1,
      updatedPrice: item.price,
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

  Future<void> submitUpdate() async {
    if (!canSubmit) return;

    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final body = {
        'vendorId': _selectedVendor!.vendorId,
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

      final result = await _repository.updatePurchaseOrder(
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
