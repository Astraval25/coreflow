import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/analytics/cash_flow.dart';
import 'package:coreflow/domain/model/analytics/dashboard_kpi.dart';
import 'package:coreflow/domain/model/analytics/item_analytics.dart';
import 'package:coreflow/domain/model/analytics/item_frequency.dart';
import 'package:coreflow/domain/model/analytics/monthly_trend.dart';
import 'package:coreflow/domain/model/analytics/order_frequency.dart';
import 'package:coreflow/domain/model/analytics/party_analytics.dart';
import 'package:coreflow/domain/model/analytics/payment_mode.dart';
import 'package:coreflow/domain/model/analytics/revenue_expense.dart';
import 'package:coreflow/domain/model/analytics/running_amount.dart';
import 'package:coreflow/features/analytics/analytics_view_model/analytics_view_model.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _fmt(double v) {
  final neg = v < 0 ? '-' : '';
  final abs = v.abs();
  final str = abs.toStringAsFixed(2).split('.');
  final intPart = str[0];
  final dec = str[1];
  final buf = StringBuffer();
  final len = intPart.length;
  for (int i = 0; i < len; i++) {
    if (i > 0) {
      final fr = len - i;
      if (fr == 3 || (fr > 3 && (fr - 3) % 2 == 0)) buf.write(',');
    }
    buf.write(intPart[i]);
  }
  return '$neg₹$buf.$dec';
}

String _monthLabel(String yyyyMm) {
  const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final p = yyyyMm.split('-');
  if (p.length < 2) return yyyyMm;
  final m = int.tryParse(p[1]) ?? 0;
  return '${months[m.clamp(0, 12)]} ${p[0]}';
}

// ─── Root ─────────────────────────────────────────────────────────────────────

