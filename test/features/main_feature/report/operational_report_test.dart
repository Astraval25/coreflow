import 'package:coreflow/features/main_feature/report/analytics_view_model/analytics_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('operational report definitions', () {
    test('expense report preserves signed net and separate subtotals', () {
      final values = ReportType.expenseSavingsReport.operationalValues({
        'expenseDate': '2026-08-04',
        'accountName': 'Reserve',
        'accountType': 'Savings',
        'partyName': 'General',
        'paymentMode': 'BANK_TRANSFER',
        'expenseAmount': 0,
        'savingsAmount': 250,
        'signedAmount': -250,
      });

      expect(values, [
        '2026-08-04',
        'Reserve',
        'Savings',
        'General',
        'BANK_TRANSFER',
        '0.00',
        '250.00',
        '-250.00',
      ]);
    });

    test('customer item report exposes its endpoint and table row', () {
      expect(
        ReportType.customerItemSales.operationalPath,
        'sales/customer-items',
      );
      expect(
        ReportType.customerItemSales.operationalValues({
          'partyName': 'Acme',
          'itemName': 'Widget',
          'orderCount': 2,
          'totalQuantity': 4.5,
          'totalAmount': 900,
        }),
        ['Acme', 'Widget', '2', '4.50', '900.00'],
      );
    });
  });
}
