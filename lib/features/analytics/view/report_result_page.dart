import 'dart:math' as math;
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
import 'package:coreflow/features/analytics/services/analytics_export_service.dart';

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
  return '$neg$buf.$dec';
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

class ReportResultPage extends StatefulWidget {
  final ReportType reportType;
  const ReportResultPage({super.key, required this.reportType});

  @override
  State<ReportResultPage> createState() => _ReportResultPageState();
}

class _ReportResultPageState extends State<ReportResultPage> {
  bool _graphView = false;
  bool _exporting = false;

  bool get _supportsGraph {
    switch (widget.reportType) {
      case ReportType.cashFlow:
      case ReportType.revenueExpense:
      case ReportType.monthlyTrend:
      case ReportType.salesOrderFrequency:
      case ReportType.purchaseOrderFrequency:
      case ReportType.salesRunningOrderAmount:
      case ReportType.purchaseRunningOrderAmount:
      case ReportType.salesRunningPaymentAmount:
      case ReportType.purchaseRunningPaymentAmount:
      case ReportType.paymentModeDistribution:
      case ReportType.salesByCustomer:
      case ReportType.purchaseByVendor:
      case ReportType.salesByItem:
      case ReportType.purchaseByItem:
      case ReportType.topSellingItems:
      case ReportType.topProfitableItems:
      case ReportType.profitByItem:
        return true;
      default:
        return false;
    }
  }

  Future<void> _export(String format, AnalyticsViewModel vm) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      if (format == 'pdf') {
        await AnalyticsExportService.exportPdf(context, vm, widget.reportType);
      } else {
        await AnalyticsExportService.exportCsv(context, vm, widget.reportType);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

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
        title: Text(widget.reportType.label,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
                letterSpacing: -0.3)),
        actions: [
          if (_supportsGraph)
            IconButton(
              tooltip: _graphView ? 'Table View' : 'Graph View',
              icon: Icon(
                _graphView ? Icons.table_rows_rounded : Icons.bar_chart_rounded,
                color: LoginColors.primary,
                size: 22,
              ),
              onPressed: () => setState(() => _graphView = !_graphView),
            ),
          _exporting
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : PopupMenuButton<String>(
                  icon: Icon(Icons.ios_share_rounded,
                      color: LoginColors.textPrimary, size: 22),
                  tooltip: 'Export',
                  onSelected: (v) => _export(v, vm),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'pdf',
                      child: Row(children: [
                        Icon(Icons.picture_as_pdf_rounded,
                            color: Color(0xFFEF4444), size: 20),
                        SizedBox(width: 10),
                        Text('Export as PDF'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'csv',
                      child: Row(children: [
                        Icon(Icons.table_chart_rounded,
                            color: Color(0xFF10B981), size: 20),
                        SizedBox(width: 10),
                        Text('Export as Excel / CSV'),
                      ]),
                    ),
                  ],
                ),
          const SizedBox(width: 4),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(vm),
    );
  }

  Widget _buildBody(AnalyticsViewModel vm) {
    if (_graphView && _supportsGraph) {
      return _GraphView(reportType: widget.reportType, vm: vm);
    }
    return _TableView(reportType: widget.reportType, vm: vm);
  }
}

// ─── Table view ───────────────────────────────────────────────────────────────

class _TableView extends StatelessWidget {
  final ReportType reportType;
  final AnalyticsViewModel vm;
  const _TableView({required this.reportType, required this.vm});

