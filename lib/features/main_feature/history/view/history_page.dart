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
  late Future<List<OrderHistoryEntry>> _future;
  late Future<List<PaymentHistoryEntry>> _paymentFuture;
  String _orderType = 'ALL';
  String _paidState = 'ALL';
  String _orderStatus = 'ALL';
  String _paymentType = 'ALL';
  String _paymentStatus = 'ALL';

  @override
  void initState() {
    super.initState();
    _future = _load();
    _paymentFuture = _loadPayments();
  }

  Future<List<OrderHistoryEntry>> _load() {
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
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _orderType,
                          items: const [
                            DropdownMenuItem(value: 'ALL', child: Text('All')),
                            DropdownMenuItem(
                              value: 'SALES',
                              child: Text('Sales'),
                            ),
                            DropdownMenuItem(
                              value: 'PURCHASE',
                              child: Text('Purchase'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _orderType = v;
                              _future = _load();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _paidState,
                          items: const [
                            DropdownMenuItem(value: 'ALL', child: Text('All')),
                            DropdownMenuItem(
                              value: 'PAID',
                              child: Text('Paid'),
                            ),
                            DropdownMenuItem(
                              value: 'PARTIAL',
                              child: Text('Partial'),
                            ),
                            DropdownMenuItem(
                              value: 'UNPAID',
                              child: Text('Unpaid'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _paidState = v;
                              _future = _load();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _orderStatus,
                          items: const [
                            DropdownMenuItem(
                              value: 'ALL',
                              child: Text('All Status'),
                            ),
                            DropdownMenuItem(
                              value: 'ORDER',
                              child: Text('ORDER'),
                            ),
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
                              _future = _load();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<OrderHistoryEntry>>(
                    future: _future,
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
                          final refreshed = _load();
                          setState(() => _future = refreshed);
                          await refreshed;
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: entries.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, i) => _OrderHistoryCard(
                            entry: entries[i],
                            companyId: widget.companyId,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _paymentType,
                          items: const [
                            DropdownMenuItem(value: 'ALL', child: Text('All')),
                            DropdownMenuItem(
                              value: 'RECEIVED',
                              child: Text('Received'),
                            ),
                            DropdownMenuItem(
                              value: 'MADE',
                              child: Text('Made'),
                            ),
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
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _paymentStatus,
                          items: const [
                            DropdownMenuItem(
                              value: 'ALL',
                              child: Text('All Status'),
                            ),
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
                      return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: entries.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final e = entries[i];
                          final date =
                              '${e.paymentDate.day.toString().padLeft(2, '0')}/${e.paymentDate.month.toString().padLeft(2, '0')}/${e.paymentDate.year}';
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: LoginColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: LoginColors.border),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        e.localPaymentNumber.isNotEmpty
                                            ? e.localPaymentNumber
                                            : 'Payment #${e.paymentId}',
                                        style: TextStyle(
                                          color: LoginColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$date • ${e.paymentStatus}',
                                        style: TextStyle(
                                          color: LoginColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatMoney(e.amount),
                                  style: TextStyle(
                                    color: LoginColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final OrderHistoryEntry entry;
  final int companyId;

  const _OrderHistoryCard({required this.entry, required this.companyId});

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

  @override
  Widget build(BuildContext context) {
    final pct = entry.paidPercentage.clamp(0, 100);
    final pctColor = _percentageColor(pct);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LoginColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.localOrderNumber.isNotEmpty
                        ? entry.localOrderNumber
                        : 'Order #${entry.orderId}',
                    style: TextStyle(
                      color: LoginColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  _dateText(entry.orderDate),
                  style: TextStyle(
                    color: LoginColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              entry.orderStatus,
              style: TextStyle(
                color: LoginColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Qty: ${_qtyText(entry.totalItemQuantity)}',
                    style: TextStyle(
                      color: LoginColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Total: ${formatMoney(entry.totalAmount)}',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: LoginColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: pct / 100,
                minHeight: 8,
                backgroundColor: LoginColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(pctColor),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$pct%',
                style: TextStyle(
                  color: pctColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
