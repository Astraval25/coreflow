import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/customer/customer.dart';
import 'package:coreflow/domain/model/main_model/payment/payment_detail.dart';
import 'package:flutter/material.dart';

class UpdateReceivePaymentAllocationEntry {
  final int? paymentOrderAllocationId;
  final int orderId;
  final String orderNumber;
  final double balanceAmount;
  double amountApplied;
  String? remarks;

  UpdateReceivePaymentAllocationEntry({
    this.paymentOrderAllocationId,
    required this.orderId,
    required this.orderNumber,
    required this.balanceAmount,
    required this.amountApplied,
    this.remarks,
  });
}

class UpdateReceivePaymentViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;
  final int paymentId;

  UpdateReceivePaymentViewModel({
    required AuthRepository repository,
    required this.companyId,
    required this.paymentId,
    required PaymentDetail initialPayment,
  }) : _repository = repository {
    _initFromPayment(initialPayment);
  }

  // State
  Customer? _selectedCustomer;
  List<UpdateReceivePaymentAllocationEntry> _allocations = [];
  final Map<int, double> _initialAllocations = {};
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
  Customer? get selectedCustomer => _selectedCustomer;
  List<UpdateReceivePaymentAllocationEntry> get allocations =>
      List.unmodifiable(_allocations);
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

  double get totalAllocated =>
      _allocations.fold(0, (sum, e) => sum + e.amountApplied);

  double get unallocatedAmount => _amount - totalAllocated;

  bool get canSubmit => _selectedCustomer != null && !_isLoading;

  void _initFromPayment(PaymentDetail payment) {
    _selectedCustomer = Customer(
      customerId: payment.customerId,
      displayName: payment.customerName,
      customerCompanyName: '',
    );

    _amount = payment.amount;
    _modeOfPayment = payment.modeOfPayment.isNotEmpty
        ? payment.modeOfPayment
        : 'BANK_TRANSFER';
    _referenceNumber = payment.referenceNumber.isNotEmpty
        ? payment.referenceNumber
        : null;
    _paymentRemarks = payment.notes.isNotEmpty ? payment.notes : null;
    _paymentDate = payment.paymentDate.toLocal();
    _fsId = payment.paymentProofFile;

    _allocations = payment.orderAllocations
        .map(
          (a) => UpdateReceivePaymentAllocationEntry(
            paymentOrderAllocationId: a.paymentOrderAllocationId,
            orderId: a.orderId,
            orderNumber: a.orderNumber,
            balanceAmount: a.amountApplied,
            amountApplied: a.amountApplied,
            remarks: a.allocationRemarks.isNotEmpty
                ? a.allocationRemarks
                : null,
          ),
        )
        .toList();

    _initialAllocations.clear();
    for (final a in payment.orderAllocations) {
      if (a.amountApplied > 0) _initialAllocations[a.orderId] = a.amountApplied;
    }

    _loadUnpaidOrders(payment.customerId);
  }

  Future<void> setCustomer(Customer customer) async {
    _selectedCustomer = customer;
    _allocations = [];
    notifyListeners();
    await _loadUnpaidOrders(customer.customerId);
  }

  Future<void> _loadUnpaidOrders(int customerId) async {
    _isLoadingOrders = true;
    notifyListeners();

    try {
      final orders = await _repository.getCustomerUnpaidOrders(
        companyId,
        customerId,
      );

      final Map<int, double> existingAmounts = {
        for (final a in _allocations) a.orderId: a.amountApplied,
      };
      final Map<int, String?> existingRemarks = {
        for (final a in _allocations) a.orderId: a.remarks,
      };

      final unpaidIds = orders.map((o) => o.orderId).toSet();
      final preserved = _allocations
          .where((a) => !unpaidIds.contains(a.orderId))
          .toList();

      final fromUnpaid = orders
          .map(
            (o) => UpdateReceivePaymentAllocationEntry(
              orderId: o.orderId,
              orderNumber: o.orderNumber,
              balanceAmount: o.balanceAmount,
              amountApplied: existingAmounts[o.orderId] ?? 0,
              remarks: existingRemarks[o.orderId],
            ),
          )
          .toList();

      _allocations = [...fromUnpaid, ...preserved];
    } catch (e) {
      debugPrint('Load customer unpaid orders error: $e');
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

  void updateAllocationAmount(int index, double amount) {
    if (index >= 0 && index < _allocations.length) {
      _allocations[index].amountApplied = amount;
      notifyListeners();
    }
  }

  void updateAllocationRemarks(int index, String? remarks) {
    if (index >= 0 && index < _allocations.length) {
      _allocations[index].remarks = remarks;
    }
  }

  void autoSplitAmount() {
    if (_amount <= 0 || _allocations.isEmpty) return;

    double remaining = _amount;
    for (final entry in _allocations) {
      if (remaining <= 0) {
        entry.amountApplied = 0;
      } else {
        final apply = remaining >= entry.balanceAmount
            ? entry.balanceAmount
            : remaining;
        entry.amountApplied = apply;
        remaining -= apply;
      }
    }
    notifyListeners();
  }

  Future<void> submitUpdate() async {
    if (!canSubmit) return;

    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final activeAllocations = _allocations
          .where((e) => e.amountApplied > 0)
          .map(
            (e) => <String, dynamic>{
              'orderId': e.orderId,
              'amountApplied': e.amountApplied,
              'allocationDate': _paymentDate.toIso8601String(),
              if (e.paymentOrderAllocationId != null &&
                  e.paymentOrderAllocationId! > 0)
                'paymentOrderAllocationId': e.paymentOrderAllocationId,
              if (e.remarks != null && e.remarks!.trim().isNotEmpty)
                'allocationRemarks': e.remarks!.trim(),
            },
          )
          .toList();

      final body = <String, dynamic>{
        'customerId': _selectedCustomer!.customerId,
        'amount': _amount,
        'paymentDate': _paymentDate.toIso8601String(),
        'modeOfPayment': _modeOfPayment,
        if (_referenceNumber != null && _referenceNumber!.trim().isNotEmpty)
          'referenceNumber': _referenceNumber!.trim(),
        if (_paymentRemarks != null && _paymentRemarks!.trim().isNotEmpty)
          'paymentRemarks': _paymentRemarks!.trim(),
        if (_fsId != null && _fsId!.trim().isNotEmpty)
          'paymentProofFsId': _fsId!.trim(),
        'orderAllocations': activeAllocations,
      };

      debugPrint('Update payment received body: $body');

      final result = await _repository.updatePaymentReceived(
        companyId,
        paymentId,
        body,
      );

      if (result['success'] == true) {
        _isSuccess = true;
        final submittedOrderIds = activeAllocations
            .map((e) => e['orderId'] as int)
            .toSet();
        for (final orderId in _initialAllocations.keys) {
          if (!submittedOrderIds.contains(orderId)) {
            await _repository.updateOrderStatus(companyId, orderId, 'invoiced');
          }
        }
      } else {
        _errorMessage = result['message'] ?? 'Failed to update payment';
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
