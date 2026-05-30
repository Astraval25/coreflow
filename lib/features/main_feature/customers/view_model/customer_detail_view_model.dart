import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_contact_lookup.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_detail.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_mapped_item.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_orders_payments.dart';
import 'package:coreflow/domain/model/main_model/analytics/party_order_payment_trend.dart';
import 'package:coreflow/domain/model/main_model/invitation/invitation_response.dart';
import 'package:coreflow/domain/model/main_model/items/item.dart';
import 'package:coreflow/domain/model/main_model/items/item_status_response.dart';
import 'package:flutter/material.dart';

enum CustomerViewState { initial, loading, loaded, error, noData }

class CustomerDetailViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  CustomerViewState _state = CustomerViewState.initial;
  CustomerDetailData? _customer;
  List<CustomerMappedItem> _mappedItems = [];
  String? _errorMessage;
  bool _isMappedItemsLoading = false;
  bool _isMappedItemStatusUpdating = false;
  int? _statusUpdatingItemId;
  List<OrderPaymentEntry> _ordersPayments = [];
  bool _isOrdersPaymentsLoading = false;
  bool _isOrdersPaymentsLoadingMore = false;
  bool _hasMoreOrdersPayments = true;
  int _nextOrdersPaymentsPage = 0;
  static const int _ordersPaymentsPageSize = 10;
  List<PartyOrderPaymentTrendEntry> _monthlyOrderPaymentTrend = [];
  bool _isMonthlyOrderPaymentTrendLoading = false;
  bool _isLinkSuggestionLoading = false;
  CustomerContactLookupResult? _linkSuggestion;
  bool _isLinkingByPhone = false;

  final int _companyId;
  final int _customerId;
  final Future<void> Function()? _refreshUnreadCount;
  bool _hasClearedUnreadActivity = false;

  CustomerDetailViewModel({
    required int companyId,
    required int customerId,
    Future<void> Function()? refreshUnreadCount,
  }) : _companyId = companyId,
       _customerId = customerId,
       _refreshUnreadCount = refreshUnreadCount {
    loadCustomerDetail();
  }

  CustomerViewState get state => _state;
  CustomerDetailData? get customer => _customer;
  List<CustomerMappedItem> get mappedItems => List.unmodifiable(_mappedItems);
  String? get errorMessage => _errorMessage;
  bool get isMappedItemsLoading => _isMappedItemsLoading;
  bool get isMappedItemStatusUpdating => _isMappedItemStatusUpdating;
  int? get statusUpdatingItemId => _statusUpdatingItemId;
  List<OrderPaymentEntry> get ordersPayments =>
      List.unmodifiable(_ordersPayments);
  bool get isOrdersPaymentsLoading => _isOrdersPaymentsLoading;
  bool get isOrdersPaymentsLoadingMore => _isOrdersPaymentsLoadingMore;
  bool get hasMoreOrdersPayments => _hasMoreOrdersPayments;
  List<PartyOrderPaymentTrendEntry> get monthlyOrderPaymentTrend =>
      List.unmodifiable(_monthlyOrderPaymentTrend);
  bool get isMonthlyOrderPaymentTrendLoading =>
      _isMonthlyOrderPaymentTrendLoading;
  bool get isLinkSuggestionLoading => _isLinkSuggestionLoading;
  CustomerContactLookupResult? get linkSuggestion => _linkSuggestion;
  bool get isLinkingByPhone => _isLinkingByPhone;
  List<CustomerOrder> get ordersOnly => _ordersPayments
      .where((e) => e.isOrder && e.order != null)
      .map((e) => e.order!)
      .toList(growable: false);
  List<CustomerPayment> get paymentsOnly => _ordersPayments
      .where((e) => !e.isOrder && e.payment != null)
      .map((e) => e.payment!)
      .toList(growable: false);
  double get totalOrderAmount =>
      ordersOnly.fold(0.0, (sum, order) => sum + order.totalAmount);
  double get totalPaidOnOrders =>
      ordersOnly.fold(0.0, (sum, order) => sum + order.paidAmount);
  double get totalDueAmount =>
      ordersOnly.fold(0.0, (sum, order) => sum + order.dueAmount);
  double get totalPaymentAmount =>
      paymentsOnly.fold(0.0, (sum, payment) => sum + payment.amount);

  bool get isLoading => _state == CustomerViewState.loading;
  bool get hasData => _state == CustomerViewState.loaded;
  bool get isError => _state == CustomerViewState.error;
  bool get isNoData => _state == CustomerViewState.noData;

  int get companyId => _companyId;
  int get customerId => _customerId;

  bool get isActive => _customer?.isActive ?? false;

  Future<void> loadCustomerDetail() async {
    _updateState(CustomerViewState.loading);

    try {
      final customerData = await _authRepository.getCustomerDetail(
        _companyId,
        _customerId,
      );

      if (customerData != null) {
        _customer = customerData;
        await _loadLinkSuggestion();
        await _clearUnreadActivityIfNeeded();
        _updateState(CustomerViewState.loaded);
        loadMappedItems();
        loadMonthlyOrderPaymentTrend();
        loadOrdersPayments(reset: true);
      } else {
        _updateState(CustomerViewState.noData, error: 'No customer data found');
      }
    } catch (e) {
      _updateState(
        CustomerViewState.error,
        error: 'Failed to load customer: $e',
      );
    }
  }

  Future<bool> activateCustomer() async {
    _updateState(CustomerViewState.loading);

    try {
      final response = await _authRepository.activateCustomer(
        _companyId,
        _customerId,
      );

      if (response != null && response.responseStatus == true) {
        await loadCustomerDetail();
        return true;
      } else {
        _updateState(
          CustomerViewState.error,
          error: response?.responseMessage ?? 'Activate failed',
        );
        return false;
      }
    } catch (e) {
      _updateState(CustomerViewState.error, error: 'Activate error: $e');
      return false;
    }
  }

  Future<bool> deactivateCustomer() async {
    _updateState(CustomerViewState.loading);

    try {
      final response = await _authRepository.deactivateCustomer(
        _companyId,
        _customerId,
      );

      if (response != null && response.responseStatus == true) {
        await loadCustomerDetail();
        return true;
      } else {
        _updateState(
          CustomerViewState.error,
          error: response?.responseMessage ?? 'Deactivate failed',
        );
        return false;
      }
    } catch (e) {
      _updateState(CustomerViewState.error, error: 'Deactivate error: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadMappedItems() async {
    _isMappedItemsLoading = true;
    notifyListeners();

    try {
      final items = await _authRepository.getCustomerMappedItems(
        _companyId,
        _customerId,
      );
      _mappedItems = items;
    } catch (e) {
      debugPrint('Failed to load mapped items: $e');
      _mappedItems = [];
    } finally {
      _isMappedItemsLoading = false;
      notifyListeners();
    }
  }

  Future<List<Item>> getActiveCompanyItems() async {
    try {
      final allItems = await _authRepository.getItems(_companyId);
      return allItems.where((item) => item.isActive).toList();
    } catch (e) {
      debugPrint('Failed to load active company items: $e');
      return [];
    }
  }

  Future<bool> createCustomerItem({
    required int itemId,
    required double salesPrice,
    String? salesDescription,
  }) async {
    try {
      final response = await _authRepository.createCustomerItem(
        companyId: _companyId,
        customerId: _customerId,
        itemId: itemId,
        salesPrice: salesPrice,
        salesDescription: salesDescription,
      );

      if (response?.responseStatus == true) {
        await loadMappedItems();
        return true;
      }

      _errorMessage =
          response?.responseMessage ?? 'Create customer item failed';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Create customer item error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomerItem({
    required int itemId,
    required double salesPrice,
    String? salesDescription,
  }) async {
    try {
      final response = await _authRepository.updateCustomerItem(
        companyId: _companyId,
        customerId: _customerId,
        itemId: itemId,
        salesPrice: salesPrice,
        salesDescription: salesDescription,
      );

      if (response?.responseStatus == true) {
        await loadMappedItems();
        return true;
      }

      _errorMessage =
          response?.responseMessage ?? 'Update customer item failed';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Update customer item error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> setMappedItemActiveStatus({
    required int itemId,
    required bool shouldActivate,
  }) async {
    _isMappedItemStatusUpdating = true;
    _statusUpdatingItemId = itemId;
    notifyListeners();

    try {
      final ItemStatusResponse? response = shouldActivate
          ? await _authRepository.activateCustomerMappedItem(
              _companyId,
              _customerId,
              itemId,
            )
          : await _authRepository.deactivateCustomerMappedItem(
              _companyId,
              _customerId,
              itemId,
            );

      if (response?.responseStatus == true) {
        await loadMappedItems();
        return true;
      }

      _errorMessage =
          response?.responseMessage ??
          (shouldActivate ? 'Activate item failed' : 'Deactivate item failed');
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Item status update failed: $e';
      notifyListeners();
      return false;
    } finally {
      _isMappedItemStatusUpdating = false;
      _statusUpdatingItemId = null;
      notifyListeners();
    }
  }

  // ─── Transaction ───

  Future<void> loadOrdersPayments({bool reset = false}) async {
    if (_isOrdersPaymentsLoading || _isOrdersPaymentsLoadingMore) return;

    if (reset) {
      _nextOrdersPaymentsPage = 0;
      _hasMoreOrdersPayments = true;
      _ordersPayments = [];
    } else if (!_hasMoreOrdersPayments) {
      return;
    }

    final page = _nextOrdersPaymentsPage;

    if (page == 0) {
      _isOrdersPaymentsLoading = true;
    } else {
      _isOrdersPaymentsLoadingMore = true;
    }
    notifyListeners();

    try {
      final data = await _authRepository.getCustomerOrdersPayments(
        _companyId,
        _customerId,
        page: page,
        size: _ordersPaymentsPageSize,
      );

      final entries = <OrderPaymentEntry>[];
      if (data != null) {
        entries.addAll([
          ...data.orders.map((o) => OrderPaymentEntry.fromOrder(o)),
          ...data.payments.map((p) => OrderPaymentEntry.fromPayment(p)),
        ]);
      }
      entries.sort();

      if (page == 0) {
        _ordersPayments = entries;
      } else {
        final existing = _ordersPayments.map(_entryKey).toSet();
        final fresh = entries
            .where((entry) => !existing.contains(_entryKey(entry)))
            .toList();
        _ordersPayments = [..._ordersPayments, ...fresh];
        if (fresh.isEmpty) {
          _hasMoreOrdersPayments = false;
          return;
        }
      }

      _hasMoreOrdersPayments = entries.length >= _ordersPaymentsPageSize;
      if (_hasMoreOrdersPayments) {
        _nextOrdersPaymentsPage = page + 1;
      }
    } catch (e) {
      debugPrint('Failed to load orders-payments: $e');
      if (page == 0) {
        _ordersPayments = [];
      }
    } finally {
      _isOrdersPaymentsLoading = false;
      _isOrdersPaymentsLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshOrdersPayments() => loadOrdersPayments(reset: true);

  Future<void> loadMonthlyOrderPaymentTrend() async {
    _isMonthlyOrderPaymentTrendLoading = true;
    notifyListeners();

    try {
      final end = DateTime.now();
      final start = end.subtract(const Duration(days: 29));
      final trend = await _authRepository.getCustomerOrderPaymentTrend(
        _companyId,
        _customerId,
        _formatDate(start),
        _formatDate(end),
      );
      _monthlyOrderPaymentTrend = trend;
    } catch (e) {
      debugPrint('Failed to load monthly order-payment trend: $e');
      _monthlyOrderPaymentTrend = [];
    } finally {
      _isMonthlyOrderPaymentTrendLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreOrdersPaymentsIfNeeded() async {
    if (_isOrdersPaymentsLoading ||
        _isOrdersPaymentsLoadingMore ||
        !_hasMoreOrdersPayments) {
      return;
    }
    await loadOrdersPayments();
  }

  String _entryKey(OrderPaymentEntry entry) {
    if (entry.isOrder && entry.order != null) {
      return 'o_${entry.order!.orderId}';
    }
    if (entry.payment != null) {
      return 'p_${entry.payment!.paymentId}';
    }
    return 'x_${entry.date.millisecondsSinceEpoch}';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  // ─── Invitation ───

  bool _isInvitationLoading = false;
  InvitationData? _invitationData;

  bool get isInvitationLoading => _isInvitationLoading;
  InvitationData? get invitationData => _invitationData;

  Future<InvitationResponse?> sendInvitation() async {
    _isInvitationLoading = true;
    notifyListeners();

    try {
      final response = await _authRepository.sendCustomerInvitation(
        _companyId,
        _customerId,
      );

      if (response?.responseStatus == true && response?.responseData != null) {
        _invitationData = response!.responseData;
      }
      return response;
    } catch (e) {
      debugPrint('Send invitation error: $e');
      return null;
    } finally {
      _isInvitationLoading = false;
      notifyListeners();
    }
  }

  Future<InvitationResponse?> getInvitationCode() async {
    _isInvitationLoading = true;
    notifyListeners();

    try {
      final response = await _authRepository.getCustomerInvitationCode(
        _companyId,
        _customerId,
      );

      if (response?.responseStatus == true && response?.responseData != null) {
        _invitationData = response!.responseData;
      }
      return response;
    } catch (e) {
      debugPrint('Get invitation code error: $e');
      return null;
    } finally {
      _isInvitationLoading = false;
      notifyListeners();
    }
  }

  Future<AcceptInvitationResponse?> acceptInvitation(String code) async {
    _isInvitationLoading = true;
    notifyListeners();

    try {
      final response = await _authRepository.acceptInvitation(
        companyId: _companyId,
        invitationCode: code,
        selectedCustomerId: _customerId,
      );
      if (response?.responseStatus == true) {
        await loadCustomerDetail();
      }
      return response;
    } catch (e) {
      debugPrint('Accept invitation error: $e');
      return null;
    } finally {
      _isInvitationLoading = false;
      notifyListeners();
    }
  }

  Future<bool> linkCustomerByPhone() async {
    if (_isLinkingByPhone) return false;
    _isLinkingByPhone = true;
    notifyListeners();

    try {
      final response = await _authRepository.linkCustomerByPhone(
        _companyId,
        _customerId,
      );

      if (response != null && response.responseStatus) {
        await loadCustomerDetail();
        return true;
      }

      _errorMessage = response?.responseMessage ?? 'Failed to link customer';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to link customer: $e';
      notifyListeners();
      return false;
    } finally {
      _isLinkingByPhone = false;
      notifyListeners();
    }
  }

  Future<void> _loadLinkSuggestion() async {
    final phone = _customer?.phone?.trim();
    final alreadyLinked = _customer?.customerCompany != null;

    if (alreadyLinked || phone == null || phone.isEmpty) {
      _linkSuggestion = null;
      _isLinkSuggestionLoading = false;
      return;
    }

    _isLinkSuggestionLoading = true;
    notifyListeners();

    try {
      final results = await _authRepository.lookupCustomerContacts(_companyId, [
        phone,
      ]);
      _linkSuggestion = results.isNotEmpty ? results.first : null;
    } catch (_) {
      _linkSuggestion = null;
    } finally {
      _isLinkSuggestionLoading = false;
      notifyListeners();
    }
  }

  void _updateState(CustomerViewState state, {String? error}) {
    _state = state;
    _errorMessage = error;
    notifyListeners();
  }

  // ─── Connection Request ───

  bool _isConnectionLoading = false;
  bool get isConnectionLoading => _isConnectionLoading;

  Future<bool> acceptConnection() async {
    _isConnectionLoading = true;
    notifyListeners();
    try {
      final success = await _authRepository.acceptCustomerConnection(
        _companyId,
        _customerId,
      );
      if (success) await loadCustomerDetail();
      return success;
    } catch (e) {
      debugPrint('Accept connection error: $e');
      return false;
    } finally {
      _isConnectionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectConnection() async {
    _isConnectionLoading = true;
    notifyListeners();
    try {
      final success = await _authRepository.rejectCustomerConnection(
        _companyId,
        _customerId,
      );
      if (success) await loadCustomerDetail();
      return success;
    } catch (e) {
      debugPrint('Reject connection error: $e');
      return false;
    } finally {
      _isConnectionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> undoConnectionDecision(String newStatus) async {
    _isConnectionLoading = true;
    notifyListeners();
    try {
      final success = await _authRepository.undoCustomerConnection(
        _companyId,
        _customerId,
        newStatus,
      );
      if (success) await loadCustomerDetail();
      return success;
    } catch (e) {
      debugPrint('Undo connection error: $e');
      return false;
    } finally {
      _isConnectionLoading = false;
      notifyListeners();
    }
  }

  Future<void> _clearUnreadActivityIfNeeded() async {
    if (_hasClearedUnreadActivity) return;

    await _authRepository.markNotificationSubjectRead(
      _companyId,
      'CUSTOMER',
      _customerId,
    );
    _hasClearedUnreadActivity = true;
    await _refreshUnreadCount?.call();
  }
}
