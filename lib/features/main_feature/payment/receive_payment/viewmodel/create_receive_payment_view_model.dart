import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/customer/customer.dart';
import 'package:coreflow/domain/model/main_model/payment/create_payment_received_request.dart';
import 'package:coreflow/domain/model/main_model/payment/create_payment_sent_request.dart';
import 'package:coreflow/domain/model/main_model/payment/payment_proof_result.dart';
import 'package:coreflow/domain/model/main_model/payment/unpaid_order.dart';
import 'package:flutter/material.dart';

class OrderAllocationEntry {
  final UnpaidOrder order;
  double amountApplied;
  String? remarks;

  OrderAllocationEntry({
    required this.order,
    this.amountApplied = 0,
    this.remarks,
  });
}

class CreateReceivePaymentViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;

  CreateReceivePaymentViewModel({
    required AuthRepository repository,
    required this.companyId,
  }) : _repository = repository;

  Customer? _selectedCustomer;
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
  int? _createdPaymentId;

  Customer? get selectedCustomer => _selectedCustomer;
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
  int? get createdPaymentId => _createdPaymentId;

  double get totalAllocated =>
      _unpaidOrders.fold(0, (sum, e) => sum + e.amountApplied);

  double get unallocatedAmount => _amount - totalAllocated;

  bool get canSubmit => _selectedCustomer != null && !_isLoading;

  Future<void> setCustomer(Customer customer) async {
    _selectedCustomer = customer;
    _unpaidOrders = [];
    notifyListeners();
    await _loadUnpaidOrders(customer.customerId);
  }

  Future<void> setCustomerWithOrder(
    Customer customer, {
    int? orderId,
    double? amount,
  }) async {
    _selectedCustomer = customer;
    _unpaidOrders = [];
    notifyListeners();
    await _loadUnpaidOrders(customer.customerId);
    _applyOrderAllocation(orderId: orderId, amount: amount);
  }

  Future<void> _loadUnpaidOrders(int customerId) async {
    _isLoadingOrders = true;
    notifyListeners();

    try {
      final orders =
          await _repository.getCustomerUnpaidOrders(companyId, customerId);
      _unpaidOrders =
          orders.map((o) => OrderAllocationEntry(order: o)).toList();
    } catch (e) {
      debugPrint('Load customer unpaid orders error: $e');
    }

    _isLoadingOrders = false;
    notifyListeners();
  }

  void _applyOrderAllocation({int? orderId, double? amount}) {
    if (orderId == null || _unpaidOrders.isEmpty) return;
    final index =
        _unpaidOrders.indexWhere((entry) => entry.order.orderId == orderId);
    if (index == -1) return;

    for (final entry in _unpaidOrders) {
      entry.amountApplied = 0;
    }

    final balance = _unpaidOrders[index].order.balanceAmount;
    final desired = (amount != null && amount > 0) ? amount : balance;
    final applied = desired > balance ? balance : desired;

    _unpaidOrders[index].amountApplied = applied;
    if (amount != null || _amount == 0) {
      _amount = applied;
    }
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

  void autoSplitAmount() {
    if (_amount <= 0 || _unpaidOrders.isEmpty) return;

    double remaining = _amount;
    for (final entry in _unpaidOrders) {
      if (remaining <= 0) {
        entry.amountApplied = 0;
      } else {
        final apply = remaining >= entry.order.balanceAmount
            ? entry.order.balanceAmount
            : remaining;
        entry.amountApplied = apply;
        remaining -= apply;
      }
    }
    notifyListeners();
  }

  Future<void> submitPayment() async {
    if (!canSubmit) return;

    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final allocations = _unpaidOrders
          .where((e) => e.amountApplied > 0)
          .map((e) => OrderAllocationRequest(
                orderId: e.order.orderId,
                amountApplied: e.amountApplied,
                allocationDate: _paymentDate,
                allocationRemarks: e.remarks,
              ))
          .toList();

      final request = CreatePaymentReceivedRequest(
        customerId: _selectedCustomer!.customerId,
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

      final result =
          await _repository.createPaymentReceived(companyId, request);

      if (result['success'] == true) {
        _isSuccess = true;
        final data = result['data'];
        if (data is Map<String, dynamic>) {
          _createdPaymentId = data['paymentId'];
        }
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
