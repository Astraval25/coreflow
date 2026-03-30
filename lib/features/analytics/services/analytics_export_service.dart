import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:coreflow/features/analytics/analytics_view_model/analytics_view_model.dart';

// ─── Public API ───────────────────────────────────────────────────────────────

class AnalyticsExportService {
  static Future<void> exportPdf(
    BuildContext context,
    AnalyticsViewModel vm,
    ReportType reportType,
  ) async {
    try {
      final pdf = pw.Document();
      final rows = _buildRows(vm, reportType);
      final headers = _headers(reportType);
      final title = reportType.label;
      final period = 'From ${_disp(vm.startDate)} To ${_disp(vm.endDate)}';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (ctx) => [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              period,
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 16),
            if (rows.isEmpty)
              pw.Text(
                'No data available for selected period.',
                style: const pw.TextStyle(color: PdfColors.grey),
              )
            else
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                columnWidths: {
                  for (int i = 0; i < headers.length; i++)
                    i: const pw.FlexColumnWidth(),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.indigo50,
                    ),
                    children: headers
                        .map((h) => _pdfCell(h, bold: true))
                        .toList(),
                  ),
                  ...rows.map(
                    (r) => pw.TableRow(
                      children: r.map((c) => _pdfCell(c)).toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );

      final dir = await getTemporaryDirectory();
      final fileName =
          '${_slug(title)}_${_fileDate(vm.startDate)}_${_fileDate(vm.endDate)}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles([XFile(file.path)], subject: '$title — $period');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 1),
            content: Text('PDF export failed: $e'),
          ),
        );
      }
    }
  }

  static Future<void> exportCsv(
    BuildContext context,
    AnalyticsViewModel vm,
    ReportType reportType,
  ) async {
    try {
      final headers = _headers(reportType);
      final rows = _buildRows(vm, reportType);
      final title = reportType.label;
      final period = 'From ${_disp(vm.startDate)} To ${_disp(vm.endDate)}';

      final buf = StringBuffer();
      buf.writeln(title);
      buf.writeln(period);
      buf.writeln();
      buf.writeln(headers.map(_csvEscape).join(','));
      for (final row in rows) {
        buf.writeln(row.map(_csvEscape).join(','));
      }

      final dir = await getTemporaryDirectory();
      final fileName =
          '${_slug(title)}_${_fileDate(vm.startDate)}_${_fileDate(vm.endDate)}.csv';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(buf.toString());

      await Share.shareXFiles([XFile(file.path)], subject: '$title — $period');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 1),
            content: Text('CSV export failed: $e'),
          ),
        );
      }
    }
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _disp(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String _fileDate(DateTime d) =>
    '${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';

String _slug(String s) =>
    s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');

String _csvEscape(String s) {
  if (s.contains(',') || s.contains('"') || s.contains('\n')) {
    return '"${s.replaceAll('"', '""')}"';
  }
  return s;
}

String _fmtNum(double v) {
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
  return '$neg $buf.$dec';
}

String _monthLabel(String yyyyMm) {
  const months = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final p = yyyyMm.split('-');
  if (p.length < 2) return yyyyMm;
  final m = int.tryParse(p[1]) ?? 0;
  return '${months[m.clamp(0, 12)]} ${p[0]}';
}

pw.Widget _pdfCell(String text, {bool bold = false}) => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  child: pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: 10,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    ),
  ),
);

// ─── Headers per report type ──────────────────────────────────────────────────

