import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/utils/common_formatters.dart';
import 'package:coreflow/data/repositories/main_repository/expense_repository.dart';
import 'package:coreflow/domain/model/main_model/expense/expense.dart';
import 'package:coreflow/features/main_feature/expense/view/create_expense_page.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ExpenseDetailPage extends StatefulWidget {
  final int companyId;
  final int expenseId;

  const ExpenseDetailPage({
    super.key,
    required this.companyId,
    required this.expenseId,
  });

  @override
  State<ExpenseDetailPage> createState() => _ExpenseDetailPageState();
}

class _ExpenseDetailPageState extends State<ExpenseDetailPage> {
  final ExpenseRepository _repository = ExpenseRepository();
  late Future<Expense?> _expenseFuture;
  bool _wasUpdated = false;

  @override
  void initState() {
    super.initState();
    _expenseFuture = _loadExpense();
  }

  Future<Expense?> _loadExpense() {
    return _repository.getExpenseDetail(widget.companyId, widget.expenseId);
  }

  Future<void> _refresh() async {
    setState(() => _expenseFuture = _loadExpense());
    await _expenseFuture;
  }

  Future<void> _editExpense() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateExpensePage(
          companyId: widget.companyId,
          expenseId: widget.expenseId,
        ),
      ),
    );
    if (updated == true && mounted) {
      _wasUpdated = true;
      await _refresh();
    }
  }

  void _close() {
    context.pop(_wasUpdated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        backgroundColor: LoginColors.background,
        foregroundColor: LoginColors.textPrimary,
        leading: IconButton(
          onPressed: _close,
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            onPressed: _editExpense,
            tooltip: 'Edit Expense',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: FutureBuilder<Expense?>(
        future: _expenseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final expense = snapshot.data;
          if (snapshot.hasError || expense == null) {
            return _errorState();
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                _amountHeader(expense),
                const SizedBox(height: 12),
                _detailsSection(expense),
                const SizedBox(height: 12),
                _recordSection(expense),
                if (expense.salaryPeriodId != null) ...[
                  const SizedBox(height: 12),
                  _salaryLink(expense.salaryPeriodId!),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _editExpense,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Expense'),
                  ),
                ),
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
              'Unable to load expense details',
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

  Widget _amountHeader(Expense expense) {
    final isSavings =
        expense.amount < 0 ||
        expense.expenseAccountType?.toLowerCase() == 'savings';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isSavings ? LoginColors.success : LoginColors.primary,
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
                      _value(expense.expenseAccountName, fallback: 'Expense'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(expense.expenseDate),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(expense.isActive),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            isSavings ? 'Savings' : 'Expense',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Rs ${formatMoney(expense.amount).trim()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsSection(Expense expense) {
    final party = _party(expense);
    return _section(
      title: 'Expense Information',
      icon: Icons.receipt_long_outlined,
      children: [
        _detailRow('Date', _formatDate(expense.expenseDate)),
        _detailRow('Expense Type', _value(expense.expenseAccountType)),
        _detailRow('Payment Mode', _displayEnum(expense.paymentMode)),
        _detailRow('Invoice Number', _value(expense.invoiceNo)),
        _detailRow('Paid To / For', party),
        _detailRow('Remark', _value(expense.remark)),
      ],
    );
  }

  Widget _recordSection(Expense expense) {
    return _section(
      title: 'Record Information',
      icon: Icons.info_outline_rounded,
      children: [
        _detailRow('Expense Number', '#${expense.expenseId}'),
        _detailRow('Created', _formatDateTime(expense.createdDt)),
        _detailRow('Last Updated', _formatDateTime(expense.lastModifiedDt)),
      ],
    );
  }

  Widget _salaryLink(int salaryPeriodId) {
    return Material(
      color: LoginColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(
          CfRoutes.employeeSalaryDetail(widget.companyId, salaryPeriodId),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: LoginColors.borderLight),
          ),
          child: Row(
            children: [
              Icon(Icons.payments_outlined, color: LoginColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Salary Payment',
                      style: TextStyle(
                        color: LoginColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Linked to salary period #$salaryPeriodId',
                      style: TextStyle(
                        color: LoginColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: LoginColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
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
              Icon(icon, size: 19, color: LoginColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: LoginColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
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

  Widget _statusBadge(bool isActive) {
    final color = isActive ? LoginColors.success : LoginColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: TextStyle(
          color: isActive ? Colors.white : color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _party(Expense expense) {
    if ((expense.vendorName ?? '').trim().isNotEmpty) {
      return expense.vendorName!.trim();
    }
    if ((expense.customerName ?? '').trim().isNotEmpty) {
      return expense.customerName!.trim();
    }
    return '-';
  }

  String _value(String? value, {String fallback = '-'}) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _displayEnum(String value) {
    final text = value.trim();
    if (text.isEmpty) return '-';
    return text
        .split('_')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part.substring(0, 1).toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    return parsed == null
        ? _value(raw)
        : DateFormat('dd MMM yyyy').format(parsed);
  }

  String _formatDateTime(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return '-';
    final parsed = DateTime.tryParse(value);
    return parsed == null
        ? value
        : DateFormat('dd MMM yyyy, hh:mm a').format(parsed.toLocal());
  }
}
