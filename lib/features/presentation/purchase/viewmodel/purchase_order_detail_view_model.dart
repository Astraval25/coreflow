import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/purchase/purchase_order_detail.dart';
import 'package:flutter/foundation.dart';

enum PurchaseOrderDetailState { initial, loading, loaded, noData, error }

class PurchaseOrderDetailViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;
  final int orderId;

  PurchaseOrderDetailViewModel({
    required AuthRepository repository,
    required this.companyId,
    required this.orderId,
  }) : _repository = repository {
    loadOrderDetail();
  }

  PurchaseOrderDetailState _state = PurchaseOrderDetailState.initial;
  PurchaseOrderDetail? _orderDetail;
  String? _errorMessage;
  bool _isDisposed = false;

  PurchaseOrderDetailState get state => _state;
  PurchaseOrderDetail? get orderDetail => _orderDetail;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == PurchaseOrderDetailState.loading;
  bool get hasData => _state == PurchaseOrderDetailState.loaded;
  bool get isNoData => _state == PurchaseOrderDetailState.noData;
  bool get hasError => _state == PurchaseOrderDetailState.error;

  Future<void> loadOrderDetail() async {
    _updateState(PurchaseOrderDetailState.loading);

    try {
      final data = await _repository.getPurchaseOrderDetail(companyId, orderId);

      if (data == null || data.orderId <= 0) {
        _orderDetail = null;
        _updateState(
          PurchaseOrderDetailState.noData,
          error: 'No purchase order detail found.',
        );
        return;
      }

      _orderDetail = data;
      _updateState(PurchaseOrderDetailState.loaded);
    } catch (e, stack) {
      debugPrint('loadPurchaseOrderDetail failed: $e\n$stack');
      _updateState(
        PurchaseOrderDetailState.error,
        error: 'Failed to load purchase order detail.',
      );
    }
  }

  Future<void> refresh() async {
    await loadOrderDetail();
  }

  void clearError() {
    _errorMessage = null;
    if (_state == PurchaseOrderDetailState.error) {
      _state = PurchaseOrderDetailState.initial;
    }
    _notifyListenersSafely();
  }

  void _updateState(PurchaseOrderDetailState next, {String? error}) {
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
