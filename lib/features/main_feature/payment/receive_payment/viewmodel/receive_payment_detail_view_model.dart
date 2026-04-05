import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/company_ref/payment_ref.dart';
import 'package:coreflow/domain/model/main_model/payment/payment_detail.dart';
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
  PaymentRef? _paymentRef;
  String? _errorMessage;
  bool _isDisposed = false;
  bool _isStatusUpdating = false;
  String? _statusError;
  bool _isRefUpdating = false;

  ReceivePaymentDetailState get state => _state;
  PaymentDetail? get paymentDetail => _paymentDetail;
  PaymentRef? get paymentRef => _paymentRef;
  String? get errorMessage => _errorMessage;
  bool get isStatusUpdating => _isStatusUpdating;
  String? get statusError => _statusError;
  bool get isRefUpdating => _isRefUpdating;

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
      _loadPaymentRef();
    } catch (e, stack) {
      debugPrint('loadReceivedPaymentDetail failed: $e\n$stack');
      _updateState(
        ReceivePaymentDetailState.error,
        error: 'Failed to load received payment detail.',
      );
    }
  }

  Future<void> _loadPaymentRef() async {
    try {
      _paymentRef = await _repository.getPaymentRef(companyId, paymentId);
      _notifyListenersSafely();
    } catch (e) {
      debugPrint('loadPaymentRef failed: $e');
    }
  }

  Future<bool> updatePaymentRef(Map<String, dynamic> body) async {
    _isRefUpdating = true;
    _notifyListenersSafely();
    try {
      final success = await _repository.updatePaymentRef(companyId, paymentId, body);
      if (success) {
        await _loadPaymentRef();
      }
      return success;
    } catch (e) {
      debugPrint('updatePaymentRef failed: $e');
      return false;
    } finally {
      _isRefUpdating = false;
      _notifyListenersSafely();
    }
  }

  Future<void> refresh() async {
    await loadPaymentDetail();
  }

  Future<bool> updateStatus(String action) async {
    _isStatusUpdating = true;
    _statusError = null;
    _notifyListenersSafely();
    try {
      final result =
          await _repository.updatePaymentStatus(companyId, paymentId, action);
      if (result['success'] == true) {
        await loadPaymentDetail();
        return true;
      }
      _statusError = result['message'];
      return false;
    } catch (e) {
      _statusError = 'Error: $e';
      return false;
    } finally {
      _isStatusUpdating = false;
      _notifyListenersSafely();
    }
  }

  Future<Uint8List?> fetchProofBytes() async {
    final fsId = _paymentDetail?.paymentProofFile;
    if (fsId == null || fsId.isEmpty) return null;
    return _repository.fetchPaymentProofBytes(companyId, fsId);
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