class ReportResultPage extends StatelessWidget {
  final ReportType reportType;
  const ReportResultPage({super.key, required this.reportType});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalyticsViewModel>();
    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        backgroundColor: LoginColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: LoginColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(reportType.label,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
                letterSpacing: -0.3)),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(vm),
    );
  }

  Widget _buildBody(AnalyticsViewModel vm) {
    switch (reportType) {
      case ReportType.dashboardKpi:
        return _KpiView(kpi: vm.kpi, vm: vm);
      case ReportType.cashFlow:
        return _MonthlyTableView<CashFlowEntry>(
          entries: vm.cashFlow, vm: vm,
          columns: const ['Month', 'Opening', 'Incoming', 'Outgoing', 'Closing'],
          rowBuilder: (e) => [
            _monthLabel(e.month), _fmt(e.openingBalance),
            _fmt(e.incoming), _fmt(e.outgoing), _fmt(e.closingBalance),
          ],
          colorBuilder: (col, val) {
            if (col == 2) return LoginColors.success;
            if (col == 3) return LoginColors.error;
            if (col == 4) return val.startsWith('-') ? LoginColors.error : LoginColors.success;
            return null;
          },
        );
      case ReportType.revenueExpense:
        return _MonthlyTableView<RevenueExpenseEntry>(
          entries: vm.revenueExpense, vm: vm,
          columns: const ['Month', 'Revenue', 'Expense', 'Net Profit'],
          rowBuilder: (e) => [
            _monthLabel(e.month), _fmt(e.revenue),
            _fmt(e.expense), _fmt(e.netProfit),
          ],
          colorBuilder: (col, val) {
            if (col == 1) return LoginColors.success;
            if (col == 2) return LoginColors.error;
            if (col == 3) return val.startsWith('-') ? LoginColors.error : LoginColors.success;
            return null;
          },
          footer: vm.revenueExpense.isNotEmpty ? [
            'Total',
            _fmt(vm.revenueExpense.last.runningRevenue),
            _fmt(vm.revenueExpense.last.runningExpense),
            _fmt(vm.revenueExpense.last.runningNetProfit),
          ] : null,
        );
      case ReportType.monthlyTrend:
        return _MonthlyTableView<MonthlyTrendEntry>(
          entries: vm.monthlyTrend, vm: vm,
          columns: const ['Month', 'Sales', 'Purchase', 'Received', 'Made'],
          rowBuilder: (e) => [
            _monthLabel(e.month), _fmt(e.salesAmount),
            _fmt(e.purchaseAmount), _fmt(e.paymentReceived), _fmt(e.paymentMade),
          ],
          colorBuilder: (col, _) {
            if (col == 1) return LoginColors.success;
            if (col == 2) return LoginColors.error;
            if (col == 3) return LoginColors.primary;
            return null;
          },
        );
      case ReportType.paymentModeDistribution:
        return _PaymentModeView(entries: vm.paymentModeDistribution, vm: vm);
      case ReportType.salesSummary:
        return _SummaryView(
          label: 'Sales Summary', vm: vm,
          rows: vm.salesSummary == null ? [] : [
            ['Total Orders', vm.salesSummary!.totalOrders.toString()],
            ['Total Amount', _fmt(vm.salesSummary!.totalAmount)],
            ['Total Paid', _fmt(vm.salesSummary!.totalPaid)],
            ['Total Due', _fmt(vm.salesSummary!.totalDue)],
            ['Avg Order Value', _fmt(vm.salesSummary!.avgOrderValue)],
          ],
        );
      case ReportType.purchaseSummary:
        return _SummaryView(
          label: 'Purchase Summary', vm: vm,
          rows: vm.purchaseSummary == null ? [] : [
            ['Total Orders', vm.purchaseSummary!.totalOrders.toString()],
            ['Total Amount', _fmt(vm.purchaseSummary!.totalAmount)],
            ['Total Paid', _fmt(vm.purchaseSummary!.totalPaid)],
            ['Total Due', _fmt(vm.purchaseSummary!.totalDue)],
            ['Avg Order Value', _fmt(vm.purchaseSummary!.avgOrderValue)],
          ],
        );
      case ReportType.salesByCustomer:
        return _PartyView(entries: vm.salesByCustomer, vm: vm, partyLabel: 'Customer');
      case ReportType.purchaseByVendor:
        return _PartyView(entries: vm.purchaseByVendor, vm: vm, partyLabel: 'Vendor');
      case ReportType.salesByItem:
        return _ItemAmountView(entries: vm.salesByItem, vm: vm);
      case ReportType.purchaseByItem:
        return _ItemAmountView(entries: vm.purchaseByItem, vm: vm);
      case ReportType.salesOrderFrequency:
        return _OrderFreqView(entries: vm.salesOrderFrequency, vm: vm);
      case ReportType.purchaseOrderFrequency:
        return _OrderFreqView(entries: vm.purchaseOrderFrequency, vm: vm);
      case ReportType.salesPaymentFrequency:
        return _PaymentFreqView(entries: vm.salesPaymentFrequency, vm: vm);
      case ReportType.purchasePaymentFrequency:
        return _PaymentFreqView(entries: vm.purchasePaymentFrequency, vm: vm);
      case ReportType.salesItemFrequency:
        return _ItemFreqView(entries: vm.salesItemFrequency, vm: vm);
      case ReportType.purchaseItemFrequency:
        return _ItemFreqView(entries: vm.purchaseItemFrequency, vm: vm);
      case ReportType.salesRunningOrderAmount:
        return _RunningAmountView(entries: vm.salesRunningOrderAmount, vm: vm);
      case ReportType.purchaseRunningOrderAmount:
        return _RunningAmountView(entries: vm.purchaseRunningOrderAmount, vm: vm);
      case ReportType.salesRunningPaymentAmount:
        return _RunningAmountView(entries: vm.salesRunningPaymentAmount, vm: vm);
      case ReportType.purchaseRunningPaymentAmount:
        return _RunningAmountView(entries: vm.purchaseRunningPaymentAmount, vm: vm);
      case ReportType.profitByItem:
        return _ProfitByItemView(entries: vm.profitByItem, vm: vm);
      case ReportType.topSellingItems:
        return _ItemAmountView(entries: vm.topSellingItems, vm: vm);
      case ReportType.topProfitableItems:
        return _ItemAmountView(entries: vm.topProfitableItems, vm: vm);
    }
  }
}

// ─── Shared header / empty ────────────────────────────────────────────────────

Widget _header(AnalyticsViewModel vm, String subtitle) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      children: [
        Text(subtitle,
            style: TextStyle(fontSize: 13, color: LoginColors.textSecondary)),
        Text(
          'From ${vm.formatDateDisplay(vm.startDate)} To ${vm.formatDateDisplay(vm.endDate)}',
          style: TextStyle(fontSize: 12, color: LoginColors.textSecondary),
        ),
      ],
    ),
  );
}

Widget _empty() => Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Text('No data available for selected period.',
            style: TextStyle(color: LoginColors.textSecondary),
            textAlign: TextAlign.center),
      ),
    );

// ─── KPI view ─────────────────────────────────────────────────────────────────

