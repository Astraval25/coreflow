import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/analytics/cash_flow.dart';
import 'package:coreflow/domain/model/analytics/dashboard_kpi.dart';
import 'package:coreflow/domain/model/analytics/revenue_expense.dart';

// ─── Formatting ───────────────────────────────────────────────────────────────

String _full(double v) {
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

String _axisLabel(double v) {
  if (v == 0) return '0';
  if (v.abs() >= 1e7) return '${(v / 1e7).toStringAsFixed(0)}Cr';
  if (v.abs() >= 1e5) return '${(v / 1e5).toStringAsFixed(0)}L';
  if (v.abs() >= 1e3) return '${(v / 1e3).toStringAsFixed(0)}K';
  return v.toStringAsFixed(0);
}

String _monthShort(String yyyyMm) {
  const m = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final p = yyyyMm.split('-');
  if (p.length < 2) return yyyyMm;
  final idx = int.tryParse(p[1]) ?? 0;
  return m[idx.clamp(0, 12)];
}

String _monthFull(String yyyyMm) {
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final p = yyyyMm.split('-');
  if (p.length < 2) return yyyyMm;
  final m = int.tryParse(p[1]) ?? 0;
  return '${months[m.clamp(0, 12)]} ${p[0]}';
}

double _niceMax(double rawMax) {
  if (rawMax <= 0) return 100;
  final magnitude =
      math.pow(10, (math.log(rawMax) / math.ln10).floor()).toDouble();
  final normalized = rawMax / magnitude;
  final nice =
      normalized <= 1.5 ? 1.5 : normalized <= 2 ? 2 : normalized <= 5 ? 5 : 10;
  return nice * magnitude;
}

List<double> _niceTicks(double max, int count) {
  final step = max / (count - 1);
  return List.generate(count, (i) => step * i);
}

// ─── Section Root ─────────────────────────────────────────────────────────────

class DashboardAnalyticsSection extends StatefulWidget {
  final DashboardKpi? kpi;
  final List<CashFlowEntry> cashFlow;
  final List<RevenueExpenseEntry> revenueExpense;
  final bool isLoading;
  final Future<void> Function(String start, String end)? onPeriodChanged;

  const DashboardAnalyticsSection({
    super.key,
    required this.kpi,
    required this.cashFlow,
    required this.revenueExpense,
    required this.isLoading,
    this.onPeriodChanged,
  });

  @override
  State<DashboardAnalyticsSection> createState() => _DashboardAnalyticsSectionState();
}

class _DashboardAnalyticsSectionState extends State<DashboardAnalyticsSection> {
  PeriodOption _selectedPeriod = PeriodOption.currentYear;
  bool _periodLoading = false;

  Future<void> _applyPeriod(PeriodOption option) async {
    setState(() {
      _selectedPeriod = option;
      _periodLoading = true;
    });
    final dates = _periodDates(option);
    await widget.onPeriodChanged?.call(dates.$1, dates.$2);
    if (mounted) {
      setState(() => _periodLoading = false);
    }
  }

  void _showPeriodSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: LoginColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: PeriodOption.values.map((option) {
              final isSelected = option == _selectedPeriod;
              return ListTile(
                title: Text(
                  option.label,
                  style: TextStyle(
                    color: isSelected
                        ? LoginColors.primary
                        : LoginColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: LoginColors.primary, size: 20)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  _applyPeriod(option);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) return const _AnalyticsSkeleton();
    if (widget.kpi == null && widget.cashFlow.isEmpty && widget.revenueExpense.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Analytics',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: LoginColors.textPrimary)),
              GestureDetector(
                onTap: _periodLoading ? null : _showPeriodSelector,
                child: _periodLoading
                    ? _periodBadgeLoading()
                    : _periodBadge(_selectedPeriod.label),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (widget.kpi != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LoginColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: LoginColors.border.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: LoginColors.shadowLight.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _FinancialSummarySection(kpi: widget.kpi!),
          ),
        if (widget.cashFlow.isNotEmpty || widget.onPeriodChanged != null) ...[
          const SizedBox(height: 16),
          _CashFlowSection(entries: widget.cashFlow),
        ],
        if (widget.revenueExpense.isNotEmpty || widget.onPeriodChanged != null) ...[
          const SizedBox(height: 16),
          _IncomeExpenseSection(entries: widget.revenueExpense),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Financial Summary Section ────────────────────────────────────────────────

class _FinancialSummarySection extends StatelessWidget {
  final DashboardKpi kpi;
  const _FinancialSummarySection({required this.kpi});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Receivables + Payables
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Receivables',
                    style: TextStyle(
                        fontSize: 12, color: LoginColors.textSecondary)),
                const SizedBox(height: 2),
                Row(children: [
                  Flexible(
                    child: Text(_full(kpi.outstandingReceivables),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B))),
                  ),
                    const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: Color(0xFF64748B)),
                ]),
                const SizedBox(height: 20),
                Text('Total Payables',
                    style: TextStyle(
                        fontSize: 12, color: LoginColors.textSecondary)),
                const SizedBox(height: 2),
                Row(children: [
                  Flexible(
                    child: Text(_full(kpi.outstandingPayables),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B))),
                  ),
                    const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: Color(0xFF64748B)),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Right: Sales + Purchase order counts
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _CountCard(
                count: kpi.totalSalesOrders,
                label: 'Sales',
                bgColor: const Color(0xFFFFF1F2),
                borderColor: const Color(0xFFFECDD3),
              ),
              const SizedBox(height: 8),
              _CountCard(
                count: kpi.totalPurchaseOrders,
                label: 'Purchase',
                bgColor: const Color(0xFFFFF7ED),
                borderColor: const Color(0xFFFED7AA),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountCard extends StatelessWidget {
  final int count;
  final String label;
  final Color bgColor;
  final Color borderColor;

  const _CountCard({
    required this.count,
    required this.label,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(count.toString(),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 2),
                Text(label,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    maxLines: 2),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

// ─── Period Options ──────────────────────────────────────────────────────────

enum PeriodOption {
  currentMonth('This Month'),
  currentQuarter('This Quarter'),
  currentHalf('This Half'),
  currentYear('This Financial Year'),
  previousYear('Prev Financial Year');

  final String label;
  const PeriodOption(this.label);
}

/// Returns (startDate, endDate) as 'YYYY-MM-DD' strings for a given period.
(String, String) _periodDates(PeriodOption option) {
  final now = DateTime.now();
  String fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // Indian financial year: April 1 – March 31
  final fyStart = now.month >= 4
      ? DateTime(now.year, 4, 1)
      : DateTime(now.year - 1, 4, 1);
  final fyEnd = DateTime(fyStart.year + 1, 3, 31);
  final prevFyStart = DateTime(fyStart.year - 1, 4, 1);
  final prevFyEnd = DateTime(fyStart.year, 3, 31);

  switch (option) {
    case PeriodOption.currentMonth:
      return (
        fmt(DateTime(now.year, now.month, 1)),
        fmt(DateTime(now.year, now.month + 1, 0)),
      );
    case PeriodOption.currentQuarter:
      // Q within FY: Apr-Jun, Jul-Sep, Oct-Dec, Jan-Mar
      final monthInFy = (now.month - 4 + 12) % 12; // 0-11
      final q = monthInFy ~/ 3; // 0-3
      final qStartMonth = (q * 3 + 4 - 1) % 12 + 1;
      final qStartYear = qStartMonth <= 3 ? fyStart.year + 1 : fyStart.year;
      final qStart = DateTime(qStartYear, qStartMonth, 1);
      final qEnd = DateTime(qStartYear, qStartMonth + 3, 0);
      return (fmt(qStart), fmt(qEnd));
    case PeriodOption.currentHalf:
      // H1: Apr-Sep, H2: Oct-Mar
      final isH1 = now.month >= 4 && now.month <= 9;
      if (isH1) {
        return (
          fmt(DateTime(fyStart.year, 4, 1)),
          fmt(DateTime(fyStart.year, 9, 30)),
        );
      } else {
        return (
          fmt(DateTime(fyStart.year, 10, 1)),
          fmt(DateTime(fyStart.year + 1, 3, 31)),
        );
      }
    case PeriodOption.currentYear:
      return (fmt(fyStart), fmt(fyEnd));
    case PeriodOption.previousYear:
      return (fmt(prevFyStart), fmt(prevFyEnd));
  }
}

// ─── Cash Flow Section ────────────────────────────────────────────────────────

class _CashFlowSection extends StatefulWidget {
  final List<CashFlowEntry> entries;
  const _CashFlowSection({required this.entries});

  @override
  State<_CashFlowSection> createState() => _CashFlowSectionState();
}

class _CashFlowSectionState extends State<_CashFlowSection> {
  int? _selectedIdx;
  Timer? _dismissTimer;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _selectPoint(int idx) {
    _dismissTimer?.cancel();
    setState(() => _selectedIdx = idx);
    _dismissTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _selectedIdx = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;
    final maxClose =
        entries.map((e) => e.closingBalance).fold<double>(0, math.max);
    final chartMax = _niceMax(maxClose);
    final ticks = _niceTicks(chartMax, 5);

    final first = entries.first;
    final last = entries.last;
    final totalIncoming = entries.fold<double>(0, (s, e) => s + e.incoming);
    final totalOutgoing = entries.fold<double>(0, (s, e) => s + e.outgoing);

    return Container(
      decoration: BoxDecoration(
        color: LoginColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: LoginColors.shadowLight.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Icon(Icons.radio_button_checked_outlined,
                    size: 16, color: LoginColors.textSecondary),
                const SizedBox(width: 6),
                Text('Cash Flow',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Chart
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Y-axis
                SizedBox(
                  width: 46,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: ticks.reversed
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(_axisLabel(t),
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: LoginColors.textSecondary)),
                            ))
                        .toList(),
                  ),
                ),
                // Chart area
                Expanded(
                  child: LayoutBuilder(
                    builder: (ctx, constraints) {
                      return GestureDetector(
                        onTapDown: (details) {
                          if (entries.isEmpty) return;
                          final chartW = constraints.maxWidth;
                          final x = details.localPosition.dx;
                          final idx =
                              ((x / chartW) * entries.length).floor().clamp(
                                    0,
                                    entries.length - 1,
                                  );
                          _selectPoint(idx);
                        },
                        child: Stack(
                          children: [
                            CustomPaint(
                              painter: _CashFlowLinePainter(
                                entries: entries,
                                chartMax: chartMax,
                                ticks: ticks,
                                selectedIndex: _selectedIdx,
                              ),
                              child: const SizedBox.expand(),
                            ),
                            if (_selectedIdx != null)
                              _Tooltip(entry: entries[_selectedIdx!]),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: LoginColors.border, height: 1),
          // Summary rows
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Cash as on ${_startDateStr(first.month)}',
                  value: _full(first.openingBalance),
                  labelColor: LoginColors.textPrimary,
                ),
                const SizedBox(height: 6),
                _SummaryRow(
                  label: '+ Incoming',
                  value: _full(totalIncoming),
                  labelColor: LoginColors.success,
                ),
                const SizedBox(height: 6),
                _SummaryRow(
                  label: '- Outgoing',
                  value: _full(totalOutgoing),
                  labelColor: LoginColors.error,
                ),
                const SizedBox(height: 6),
                _SummaryRow(
                  label: '= Cash as on ${_endDateStr(last.month)}',
                  value: _full(last.closingBalance),
                  labelColor: LoginColors.primary,
                  bold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _startDateStr(String yyyyMm) {
    final p = yyyyMm.split('-');
    if (p.length < 2) return yyyyMm;
    return '01/${p[1]}/${p[0]}';
  }

  String _endDateStr(String yyyyMm) {
    final p = yyyyMm.split('-');
    if (p.length < 2) return yyyyMm;
    final year = int.tryParse(p[0]) ?? 2024;
    final month = int.tryParse(p[1]) ?? 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return '${lastDay.toString().padLeft(2, '0')}/${p[1]}/${p[0]}';
  }
}

class _Tooltip extends StatelessWidget {
  final CashFlowEntry entry;
  const _Tooltip({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: LoginColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: LoginColors.border),
          boxShadow: [
            BoxShadow(
              color: LoginColors.shadowLight.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_monthFull(entry.month),
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary)),
            const SizedBox(height: 6),
            _ttRow('Opening Bal.', _full(entry.openingBalance),
                LoginColors.textPrimary),
            _ttRow('Income', _full(entry.incoming), LoginColors.success),
            _ttRow('Outgoing', _full(entry.outgoing), LoginColors.error),
            _ttRow('Ending Bal.', _full(entry.closingBalance),
                LoginColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _ttRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 84,
            child: Text(label,
                style:
                    TextStyle(fontSize: 12, color: LoginColors.textSecondary)),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.labelColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: labelColor,
                  fontWeight:
                      bold ? FontWeight.w700 : FontWeight.w500)),
        ),
        const SizedBox(width: 8),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                color: LoginColors.textPrimary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
      ],
    );
  }
}

class _CashFlowLinePainter extends CustomPainter {
  final List<CashFlowEntry> entries;
  final double chartMax;
  final List<double> ticks;
  final int? selectedIndex;

  const _CashFlowLinePainter({
    required this.entries,
    required this.chartMax,
    required this.ticks,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty || chartMax == 0) return;

    const labelH = 18.0;
    final chartH = size.height - labelH;

    // Grid lines
    final gridPaint = Paint()
      ..color = LoginColors.border.withValues(alpha: 0.6)
      ..strokeWidth = 0.5;
    for (final tick in ticks) {
      final gy = chartH - (tick / chartMax) * chartH;
      canvas.drawLine(Offset(0, gy), Offset(size.width, gy), gridPaint);
    }

    double xOf(int i) {
      if (entries.length == 1) return size.width / 2;
      return i * size.width / (entries.length - 1);
    }

    double yOf(double val) => chartH - (val.clamp(0, chartMax) / chartMax) * chartH;

    // Fill
    if (entries.length >= 2) {
      final fill = Path()..moveTo(xOf(0), yOf(entries[0].closingBalance));
      for (int i = 1; i < entries.length; i++) {
        fill.lineTo(xOf(i), yOf(entries[i].closingBalance));
      }
      fill
        ..lineTo(xOf(entries.length - 1), chartH)
        ..lineTo(xOf(0), chartH)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              LoginColors.primary.withValues(alpha: 0.15),
              LoginColors.primary.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
      );
    }

    // Line
    final linePaint = Paint()
      ..color = LoginColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final linePath = Path();
    for (int i = 0; i < entries.length; i++) {
      final x = xOf(i);
      final y = yOf(entries[i].closingBalance);
      if (i == 0) { linePath.moveTo(x, y); } else { linePath.lineTo(x, y); }
    }
    canvas.drawPath(linePath, linePaint);

    // Labels + dots
    final labelStyle = TextStyle(fontSize: 9, color: LoginColors.textSecondary);
    final dotPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < entries.length; i++) {
      final x = xOf(i);
      final y = yOf(entries[i].closingBalance);

      if (selectedIndex == i) {
        canvas.drawLine(Offset(x, 0), Offset(x, chartH),
            Paint()
              ..color = LoginColors.primary.withValues(alpha: 0.25)
              ..strokeWidth = 1);
        dotPaint.color = LoginColors.primary;
        canvas.drawCircle(Offset(x, y), 5, dotPaint);
        dotPaint.color = Colors.white;
        canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
      } else {
        dotPaint.color = LoginColors.primary;
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }

      if (entries.length <= 6 || i % 2 == 0 || i == entries.length - 1) {
        final tp = TextPainter(
          text: TextSpan(text: _monthShort(entries[i].month), style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, chartH + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_CashFlowLinePainter old) =>
      old.entries != entries || old.selectedIndex != selectedIndex;
}

// ─── Income & Expense Section ─────────────────────────────────────────────────

class _IncomeExpenseSection extends StatefulWidget {
  final List<RevenueExpenseEntry> entries;
  const _IncomeExpenseSection({required this.entries});

  @override
  State<_IncomeExpenseSection> createState() => _IncomeExpenseSectionState();
}

class _IncomeExpenseSectionState extends State<_IncomeExpenseSection> {
  Widget build(BuildContext context) {
    final entries = widget.entries;
    final maxVal = entries
        .expand((e) => [e.revenue, e.expense])
        .fold<double>(0, math.max);
    final chartMax = _niceMax(maxVal);
    final ticks = _niceTicks(chartMax, 5);

    final totalRevenue =
        entries.isEmpty ? 0.0 : entries.last.runningRevenue;
    final totalExpense =
        entries.isEmpty ? 0.0 : entries.last.runningExpense;

    return Container(
      decoration: BoxDecoration(
        color: LoginColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: LoginColors.shadowLight.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: LoginColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Income Vs Expense',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: LoginColors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Chart
          SizedBox(
            height: 200,
            child: Row(
              children: [
                SizedBox(
                  width: 46,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: ticks.reversed
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(_axisLabel(t),
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: LoginColors.textSecondary)),
                            ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: CustomPaint(
                    painter: _IncomeExpenseBarPainter(
                      entries: entries,
                      chartMax: chartMax,
                      ticks: ticks,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Divider(color: LoginColors.border, height: 1),
          // Totals
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text('Income',
                          style: TextStyle(
                              fontSize: 13,
                              color: LoginColors.primary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(_full(totalRevenue),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: LoginColors.textPrimary)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Expense',
                          style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(_full(totalExpense),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: LoginColors.textPrimary)),
                    ],
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


class _IncomeExpenseBarPainter extends CustomPainter {
  final List<RevenueExpenseEntry> entries;
  final double chartMax;
  final List<double> ticks;

  const _IncomeExpenseBarPainter({
    required this.entries,
    required this.chartMax,
    required this.ticks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty || chartMax == 0) return;

    const labelH = 18.0;
    final chartH = size.height - labelH;

    final gridPaint = Paint()
      ..color = LoginColors.border.withValues(alpha: 0.6)
      ..strokeWidth = 0.5;
    for (final tick in ticks) {
      final gy = chartH - (tick / chartMax) * chartH;
      canvas.drawLine(Offset(0, gy), Offset(size.width, gy), gridPaint);
    }

    const barGap = 3.0;
    const groupGap = 8.0;
    final groupW =
        (size.width - groupGap * (entries.length - 1)) / entries.length;
    final barW = (groupW - barGap) / 2;

    final revPaint = Paint()
      ..color = LoginColors.primary
      ..style = PaintingStyle.fill;
    final expPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    final labelStyle = TextStyle(fontSize: 9, color: LoginColors.textSecondary);

    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final x = i * (groupW + groupGap);

      final revH = (e.revenue.clamp(0, chartMax) / chartMax) * chartH;
      canvas.drawRRect(
        RRect.fromLTRBR(x, chartH - revH, x + barW, chartH,
            const Radius.circular(3)),
        revPaint,
      );

      final expH = (e.expense.clamp(0, chartMax) / chartMax) * chartH;
      canvas.drawRRect(
        RRect.fromLTRBR(x + barW + barGap, chartH - expH,
            x + barW * 2 + barGap, chartH, const Radius.circular(3)),
        expPaint,
      );

      if (entries.length <= 6 || i % 2 == 0 || i == entries.length - 1) {
        final tp = TextPainter(
          text:
              TextSpan(text: _monthShort(entries[i].month), style: labelStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x + groupW / 2 - tp.width / 2, chartH + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_IncomeExpenseBarPainter old) =>
      old.entries != entries;
}

// ─── Period Badge ─────────────────────────────────────────────────────────────

Widget _periodBadge(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      border: Border.all(color: LoginColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text,
            style: TextStyle(fontSize: 12, color: LoginColors.textSecondary)),
        Icon(Icons.keyboard_arrow_down_rounded,
            size: 14, color: LoginColors.textSecondary),
      ],
    ),
  );
}

Widget _periodBadgeLoading() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      border: Border.all(color: LoginColors.border),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const SizedBox(
      width: 12,
      height: 12,
      child: CircularProgressIndicator(strokeWidth: 1.5),
    ),
  );
}

// ─── Loading Skeleton ─────────────────────────────────────────────────────────

class _AnalyticsSkeleton extends StatelessWidget {
  const _AnalyticsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(flex: 3, child: _shimmer(height: 96)),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _shimmer(height: 44),
                  const SizedBox(height: 8),
                  _shimmer(height: 44),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _shimmer(height: 340),
        const SizedBox(height: 16),
        _shimmer(height: 340),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _shimmer({required double height, double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: LoginColors.border.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