List<String> _headers(ReportType type) {
  switch (type) {
    case ReportType.dashboardKpi:
      return ['Metric', 'Value'];
    case ReportType.cashFlow:
      return [
        'Month',
        'Opening Balance',
        'Incoming',
        'Outgoing',
        'Closing Balance',
      ];
    case ReportType.revenueExpense:
      return ['Month', 'Revenue', 'Expense', 'Net Profit'];
    case ReportType.monthlyTrend:
      return ['Month', 'Sales', 'Purchase', 'Received', 'Made'];
    case ReportType.paymentModeDistribution:
      return ['Mode', 'Amount', 'Transactions', 'Percentage'];
    case ReportType.salesSummary:
    case ReportType.purchaseSummary:
      return ['Metric', 'Value'];
    case ReportType.salesByCustomer:
      return ['Customer', 'Orders', 'Amount', 'Paid', 'Due'];
    case ReportType.purchaseByVendor:
      return ['Vendor', 'Orders', 'Amount', 'Paid', 'Due'];
    case ReportType.salesByItem:
    case ReportType.purchaseByItem:
    case ReportType.topSellingItems:
    case ReportType.topProfitableItems:
      return ['Item Name', 'Quantity', 'Amount'];
    case ReportType.salesOrderFrequency:
    case ReportType.purchaseOrderFrequency:
      return ['Month', 'Order Count'];
    case ReportType.salesPaymentFrequency:
    case ReportType.purchasePaymentFrequency:
      return ['Month', 'Payment Count'];
    case ReportType.salesItemFrequency:
    case ReportType.purchaseItemFrequency:
      return ['Item', 'Quantity', 'Order Count'];
    case ReportType.salesRunningOrderAmount:
    case ReportType.purchaseRunningOrderAmount:
    case ReportType.salesRunningPaymentAmount:
    case ReportType.purchaseRunningPaymentAmount:
      return ['Month', 'Cumulative Amount'];
    case ReportType.profitByItem:
      return ['Item', 'Sales', 'Purchase', 'Profit', 'Margin %'];
  }
}

// ─── Rows per report type ─────────────────────────────────────────────────────

