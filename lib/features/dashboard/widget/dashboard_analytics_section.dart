import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/analytics/cash_flow.dart';
import 'package:coreflow/domain/model/analytics/dashboard_kpi.dart';
import 'package:coreflow/domain/model/analytics/revenue_expense.dart';

// ─── Formatting ───────────────────────────────────────────────────────────────

String _compact(double v) {
  final neg = v < 0 ? '-' : '';
  final abs = v.abs();
  if (abs >= 1e7) return '$neg₹${(abs / 1e7).toStringAsFixed(1)}Cr';
  if (abs >= 1e5) return '$neg₹${(abs / 1e5).toStringAsFixed(1)}L';
  if (abs >= 1e3) return '$neg₹${(abs / 1e3).toStringAsFixed(1)}K';
  return '$neg₹${abs.toStringAsFixed(0)}';
}

String _monthShort(String yyyyMm) {
  const m = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final p = yyyyMm.split('-');
  if (p.length < 2) return yyyyMm;
  final idx = int.tryParse(p[1]) ?? 0;
  return m[idx.clamp(0, 12)];
}

// ─── Section Root ─────────────────────────────────────────────────────────────

class DashboardAnalyticsSection extends StatelessWidget {
  final DashboardKpi? kpi;
  final List<CashFlowEntry> cashFlow;
  final List<RevenueExpenseEntry> revenueExpense;
  final bool isLoading;

