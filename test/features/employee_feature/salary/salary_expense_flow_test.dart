import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/domain/model/main_model/expense/expense_requests.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('salary expense flow', () {
    test('salary detail route contains company and period IDs', () {
      expect(
        CfRoutes.employeeSalaryDetail(7, 42),
        '/cf/company/7/employee-salary/42',
      );
    });

    test('expense request preserves salary period linkage', () {
      final request = ExpenseRequest(
        expenseDate: '2026-08-03',
        paymentMode: 'BANK_TRANSFER',
        amount: 12500,
        expenseAccountId: 9,
        salaryPeriodId: 42,
      );

      expect(request.toJson()['salaryPeriodId'], 42);
    });

    test('expense detail route contains company and expense IDs', () {
      expect(CfRoutes.expenseDetail(7, 99), '/cf/company/7/expenses/99/detail');
    });

    test('salary detail parses lines and payments from backend response', () {
      final detail = SalaryPeriodDetailData.fromJson({
        'salaryPeriodId': 42,
        'employeeId': 11,
        'employeeName': 'Employee One',
        'employeeCode': 'EMP-11',
        'period': '202608',
        'fromDate': '2026-08-01',
        'toDate': '2026-08-31',
        'salaryType': 'MONTHLY',
        'grossAmount': 15000,
        'netAmount': 14000,
        'paidAmount': 5000,
        'balanceAmount': 9000,
        'paymentCount': 1,
        'status': 'APPROVED',
        'lines': [
          {
            'lineId': 1,
            'lineType': 'FIXED',
            'description': 'Monthly salary',
            'amount': 15000,
          },
        ],
        'payments': [
          {
            'expenseId': 99,
            'expenseDate': '2026-08-03',
            'paymentMode': 'BANK_TRANSFER',
            'amount': 5000,
          },
        ],
      });

      expect(detail.salaryPeriodId, 42);
      expect(detail.balanceAmount, 9000);
      expect(detail.lines.single.description, 'Monthly salary');
      expect(detail.payments.single.expenseId, 99);
    });
  });
}
