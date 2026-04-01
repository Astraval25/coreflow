import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/model/analytics/cash_flow.dart';
import '../../../domain/model/analytics/dashboard_kpi.dart';
import '../../../domain/model/analytics/item_analytics.dart';
import '../../../domain/model/analytics/item_frequency.dart';
import '../../../domain/model/analytics/monthly_trend.dart';
import '../../../domain/model/analytics/order_frequency.dart';
import '../../../domain/model/analytics/party_analytics.dart';
import '../../../domain/model/analytics/payment_mode.dart';
import '../../../domain/model/analytics/revenue_expense.dart';
import '../../../domain/model/analytics/running_amount.dart';
import '../../../domain/model/analytics/sales_summary.dart';

enum ReportType {
  // Dashboard / Financial
  dashboardKpi,
  cashFlow,
  revenueExpense,
  monthlyTrend,
  paymentModeDistribution,
  // Sales
  salesSummary,
  salesByCustomer,
  salesByItem,
  salesOrderFrequency,
  salesPaymentFrequency,
  salesItemFrequency,
  salesRunningOrderAmount,
  salesRunningPaymentAmount,
  // Purchase
  purchaseSummary,
  purchaseByVendor,
  purchaseByItem,
  purchaseOrderFrequency,
  purchasePaymentFrequency,
  purchaseItemFrequency,
  purchaseRunningOrderAmount,
  purchaseRunningPaymentAmount,
  // Profit
  profitByItem,
  topSellingItems,
  topProfitableItems,
}

extension ReportTypeLabel on ReportType {
  String get label {
    switch (this) {
      case ReportType.dashboardKpi:           return 'Dashboard KPI';
      case ReportType.cashFlow:               return 'Cash Flow Statement';
      case ReportType.revenueExpense:         return 'Revenue vs Expense';
      case ReportType.monthlyTrend:           return 'Monthly Trend';
      case ReportType.paymentModeDistribution:return 'Payment Mode Distribution';
      case ReportType.salesSummary:           return 'Sales Summary';
      case ReportType.salesByCustomer:        return 'Sales by Customer';
      case ReportType.salesByItem:            return 'Sales by Item';
      case ReportType.salesOrderFrequency:    return 'Sales Order Frequency';
      case ReportType.salesPaymentFrequency:  return 'Sales Payment Frequency';
      case ReportType.salesItemFrequency:     return 'Sales Item Frequency';
      case ReportType.salesRunningOrderAmount: return 'Sales Running Order Amount';
      case ReportType.salesRunningPaymentAmount: return 'Sales Running Payment Amount';
      case ReportType.purchaseSummary:        return 'Purchase Summary';
      case ReportType.purchaseByVendor:       return 'Purchase by Vendor';
      case ReportType.purchaseByItem:         return 'Purchase by Item';
      case ReportType.purchaseOrderFrequency: return 'Purchase Order Frequency';
      case ReportType.purchasePaymentFrequency: return 'Purchase Payment Frequency';
      case ReportType.purchaseItemFrequency:  return 'Purchase Item Frequency';
      case ReportType.purchaseRunningOrderAmount: return 'Purchase Running Order Amount';
      case ReportType.purchaseRunningPaymentAmount: return 'Purchase Running Payment Amount';
      case ReportType.profitByItem:           return 'Profit by Item';
      case ReportType.topSellingItems:        return 'Top Selling Items';
      case ReportType.topProfitableItems:     return 'Top Profitable Items';
    }
  }
}

enum AnalyticsDateRange {
  thisMonth,
  lastMonth,
  thisQuarter,
  lastQuarter,
  thisYear,
  custom,
}

extension AnalyticsDateRangeLabel on AnalyticsDateRange {
  String get label {
    switch (this) {
      case AnalyticsDateRange.thisMonth:    return 'This Month';
      case AnalyticsDateRange.lastMonth:    return 'Last Month';
      case AnalyticsDateRange.thisQuarter:  return 'This Quarter';
      case AnalyticsDateRange.lastQuarter:  return 'Last Quarter';
      case AnalyticsDateRange.thisYear:     return 'This Year';
      case AnalyticsDateRange.custom:       return 'Custom';
    }
  }
}