class _KpiView extends StatelessWidget {
  final DashboardKpi? kpi;
  final AnalyticsViewModel vm;
  const _KpiView({required this.kpi, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (kpi == null) return _empty();
    final rows = [
      ['Total Revenue', _fmt(kpi!.totalRevenue), true, null],
      ['Total Expense', _fmt(kpi!.totalExpense), false, null],
      ['Net Profit', _fmt(kpi!.netProfit), kpi!.netProfit >= 0, true],
      ['Sales Orders', kpi!.totalSalesOrders.toString(), null, null],
      ['Purchase Orders', kpi!.totalPurchaseOrders.toString(), null, null],
      ['Payments Received', kpi!.totalPaymentsReceived.toString(), null, null],
      ['Payments Made', kpi!.totalPaymentsMade.toString(), null, null],
      ['Avg Order Value', _fmt(kpi!.avgOrderValue), null, null],
      ['Outstanding Receivables', _fmt(kpi!.outstandingReceivables), null, null],
      ['Outstanding Payables', _fmt(kpi!.outstandingPayables), null, null],
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _header(vm, 'Key Performance Indicators'),
          _tableHead(['Metric', 'Value']),
          ...rows.map((r) {
            final isPos = r[2] as bool?;
            final isHL = r[3] as bool?;
            Color vc = LoginColors.textPrimary;
            if (isPos == true) vc = LoginColors.success;
            if (isPos == false) vc = LoginColors.error;
            return _row2(
              r[0] as String, r[1] as String,
              valueColor: vc,
              highlight: isHL == true,
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Generic monthly table ────────────────────────────────────────────────────

class _MonthlyTableView<T> extends StatelessWidget {
  final List<T> entries;
  final AnalyticsViewModel vm;
  final List<String> columns;
  final List<String> Function(T) rowBuilder;
  final Color? Function(int col, String val)? colorBuilder;
  final List<String>? footer;

  const _MonthlyTableView({
    required this.entries,
    required this.vm,
    required this.columns,
    required this.rowBuilder,
    this.colorBuilder,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return _empty();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _header(vm, columns.first),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTable(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder.all(color: LoginColors.border, width: 0.5),
      children: [
        _headerRow(columns),
        ...entries.map((e) {
          final cells = rowBuilder(e);
          return _dataRow(cells, colorBuilder);
        }),
        if (footer != null)
          _footerRow(footer!),
      ],
    );
  }

  TableRow _headerRow(List<String> cols) => TableRow(
        decoration: BoxDecoration(color: LoginColors.surfaceSecondary),
        children: cols
            .map((c) => _cell(c,
                bold: true, color: LoginColors.textPrimary, padding: 10))
            .toList(),
      );

  TableRow _dataRow(
    List<String> cells,
    Color? Function(int, String)? cb,
  ) =>
      TableRow(
        decoration: BoxDecoration(color: LoginColors.surface),
        children: cells.asMap().entries.map((e) {
          final color = cb?.call(e.key, e.value);
          return _cell(e.value, color: color ?? LoginColors.textPrimary);
        }).toList(),
      );

  TableRow _footerRow(List<String> cells) => TableRow(
        decoration: BoxDecoration(color: LoginColors.surfaceSecondary),
        children: cells
            .map((c) => _cell(c, bold: true, color: LoginColors.textPrimary))
            .toList(),
      );

  Widget _cell(String text,
      {bool bold = false, Color? color, double padding = 8}) =>
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: padding),
        child: Text(text,
            style: TextStyle(
              fontSize: 13,
              color: color ?? LoginColors.textPrimary,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            )),
      );
}

// ─── Summary (key-value) ──────────────────────────────────────────────────────

class _SummaryView extends StatelessWidget {
  final String label;
  final AnalyticsViewModel vm;
  final List<List<String>> rows;
  const _SummaryView({required this.label, required this.vm, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return _empty();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _header(vm, label),
          _tableHead(['Metric', 'Value']),
          ...rows.map((r) => _row2(r[0], r[1])),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Party (customer/vendor) ──────────────────────────────────────────────────

class _PartyView extends StatelessWidget {
  final List<PartyAnalyticsEntry> entries;
  final AnalyticsViewModel vm;
  final String partyLabel;
  const _PartyView({required this.entries, required this.vm, required this.partyLabel});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return _empty();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _header(vm, 'By $partyLabel'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: TableBorder.all(color: LoginColors.border, width: 0.5),
              children: [
                _hRow([partyLabel, 'Orders', 'Amount', 'Paid', 'Due']),
                ...entries.map((e) => _dRow([
                  e.partyName, e.totalOrders.toString(),
                  _fmt(e.totalAmount), _fmt(e.paidAmount), _fmt(e.dueAmount),
                ])),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  TableRow _hRow(List<String> cols) => TableRow(
        decoration: BoxDecoration(color: LoginColors.surfaceSecondary),
        children: cols.map((c) => _c(c, bold: true)).toList(),
      );
  TableRow _dRow(List<String> cells) => TableRow(
        decoration: BoxDecoration(color: LoginColors.surface),
        children: cells.map((c) => _c(c)).toList(),
      );
  Widget _c(String t, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(t,
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: LoginColors.textPrimary)),
      );
}

// ─── Item amount ──────────────────────────────────────────────────────────────

class _ItemAmountView extends StatelessWidget {
  final List<ItemAnalyticsEntry> entries;
  final AnalyticsViewModel vm;
  const _ItemAmountView({required this.entries, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return _empty();
    final totalQty = entries.fold(0.0, (s, e) => s + e.totalQuantity);
    final totalAmt = entries.fold(0.0, (s, e) => s + e.totalAmount);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _header(vm, 'By Item'),
          _tableHead(['Item Name', 'Qty', 'Amount']),
          ...entries.map((e) => _row3(
              e.itemName, e.totalQuantity.toStringAsFixed(2), _fmt(e.totalAmount))),
          _footerRow3(
              'Total', totalQty.toStringAsFixed(2), _fmt(totalAmt)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Order frequency ──────────────────────────────────────────────────────────

class _OrderFreqView extends StatelessWidget {
  final List<OrderFrequencyEntry> entries;
  final AnalyticsViewModel vm;
  const _OrderFreqView({required this.entries, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return _empty();
    final total = entries.fold(0, (s, e) => s + e.orderCount);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _header(vm, 'Order Frequency'),
          _tableHead(['Month', 'Orders']),
          ...entries.map((e) => _row2(_monthLabel(e.month), e.orderCount.toString())),
          _footerRow2('Total', total.toString()),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Payment frequency ────────────────────────────────────────────────────────

class _PaymentFreqView extends StatelessWidget {
  final List<PaymentFrequencyEntry> entries;
  final AnalyticsViewModel vm;
  const _PaymentFreqView({required this.entries, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return _empty();
    final total = entries.fold(0, (s, e) => s + e.paymentCount);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _header(vm, 'Payment Frequency'),
          _tableHead(['Month', 'Payments']),
          ...entries.map((e) => _row2(_monthLabel(e.month), e.paymentCount.toString())),
          _footerRow2('Total', total.toString()),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Item frequency ───────────────────────────────────────────────────────────

class _ItemFreqView extends StatelessWidget {
  final List<ItemFrequencyEntry> entries;
  final AnalyticsViewModel vm;
  const _ItemFreqView({required this.entries, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return _empty();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _header(vm, 'Item Frequency'),
          _tableHead(['Item', 'Qty', 'Orders']),
          ...entries.map((e) => _row3(
              e.itemName,
              e.totalQuantity.toStringAsFixed(2),
              e.orderCount.toString())),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Running amount ───────────────────────────────────────────────────────────

class _RunningAmountView extends StatelessWidget {
  final List<RunningAmountEntry> entries;
  final AnalyticsViewModel vm;
  const _RunningAmountView({required this.entries, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return _empty();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _header(vm, 'Running Amount'),
          _tableHead(['Month', 'Cumulative Amount']),
          ...entries.map((e) =>
              _row2(_monthLabel(e.month), _fmt(e.cumulativeAmount),
                  valueColor: LoginColors.primary)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Profit by item ───────────────────────────────────────────────────────────

class _ProfitByItemView extends StatelessWidget {
  final List<ProfitByItemEntry> entries;
  final AnalyticsViewModel vm;
  const _ProfitByItemView({required this.entries, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return _empty();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _header(vm, 'Profit by Item'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: TableBorder.all(color: LoginColors.border, width: 0.5),
              children: [
                _hRow(['Item', 'Sales', 'Purchase', 'Profit', 'Margin %']),
                ...entries.map((e) => _dRow([
                  e.itemName, _fmt(e.totalSalesAmount),
                  _fmt(e.totalPurchaseAmount), _fmt(e.profit),
                  '${e.profitMargin.toStringAsFixed(1)}%',
                ], profitColor: e.profit >= 0 ? LoginColors.success : LoginColors.error)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  TableRow _hRow(List<String> cols) => TableRow(
        decoration: BoxDecoration(color: LoginColors.surfaceSecondary),
        children: cols
            .map((c) => _c(c, bold: true, color: LoginColors.textPrimary))
            .toList(),
      );
  TableRow _dRow(List<String> cells, {Color? profitColor}) => TableRow(
        decoration: BoxDecoration(color: LoginColors.surface),
        children: cells.asMap().entries.map((e) {
          Color color = LoginColors.textPrimary;
          if ((e.key == 3 || e.key == 4) && profitColor != null) {
            color = profitColor;
          }
          return _c(e.value, color: color);
        }).toList(),
      );
  Widget _c(String t, {bool bold = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(t,
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: color ?? LoginColors.textPrimary)),
      );
}

// ─── Payment mode distribution ────────────────────────────────────────────────

class _PaymentModeView extends StatelessWidget {
  final List<PaymentModeEntry> entries;
  final AnalyticsViewModel vm;
  const _PaymentModeView({required this.entries, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return _empty();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _header(vm, 'Payment Mode Distribution'),
          _tableHead(['Mode', 'Amount', 'Txns', '%']),
          ...entries.map((e) => _row(e)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _row(PaymentModeEntry e) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        border: Border(
          bottom: BorderSide(color: LoginColors.border, width: 0.5),
          left: BorderSide(color: LoginColors.border, width: 0.5),
          right: BorderSide(color: LoginColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3,
              child: Text(_modeLabel(e.mode),
                  style: TextStyle(fontSize: 13, color: LoginColors.textPrimary))),
          Expanded(flex: 3,
              child: Text(_fmt(e.totalAmount),
                  style: TextStyle(fontSize: 13, color: LoginColors.success))),
          Expanded(flex: 1,
              child: Text(e.transactionCount.toString(),
                  style: TextStyle(fontSize: 13, color: LoginColors.textPrimary))),
          Expanded(flex: 2,
              child: Text('${e.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 13, color: LoginColors.primary,
                      fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  String _modeLabel(String mode) {
    switch (mode) {
      case 'BANK_TRANSFER': return 'Bank Transfer';
      case 'CASH':          return 'Cash';
      case 'UPI':           return 'UPI';
      case 'CHEQUE':        return 'Cheque';
      default:              return mode;
    }
  }
}

// ─── Shared row / header helpers ──────────────────────────────────────────────

Widget _tableHead(List<String> cols) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LoginColors.surfaceSecondary,
        border: Border.all(color: LoginColors.border, width: 0.5),
      ),
      child: Row(
        children: cols.asMap().entries.map((e) => Expanded(
          child: Text(e.value,
              textAlign: e.key == 0 ? TextAlign.left : TextAlign.right,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary)),
        )).toList(),
      ),
    );

Widget _row2(String label, String value,
    {Color? valueColor, bool highlight = false}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: highlight
            ? LoginColors.primary.withValues(alpha: 0.06)
            : LoginColors.surface,
        border: Border(
          bottom: BorderSide(color: LoginColors.border, width: 0.5),
          left: BorderSide(color: LoginColors.border, width: 0.5),
          right: BorderSide(color: LoginColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: LoginColors.textPrimary,
                    fontWeight:
                        highlight ? FontWeight.w700 : FontWeight.w400)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  color: valueColor ?? LoginColors.textPrimary,
                  fontWeight:
                      highlight ? FontWeight.w700 : FontWeight.w500)),
        ],
      ),
    );

Widget _row3(String c1, String c2, String c3) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        border: Border(
          bottom: BorderSide(color: LoginColors.border, width: 0.5),
          left: BorderSide(color: LoginColors.border, width: 0.5),
          right: BorderSide(color: LoginColors.border, width: 0.5),
        ),
      ),
      child: Row(children: [
        Expanded(child: Text(c1,
            style: TextStyle(fontSize: 13, color: LoginColors.textPrimary))),
        Text(c2,
            style: TextStyle(fontSize: 13, color: LoginColors.textSecondary)),
        const SizedBox(width: 24),
        Text(c3,
            style: TextStyle(
                fontSize: 13,
                color: LoginColors.textPrimary,
                fontWeight: FontWeight.w500)),
      ]),
    );

Widget _footerRow2(String l, String v) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LoginColors.surfaceSecondary,
        border: Border.all(color: LoginColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(child: Text(l,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary))),
          Text(v,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary)),
        ],
      ),
    );

Widget _footerRow3(String c1, String c2, String c3) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LoginColors.surfaceSecondary,
        border: Border.all(color: LoginColors.border, width: 0.5),
      ),
      child: Row(children: [
        Expanded(child: Text(c1,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary))),
        Text(c2,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: LoginColors.textSecondary)),
        const SizedBox(width: 24),
        Text(c3,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary)),
      ]),
    );
