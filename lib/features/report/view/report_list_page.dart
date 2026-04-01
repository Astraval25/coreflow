import 'package:flutter/material.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/report/analytics_view_model/analytics_view_model.dart';
import 'package:coreflow/features/report/view/report_detail_page.dart';

class ReportListPage extends StatelessWidget {
  final int companyId;
  const ReportListPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        backgroundColor: LoginColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: LoginColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reports',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: LoginColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        children: [
          _ReportSection(
            title: 'Financial',
            color: LoginColors.primary,
            items: const [
              ReportType.dashboardKpi,
              ReportType.cashFlow,
              ReportType.revenueExpense,
              ReportType.monthlyTrend,
              ReportType.paymentModeDistribution,
            ],
            companyId: companyId,
          ),
          _ReportSection(
            title: 'Sales',
            color: LoginColors.success,
            items: const [
              ReportType.salesSummary,
              ReportType.salesByCustomer,
              ReportType.salesByItem,
              ReportType.salesOrderFrequency,
              ReportType.salesPaymentFrequency,
              ReportType.salesItemFrequency,
              ReportType.salesRunningOrderAmount,
              ReportType.salesRunningPaymentAmount,
            ],
            companyId: companyId,
          ),
          _ReportSection(
            title: 'Purchase',
            color: Colors.orange,
            items: const [
              ReportType.purchaseSummary,
              ReportType.purchaseByVendor,
              ReportType.purchaseByItem,
              ReportType.purchaseOrderFrequency,
              ReportType.purchasePaymentFrequency,
              ReportType.purchaseItemFrequency,
              ReportType.purchaseRunningOrderAmount,
              ReportType.purchaseRunningPaymentAmount,
            ],
            companyId: companyId,
          ),
          _ReportSection(
            title: 'Profitability',
            color: Colors.deepPurple,
            items: const [
              ReportType.profitByItem,
              ReportType.topSellingItems,
              ReportType.topProfitableItems,
            ],
            companyId: companyId,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<ReportType> items;
  final int companyId;

  const _ReportSection({
    required this.title,
    required this.color,
    required this.items,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: LoginColors.surface,
            border: Border(
              top: BorderSide(color: LoginColors.border),
              bottom: BorderSide(color: LoginColors.border),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _ReportTile(reportType: items[i], companyId: companyId),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    indent: 16,
                    color: LoginColors.border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportTile extends StatelessWidget {
  final ReportType reportType;
  final int companyId;
  const _ReportTile({required this.reportType, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        reportType.label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: LoginColors.textPrimary,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: LoginColors.textTertiary, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ReportDetailPage(reportType: reportType, companyId: companyId),
        ),
      ),
    );
  }
}
