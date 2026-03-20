import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/payment/create_payment_sent_request.dart';
import 'package:coreflow/domain/model/payment/payment_proof_result.dart';
import 'package:coreflow/domain/model/payment/unpaid_order.dart';
import 'package:coreflow/domain/model/vendors/vendors.dart';
import 'package:flutter/material.dart';

class OrderAllocationEntry {
  final UnpaidOrder order;
  double amountApplied;
  String? remarks;
  bool selected;

  OrderAllocationEntry({
    required this.order,
    this.amountApplied = 0,
    this.remarks,
    this.selected = false,
  });
}

class CreatePaymentSentViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;

  CreatePaymentSentViewModel({
    required AuthRepository repository,
    required this.companyId,
  }) : _repository = repository;

  // State
  Vendor? _selectedVendor;
  List<OrderAllocationEntry> _unpaidOrders = [];
  double _amount = 0;
  String _modeOfPayment = 'BANK_TRANSFER';
  String? _referenceNumber;
  String? _paymentRemarks;
  DateTime _paymentDate = DateTime.now();
  String? _fsId;

  bool _isLoading = false;
  bool _isLoadingOrders = false;
  bool _isSuccess = false;
  String? _errorMessage;

  // Getters
  Vendor? get selectedVendor => _selectedVendor;
  List<OrderAllocationEntry> get unpaidOrders =>
      List.unmodifiable(_unpaidOrders);
  double get amount => _amount;
  String get modeOfPayment => _modeOfPayment;
  String? get referenceNumber => _referenceNumber;
  String? get paymentRemarks => _paymentRemarks;
  DateTime get paymentDate => _paymentDate;
  String? get fsId => _fsId;
  bool get isLoading => _isLoading;
  bool get isLoadingOrders => _isLoadingOrders;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;

  double get totalAllocated => _unpaidOrders
      .where((e) => e.selected)
      .fold(0, (sum, e) => sum + e.amountApplied);

  double get unallocatedAmount => _amount - totalAllocated;

  bool get canSubmit =>
      _selectedVendor != null && _amount > 0 && !_isLoading;

  // Actions
  Future<void> setVendor(Vendor vendor) async {
    _selectedVendor = vendor;
    _unpaidOrders = [];
    notifyListeners();
    await _loadUnpaidOrders(vendor.vendorId);
  }

  Future<void> _loadUnpaidOrders(int vendorId) async {
    _isLoadingOrders = true;
    notifyListeners();

    try {
      final orders =
          await _repository.getVendorUnpaidOrders(companyId, vendorId);
      _unpaidOrders = orders
          .map((o) => OrderAllocationEntry(order: o))
          .toList();
    } catch (e) {
      debugPrint('Load unpaid orders error: $e');
    }

    _isLoadingOrders = false;
    notifyListeners();
  }

  void setAmount(double value) {
    _amount = value;
    notifyListeners();
  }

  void setModeOfPayment(String value) {
    _modeOfPayment = value;
    notifyListeners();
  }

  void setReferenceNumber(String? value) {
    _referenceNumber = value;
  }

  void setPaymentRemarks(String? value) {
    _paymentRemarks = value;
  }

  void setPaymentDate(DateTime date) {
    _paymentDate = date;
    notifyListeners();
  }

  void setProofResult(PaymentProofResult result) {
    _fsId = result.fsId;
    if (result.amount != null) {
      _amount = result.amount!;
    }
    if (result.transactionId != null) {
      _referenceNumber = result.transactionId;
    }
    notifyListeners();
  }

  void clearProof() {
    _fsId = null;
    notifyListeners();
  }

  void toggleOrderSelection(int index, bool selected) {
    if (index >= 0 && index < _unpaidOrders.length) {
      _unpaidOrders[index].selected = selected;
      if (!selected) {
        _unpaidOrders[index].amountApplied = 0;
        _unpaidOrders[index].remarks = null;
      } else {
        _unpaidOrders[index].amountApplied =
            _unpaidOrders[index].order.balanceAmount;
      }
      notifyListeners();
    }
  }

  void updateAllocationAmount(int index, double amount) {
    if (index >= 0 && index < _unpaidOrders.length) {
      _unpaidOrders[index].amountApplied = amount;
      notifyListeners();
    }
  }

  void updateAllocationRemarks(int index, String? remarks) {
    if (index >= 0 && index < _unpaidOrders.length) {
      _unpaidOrders[index].remarks = remarks;
    }
  }

  Future<void> submitPayment() async {
    if (!canSubmit) return;

    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final allocations = _unpaidOrders
          .where((e) => e.selected && e.amountApplied > 0)
          .map((e) => OrderAllocationRequest(
                orderId: e.order.orderId,
                amountApplied: e.amountApplied,
                allocationDate: _paymentDate,
                allocationRemarks: e.remarks,
              ))
          .toList();

      final request = CreatePaymentSentRequest(
        vendorId: _selectedVendor!.vendorId,
        paymentDetails: PaymentDetailsRequest(
          amount: _amount,
          paymentDate: _paymentDate,
          modeOfPayment: _modeOfPayment,
          referenceNumber: _referenceNumber,
          paymentRemarks: _paymentRemarks,
          fsId: _fsId,
          orderAllocations: allocations,
        ),
      );

      final result = await _repository.createPaymentSent(companyId, request);

      if (result['success'] == true) {
        _isSuccess = true;
      } else {
        _errorMessage = result['message'] ?? 'Failed to create payment';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