  const DashboardAnalyticsSection({
    super.key,
    required this.kpi,
    required this.cashFlow,
    required this.revenueExpense,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _AnalyticsSkeleton();
    if (kpi == null && cashFlow.isEmpty && revenueExpense.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _sectionHeader('Analytics'),
        const SizedBox(height: 12),
        if (kpi != null) _KpiRow(kpi: kpi!),
        if (cashFlow.isNotEmpty) ...[
          const SizedBox(height: 12),
          _CashFlowCard(entries: cashFlow),
        ],
        if (revenueExpense.isNotEmpty) ...[
          const SizedBox(height: 12),
          _RevenueExpenseCard(entries: revenueExpense),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: LoginColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      );
}

// ─── KPI Row ──────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  final DashboardKpi kpi;
  const _KpiRow({required this.kpi});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _KpiCard(
                label: 'Revenue',
                value: _compact(kpi.totalRevenue),
                icon: Icons.trending_up_rounded,
                iconColor: LoginColors.success,
                valueColor: LoginColors.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _KpiCard(
                label: 'Expense',
                value: _compact(kpi.totalExpense),
                icon: Icons.trending_down_rounded,
                iconColor: LoginColors.error,
                valueColor: LoginColors.error,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _KpiCard(
                label: 'Net Profit',
                value: _compact(kpi.netProfit),
                icon: Icons.account_balance_rounded,
                iconColor: kpi.netProfit >= 0
                    ? LoginColors.primary
                    : LoginColors.error,
                valueColor: kpi.netProfit >= 0
                    ? LoginColors.primary
                    : LoginColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _KpiMiniCard(
                label: 'Sales Orders',
                value: kpi.totalSalesOrders.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _KpiMiniCard(
                label: 'Purchase Orders',
                value: kpi.totalPurchaseOrders.toString(),
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _KpiMiniCard(
                label: 'Receivables',
                value: _compact(kpi.outstandingReceivables),
                color: Colors.teal,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _KpiMiniCard(
                label: 'Payables',
                value: _compact(kpi.outstandingPayables),
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color valueColor;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: LoginColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
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
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: valueColor,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: LoginColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _KpiMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _KpiMiniCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: LoginColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: LoginColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Cash Flow Bar Chart ──────────────────────────────────────────────────────

class _CashFlowCard extends StatelessWidget {
  final List<CashFlowEntry> entries;
  const _CashFlowCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Cash Flow',
      legend: const [
        _LegendDot(color: Color(0xFF10B981), label: 'Incoming'),
        SizedBox(width: 12),
        _LegendDot(color: Color(0xFFEF4444), label: 'Outgoing'),
      ],
      child: SizedBox(
        height: 140,
        child: CustomPaint(
          painter: _BarChartPainter(entries: entries),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<CashFlowEntry> entries;
  _BarChartPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final maxVal = entries
        .expand((e) => [e.incoming, e.outgoing])
        .fold<double>(0, math.max);
    if (maxVal == 0) return;

    const barGap = 4.0;
    const groupGap = 16.0;
    const labelHeight = 20.0;
    final chartH = size.height - labelHeight;
    final groupW =
        (size.width - groupGap * (entries.length - 1)) / entries.length;
    final barW = (groupW - barGap) / 2;

    final inPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;
    final outPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    final labelStyle = TextStyle(
      fontSize: 10,
      color: LoginColors.textSecondary,
      fontWeight: FontWeight.w500,
    );

    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final x = i * (groupW + groupGap);

      // Incoming bar
      final inH = (e.incoming / maxVal) * chartH;
      final inRect = RRect.fromLTRBR(
        x, chartH - inH, x + barW, chartH, const Radius.circular(4),
      );
      canvas.drawRRect(inRect, inPaint);

      // Outgoing bar
      final outH = (e.outgoing / maxVal) * chartH;
      final outRect = RRect.fromLTRBR(
        x + barW + barGap, chartH - outH,
        x + barW * 2 + barGap, chartH,
        const Radius.circular(4),
      );
      canvas.drawRRect(outRect, outPaint);

      // Month label
      final tp = TextPainter(
        text: TextSpan(text: _monthShort(e.month), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x + groupW / 2 - tp.width / 2, chartH + 4),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.entries != entries;
}

// ─── Revenue vs Expense Line Chart ───────────────────────────────────────────

class _RevenueExpenseCard extends StatelessWidget {
  final List<RevenueExpenseEntry> entries;
  const _RevenueExpenseCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    return _ChartCard(
      title: 'Revenue vs Expense',
      legend: const [
        _LegendDot(color: Color(0xFF6366F1), label: 'Revenue'),
        SizedBox(width: 12),
        _LegendDot(color: Color(0xFFF59E0B), label: 'Expense'),
      ],
      child: SizedBox(
        height: 140,
        child: CustomPaint(
          painter: _LineChartPainter(entries: entries),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<RevenueExpenseEntry> entries;
  _LineChartPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) {
      _paintSinglePoint(canvas, size);
      return;
    }

    final maxVal = entries
        .expand((e) => [e.revenue, e.expense])
        .fold<double>(0, math.max);
    if (maxVal == 0) return;

    const labelHeight = 20.0;
    final chartH = size.height - labelHeight;

    double xOf(int i) => i * size.width / (entries.length - 1);
    double yRev(int i) => chartH - (entries[i].revenue / maxVal) * chartH;
    double yExp(int i) => chartH - (entries[i].expense / maxVal) * chartH;

    final revPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final expPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Fill under revenue line
    final revFill = Path()..moveTo(xOf(0), yRev(0));
    for (int i = 1; i < entries.length; i++) {
      revFill.lineTo(xOf(i), yRev(i));
    }
    revFill
      ..lineTo(xOf(entries.length - 1), chartH)
      ..lineTo(xOf(0), chartH)
      ..close();
    canvas.drawPath(
      revFill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.18),
            const Color(0xFF6366F1).withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Draw lines
    final revPath = Path()..moveTo(xOf(0), yRev(0));
    final expPath = Path()..moveTo(xOf(0), yExp(0));
    for (int i = 1; i < entries.length; i++) {
      revPath.lineTo(xOf(i), yRev(i));
      expPath.lineTo(xOf(i), yExp(i));
    }
    canvas.drawPath(revPath, revPaint);
    canvas.drawPath(expPath, expPaint);

    // Dots + labels
    final dotFill = Paint()..style = PaintingStyle.fill;
    final labelStyle = TextStyle(
      fontSize: 10,
      color: LoginColors.textSecondary,
      fontWeight: FontWeight.w500,
    );
    for (int i = 0; i < entries.length; i++) {
      dotFill.color = const Color(0xFF6366F1);
      canvas.drawCircle(Offset(xOf(i), yRev(i)), 3.5, dotFill);
      dotFill.color = const Color(0xFFF59E0B);
      canvas.drawCircle(Offset(xOf(i), yExp(i)), 3.5, dotFill);

      final tp = TextPainter(
        text: TextSpan(text: _monthShort(entries[i].month), style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(xOf(i) - tp.width / 2, chartH + 4));
    }
  }

  void _paintSinglePoint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;
    const labelHeight = 20.0;
    final chartH = size.height - labelHeight;
    final e = entries.first;
    final maxVal = math.max(e.revenue, e.expense);
    if (maxVal == 0) return;

    final dotPaint = Paint()..style = PaintingStyle.fill;
    dotPaint.color = const Color(0xFF6366F1);
    canvas.drawCircle(
        Offset(size.width / 2, chartH - (e.revenue / maxVal) * chartH),
        5, dotPaint);
    dotPaint.color = const Color(0xFFF59E0B);
    canvas.drawCircle(
        Offset(size.width / 2, chartH - (e.expense / maxVal) * chartH),
        5, dotPaint);
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.entries != entries;
}

// ─── Shared card wrapper ──────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final List<Widget> legend;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.legend,
    required this.child,
  });

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
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              Row(children: legend),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: LoginColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────

class _AnalyticsSkeleton extends StatelessWidget {
  const _AnalyticsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        _shimmer(height: 16, width: 100),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _shimmer(height: 78)),
            const SizedBox(width: 8),
            Expanded(child: _shimmer(height: 78)),
            const SizedBox(width: 8),
            Expanded(child: _shimmer(height: 78)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _shimmer(height: 48)),
            const SizedBox(width: 8),
            Expanded(child: _shimmer(height: 48)),
            const SizedBox(width: 8),
            Expanded(child: _shimmer(height: 48)),
            const SizedBox(width: 8),
            Expanded(child: _shimmer(height: 48)),
          ],
        ),
        const SizedBox(height: 12),
        _shimmer(height: 182),
        const SizedBox(height: 12),
        _shimmer(height: 182),
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