class AnalyticsViewModel extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  final int companyId;

  AnalyticsViewModel({required this.companyId}) {
    _applyDateRange(AnalyticsDateRange.thisYear);
  }

  AnalyticsDateRange _selectedRange = AnalyticsDateRange.thisYear;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  // Results — one field per report type
  DashboardKpi? kpi;
  List<CashFlowEntry> cashFlow = [];
  List<RevenueExpenseEntry> revenueExpense = [];
  List<MonthlyTrendEntry> monthlyTrend = [];
  List<PaymentModeEntry> paymentModeDistribution = [];
  SalesSummary? salesSummary;
  List<PartyAnalyticsEntry> salesByCustomer = [];
  List<ItemAnalyticsEntry> salesByItem = [];
  List<OrderFrequencyEntry> salesOrderFrequency = [];
  List<PaymentFrequencyEntry> salesPaymentFrequency = [];
  List<ItemFrequencyEntry> salesItemFrequency = [];
  List<RunningAmountEntry> salesRunningOrderAmount = [];
  List<RunningAmountEntry> salesRunningPaymentAmount = [];
  PurchaseSummary? purchaseSummary;
  List<PartyAnalyticsEntry> purchaseByVendor = [];
  List<ItemAnalyticsEntry> purchaseByItem = [];
  List<OrderFrequencyEntry> purchaseOrderFrequency = [];
  List<PaymentFrequencyEntry> purchasePaymentFrequency = [];
  List<ItemFrequencyEntry> purchaseItemFrequency = [];
  List<RunningAmountEntry> purchaseRunningOrderAmount = [];
  List<RunningAmountEntry> purchaseRunningPaymentAmount = [];
  List<ProfitByItemEntry> profitByItem = [];
  List<ItemAnalyticsEntry> topSellingItems = [];
  List<ItemAnalyticsEntry> topProfitableItems = [];

  AnalyticsDateRange get selectedRange => _selectedRange;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get startDateFormatted => _fmt(_startDate);
  String get endDateFormatted => _fmt(_endDate);
  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String formatDateDisplay(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void setDateRange(AnalyticsDateRange range) {
    _selectedRange = range;
    _applyDateRange(range);
    notifyListeners();
  }

  void setCustomDates(DateTime start, DateTime end) {
    _selectedRange = AnalyticsDateRange.custom;
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void _applyDateRange(AnalyticsDateRange range) {
    final now = DateTime.now();
    switch (range) {
      case AnalyticsDateRange.thisMonth:
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case AnalyticsDateRange.lastMonth:
        _startDate = DateTime(now.year, now.month - 1, 1);
        _endDate = DateTime(now.year, now.month, 0);
        break;
      case AnalyticsDateRange.thisQuarter:
        final q = (now.month - 1) ~/ 3;
        _startDate = DateTime(now.year, q * 3 + 1, 1);
        _endDate = DateTime(now.year, q * 3 + 4, 0);
        break;
      case AnalyticsDateRange.lastQuarter:
        final q = ((now.month - 1) ~/ 3) - 1;
        final year = q < 0 ? now.year - 1 : now.year;
        final aq = q < 0 ? 3 : q;
        _startDate = DateTime(year, aq * 3 + 1, 1);
        _endDate = DateTime(year, aq * 3 + 4, 0);
        break;
      case AnalyticsDateRange.thisYear:
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year, 12, 31);
        break;
      case AnalyticsDateRange.custom:
        break;
    }
  }

  Future<void> runReport(ReportType type) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final s = startDateFormatted;
    final e = endDateFormatted;
    final c = companyId;

    try {
      switch (type) {
        case ReportType.dashboardKpi:
          kpi = await _repo.getDashboardKpi(c, s, e);
          break;
        case ReportType.cashFlow:
          cashFlow = await _repo.getCashFlow(c, s, e);
          break;
        case ReportType.revenueExpense:
          revenueExpense = await _repo.getRevenueExpense(c, s, e);
          break;
        case ReportType.monthlyTrend:
          monthlyTrend = await _repo.getMonthlyTrend(c, s, e);
          break;
        case ReportType.paymentModeDistribution:
          paymentModeDistribution = await _repo.getPaymentModeDistribution(c, s, e);
          break;
        case ReportType.salesSummary:
          salesSummary = await _repo.getSalesSummary(c, s, e);
          break;
        case ReportType.salesByCustomer:
          salesByCustomer = await _repo.getSalesByCustomer(c, s, e);
          break;
        case ReportType.salesByItem:
          salesByItem = await _repo.getSalesByItem(c, s, e);
          break;
        case ReportType.salesOrderFrequency:
          salesOrderFrequency = await _repo.getSalesOrderFrequency(c, s, e);
          break;
        case ReportType.salesPaymentFrequency:
          salesPaymentFrequency = await _repo.getSalesPaymentFrequency(c, s, e);
          break;
        case ReportType.salesItemFrequency:
          salesItemFrequency = await _repo.getSalesItemFrequency(c, s, e);
          break;
        case ReportType.salesRunningOrderAmount:
          salesRunningOrderAmount = await _repo.getSalesRunningOrderAmount(c, s, e);
          break;
        case ReportType.salesRunningPaymentAmount:
          salesRunningPaymentAmount = await _repo.getSalesRunningPaymentAmount(c, s, e);
          break;
        case ReportType.purchaseSummary:
          purchaseSummary = await _repo.getPurchaseSummary(c, s, e);
          break;
        case ReportType.purchaseByVendor:
          purchaseByVendor = await _repo.getPurchaseByVendor(c, s, e);
          break;
        case ReportType.purchaseByItem:
          purchaseByItem = await _repo.getPurchaseByItem(c, s, e);
          break;
        case ReportType.purchaseOrderFrequency:
          purchaseOrderFrequency = await _repo.getPurchaseOrderFrequency(c, s, e);
          break;
        case ReportType.purchasePaymentFrequency:
          purchasePaymentFrequency = await _repo.getPurchasePaymentFrequency(c, s, e);
          break;
        case ReportType.purchaseItemFrequency:
          purchaseItemFrequency = await _repo.getPurchaseItemFrequency(c, s, e);
          break;
        case ReportType.purchaseRunningOrderAmount:
          purchaseRunningOrderAmount = await _repo.getPurchaseRunningOrderAmount(c, s, e);
          break;
        case ReportType.purchaseRunningPaymentAmount:
          purchaseRunningPaymentAmount = await _repo.getPurchaseRunningPaymentAmount(c, s, e);
          break;
        case ReportType.profitByItem:
          profitByItem = await _repo.getProfitByItem(c, s, e);
          break;
        case ReportType.topSellingItems:
          topSellingItems = await _repo.getTopSellingItems(c, s, e);
          break;
        case ReportType.topProfitableItems:
          topProfitableItems = await _repo.getTopProfitableItems(c, s, e);
          break;
      }
    } catch (err) {
      _error = 'Failed to load report. Please try again.';
      debugPrint('runReport($type): $err');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
