import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/payment/payment_detail.dart';
import 'package:coreflow/domain/model/payment/payment_received_summary.dart';
import 'package:flutter/material.dart';

class ReceivePaymentViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;

  ReceivePaymentViewModel({
    required AuthRepository repository,
    required this.companyId,
  }) : _repository = repository;

  List<PaymentReceivedSummary> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  List<PaymentReceivedSummary> get payments => List.unmodifiable(_payments);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPaymentsReceivedSummary() async {
    _setLoading(true);
    _setError(null);

    try {
      _payments = await _repository.getPaymentsReceivedSummary(companyId);
    } catch (e, stack) {
      debugPrint('fetchPaymentsReceivedSummary failed: $e\n$stack');
      _setError('Failed to load received payment summary. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await fetchPaymentsReceivedSummary();
  }

  Future<PaymentDetail?> fetchPaymentDetail(int paymentId) async {
    try {
      return await _repository.getReceivePaymentDetail(companyId, paymentId);
    } catch (e, stack) {
      debugPrint('fetch received payment detail failed: $e\n$stack');
      return null;
    }
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
