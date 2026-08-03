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
            if (vm.isWorkBased) ...[
              _dayWiseEarnedCard(vm),
              const SizedBox(height: 16),
            ],
            if (vm.salaryPeriods.isEmpty)
              const PortalEmptyCard(
                icon: Icons.payments_rounded,
                title: 'No salary periods yet',
                subtitle: 'Calculated salaries will appear here.',
              )
            else
              ...vm.salaryPeriods.map(_periodCard),
          ],
        ],
      ),
    );
  }

  Widget _dayWiseEarnedCard(EmployeePortalViewModel vm) {
    final logs = vm.salaryDayWorkLogs;
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
          Row(
            children: [
              Icon(Icons.today_rounded, size: 20, color: LoginColors.primary),
              const SizedBox(width: 8),
              Text(
                'Day-wise Total Earned',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: LoginColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed: vm.isSalaryDayLoading
                    ? null
                    : () => vm.goToPreviousSalaryDay(),
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: 'Previous day',
              ),
              Expanded(
                child: Text(
                  portalDisplayDate(vm.salaryDayDate),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: vm.isSalaryDayLoading || !vm.canGoToNextSalaryDay
                    ? null
                    : () => vm.goToNextSalaryDay(),
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: 'Next day',
              ),
            ],
          ),
          if (vm.isSalaryDayLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            const SizedBox(height: 8),
            if (logs.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'No work logs for this day.',
                  style: TextStyle(color: LoginColors.textSecondary),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  border: TableBorder.all(color: LoginColors.borderLight),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: FixedColumnWidth(170),
                    1: FixedColumnWidth(110),
                    2: FixedColumnWidth(120),
                    3: FixedColumnWidth(100),
                  },
                  children: [
                    _dayTableHeaderRow(),
                    ...logs.map(_dayTableDataRow),
                    _dayTableTotalRow(vm.salaryDayTotalEarned),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  TableRow _dayTableHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: LoginColors.background),
      children: const [
        _DayTableCell(
          text: 'Work',
          isHeader: true,
          alignment: Alignment.centerLeft,
        ),
        _DayTableCell(text: 'Qty Unit', isHeader: true),
        _DayTableCell(
          text: 'Amount',
          isHeader: true,
          alignment: Alignment.centerRight,
        ),
        _DayTableCell(text: 'Status', isHeader: true),
      ],
    );
  }

  TableRow _dayTableDataRow(WorkLogData log) {
    final qty = log.quantity;
    final amount = _resolveRowAmount(log);
    final qtyLabel = qty == null
        ? '-'
        : qty % 1 == 0
        ? qty.toInt().toString()
        : qty.toStringAsFixed(2);
    final qtyWithUnit = qty == null ? '-' : '$qtyLabel ${log.unit}';

    return TableRow(
      children: [
        _DayTableCell(text: log.workName, alignment: Alignment.centerLeft),
        _DayTableCell(text: qtyWithUnit),
        _DayTableCell(
          text: '\u20B9${amount.toStringAsFixed(2)}',
          alignment: Alignment.centerRight,
        ),
        _DayTableCell(text: log.status),
      ],
    );
  }

  TableRow _dayTableTotalRow(double totalAmount) {
    return TableRow(
      decoration: BoxDecoration(
        color: LoginColors.primary.withValues(alpha: 0.08),
      ),
      children: [
        const _DayTableCell(
          text: 'Total',
          isHeader: true,
          alignment: Alignment.centerLeft,
        ),
        const _DayTableCell(text: '-', isHeader: true),
        _DayTableCell(
          text: '\u20B9${totalAmount.toStringAsFixed(2)}',
          isHeader: true,
          alignment: Alignment.centerRight,
        ),
        const _DayTableCell(text: '-', isHeader: true),
      ],
    );
  }

  double _resolveRowAmount(WorkLogData log) {
    if (log.status.toUpperCase() == 'REJECTED') return 0;
    final amountEarned = log.amountEarned;
    if (amountEarned != null) return amountEarned;
    final qty = log.quantity;
    final rate = log.rateSnapshot;
    if (qty == null || rate == null) return 0;
    return qty * rate;
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
                '\u20B9${period.netAmount?.toStringAsFixed(2) ?? '-'}',
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

class _DayTableCell extends StatelessWidget {
  final String text;
  final bool isHeader;
  final Alignment alignment;

  const _DayTableCell({
    required this.text,
    this.isHeader = false,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        textAlign: alignment == Alignment.centerRight
            ? TextAlign.right
            : alignment == Alignment.centerLeft
            ? TextAlign.left
            : TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isHeader ? FontWeight.w800 : FontWeight.w600,
          color: LoginColors.textPrimary,
        ),
      ),
    );
  }
}
