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
    } catch (e) {
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 42,
                      color: LoginColors.error,
                    ),
                    const SizedBox(height: 12),
                    const Text('Failed to load salary details'),
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

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _summaryCard(detail),
                const SizedBox(height: 14),
                _section(
                  title: 'Period and Employee',
                  icon: Icons.badge_outlined,
                  children: [
                    _detailRow('Salary Period ID', '${detail.salaryPeriodId}'),
                    _detailRow('Employee ID', '${detail.employeeId}'),
                    _detailRow('Employee', detail.employeeName),
                    _detailRow('Employee Code', detail.employeeCode),
                    _detailRow('Period', detail.period),
                    _detailRow('From Date', detail.fromDate),
                    _detailRow('To Date', detail.toDate),
                    _detailRow('Salary Type', detail.salaryType),
                    _detailRow('Status', detail.status),
                  ],
                ),
                const SizedBox(height: 14),
                _section(
                  title: 'Attendance and Calculation',
                  icon: Icons.calculate_outlined,
                  children: [
                    _detailRow(
                      'Working Days',
                      _number(detail.workingDaysInMonth),
                    ),
                    _detailRow('Days Present', _number(detail.daysPresent)),
                    _detailRow('Days Absent', _number(detail.daysAbsent)),
                    _detailRow('LOP Days', _number(detail.lopDays)),
                    _detailRow('Gross Amount', _money(detail.grossAmount)),
                    _detailRow('LOP Deduction', _money(detail.lopDeduction)),
                    _detailRow(
                      'Other Deductions',
                      _money(detail.otherDeductions),
                    ),
                    _detailRow('Net Amount', _money(detail.netAmount)),
                    _detailRow('Paid Amount', _money(detail.paidAmount)),
                    _detailRow('Balance Amount', _money(detail.balanceAmount)),
                    _detailRow('Payment Count', _number(detail.paymentCount)),
                  ],
                ),
                const SizedBox(height: 14),
                _section(
                  title: 'Audit Information',
                  icon: Icons.history_rounded,
                  children: [
                    _detailRow('Computed At', _text(detail.computedDt)),
                    _detailRow('Approved By', _number(detail.approvedBy)),
                    _detailRow('Approved At', _text(detail.approvedDt)),
                    _detailRow('Paid At', _text(detail.paidDt)),
                    _detailRow('Payment Reference', _text(detail.paymentRef)),
                  ],
                ),
                const SizedBox(height: 14),
                _linesSection(detail.lines),
                const SizedBox(height: 14),
                _paymentsSection(detail.payments),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _isDownloading
                          ? null
                          : () => _download(detail),
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
                      label: Text(
                        _isDownloading ? 'Preparing...' : 'Download Slip',
                      ),
                    ),
                    if (detail.status.toUpperCase() == 'DRAFT')
                      OutlinedButton.icon(
                        onPressed: _isDeleting
                            ? null
                            : () => _deleteDraft(detail),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: LoginColors.error,
                        ),
                        icon: _isDeleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.delete_outline_rounded),
                        label: Text(
                          _isDeleting ? 'Deleting...' : 'Delete Draft',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCard(SalaryPeriodDetailData detail) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LoginColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${detail.employeeName} (${detail.employeeCode})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${detail.fromDate} to ${detail.toDate}',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _summaryValue('Net Salary', _money(detail.netAmount)),
              _summaryValue('Paid', _money(detail.paidAmount)),
              _summaryValue('Balance', _money(detail.balanceAmount)),
              _summaryValue('Status', detail.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _linesSection(List<SalaryLineData> lines) {
    return _section(
      title: 'Salary Lines (${lines.length})',
      icon: Icons.format_list_bulleted_rounded,
      children: lines.isEmpty
          ? [const Text('No salary lines available')]
          : lines
                .map((line) {
                  return _nestedCard([
                    _detailRow('Line ID', '${line.lineId}'),
                    _detailRow('Type', line.lineType),
                    _detailRow('Description', line.description),
                    _detailRow('Quantity', _number(line.totalQty)),
                    _detailRow('Unit', _text(line.unit)),
                    _detailRow('Rate Used', _money(line.rateUsed)),
                    _detailRow('Amount', _money(line.amount)),
                    _detailRow('Work Definition ID', _number(line.workDefId)),
                    _detailRow('Work Name', _text(line.workName)),
                  ]);
                })
                .toList(growable: false),
    );
  }

  Widget _paymentsSection(List<SalaryPaymentData> payments) {
    return _section(
      title: 'Payments (${payments.length})',
      icon: Icons.account_balance_wallet_outlined,
      children: payments.isEmpty
          ? [const Text('No salary payments recorded')]
          : payments
                .map((payment) {
                  return _nestedCard([
                    _detailRow('Expense ID', _number(payment.expenseId)),
                    _detailRow('Expense Date', payment.expenseDate),
                    _detailRow('Payment Mode', payment.paymentMode),
                    _detailRow('Amount', _money(payment.amount)),
                    _detailRow('Invoice No', _text(payment.invoiceNo)),
                    _detailRow('Remark', _text(payment.remark)),
                  ]);
                })
                .toList(growable: false),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
          ...children,
        ],
      ),
    );
  }

  Widget _nestedCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LoginColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(children: children),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: TextStyle(color: LoginColors.textSecondary, fontSize: 13),
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

  String _money(num? value) =>
      value == null ? '-' : '₹${value.toStringAsFixed(2)}';

  String _number(num? value) {
    if (value == null) return '-';
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  String _text(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? '-' : text;
  }
}
