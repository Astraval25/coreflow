import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/payment/payment_detail.dart';
import 'package:flutter/foundation.dart';

enum ReceivePaymentDetailState { initial, loading, loaded, noData, error }

class ReceivePaymentDetailViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;
  final int paymentId;

  ReceivePaymentDetailViewModel({
    required AuthRepository repository,
    required this.companyId,
    required this.paymentId,
  }) : _repository = repository {
    loadPaymentDetail();
  }

  ReceivePaymentDetailState _state = ReceivePaymentDetailState.initial;
  PaymentDetail? _paymentDetail;
  String? _errorMessage;
  bool _isDisposed = false;

  ReceivePaymentDetailState get state => _state;
  PaymentDetail? get paymentDetail => _paymentDetail;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == ReceivePaymentDetailState.loading;
  bool get hasData => _state == ReceivePaymentDetailState.loaded;
  bool get isNoData => _state == ReceivePaymentDetailState.noData;
  bool get hasError => _state == ReceivePaymentDetailState.error;

  Future<void> loadPaymentDetail() async {
    _updateState(ReceivePaymentDetailState.loading);

    try {
      final data = await _repository.getReceivePaymentDetail(
        companyId,
        paymentId,
      );

      if (data == null || data.paymentId <= 0) {
        _paymentDetail = null;
        _updateState(
          ReceivePaymentDetailState.noData,
          error: 'No received payment detail found.',
        );
        return;
      }

      _paymentDetail = data;
      _updateState(ReceivePaymentDetailState.loaded);
    } catch (e, stack) {
      debugPrint('loadReceivedPaymentDetail failed: $e\n$stack');
      _updateState(
        ReceivePaymentDetailState.error,
        error: 'Failed to load received payment detail.',
      );
    }
  }

  Future<void> refresh() async {
    await loadPaymentDetail();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == ReceivePaymentDetailState.error) {
      _state = ReceivePaymentDetailState.initial;
    }
    _notifyListenersSafely();
  }

  void _updateState(ReceivePaymentDetailState next, {String? error}) {
    _state = next;
    _errorMessage = error;
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
