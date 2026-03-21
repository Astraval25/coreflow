import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/sales/sales_order_detail.dart'
    as sales_detail;
import 'package:coreflow/domain/model/sales/sales_order_item.dart'
    as sales_item;
import 'package:flutter/foundation.dart';

enum SalesOrderDetailState { initial, loading, loaded, noData, error }

class SalesOrderDetailViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  final int companyId;
  final int orderId;

  SalesOrderDetailViewModel({
    required AuthRepository repository,
    required this.companyId,
    required this.orderId,
  }) : _repository = repository {
    loadOrderDetail();
  }

  SalesOrderDetailState _state = SalesOrderDetailState.initial;
  sales_detail.SalesOrderDetail? _orderDetail;
  String? _errorMessage;
  bool _isDisposed = false;
  bool _isStatusUpdating = false;
  String? _statusError;

  SalesOrderDetailState get state => _state;
  bool get isStatusUpdating => _isStatusUpdating;
  String? get statusError => _statusError;
  sales_detail.SalesOrderDetail? get orderDetail => _orderDetail;

  sales_detail.SalesOrderDetail? get order => _orderDetail;

  List<sales_item.SalesOrderItem> get items =>
      List.unmodifiable(_orderDetail?.orderItems ?? const []);

  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == SalesOrderDetailState.loading;
  bool get hasData => _state == SalesOrderDetailState.loaded;
  bool get isNoData => _state == SalesOrderDetailState.noData;
  bool get hasError => _state == SalesOrderDetailState.error;

  Future<void> loadOrderDetail() async {
    _updateState(SalesOrderDetailState.loading);

    try {
      final data = await _repository.getSalesOrderDetail(companyId, orderId);

      if (data == null) {
        _orderDetail = null;
        _updateState(
          SalesOrderDetailState.noData,
          error: 'No sales order detail found.',
        );
        return;
      }

      if (data.orderId <= 0) {
        _orderDetail = null;
        _updateState(
          SalesOrderDetailState.noData,
          error: 'No sales order detail found.',
        );
        return;
      }

      _orderDetail = data;
      _updateState(SalesOrderDetailState.loaded);
    } catch (e, stack) {
      debugPrint('loadOrderDetail failed: $e\n$stack');
      _updateState(
        SalesOrderDetailState.error,
        error: 'Failed to load sales order detail.',
      );
    }
  }

  Future<void> refresh() async {
    await loadOrderDetail();
  }

  Future<bool> updateStatus(String action) async {
    _isStatusUpdating = true;
    _statusError = null;
    _notifyListenersSafely();
    try {
      final result =
          await _repository.updateOrderStatus(companyId, orderId, action);
      if (result['success'] == true) {
        await loadOrderDetail();
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

  void clearError() {
    _errorMessage = null;
    if (_state == SalesOrderDetailState.error) {
      _state = SalesOrderDetailState.initial;
    }
    _notifyListenersSafely();
  }

  void _updateState(SalesOrderDetailState next, {String? error}) {
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
