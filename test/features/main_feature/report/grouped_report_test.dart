import 'package:coreflow/features/main_feature/report/analytics_view_model/analytics_view_model.dart';
import 'package:coreflow/features/main_feature/report/services/grouped_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('work totals preserve employee identity, rate and status', () {
    Map<String, dynamic> row(int id, double rate, String status) => {
      'employeeId': id,
      'employeeName': 'Alex',
      'workDefinitionId': 4,
      'workName': 'Packing',
      'unit': 'box',
      'rate': rate,
      'quantity': 2,
      'amount': rate * 2,
      'status': status,
    };
    final groups = ReportType.workLogReport.groups([
      row(1, 10, 'APPROVED'),
      row(1, 10, 'APPROVED'),
      row(1, 20, 'APPROVED'),
      row(1, 10, 'PENDING'),
      row(2, 10, 'APPROVED'),
    ]);
    expect(groups.length, 2);
    expect(groups.first.rows.length, 3);
    expect(groups.first.rows.first.sublist(1), ['10.00', '4.00', '2', '40.00']);
    expect(groups.first.total, ['Total', '', '8.00', '4.00', '100.00']);
  });

  test('party item report preserves distinct rates and exact totals', () {
    final groups = ReportType.customerItemSales.groups([
      {
        'partyId': 1,
        'partyName': 'Acme',
        'itemId': 2,
        'itemName': 'Box',
        'rate': 10,
        'totalQuantity': 2,
        'totalAmount': 20,
      },
      {
        'partyId': 1,
        'partyName': 'Acme',
        'itemId': 2,
        'itemName': 'Box',
        'rate': 15,
        'totalQuantity': 3,
        'totalAmount': 45,
      },
    ]);
    expect(groups.single.rows.length, 2);
    expect(groups.single.total, ['Total', '', '5.00', '65.00']);
  });

  test('leave totals retain fractional days and status', () {
    final group = ReportType.leaveReport.groups([
      {
        'employeeId': 1,
        'employeeName': 'Alex',
        'leaveCategory': 'CASUAL',
        'leaveType': 'HALF_DAY',
        'status': 'APPROVED',
        'leaveCount': 1,
        'leaveDays': 0.5,
      },
      {
        'employeeId': 1,
        'employeeName': 'Alex',
        'leaveCategory': 'CASUAL',
        'leaveType': 'FULL_DAY',
        'status': 'PENDING',
        'leaveCount': 2,
        'leaveDays': 2,
      },
    ]).single;
    expect(group.total, ['Total', '', '', '3.00', '2.50']);
    expect(group.rows.first[2], 'APPROVED');
  });

  test('outstanding salary excludes settled and overpaid periods', () {
    final groups = ReportType.salaryOutstanding.groups([
      for (final balance in [0, -20, 50])
        {
          'employeeId': 1,
          'employeeName': 'Alex',
          'period': '2026-09',
          'grossAmount': 110,
          'deductionAmount': 10,
          'netAmount': 100,
          'paidAmount': 100 - balance,
          'balanceAmount': balance,
        },
    ]);
    expect(groups.single.rows.length, 1);
    expect(groups.single.total, [
      'Total',
      '110.00',
      '10.00',
      '100.00',
      '50.00',
      '50.00',
    ]);
  });

  test('salary period totals combine employees', () {
    final group = ReportType.salaryByPeriod.groups([
      for (final id in [1, 2])
        {
          'employeeId': id,
          'employeeName': 'Employee $id',
          'period': '2026-09',
          'grossAmount': 100,
          'deductionAmount': 10,
          'netAmount': 90,
          'paidAmount': 40,
          'balanceAmount': 50,
        },
    ]).single;
    expect(group.rows.length, 2);
    expect(group.total, [
      'Total',
      '200.00',
      '20.00',
      '180.00',
      '80.00',
      '100.00',
    ]);
  });
}
