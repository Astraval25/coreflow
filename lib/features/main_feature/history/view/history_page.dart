import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/utils/common_formatters.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/analytics/order_history.dart';
import 'package:coreflow/domain/model/main_model/analytics/payment_history.dart';
import 'package:coreflow/features/main_feature/purchase/view/purchase_order_detail_page.dart';
import 'package:coreflow/features/main_feature/sales/view/sales_order_detail_page.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  final int companyId;

  const HistoryPage({super.key, required this.companyId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final AuthRepository _repo = AuthRepository();

  late Future<List<OrderHistoryEntry>> _orderFuture;
  late Future<List<PaymentHistoryEntry>> _paymentFuture;

  String _orderType = 'ALL';
  String _paidState = 'ALL';
  String _orderStatus = 'ALL';

  String _paymentType = 'ALL';
  String _paymentStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    _orderFuture = _loadOrders();
    _paymentFuture = _loadPayments();
  }

  Future<List<OrderHistoryEntry>> _loadOrders() {
    final now = DateTime.now();
    final start = DateTime(now.year - 1, now.month, now.day);

    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return _repo.getOrderHistory(
      widget.companyId,
      fmt(start),
      fmt(now),
      orderType: _orderType,
      paidState: _paidState,
      statuses: _orderStatus == 'ALL' ? const [] : [_orderStatus],
    );
  }

  Future<List<PaymentHistoryEntry>> _loadPayments() {
    final now = DateTime.now();
    final start = DateTime(now.year - 1, now.month, now.day);

    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return _repo.getPaymentHistory(
      widget.companyId,
      fmt(start),
      fmt(now),
      paymentType: _paymentType,
      statuses: _paymentStatus == 'ALL' ? const [] : [_paymentStatus],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: LoginColors.background,
        appBar: AppBar(
          backgroundColor: LoginColors.background,
          elevation: 0,
          title: Text(
            'History',
            style: TextStyle(
              color: LoginColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Order History'),
              Tab(text: 'Payment History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildOrderHistoryTab(), _buildPaymentHistoryTab()],
        ),
      ),
    );
  }

  Widget _buildOrderHistoryTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<String>(
                    initialValue: _orderType,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All')),
                      DropdownMenuItem(value: 'SALES', child: Text('Sales')),
                      DropdownMenuItem(
                        value: 'PURCHASE',
                        child: Text('Purchase'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _orderType = v;
                        _orderFuture = _loadOrders();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 140,
                  child: DropdownButtonFormField<String>(
                    initialValue: _paidState,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All')),
                      DropdownMenuItem(value: 'PAID', child: Text('Paid')),
                      DropdownMenuItem(
                        value: 'PARTIAL',
                        child: Text('Partial'),
                      ),
                      DropdownMenuItem(value: 'UNPAID', child: Text('Unpaid')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _paidState = v;
                        _orderFuture = _loadOrders();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<String>(
                    initialValue: _orderStatus,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Status')),
                      DropdownMenuItem(value: 'ORDER', child: Text('ORDER')),
                      DropdownMenuItem(
                        value: 'ORDER_VIEWED',
                        child: Text('ORDER_VIEWED'),
                      ),
                      DropdownMenuItem(
                        value: 'ORDER_INVOICED',
                        child: Text('ORDER_INVOICED'),
                      ),
                      DropdownMenuItem(
                        value: 'ORDER_PAYED',
                        child: Text('ORDER_PAYED'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _orderStatus = v;
                        _orderFuture = _loadOrders();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<OrderHistoryEntry>>(
            future: _orderFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final entries = snapshot.data ?? [];
              if (entries.isEmpty) {
                return Center(
                  child: Text(
                    'No order history found',
                    style: TextStyle(color: LoginColors.textSecondary),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  final refreshed = _loadOrders();
                  setState(() => _orderFuture = refreshed);
                  await refreshed;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: entries.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: _HistoryListHeader(),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _OrderHistoryRow(
                        entry: entries[i - 1],
                        companyId: widget.companyId,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 160,
                  child: DropdownButtonFormField<String>(
                    initialValue: _paymentType,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All')),
                      DropdownMenuItem(
                        value: 'RECEIVED',
                        child: Text('Received'),
                      ),
                      DropdownMenuItem(value: 'MADE', child: Text('Made')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _paymentType = v;
                        _paymentFuture = _loadPayments();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<String>(
                    initialValue: _paymentStatus,
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('All Status')),
                      DropdownMenuItem(
                        value: 'PAYMENT_PAID',
                        child: Text('PAID'),
                      ),
                      DropdownMenuItem(
                        value: 'PAYMENT_VIEWED',
                        child: Text('VIEWED'),
                      ),
                      DropdownMenuItem(
                        value: 'PAYMENT_PARTIALLY_PAID',
                        child: Text('PARTIAL'),
                      ),
                      DropdownMenuItem(
                        value: 'PAYMENT_FAILED',
                        child: Text('FAILED'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _paymentStatus = v;
                        _paymentFuture = _loadPayments();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<PaymentHistoryEntry>>(
            future: _paymentFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final entries = snapshot.data ?? [];
              if (entries.isEmpty) {
                return Center(
                  child: Text(
                    'No payment history found',
                    style: TextStyle(color: LoginColors.textSecondary),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  final refreshed = _loadPayments();
                  setState(() => _paymentFuture = refreshed);
                  await refreshed;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: entries.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: _HistoryListHeader(),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PaymentHistoryRow(entry: entries[i - 1]),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HistoryListHeader extends StatelessWidget {
  const _HistoryListHeader();

  Widget _title(String value, {TextAlign textAlign = TextAlign.start}) {
    return Text(
      value,
      textAlign: textAlign,
      style: TextStyle(
        color: LoginColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 18),
        Expanded(flex: 3, child: _title('Date')),
        Expanded(flex: 5, child: _title('Name')),
        Expanded(flex: 2, child: _title('Qty', textAlign: TextAlign.center)),
        Expanded(flex: 3, child: _title('Total', textAlign: TextAlign.end)),
      ],
    );
  }
}

class _OrderHistoryRow extends StatelessWidget {
  final OrderHistoryEntry entry;
  final int companyId;

  const _OrderHistoryRow({required this.entry, required this.companyId});

  Color _percentageColor(int value) {
    if (value >= 100) return LoginColors.success;
    if (value >= 70) return const Color(0xFF10B981);
    if (value >= 40) return const Color(0xFFF59E0B);
    return LoginColors.error;
  }

  String _dateText(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _qtyText(double value) {
    if ((value - value.roundToDouble()).abs() < 0.000001) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String _partyLabel() {
    if (entry.partyName.trim().isNotEmpty) return entry.partyName.trim();
    return entry.orderType.toUpperCase() == 'SALES' ? 'Customer' : 'Vendor';
  }

  @override
  Widget build(BuildContext context) {
    final pct = entry.paidPercentage.clamp(0, 100);
    final pctColor = _percentageColor(pct);
    final orderNumber = entry.localOrderNumber.isNotEmpty
        ? entry.localOrderNumber
        : 'Order #${entry.orderId}';

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        if (entry.orderType.toUpperCase() == 'SALES') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SalesOrderDetailPage(
                companyId: companyId,
                orderId: entry.orderId,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PurchaseOrderDetailPage(
                companyId: companyId,
                orderId: entry.orderId,
              ),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: LoginColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: pctColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                _dateText(entry.orderDate),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: LoginColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _partyLabel(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: LoginColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    orderNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: LoginColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _qtyText(entry.totalItemQuantity),
                textAlign: TextAlign.center,
                style: TextStyle(color: LoginColors.textPrimary, fontSize: 12),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatMoney(entry.totalAmount),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: LoginColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatMoney(entry.paidAmount),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: pctColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentHistoryRow extends StatelessWidget {
  final PaymentHistoryEntry entry;

  const _PaymentHistoryRow({required this.entry});

  Color _percentageColor(int value) {
    if (value >= 100) return LoginColors.success;
    if (value >= 70) return const Color(0xFF10B981);
    if (value >= 40) return const Color(0xFFF59E0B);
    return LoginColors.error;
  }

  String _dateText(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _qtyText(double value) {
    if (value <= 0) return '-';
    if ((value - value.roundToDouble()).abs() < 0.000001) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String _partyLabel() {
    if (entry.partyName.trim().isNotEmpty) return entry.partyName.trim();
    return entry.paymentType.toUpperCase() == 'RECEIVED'
        ? 'Customer'
        : 'Vendor';
  }

  @override
  Widget build(BuildContext context) {
    final total = entry.totalAmount > 0 ? entry.totalAmount : entry.amount;
    final paid = entry.paidAmount > 0 ? entry.paidAmount : entry.amount;
    final ratio = total > 0 ? ((paid / total) * 100).clamp(0, 100) : 100.0;
    final pctColor = _percentageColor(ratio.round());
    final paymentNumber = entry.localPaymentNumber.isNotEmpty
        ? entry.localPaymentNumber
        : 'Payment #${entry.paymentId}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: LoginColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: pctColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              _dateText(entry.paymentDate),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: LoginColors.textSecondary, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _partyLabel(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: LoginColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  paymentNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: LoginColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _qtyText(entry.quantity),
              textAlign: TextAlign.center,
              style: TextStyle(color: LoginColors.textPrimary, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatMoney(total),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: LoginColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatMoney(paid),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: pctColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
