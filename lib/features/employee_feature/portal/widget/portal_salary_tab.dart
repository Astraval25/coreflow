import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/features/employee_feature/portal/view_model/employee_portal_view_model.dart';
import 'package:coreflow/features/employee_feature/portal/widget/portal_common.dart';
import 'package:coreflow/features/employee_feature/salary/service/salary_file_service.dart';
import 'package:flutter/material.dart';

class PortalSalaryTab extends StatefulWidget {
  final EmployeePortalViewModel vm;
  const PortalSalaryTab({super.key, required this.vm});

  @override
  State<PortalSalaryTab> createState() => _PortalSalaryTabState();
}

class _PortalSalaryTabState extends State<PortalSalaryTab> {
  int? _downloadingId;

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? LoginColors.error : LoginColors.success,
      ),
    );
  }

  Future<void> _downloadSlip(SalaryPeriodSummary period) async {
    setState(() => _downloadingId = period.salaryPeriodId);
    try {
      final bytes = await widget.vm.downloadSalarySlip(period.salaryPeriodId);
      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        _showMessage('Failed to download', isError: true);
        return;
      }
      await SalaryFileService.shareSalarySlip(
        bytes: bytes,
        fileName: 'salary-slip-${period.period}.pdf',
      );
    } catch (e) {
      if (mounted) _showMessage('Failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _downloadingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return RefreshIndicator(
      onRefresh: vm.loadPortal,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (vm.isSalaryLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (vm.salaryReport != null) ...[
              _summaryCard(vm.salaryReport!),
              const SizedBox(height: 16),
            ],
            if (vm.salaryPeriods.isEmpty)
              const PortalEmptyCard(
                icon: Icons.payments_rounded,
                title: 'No salary for this range',
                subtitle: 'Change the date range to view another month.',
              )
            else
              ...vm.salaryPeriods.map(_periodCard),
          ],
        ],
      ),
    );
  }

  Widget _summaryCard(SalaryReportData report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow('From', portalDisplayDate(report.fromDate)),
          _summaryRow('To', portalDisplayDate(report.toDate)),
          _summaryRow('Net', report.totalNetAmount?.toStringAsFixed(2) ?? '-'),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child:
                Text(label, style: TextStyle(color: LoginColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodCard(SalaryPeriodSummary period) {
    final downloading = _downloadingId == period.salaryPeriodId;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: LoginColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: LoginColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      period.period,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${portalDisplayDate(period.fromDate)} to ${portalDisplayDate(period.toDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PortalStatusBadge(period.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'You will get',
                style: TextStyle(
                  color: LoginColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                '₹${period.netAmount?.toStringAsFixed(2) ?? '-'}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: LoginColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: downloading ? null : () => _downloadSlip(period),
              icon: downloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(downloading ? 'Preparing...' : 'Download Slip'),
            ),
          ),
        ],
      ),
    );
  }
}
