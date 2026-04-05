import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/company_ref/order_ref.dart';
import 'package:coreflow/domain/model/main_model/company_ref/payment_ref.dart';
import 'package:coreflow/domain/model/main_model/sales/sales_order_detail.dart'
    as sales_detail;
import 'package:coreflow/domain/model/main_model/sales/sales_order_item.dart'
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

  SalesOrderDetailState get state => _state;
  bool get isStatusUpdating => _isStatusUpdating;
  String? get statusError => _statusError;
  bool get isCanceling => _isCanceling;
  String? get cancelError => _cancelError;
  List<PaymentRef> get dependentPayments =>
      List.unmodifiable(_dependentPayments);
  List<PaymentRef> get orderPayments => List.unmodifiable(_orderPayments);
  bool get isOrderPaymentsLoading => _isOrderPaymentsLoading;
  sales_detail.SalesOrderDetail? get orderDetail => _orderDetail;
  OrderRef? get orderRef => _orderRef;
  bool get isRefUpdating => _isRefUpdating;

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
      _loadOrderRef();
      _loadOrderPayments();
    } catch (e, stack) {
      debugPrint('loadOrderDetail failed: $e\n$stack');
      _updateState(
        SalesOrderDetailState.error,
        error: 'Failed to load sales order detail.',
      );
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
