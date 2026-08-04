import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/features/employee_feature/salary/service/salary_file_service.dart';
import 'package:flutter/material.dart';

class AdminSalaryDetailPage extends StatefulWidget {
  final int companyId;
  final int salaryPeriodId;

  const AdminSalaryDetailPage({
    super.key,
    required this.companyId,
    required this.salaryPeriodId,
  });

  @override
  State<AdminSalaryDetailPage> createState() => _AdminSalaryDetailPageState();
}

class _AdminSalaryDetailPageState extends State<AdminSalaryDetailPage> {
  final EmployeeRepository _repository = EmployeeRepository();
  late Future<SalaryPeriodDetailData?> _detailFuture;
  bool _isDownloading = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  Future<SalaryPeriodDetailData?> _loadDetail() {
    return _repository.getSalaryPeriodDetail(
      widget.companyId,
      widget.salaryPeriodId,
    );
  }

  Future<void> _refresh() async {
    setState(() => _detailFuture = _loadDetail());
    await _detailFuture;
  }

  Future<void> _download(SalaryPeriodDetailData detail) async {
    setState(() => _isDownloading = true);
    try {
      final bytes = await _repository.downloadSalarySlip(
        widget.companyId,
        widget.salaryPeriodId,
      );
      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        _showMessage('Failed to download salary slip', isError: true);
        return;
      }
      await SalaryFileService.shareSalarySlip(
        bytes: bytes,
        fileName: 'salary-slip-${detail.employeeCode}-${detail.period}.pdf',
      );
    } catch (_) {
      if (mounted) {
        _showMessage('Failed to download salary slip', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _deleteDraft(SalaryPeriodDetailData detail) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Draft Salary?'),
        content: Text(
          'Delete the draft salary calculation for ${detail.employeeName}, '
          '${detail.fromDate} to ${detail.toDate}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: LoginColors.error),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    setState(() => _isDeleting = true);
    final response = await _repository.deleteSalaryPeriod(
      widget.companyId,
      widget.salaryPeriodId,
    );
    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (response?.responseStatus == true) {
      Navigator.of(context).pop(true);
      return;
    }
    _showMessage(
      response?.responseMessage ?? 'Failed to delete salary period',
      isError: true,
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? LoginColors.error : LoginColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: const Text('Salary Details'),
        backgroundColor: LoginColors.background,
        foregroundColor: LoginColors.textPrimary,
        actions: [
          IconButton(
            onPressed: _refresh,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<SalaryPeriodDetailData?>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final detail = snapshot.data;
          if (snapshot.hasError || detail == null) {
            return _errorState();
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _salaryHeader(detail),
                const SizedBox(height: 12),
                _employeeAndPeriod(detail),
                if (_hasAttendance(detail)) ...[
                  const SizedBox(height: 12),
                  _attendanceSection(detail),
                ],
                const SizedBox(height: 12),
                _salaryCalculation(detail),
                const SizedBox(height: 12),
                _paymentSummary(detail),
                if (detail.payments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _paymentHistory(detail.payments),
                ],
                if (_hasAudit(detail)) ...[
                  const SizedBox(height: 12),
                  _auditSection(detail),
                ],
                const SizedBox(height: 18),
                _actions(detail),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 44,
              color: LoginColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load salary details',
              style: TextStyle(
                color: LoginColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _salaryHeader(SalaryPeriodDetailData detail) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LoginColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.employeeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${detail.employeeCode}  |  ${detail.salaryType.replaceAll('_', ' ')}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(detail.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${detail.fromDate} to ${detail.toDate}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _headerMetric('Gross', detail.grossAmount)),
              Expanded(child: _headerMetric('Net Salary', detail.netAmount)),
              Expanded(child: _headerMetric('Balance', detail.balanceAmount)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerMetric(String label, num? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _money(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _employeeAndPeriod(SalaryPeriodDetailData detail) {
    return _section(
      title: 'Employee and Salary Period',
      icon: Icons.badge_outlined,
      child: Column(
        children: [
          _detailRow('Employee', detail.employeeName),
          _detailRow('Employee Code', detail.employeeCode),
          _detailRow('Salary Type', detail.salaryType.replaceAll('_', ' ')),
          _detailRow('Payroll Period', detail.period),
          _detailRow('Date Range', '${detail.fromDate} to ${detail.toDate}'),
        ],
      ),
    );
  }

  Widget _attendanceSection(SalaryPeriodDetailData detail) {
    return _section(
      title: 'Attendance',
      icon: Icons.calendar_month_outlined,
      child: Row(
        children: [
          Expanded(
            child: _plainMetric(
              'Working Days',
              _number(detail.workingDaysInMonth),
            ),
          ),
          _verticalDivider(),
          Expanded(child: _plainMetric('Present', _number(detail.daysPresent))),
          _verticalDivider(),
          Expanded(child: _plainMetric('Absent', _number(detail.daysAbsent))),
          _verticalDivider(),
          Expanded(child: _plainMetric('LOP', _number(detail.lopDays))),
        ],
      ),
    );
  }

  Widget _salaryCalculation(SalaryPeriodDetailData detail) {
    final earningsSubtotal = detail.lines
        .where(
          (line) =>
              line.lineType.toUpperCase() != 'DEDUCTION' &&
              (line.amount ?? 0) >= 0,
        )
        .fold<double>(0, (sum, line) => sum + (line.amount ?? 0));
    final deductionsSubtotal = detail.lines
        .where(
          (line) =>
              line.lineType.toUpperCase() == 'DEDUCTION' ||
              (line.amount ?? 0) < 0,
        )
        .fold<double>(0, (sum, line) => sum + (line.amount ?? 0).abs());
    final lineSubtotal = earningsSubtotal - deductionsSubtotal;
    final totalDeductions =
        (detail.lopDeduction ?? 0) + (detail.otherDeductions ?? 0);

    return _section(
      title: 'Salary Calculation',
      icon: Icons.calculate_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.lines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No salary calculation lines available',
                style: TextStyle(color: LoginColors.textSecondary),
              ),
            )
          else
            _salaryLinesTable(detail.lines),
          const SizedBox(height: 14),
          Divider(height: 1, color: LoginColors.borderLight),
          const SizedBox(height: 10),
          _totalRow('Earnings Subtotal', earningsSubtotal),
          _totalRow(
            'Deductions Subtotal',
            deductionsSubtotal,
            negative: deductionsSubtotal > 0,
          ),
          _totalRow('Calculated Line Total', lineSubtotal, emphasized: true),
          const SizedBox(height: 6),
          Divider(height: 1, color: LoginColors.borderLight),
          const SizedBox(height: 8),
          _totalRow('Gross Salary', detail.grossAmount ?? 0),
          if ((detail.lopDeduction ?? 0) > 0)
            _totalRow(
              'LOP Deduction',
              detail.lopDeduction ?? 0,
              negative: true,
            ),
          if ((detail.otherDeductions ?? 0) > 0)
            _totalRow(
              'Other Deductions',
              detail.otherDeductions ?? 0,
              negative: true,
            ),
          if (totalDeductions > 0)
            _totalRow('Total Deductions', totalDeductions, negative: true),
          _totalRow(
            'Net Payable',
            detail.netAmount ?? lineSubtotal,
            emphasized: true,
            accent: true,
          ),
        ],
      ),
    );
  }

  Widget _salaryLinesTable(List<SalaryLineData> lines) {
    const widths = <int, TableColumnWidth>{
      0: FixedColumnWidth(38),
      1: FixedColumnWidth(100),
      2: FixedColumnWidth(210),
      3: FixedColumnWidth(82),
      4: FixedColumnWidth(98),
      5: FixedColumnWidth(112),
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        columnWidths: widths,
        border: TableBorder.all(color: LoginColors.borderLight, width: 0.8),
        children: [
          TableRow(
            decoration: BoxDecoration(color: LoginColors.surfaceSecondary),
            children: const [
              _SalaryTableCell('#', header: true, centered: true),
              _SalaryTableCell('Type', header: true),
              _SalaryTableCell('Description', header: true),
              _SalaryTableCell('Qty', header: true, alignedRight: true),
              _SalaryTableCell('Rate', header: true, alignedRight: true),
              _SalaryTableCell('Amount', header: true, alignedRight: true),
            ],
          ),
          for (var index = 0; index < lines.length; index++)
            _salaryLineRow(lines[index], index),
        ],
      ),
    );
  }

  TableRow _salaryLineRow(SalaryLineData line, int index) {
    final isDeduction =
        line.lineType.toUpperCase() == 'DEDUCTION' || (line.amount ?? 0) < 0;
    final quantity = [
      _number(line.totalQty),
      if ((line.unit ?? '').trim().isNotEmpty) line.unit!.trim(),
    ].join(' ');
    final description = (line.workName ?? '').trim().isNotEmpty
        ? line.workName!.trim()
        : line.description;

    return TableRow(
      decoration: BoxDecoration(
        color: index.isOdd
            ? LoginColors.surfaceSecondary.withValues(alpha: 0.45)
            : LoginColors.surface,
      ),
      children: [
        _SalaryTableCell('${index + 1}', centered: true),
        _SalaryTableCell(line.lineType.replaceAll('_', ' ')),
        _SalaryTableCell(description),
        _SalaryTableCell(quantity, alignedRight: true),
        _SalaryTableCell(_amount(line.rateUsed), alignedRight: true),
        _SalaryTableCell(
          isDeduction
              ? '- ${_money((line.amount ?? 0).abs())}'
              : _money(line.amount),
          alignedRight: true,
          color: isDeduction ? LoginColors.error : LoginColors.textPrimary,
          bold: true,
        ),
      ],
    );
  }

  Widget _paymentSummary(SalaryPeriodDetailData detail) {
    return _section(
      title: 'Payment Summary',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _plainMetric('Net Salary', _money(detail.netAmount)),
              ),
              _verticalDivider(),
              Expanded(
                child: _plainMetric(
                  'Paid',
                  _money(detail.paidAmount),
                  color: LoginColors.success,
                ),
              ),
              _verticalDivider(),
              Expanded(
                child: _plainMetric(
                  'Balance',
                  _money(detail.balanceAmount),
                  color: LoginColors.accent,
                ),
              ),
            ],
          ),
          if ((detail.paymentRef ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _detailRow('Payment Reference', detail.paymentRef!.trim()),
          ],
        ],
      ),
    );
  }

  Widget _paymentHistory(List<SalaryPaymentData> payments) {
    return _section(
      title: 'Payment History (${payments.length})',
      icon: Icons.history_rounded,
      child: Column(
        children: [
          for (var index = 0; index < payments.length; index++) ...[
            _paymentRecord(payments[index]),
            if (index != payments.length - 1)
              Divider(height: 20, color: LoginColors.borderLight),
          ],
        ],
      ),
    );
  }

  Widget _paymentRecord(SalaryPaymentData payment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: LoginColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.payments_outlined,
            size: 18,
            color: LoginColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.expenseDate,
                style: TextStyle(
                  color: LoginColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                [
                  payment.paymentMode.replaceAll('_', ' '),
                  if ((payment.invoiceNo ?? '').trim().isNotEmpty)
                    payment.invoiceNo!.trim(),
                ].join('  |  '),
                style: TextStyle(
                  color: LoginColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              if ((payment.remark ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  payment.remark!.trim(),
                  style: TextStyle(
                    color: LoginColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _money(payment.amount),
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _auditSection(SalaryPeriodDetailData detail) {
    return _section(
      title: 'Processing Information',
      icon: Icons.schedule_outlined,
      child: Column(
        children: [
          if ((detail.computedDt ?? '').trim().isNotEmpty)
            _detailRow('Calculated At', detail.computedDt!.trim()),
          if ((detail.approvedDt ?? '').trim().isNotEmpty)
            _detailRow('Approved At', detail.approvedDt!.trim()),
          if ((detail.paidDt ?? '').trim().isNotEmpty)
            _detailRow('Paid At', detail.paidDt!.trim()),
        ],
      ),
    );
  }

  Widget _actions(SalaryPeriodDetailData detail) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: _isDownloading ? null : () => _download(detail),
            icon: _isDownloading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download_rounded),
            label: Text(_isDownloading ? 'Preparing...' : 'Download Slip'),
          ),
        ),
        if (detail.status.toUpperCase() == 'DRAFT') ...[
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isDeleting ? null : () => _deleteDraft(detail),
              style: OutlinedButton.styleFrom(
                foregroundColor: LoginColors.error,
              ),
              icon: _isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline_rounded),
              label: Text(_isDeleting ? 'Deleting...' : 'Delete Draft'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
              Icon(icon, color: LoginColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: LoginColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Text(
              label,
              style: TextStyle(
                color: LoginColors.textSecondary,
                fontSize: 12.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: LoginColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _plainMetric(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: LoginColors.textSecondary, fontSize: 10.5),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: color ?? LoginColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: LoginColors.borderLight,
    );
  }

  Widget _totalRow(
    String label,
    num value, {
    bool negative = false,
    bool emphasized = false,
    bool accent = false,
  }) {
    final color = accent
        ? LoginColors.primary
        : negative
        ? LoginColors.error
        : LoginColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasized
                    ? LoginColors.textPrimary
                    : LoginColors.textSecondary,
                fontSize: emphasized ? 13.5 : 12.5,
                fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${negative ? '- ' : ''}${_money(value.abs())}',
            style: TextStyle(
              color: color,
              fontSize: emphasized ? 14 : 13,
              fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final normalized = status.toUpperCase();
    final color = switch (normalized) {
      'PAID' => LoginColors.success,
      'PARTIALLY_PAID' => const Color(0xFFF59E0B),
      'APPROVED' => const Color(0xFF2563EB),
      _ => Colors.white,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalized.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  bool _hasAttendance(SalaryPeriodDetailData detail) {
    return detail.workingDaysInMonth != null ||
        detail.daysPresent != null ||
        detail.daysAbsent != null ||
        detail.lopDays != null;
  }

  bool _hasAudit(SalaryPeriodDetailData detail) {
    return (detail.computedDt ?? '').trim().isNotEmpty ||
        (detail.approvedDt ?? '').trim().isNotEmpty ||
        (detail.paidDt ?? '').trim().isNotEmpty;
  }

  String _money(num? value) =>
      value == null ? '-' : 'Rs ${value.toStringAsFixed(2)}';

  String _amount(num? value) => value == null ? '-' : value.toStringAsFixed(2);

  String _number(num? value) {
    if (value == null) return '-';
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }
}

class _SalaryTableCell extends StatelessWidget {
  final String value;
  final bool header;
  final bool centered;
  final bool alignedRight;
  final bool bold;
  final Color? color;

  const _SalaryTableCell(
    this.value, {
    this.header = false,
    this.centered = false,
    this.alignedRight = false,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        value,
        textAlign: centered
            ? TextAlign.center
            : alignedRight
            ? TextAlign.right
            : TextAlign.left,
        style: TextStyle(
          color:
              color ??
              (header ? LoginColors.textSecondary : LoginColors.textPrimary),
          fontSize: header ? 10.5 : 12,
          fontWeight: header || bold ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
  }
}