List<List<String>> _buildRows(AnalyticsViewModel vm, ReportType type) {
  switch (type) {
    case ReportType.dashboardKpi:
      if (vm.kpi == null) return [];
      return [
        ['Total Revenue', _fmtNum(vm.kpi!.totalRevenue)],
        ['Total Expense', _fmtNum(vm.kpi!.totalExpense)],
        ['Net Profit', _fmtNum(vm.kpi!.netProfit)],
        ['Sales Orders', vm.kpi!.totalSalesOrders.toString()],
        ['Purchase Orders', vm.kpi!.totalPurchaseOrders.toString()],
        ['Payments Received', vm.kpi!.totalPaymentsReceived.toString()],
        ['Payments Made', vm.kpi!.totalPaymentsMade.toString()],
        ['Avg Order Value', _fmtNum(vm.kpi!.avgOrderValue)],
        ['Outstanding Receivables', _fmtNum(vm.kpi!.outstandingReceivables)],
        ['Outstanding Payables', _fmtNum(vm.kpi!.outstandingPayables)],
      ];
    case ReportType.cashFlow:
      return vm.cashFlow
          .map(
            (e) => [
              _monthLabel(e.month),
              _fmtNum(e.openingBalance),
              _fmtNum(e.incoming),
              _fmtNum(e.outgoing),
              _fmtNum(e.closingBalance),
            ],
          )
          .toList();
    case ReportType.revenueExpense:
      return vm.revenueExpense
          .map(
            (e) => [
              _monthLabel(e.month),
              _fmtNum(e.revenue),
              _fmtNum(e.expense),
              _fmtNum(e.netProfit),
            ],
          )
          .toList();
    case ReportType.monthlyTrend:
      return vm.monthlyTrend
          .map(
            (e) => [
              _monthLabel(e.month),
              _fmtNum(e.salesAmount),
              _fmtNum(e.purchaseAmount),
              _fmtNum(e.paymentReceived),
              _fmtNum(e.paymentMade),
            ],
          )
          .toList();
    case ReportType.paymentModeDistribution:
      return vm.paymentModeDistribution
          .map(
            (e) => [
              e.mode,
              _fmtNum(e.totalAmount),
              e.transactionCount.toString(),
              '${e.percentage.toStringAsFixed(1)}%',
            ],
          )
          .toList();
    case ReportType.salesSummary:
      if (vm.salesSummary == null) return [];
      return [
        ['Total Orders', vm.salesSummary!.totalOrders.toString()],
        ['Total Amount', _fmtNum(vm.salesSummary!.totalAmount)],
        ['Total Paid', _fmtNum(vm.salesSummary!.totalPaid)],
        ['Total Due', _fmtNum(vm.salesSummary!.totalDue)],
        ['Avg Order Value', _fmtNum(vm.salesSummary!.avgOrderValue)],
      ];
    case ReportType.purchaseSummary:
      if (vm.purchaseSummary == null) return [];
      return [
        ['Total Orders', vm.purchaseSummary!.totalOrders.toString()],
        ['Total Amount', _fmtNum(vm.purchaseSummary!.totalAmount)],
        ['Total Paid', _fmtNum(vm.purchaseSummary!.totalPaid)],
        ['Total Due', _fmtNum(vm.purchaseSummary!.totalDue)],
        ['Avg Order Value', _fmtNum(vm.purchaseSummary!.avgOrderValue)],
      ];
    case ReportType.salesByCustomer:
      return vm.salesByCustomer
          .map(
            (e) => [
              e.partyName,
              e.totalOrders.toString(),
              _fmtNum(e.totalAmount),
              _fmtNum(e.paidAmount),
              _fmtNum(e.dueAmount),
            ],
          )
          .toList();
    case ReportType.purchaseByVendor:
      return vm.purchaseByVendor
          .map(
            (e) => [
              e.partyName,
              e.totalOrders.toString(),
              _fmtNum(e.totalAmount),
              _fmtNum(e.paidAmount),
              _fmtNum(e.dueAmount),
            ],
          )
          .toList();
    case ReportType.salesByItem:
      return vm.salesByItem
          .map(
            (e) => [
              e.itemName,
              e.totalQuantity.toStringAsFixed(2),
              _fmtNum(e.totalAmount),
            ],
          )
          .toList();
    case ReportType.purchaseByItem:
      return vm.purchaseByItem
          .map(
            (e) => [
              e.itemName,
              e.totalQuantity.toStringAsFixed(2),
              _fmtNum(e.totalAmount),
            ],
          )
          .toList();
    case ReportType.topSellingItems:
      return vm.topSellingItems
          .map(
            (e) => [
              e.itemName,
              e.totalQuantity.toStringAsFixed(2),
              _fmtNum(e.totalAmount),
            ],
          )
          .toList();
    case ReportType.topProfitableItems:
      return vm.topProfitableItems
          .map(
            (e) => [
              e.itemName,
              e.totalQuantity.toStringAsFixed(2),
              _fmtNum(e.totalAmount),
            ],
          )
          .toList();
    case ReportType.salesOrderFrequency:
      return vm.salesOrderFrequency
          .map((e) => [_monthLabel(e.month), e.orderCount.toString()])
          .toList();
    case ReportType.purchaseOrderFrequency:
      return vm.purchaseOrderFrequency
          .map((e) => [_monthLabel(e.month), e.orderCount.toString()])
          .toList();
    case ReportType.salesPaymentFrequency:
      return vm.salesPaymentFrequency
          .map((e) => [_monthLabel(e.month), e.paymentCount.toString()])
          .toList();
    case ReportType.purchasePaymentFrequency:
      return vm.purchasePaymentFrequency
          .map((e) => [_monthLabel(e.month), e.paymentCount.toString()])
          .toList();
    case ReportType.salesItemFrequency:
      return vm.salesItemFrequency
          .map(
            (e) => [
              e.itemName,
              e.totalQuantity.toStringAsFixed(2),
              e.orderCount.toString(),
            ],
          )
          .toList();
    case ReportType.purchaseItemFrequency:
      return vm.purchaseItemFrequency
          .map(
            (e) => [
              e.itemName,
              e.totalQuantity.toStringAsFixed(2),
              e.orderCount.toString(),
            ],
          )
          .toList();
    case ReportType.salesRunningOrderAmount:
      return vm.salesRunningOrderAmount
          .map((e) => [_monthLabel(e.month), _fmtNum(e.cumulativeAmount)])
          .toList();
    case ReportType.purchaseRunningOrderAmount:
      return vm.purchaseRunningOrderAmount
          .map((e) => [_monthLabel(e.month), _fmtNum(e.cumulativeAmount)])
          .toList();
    case ReportType.salesRunningPaymentAmount:
      return vm.salesRunningPaymentAmount
          .map((e) => [_monthLabel(e.month), _fmtNum(e.cumulativeAmount)])
          .toList();
    case ReportType.purchaseRunningPaymentAmount:
      return vm.purchaseRunningPaymentAmount
          .map((e) => [_monthLabel(e.month), _fmtNum(e.cumulativeAmount)])
          .toList();
    case ReportType.profitByItem:
      return vm.profitByItem
          .map(
            (e) => [
              e.itemName,
              _fmtNum(e.totalSalesAmount),
              _fmtNum(e.totalPurchaseAmount),
              _fmtNum(e.profit),
              '${e.profitMargin.toStringAsFixed(1)}%',
            ],
          )
          .toList();
  }
}