  @override
  Widget build(BuildContext context) {
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

// ─── Graph view ───────────────────────────────────────────────────────────────

class _GraphView extends StatelessWidget {
  final ReportType reportType;
  final AnalyticsViewModel vm;
  const _GraphView({required this.reportType, required this.vm});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(vm, reportType.label),
          const SizedBox(height: 12),
          _buildChart(),
        ],
      ),
    );
  }

  Widget _buildChart() {
    switch (reportType) {
      case ReportType.cashFlow:
        if (vm.cashFlow.isEmpty) return _empty();
        return _ChartCard(
          title: 'Cash Flow — Closing Balance',
          legend: const [_LegendDot(color: Color(0xFF6366F1), label: 'Closing Balance')],
          child: SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _SingleLineChartPainter(
                labels: vm.cashFlow.map((e) => e.month).toList(),
                values: vm.cashFlow.map((e) => e.closingBalance).toList(),
                color: LoginColors.primary,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      case ReportType.revenueExpense:
        if (vm.revenueExpense.isEmpty) return _empty();
        return _ChartCard(
          title: 'Revenue vs Expense',
          legend: const [
            _LegendDot(color: Color(0xFF6366F1), label: 'Revenue'),
            SizedBox(width: 10),
            _LegendDot(color: Color(0xFFF59E0B), label: 'Expense'),
          ],
          child: SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _DualLineChartPainter(
                labels: vm.revenueExpense.map((e) => e.month).toList(),
                values1: vm.revenueExpense.map((e) => e.revenue).toList(),
                values2: vm.revenueExpense.map((e) => e.expense).toList(),
                color1: LoginColors.primary,
                color2: const Color(0xFFF59E0B),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      case ReportType.monthlyTrend:
        if (vm.monthlyTrend.isEmpty) return _empty();
        return _ChartCard(
          title: 'Monthly Trend',
          legend: const [
            _LegendDot(color: Color(0xFF10B981), label: 'Sales'),
            SizedBox(width: 10),
            _LegendDot(color: Color(0xFFEF4444), label: 'Purchase'),
          ],
          child: SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _DualLineChartPainter(
                labels: vm.monthlyTrend.map((e) => e.month).toList(),
                values1: vm.monthlyTrend.map((e) => e.salesAmount).toList(),
                values2: vm.monthlyTrend.map((e) => e.purchaseAmount).toList(),
                color1: LoginColors.success,
                color2: LoginColors.error,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      case ReportType.salesOrderFrequency:
      case ReportType.purchaseOrderFrequency:
        final entries = reportType == ReportType.salesOrderFrequency
            ? vm.salesOrderFrequency
            : vm.purchaseOrderFrequency;
        if (entries.isEmpty) return _empty();
        return _ChartCard(
          title: 'Order Frequency',
          legend: const [_LegendDot(color: Color(0xFF6366F1), label: 'Orders')],
          child: SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _BarChartPainter(
                labels: entries.map((e) => e.month).toList(),
                values: entries.map((e) => e.orderCount.toDouble()).toList(),
                color: LoginColors.primary,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      case ReportType.salesRunningOrderAmount:
      case ReportType.purchaseRunningOrderAmount:
      case ReportType.salesRunningPaymentAmount:
      case ReportType.purchaseRunningPaymentAmount:
        final running = reportType == ReportType.salesRunningOrderAmount
            ? vm.salesRunningOrderAmount
            : reportType == ReportType.purchaseRunningOrderAmount
                ? vm.purchaseRunningOrderAmount
                : reportType == ReportType.salesRunningPaymentAmount
                    ? vm.salesRunningPaymentAmount
                    : vm.purchaseRunningPaymentAmount;
        if (running.isEmpty) return _empty();
        return _ChartCard(
          title: 'Cumulative Amount',
          legend: const [_LegendDot(color: Color(0xFF6366F1), label: 'Running Total')],
          child: SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _SingleLineChartPainter(
                labels: running.map((e) => e.month).toList(),
                values: running.map((e) => e.cumulativeAmount).toList(),
                color: LoginColors.primary,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      case ReportType.paymentModeDistribution:
        if (vm.paymentModeDistribution.isEmpty) return _empty();
        return _ChartCard(
          title: 'Payment Mode Distribution',
          legend: const [],
          child: SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _PieChartPainter(entries: vm.paymentModeDistribution),
              child: const SizedBox.expand(),
            ),
          ),
        );
      case ReportType.salesByCustomer:
      case ReportType.purchaseByVendor:
        final parties = reportType == ReportType.salesByCustomer
            ? vm.salesByCustomer
            : vm.purchaseByVendor;
        if (parties.isEmpty) return _empty();
        final topP = parties.length > 8 ? parties.sublist(0, 8) : parties;
        return _ChartCard(
          title: reportType == ReportType.salesByCustomer
              ? 'Sales by Customer' : 'Purchase by Vendor',
          legend: const [_LegendDot(color: Color(0xFF6366F1), label: 'Amount')],
          child: SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _BarChartPainter(
                labels: topP.map((e) => e.partyName).toList(),
                values: topP.map((e) => e.totalAmount).toList(),
                color: LoginColors.primary,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      case ReportType.salesByItem:
      case ReportType.purchaseByItem:
      case ReportType.topSellingItems:
      case ReportType.topProfitableItems:
        final items = reportType == ReportType.salesByItem
            ? vm.salesByItem
            : reportType == ReportType.purchaseByItem
                ? vm.purchaseByItem
                : reportType == ReportType.topSellingItems
                    ? vm.topSellingItems
                    : vm.topProfitableItems;
        if (items.isEmpty) return _empty();
        final topI = items.length > 8 ? items.sublist(0, 8) : items;
        return _ChartCard(
          title: reportType.label,
          legend: const [_LegendDot(color: Color(0xFF10B981), label: 'Amount')],
          child: SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _BarChartPainter(
                labels: topI.map((e) => e.itemName).toList(),
                values: topI.map((e) => e.totalAmount).toList(),
                color: LoginColors.success,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      case ReportType.profitByItem:
        if (vm.profitByItem.isEmpty) return _empty();
        final topPr = vm.profitByItem.length > 8
            ? vm.profitByItem.sublist(0, 8)
            : vm.profitByItem;
        return _ChartCard(
          title: 'Profit by Item',
          legend: const [_LegendDot(color: Color(0xFF10B981), label: 'Profit')],
          child: SizedBox(
            height: 220,
            child: CustomPaint(
              painter: _BarChartPainter(
                labels: topPr.map((e) => e.itemName).toList(),
                values: topPr.map((e) => e.profit).toList(),
                color: LoginColors.success,
                negativeColor: LoginColors.error,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      default:
        return _empty();
    }
  }
}

// ─── Chart Helpers ────────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final List<Widget> legend;
  final Widget child;
  const _ChartCard({required this.title, required this.legend, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: LoginColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: LoginColors.shadowLight.withValues(alpha: 0.08),
            blurRadius: 8, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                      color: LoginColors.textPrimary))),
              if (legend.isNotEmpty) Row(children: legend),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, color: LoginColors.textSecondary)),
    ]);
  }
}

// ─── Chart Painters ───────────────────────────────────────────────────────────

double _niceMax(double rawMax) {
  if (rawMax <= 0) return 100;
  final mag = math.pow(10, (math.log(rawMax.abs()) / math.ln10).floor()).toDouble();
  final norm = rawMax / mag;
  final nice = norm <= 1.5 ? 1.5 : norm <= 2 ? 2 : norm <= 5 ? 5 : 10;
  return nice * mag;
}

String _axisLabel(double v) {
  if (v == 0) return '0';
  if (v.abs() >= 1e7) return '${(v / 1e7).toStringAsFixed(0)}Cr';
  if (v.abs() >= 1e5) return '${(v / 1e5).toStringAsFixed(0)}L';
  if (v.abs() >= 1e3) return '${(v / 1e3).toStringAsFixed(0)}K';
  return v.toStringAsFixed(0);
}

String _monthShort(String s) {
  const m = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  final p = s.split('-');
  if (p.length < 2) return s.length > 7 ? '${s.substring(0, 7)}…' : s;
  final idx = int.tryParse(p[1]) ?? 0;
  return m[idx.clamp(0, 12)];
}

class _SingleLineChartPainter extends CustomPainter {
  final List<String> labels;
  final List<double> values;
  final Color color;
  const _SingleLineChartPainter({
    required this.labels, required this.values, required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.fold<double>(0, math.max);
    final chartMax = _niceMax(maxV);
    if (chartMax == 0) return;

    const yAxisW = 48.0;
    const labelH = 18.0;
    final chartW = size.width - yAxisW;
    final chartH = size.height - labelH;
    final labelStyle = TextStyle(fontSize: 9, color: LoginColors.textSecondary);
    final gridPaint = Paint()
      ..color = LoginColors.border.withValues(alpha: 0.5) ..strokeWidth = 0.5;

    for (int t = 0; t <= 4; t++) {
      final val = chartMax * t / 4;
      final y = chartH - (val / chartMax) * chartH;
      canvas.drawLine(Offset(yAxisW, y), Offset(size.width, y), gridPaint);
      final tp = TextPainter(
          text: TextSpan(text: _axisLabel(val), style: labelStyle),
          textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(yAxisW - tp.width - 4, y - tp.height / 2));
    }

    double xOf(int i) =>
        yAxisW + (values.length == 1 ? chartW / 2 : i * chartW / (values.length - 1));
    double yOf(double v) => chartH - (v.clamp(0, chartMax) / chartMax) * chartH;

    if (values.length >= 2) {
      final fill = Path()..moveTo(xOf(0), yOf(values[0]));
      for (int i = 1; i < values.length; i++) { fill.lineTo(xOf(i), yOf(values[i])); }
      fill..lineTo(xOf(values.length - 1), chartH)..lineTo(xOf(0), chartH)..close();
      canvas.drawPath(fill, Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
    }

    final linePaint = Paint()
      ..color = color ..strokeWidth = 2.5 ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round ..strokeJoin = StrokeJoin.round;
    final path = Path();
    for (int i = 0; i < values.length; i++) {
      if (i == 0) { path.moveTo(xOf(i), yOf(values[i])); }
      else { path.lineTo(xOf(i), yOf(values[i])); }
    }
    canvas.drawPath(path, linePaint);

    final dot = Paint()..style = PaintingStyle.fill ..color = color;
    for (int i = 0; i < values.length; i++) {
      canvas.drawCircle(Offset(xOf(i), yOf(values[i])), 3, dot);
      if (values.length <= 8 || i % 2 == 0 || i == values.length - 1) {
        final tp = TextPainter(
          text: TextSpan(text: _monthShort(labels[i]), style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(xOf(i) - tp.width / 2, chartH + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_SingleLineChartPainter old) => old.values != values;
}

class _DualLineChartPainter extends CustomPainter {
  final List<String> labels;
  final List<double> values1;
  final List<double> values2;
  final Color color1;
  final Color color2;
  const _DualLineChartPainter({
    required this.labels, required this.values1, required this.values2,
    required this.color1, required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values1.isEmpty) return;
    final maxV = [...values1, ...values2].fold<double>(0, math.max);
    final chartMax = _niceMax(maxV);
    if (chartMax == 0) return;

    const yAxisW = 48.0;
    const labelH = 18.0;
    final chartW = size.width - yAxisW;
    final chartH = size.height - labelH;
    final n = values1.length;
    final labelStyle = TextStyle(fontSize: 9, color: LoginColors.textSecondary);
    final gridPaint = Paint()
      ..color = LoginColors.border.withValues(alpha: 0.5) ..strokeWidth = 0.5;

    for (int t = 0; t <= 4; t++) {
      final val = chartMax * t / 4;
      final y = chartH - (val / chartMax) * chartH;
      canvas.drawLine(Offset(yAxisW, y), Offset(size.width, y), gridPaint);
      final tp = TextPainter(
          text: TextSpan(text: _axisLabel(val), style: labelStyle),
          textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(yAxisW - tp.width - 4, y - tp.height / 2));
    }

    double xOf(int i) => yAxisW + (n == 1 ? chartW / 2 : i * chartW / (n - 1));
    double yOf(double v) => chartH - (v.clamp(0, chartMax) / chartMax) * chartH;

    void drawLine(List<double> vals, Color c) {
      final paint = Paint()
        ..color = c ..strokeWidth = 2.5 ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round ..strokeJoin = StrokeJoin.round;
      final p = Path();
      for (int i = 0; i < vals.length; i++) {
        if (i == 0) { p.moveTo(xOf(i), yOf(vals[i])); }
        else { p.lineTo(xOf(i), yOf(vals[i])); }
      }
      canvas.drawPath(p, paint);
      final dot = Paint()..style = PaintingStyle.fill ..color = c;
      for (int i = 0; i < vals.length; i++) {
        canvas.drawCircle(Offset(xOf(i), yOf(vals[i])), 3, dot);
      }
    }

    drawLine(values1, color1);
    drawLine(values2, color2);

    for (int i = 0; i < n; i++) {
      if (n <= 8 || i % 2 == 0 || i == n - 1) {
        final tp = TextPainter(
          text: TextSpan(text: _monthShort(labels[i]), style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(xOf(i) - tp.width / 2, chartH + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_DualLineChartPainter old) => old.values1 != values1;
}

class _BarChartPainter extends CustomPainter {
  final List<String> labels;
  final List<double> values;
  final Color color;
  final Color? negativeColor;
  const _BarChartPainter({
    required this.labels, required this.values, required this.color,
    this.negativeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.map((v) => v.abs()).fold<double>(0, math.max);
    final chartMax = _niceMax(maxV);
    if (chartMax == 0) return;

    const yAxisW = 48.0;
    const labelH = 18.0;
    final chartW = size.width - yAxisW;
    final chartH = size.height - labelH;
    final labelStyle = TextStyle(fontSize: 9, color: LoginColors.textSecondary);
    final gridPaint = Paint()
      ..color = LoginColors.border.withValues(alpha: 0.5) ..strokeWidth = 0.5;

    for (int t = 0; t <= 4; t++) {
      final val = chartMax * t / 4;
      final y = chartH - (val / chartMax) * chartH;
      canvas.drawLine(Offset(yAxisW, y), Offset(size.width, y), gridPaint);
      final tp = TextPainter(
          text: TextSpan(text: _axisLabel(val), style: labelStyle),
          textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(yAxisW - tp.width - 4, y - tp.height / 2));
    }

    const barGap = 4.0;
    final barW = (chartW - barGap * (values.length - 1)) / values.length;

    for (int i = 0; i < values.length; i++) {
      final v = values[i];
      final barH = (v.abs() / chartMax) * chartH;
      final x = yAxisW + i * (barW + barGap);
      canvas.drawRRect(
        RRect.fromLTRBR(x, chartH - barH, x + barW, chartH, const Radius.circular(3)),
        Paint()
          ..color = (v < 0 && negativeColor != null) ? negativeColor! : color
          ..style = PaintingStyle.fill,
      );
      if (values.length <= 8 || i % 2 == 0 || i == values.length - 1) {
        final lbl = _monthShort(labels[i]);
        final tp = TextPainter(
          text: TextSpan(text: lbl, style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + barW / 2 - tp.width / 2, chartH + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.values != values;
}

class _PieChartPainter extends CustomPainter {
  final List<PaymentModeEntry> entries;
  const _PieChartPainter({required this.entries});

  static const _colors = [
    Color(0xFF6366F1), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFFEF4444), Color(0xFF3B82F6), Color(0xFF8B5CF6),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;
    final cx = size.width / 2;
    final cy = (size.height - 20) / 2;
    final radius = math.min(cx, cy) - 10;
    double startAngle = -math.pi / 2;

    for (int i = 0; i < entries.length; i++) {
      final sweep = (entries[i].percentage / 100) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle, sweep, true,
        Paint()..color = _colors[i % _colors.length] ..style = PaintingStyle.fill,
      );
      if (entries[i].percentage > 5) {
        final mid = startAngle + sweep / 2;
        final lx = cx + (radius * 0.65) * math.cos(mid);
        final ly = cy + (radius * 0.65) * math.sin(mid);
        final tp = TextPainter(
          text: TextSpan(
            text: '${entries[i].percentage.toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 10, color: Colors.white,
                fontWeight: FontWeight.w700),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
      }
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter old) => old.entries != entries;
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
            return _row2(r[0] as String, r[1] as String,
                valueColor: vc, highlight: isHL == true);
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
    required this.entries, required this.vm, required this.columns,
    required this.rowBuilder, this.colorBuilder, this.footer,
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
            child: _buildTable(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      border: TableBorder.all(color: LoginColors.border, width: 0.5),
      children: [
        _headerRow(columns),
        ...entries.map((e) => _dataRow(rowBuilder(e), colorBuilder)),
        if (footer != null) _footerRow(footer!),
      ],
    );
  }

  TableRow _headerRow(List<String> cols) => TableRow(
        decoration: BoxDecoration(color: LoginColors.surfaceSecondary),
        children: cols
            .map((c) => _cell(c, bold: true, color: LoginColors.textPrimary, padding: 10))
            .toList(),
      );

  TableRow _dataRow(List<String> cells, Color? Function(int, String)? cb) =>
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

  Widget _cell(String text, {bool bold = false, Color? color, double padding = 8}) =>
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: padding),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                color: color ?? LoginColors.textPrimary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      );
}

// ─── Summary ──────────────────────────────────────────────────────────────────

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

// ─── Party ────────────────────────────────────────────────────────────────────

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
        children: cells.map(_c).toList(),
      );
  Widget _c(String t, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(t, style: TextStyle(fontSize: 13,
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
          _footerRow3('Total', totalQty.toStringAsFixed(2), _fmt(totalAmt)),
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
              e.itemName, e.totalQuantity.toStringAsFixed(2), e.orderCount.toString())),
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
                  e.itemName, _fmt(e.totalSalesAmount), _fmt(e.totalPurchaseAmount),
                  _fmt(e.profit), '${e.profitMargin.toStringAsFixed(1)}%',
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
        children: cols.map((c) => _c(c, bold: true, color: LoginColors.textPrimary)).toList(),
      );
  TableRow _dRow(List<String> cells, {Color? profitColor}) => TableRow(
        decoration: BoxDecoration(color: LoginColors.surface),
        children: cells.asMap().entries.map((e) {
          Color color = LoginColors.textPrimary;
          if ((e.key == 3 || e.key == 4) && profitColor != null) color = profitColor;
          return _c(e.value, color: color);
        }).toList(),
      );
  Widget _c(String t, {bool bold = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(t, style: TextStyle(fontSize: 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: color ?? LoginColors.textPrimary)),
      );
}

// ─── Payment mode ─────────────────────────────────────────────────────────────

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
          ...entries.map(_modeRow),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _modeRow(PaymentModeEntry e) => Container(
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
          Expanded(flex: 3, child: Text(_modeLabel(e.mode),
              style: TextStyle(fontSize: 13, color: LoginColors.textPrimary))),
          Expanded(flex: 3, child: Text(_fmt(e.totalAmount),
              style: TextStyle(fontSize: 13, color: LoginColors.success))),
          Expanded(flex: 1, child: Text(e.transactionCount.toString(),
              style: TextStyle(fontSize: 13, color: LoginColors.textPrimary))),
          Expanded(flex: 2, child: Text('${e.percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 13, color: LoginColors.primary,
                  fontWeight: FontWeight.w600))),
        ]),
      );

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
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
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
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 13,
            color: LoginColors.textPrimary,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w400))),
        Text(value, style: TextStyle(fontSize: 13,
            color: valueColor ?? LoginColors.textPrimary,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500)),
      ]),
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
        Expanded(child: Text(c1, style: TextStyle(fontSize: 13, color: LoginColors.textPrimary))),
        Text(c2, style: TextStyle(fontSize: 13, color: LoginColors.textSecondary)),
        const SizedBox(width: 24),
        Text(c3, style: TextStyle(fontSize: 13, color: LoginColors.textPrimary,
            fontWeight: FontWeight.w500)),
      ]),
    );

Widget _footerRow2(String l, String v) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LoginColors.surfaceSecondary,
        border: Border.all(color: LoginColors.border, width: 0.5),
      ),
      child: Row(children: [
        Expanded(child: Text(l, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: LoginColors.textPrimary))),
        Text(v, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: LoginColors.textPrimary)),
      ]),
    );

Widget _footerRow3(String c1, String c2, String c3) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LoginColors.surfaceSecondary,
        border: Border.all(color: LoginColors.border, width: 0.5),
      ),
      child: Row(children: [
        Expanded(child: Text(c1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: LoginColors.textPrimary))),
        Text(c2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: LoginColors.textSecondary)),
        const SizedBox(width: 24),
        Text(c3, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: LoginColors.textPrimary)),
      ]),
    );
