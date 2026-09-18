import '../analytics_view_model/analytics_view_model.dart';

double reportNumber(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

class ReportGroup {
  final String title;
  final List<String> headers;
  final List<List<String>> rows;
  final List<String> total;
  ReportGroup(this.title, this.headers, this.rows, this.total);
}

extension GroupedReport on ReportType {
  bool get hasGroups => const {
    ReportType.customerItemSales,
    ReportType.vendorItemPurchases,
    ReportType.workLogReport,
    ReportType.leaveReport,
    ReportType.salaryByEmployee,
    ReportType.salaryByPeriod,
    ReportType.salaryOutstanding,
    ReportType.salaryDeductions,
    ReportType.allSalesBill,
    ReportType.allPurchaseBill,
  }.contains(this);

  List<String> get groupHeaders {
    switch (this) {
      case ReportType.leaveReport:
        return ['Leave category', 'Type', 'Status', 'Requests', 'Days'];
      case ReportType.salaryByEmployee:
      case ReportType.salaryByPeriod:
      case ReportType.salaryOutstanding:
      case ReportType.salaryDeductions:
        return [
          'Period / Employee',
          'Gross',
          'Deductions',
          'Net',
          'Paid',
          'Balance',
        ];
      case ReportType.allSalesBill:
      case ReportType.allPurchaseBill:
        return [
          'Date',
          'Bill / Order no.',
          'Status',
          'Amount',
          'Paid',
          'Balance',
        ];
      case ReportType.workLogReport:
        return ['Item / Status', 'Rate', 'Qty', 'Work count', 'Amount'];
      default:
        return ['Item', 'Rate', 'Qty', 'Amount'];
    }
  }

  List<ReportGroup> groups(List<Map<String, dynamic>> source) {
    final party =
        this == ReportType.customerItemSales ||
        this == ReportType.vendorItemPurchases;
    final bill =
        this == ReportType.allSalesBill || this == ReportType.allPurchaseBill;
    final salary = const {
      ReportType.salaryByEmployee,
      ReportType.salaryByPeriod,
      ReportType.salaryOutstanding,
      ReportType.salaryDeductions,
    }.contains(this);
    final buckets = <String, List<Map<String, dynamic>>>{};
    String employee(Map<String, dynamic> r) =>
        '${r['employeeName'] ?? '-'}${r['employeeCode'] == null ? '' : ' (${r['employeeCode']})'}';
    for (final r in source) {
      if (this == ReportType.salaryOutstanding &&
          reportNumber(r['balanceAmount']) <= 0) {
        continue;
      }
      if (this == ReportType.salaryDeductions &&
          reportNumber(r['deductionAmount']) == 0) {
        continue;
      }
      final key = this == ReportType.salaryByPeriod
          ? '${r['period']}'
          : party || bill
          ? '${r['partyId'] ?? r['partyName']}'
          : '${r['employeeId'] ?? employee(r)}';
      buckets.putIfAbsent(key, () => []).add(r);
    }
    final result = <ReportGroup>[];
    for (final entries in buckets.values) {
      final first = entries.first;
      final title = this == ReportType.salaryByPeriod
          ? '${first['period']}'
          : party || bill
          ? '${first['partyName'] ?? '-'}'
          : employee(first);
      final lines = <List<String>>[];
      final totals = List<double>.filled(groupHeaders.length, 0);
      String fmt(dynamic n) => reportNumber(n).toStringAsFixed(2);
      if (salary || bill || this == ReportType.leaveReport) {
        for (final r in entries) {
          final keys = salary
              ? [
                  'grossAmount',
                  'deductionAmount',
                  'netAmount',
                  'paidAmount',
                  'balanceAmount',
                ]
              : bill
              ? ['totalAmount', 'paidAmount', 'balanceAmount']
              : ['leaveCount', 'leaveDays'];
          final labels = salary
              ? [
                  this == ReportType.salaryByPeriod
                      ? employee(r)
                      : '${r['period']}',
                ]
              : bill
              ? ['${r['date']}', '${r['number']}', '${r['status']}']
              : [
                  '${r['leaveCategory']}',
                  '${r['leaveType']}',
                  '${r['status']}',
                ];
          lines.add([...labels, ...keys.map((k) => fmt(r[k]))]);
          for (var i = 0; i < keys.length; i++) {
            totals[labels.length + i] += reportNumber(r[keys[i]]);
          }
        }
      } else {
        // Keep different rates, units and approval statuses on separate lines.
        final items = <String, List<Map<String, dynamic>>>{};
        for (final r in entries) {
          final key = party
              ? '${r['itemId'] ?? r['itemName']}|${r['rate']}'
              : '${r['workDefinitionId'] ?? r['workName']}|${r['rate']}|${r['unit']}|${r['status']}';
          items.putIfAbsent(key, () => []).add(r);
        }
        for (final item in items.values) {
          final r = item.first;
          final qty = item.fold<double>(
            0,
            (s, r) => s + reportNumber(r[party ? 'totalQuantity' : 'quantity']),
          );
          final amount = item.fold<double>(
            0,
            (s, r) => s + reportNumber(r[party ? 'totalAmount' : 'amount']),
          );
          final rate = r['rate'];
          lines.add([
            party
                ? '${r['itemName']}'
                : '${r['workName']} (${r['unit'] ?? '-'}) / ${r['status']}',
            rate == null ? '-' : fmt(rate),
            fmt(qty),
            if (!party) '${item.length}',
            fmt(amount),
          ]);
          totals[2] += qty;
          if (!party) totals[3] += item.length;
          totals[totals.length - 1] += amount;
        }
      }
      final total = List<String>.filled(groupHeaders.length, '');
      total[0] = 'Total';
      final start = salary
          ? 1
          : bill || this == ReportType.leaveReport
          ? 3
          : 2;
      for (var i = start; i < total.length; i++) {
        total[i] = fmt(totals[i]);
      }
      result.add(ReportGroup(title, groupHeaders, lines, total));
    }
    result.sort((a, b) => a.title.compareTo(b.title));
    return result;
  }
}
