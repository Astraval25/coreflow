import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/company_ref/order_ref.dart';
import 'package:coreflow/domain/model/main_model/company_ref/payment_ref.dart';
import 'package:coreflow/domain/model/main_model/purchase/purchase_order_detail.dart';
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
  OrderRef? _orderRef;
  String? _errorMessage;
  bool _isDisposed = false;
  bool _isStatusUpdating = false;
  String? _statusError;
  bool _isRefUpdating = false;
  bool _isCanceling = false;
  String? _cancelError;
  List<PaymentRef> _dependentPayments = const [];
  List<PaymentRef> _orderPayments = const [];
  bool _isOrderPaymentsLoading = false;

  PurchaseOrderDetailState get state => _state;
  PurchaseOrderDetail? get orderDetail => _orderDetail;
  OrderRef? get orderRef => _orderRef;
  String? get errorMessage => _errorMessage;
  bool get isStatusUpdating => _isStatusUpdating;
  String? get statusError => _statusError;
  bool get isCanceling => _isCanceling;
  String? get cancelError => _cancelError;
  List<PaymentRef> get dependentPayments =>
      List.unmodifiable(_dependentPayments);
  List<PaymentRef> get orderPayments => List.unmodifiable(_orderPayments);
  bool get isOrderPaymentsLoading => _isOrderPaymentsLoading;
  bool get isRefUpdating => _isRefUpdating;

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
      _loadOrderRef();
      _loadOrderPayments();

      if (data.orderStatus == 'ORDER') {
        _autoMarkViewed();
      }
    } catch (e, stack) {
      debugPrint('loadPurchaseOrderDetail failed: $e\n$stack');
      _updateState(
        PurchaseOrderDetailState.error,
        error: 'Failed to load purchase order detail.',
      );
    }
  }

  Future<void> _autoMarkViewed() async {
    try {
      final result = await _repository.updateOrderStatus(
        companyId,
        orderId,
        'viewed',
      );
      if (result['success'] == true) {
        await loadOrderDetail();
      }
    } catch (e) {
      debugPrint('Auto mark viewed failed: $e');
    }
  }

  Future<void> _loadOrderRef() async {
    try {
      _orderRef = await _repository.getOrderRef(companyId, orderId);
      _notifyListenersSafely();
    } catch (e) {
      debugPrint('loadOrderRef failed: $e');
    }
  }

  Future<void> _loadOrderPayments() async {
    _isOrderPaymentsLoading = true;
    _notifyListenersSafely();
    try {
      _orderPayments = await _repository.getOrderPaymentDetails(
        companyId,
        orderId,
      );
    } catch (e) {
      debugPrint('loadOrderPayments failed: $e');
      _orderPayments = const [];
    } finally {
      _isOrderPaymentsLoading = false;
      _notifyListenersSafely();
    }
  }

  Future<bool> updateOrderRef(Map<String, dynamic> body) async {
    _isRefUpdating = true;
    _notifyListenersSafely();
    try {
      final success = await _repository.updateOrderRef(
        companyId,
        orderId,
        body,
      );
      if (success) {
        await _loadOrderRef();
      }
      return success;
    } catch (e) {
      debugPrint('updateOrderRef failed: $e');
      return false;
    } finally {
      _isRefUpdating = false;
      _notifyListenersSafely();
    }
  }

  Future<void> refresh() async {
    await loadOrderDetail();
  }

  Future<Uint8List?> downloadOrderBill() {
    return _repository.downloadOrderBill(companyId, orderId);
  }

  Future<bool> updateStatus(String action) async {
    _isStatusUpdating = true;
    _statusError = null;
    _notifyListenersSafely();
    try {
      final result = await _repository.updateOrderStatus(
        companyId,
        orderId,
        action,
      );
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

  Future<Map<String, dynamic>> cancelOrder() async {
    _isCanceling = true;
    _cancelError = null;
    _dependentPayments = const [];
    _notifyListenersSafely();
    try {
      final result = await _repository.cancelOrder(companyId, orderId);
      if (result['success'] == true) {
        await loadOrderDetail();
        return {
          'success': true,
          'message': result['message'] ?? 'Order canceled successfully',
          'dependentPayments': <PaymentRef>[],
        };
      }

      final payments = result['dependentPayments'];
      _dependentPayments = payments is List<PaymentRef>
          ? payments
          : const <PaymentRef>[];
      _cancelError = result['message']?.toString() ?? 'Failed to cancel order';
      return {
        'success': false,
        'message': _cancelError,
        'responseCode': result['responseCode'],
        'dependentPayments': _dependentPayments,
      };
    } catch (e) {
      _cancelError = 'Error: $e';
      return {
        'success': false,
        'message': _cancelError,
        'dependentPayments': <PaymentRef>[],
      };
    } finally {
      _isCanceling = false;
      _notifyListenersSafely();
    }
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
