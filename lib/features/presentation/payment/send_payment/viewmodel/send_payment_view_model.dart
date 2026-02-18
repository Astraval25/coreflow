import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/payment/payment_sent_summary.dart';
import 'package:flutter/material.dart';

class SendPaymentViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;

  SendPaymentViewModel({
    required AuthRepository repository,
    required this.companyId,
  }) : _repository = repository;

  List<PaymentSentSummary> _payments = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  List<PaymentSentSummary> get payments => List.unmodifiable(_payments);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPaymentsSentSummary() async {
    _setLoading(true);
    _setError(null);

    try {
      _payments = await _repository.getPaymentsSentSummary(companyId);
    } catch (e, stack) {
      debugPrint('fetchPaymentsSentSummary failed: $e\n$stack');
      _setError('Failed to load payment summary. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await fetchPaymentsSentSummary();
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
