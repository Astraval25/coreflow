import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/success_popup.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/data/repositories/main_repository/expense_repository.dart';
import 'package:coreflow/domain/model/main_model/customer/customer.dart';
import 'package:coreflow/domain/model/main_model/expense/expense.dart';
import 'package:coreflow/domain/model/main_model/expense/expense_account.dart';
import 'package:coreflow/domain/model/main_model/expense/expense_requests.dart';
import 'package:coreflow/domain/model/main_model/vendors/vendors.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateExpensePage extends StatefulWidget {
  final int companyId;
  final int? expenseId;
  final ExpenseAccount? selectedAccount;
  final int? salaryPeriodId;
  final double? initialAmount;
  final String? initialRemark;
  final String? salaryEmployeeName;
  final String? salaryPeriodLabel;

  const CreateExpensePage({
    super.key,
    required this.companyId,
    this.expenseId,
    this.selectedAccount,
    this.salaryPeriodId,
    this.initialAmount,
    this.initialRemark,
    this.salaryEmployeeName,
    this.salaryPeriodLabel,
  });

  @override
  State<CreateExpensePage> createState() => _CreateExpensePageState();
}

class _CreateExpensePageState extends State<CreateExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _invoiceCtrl = TextEditingController();
  final _remarkCtrl = TextEditingController();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;
  String? _error;
  DateTime _expenseDate = DateTime.now();
  String _paymentMode = 'BANK_TRANSFER';
  List<ExpenseAccount> _accounts = const [];
  List<Customer> _customers = const [];
  List<Vendor> _vendors = const [];
  int? _selectedAccountId;
  int? _selectedCustomerId;
  int? _selectedVendorId;
  int? _salaryPeriodId;

  static const List<String> _paymentModes = [
    'BANK_TRANSFER',
    'CASH',
    'CHEQUE',
    'UPI',
    'CREDIT_CARD',
    'DEBIT_CARD',
    'OTHER',
  ];

  bool get _isEditMode => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.selectedAccount?.expenseAccountId;
    _salaryPeriodId = widget.salaryPeriodId;
    if (widget.initialAmount != null) {
      _amountCtrl.text = widget.initialAmount!.toStringAsFixed(2);
    }
    _remarkCtrl.text = widget.initialRemark ?? '';
    _load();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _invoiceCtrl.dispose();
    _remarkCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _expenseRepository.getExpenseAccounts(
          widget.companyId,
          activeOnly: true,
        ),
        _authRepository.getCustomers(widget.companyId),
        _authRepository.getActiveVendors(widget.companyId),
      ]);
      if (!mounted) return;
      _accounts = results[0] as List<ExpenseAccount>;
      _customers = results[1] as List<Customer>;
      _vendors = results[2] as List<Vendor>;

      if (_isEditMode) {
        final detail = await _expenseRepository.getExpenseDetail(
          widget.companyId,
          widget.expenseId!,
        );
        if (detail != null && mounted) {
          _applyExpenseDetail(detail);
        }
      } else if (_selectedAccountId == null && _accounts.isNotEmpty) {
        _selectedAccountId = _defaultExpenseAccountId();
      }
    } catch (_) {
      if (!mounted) return;
      _error = 'Failed to load expense form';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyExpenseDetail(Expense e) {
    _selectedAccountId = e.expenseAccountId;
    _selectedCustomerId = e.customerId;
    _selectedVendorId = e.vendorId;
    _salaryPeriodId = e.salaryPeriodId;
    _paymentMode = e.paymentMode.isEmpty ? _paymentMode : e.paymentMode;
    // The API stores Savings as a negative value; the form always edits the
    // user-facing magnitude and lets the server apply the account sign.
    _amountCtrl.text = e.amount.abs().toStringAsFixed(2);
    _invoiceCtrl.text = e.invoiceNo ?? '';
    _remarkCtrl.text = e.remark ?? '';
    try {
      _expenseDate = DateTime.parse(e.expenseDate);
    } catch (_) {}
    setState(() {});
  }

  int _defaultExpenseAccountId() {
    if (_salaryPeriodId != null) {
      for (final account in _accounts) {
        if (account.accountName.toLowerCase().contains('salary')) {
          return account.expenseAccountId;
        }
      }
    }
    return _accounts.first.expenseAccountId;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && mounted) {
      setState(() => _expenseDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) {
      setState(() => _error = 'Please select an expense type');
      return;
    }
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Please enter a valid amount');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final request = ExpenseRequest(
      expenseDate: DateFormat('yyyy-MM-dd').format(_expenseDate),
      paymentMode: _paymentMode,
      amount: amount,
      expenseAccountId: _selectedAccountId!,
      invoiceNo: _invoiceCtrl.text.trim(),
      vendorId: _selectedVendorId,
      customerId: _selectedCustomerId,
      remark: _remarkCtrl.text.trim(),
      salaryPeriodId: _salaryPeriodId,
    );

    final result = _isEditMode
        ? await _expenseRepository.updateExpense(
            widget.companyId,
            widget.expenseId!,
            request,
          )
        : await _expenseRepository.createExpense(widget.companyId, request);

    if (!mounted) return;
    if (!result.success) {
      setState(() {
        _isLoading = false;
        _error = result.message;
      });
      return;
    }

    await showSuccessPopup(
      context: context,
      message: _isEditMode
          ? 'Expense updated successfully'
          : 'Expense created successfully',
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final dashboardVm = context.watch<DashboardViewModel>();
    final modeLabel = _isEditMode ? 'Update Expense' : 'Create Expense';

    return Scaffold(
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          modeLabel,
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: LoginColors.textPrimary,
        backgroundColor: LoginColors.background,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: LoginColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: LoginColors.error.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(color: LoginColors.error),
                      ),
                    ),
                  ],
                  if (_salaryPeriodId != null) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: LoginColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: LoginColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.payments_outlined,
                            color: LoginColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Salary Payment',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: LoginColors.textPrimary,
                                  ),
                                ),
                                if ((widget.salaryEmployeeName ?? '')
                                    .isNotEmpty)
                                  Text(
                                    '${widget.salaryEmployeeName} • ${widget.salaryPeriodLabel ?? ''}',
                                    style: TextStyle(
                                      color: LoginColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  _buildSection(
                    title: 'Expense Details',
                    icon: Icons.receipt_long_rounded,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(10),
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              label: 'Expense Date',
                              icon: Icons.calendar_today_rounded,
                            ),
                            child: Text(
                              DateFormat('dd MMM yyyy').format(_expenseDate),
                              style: TextStyle(
                                fontSize: 15,
                                color: LoginColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _paymentMode,
                          isExpanded: true,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _paymentMode = value);
                            }
                          },
                          items: _paymentModes
                              .map(
                                (mode) => DropdownMenuItem(
                                  value: mode,
                                  child: Text(mode.replaceAll('_', ' ')),
                                ),
                              )
                              .toList(),
                          decoration: _inputDecoration(
                            label: 'Payment Mode',
                            icon: Icons.payments_rounded,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _amountCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Amount is required';
                            }
                            final n = double.tryParse(value.trim());
                            if (n == null || n <= 0) {
                              return 'Must be greater than 0';
                            }
                            return null;
                          },
                          decoration: _inputDecoration(
                            label: 'Amount',
                            icon: Icons.currency_rupee_rounded,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          key: ValueKey(
                            'expense-account-${_selectedAccountId ?? 'none'}-${_accounts.length}',
                          ),
                          initialValue: _selectedAccountId,
                          isExpanded: true,
                          onChanged: (value) =>
                              setState(() => _selectedAccountId = value),
                          items: _accounts
                              .map(
                                (account) => DropdownMenuItem(
                                  value: account.expenseAccountId,
                                  child: Text(
                                    '${account.accountName} • ${account.accountType}',
                                  ),
                                ),
                              )
                              .toList(),
                          decoration: _inputDecoration(
                            label: 'Expense Type',
                            icon: Icons.category_rounded,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _invoiceCtrl,
                          decoration: _inputDecoration(
                            label: 'Invoice No (optional)',
                            icon: Icons.confirmation_number_rounded,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int?>(
                          key: ValueKey(
                            'expense-vendor-${_selectedVendorId ?? 'none'}-${_vendors.length}',
                          ),
                          initialValue: _selectedVendorId,
                          isExpanded: true,
                          onChanged: (value) =>
                              setState(() => _selectedVendorId = value),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('No Vendor'),
                            ),
                            ..._vendors.map(
                              (vendor) => DropdownMenuItem<int?>(
                                value: vendor.vendorId,
                                child: Text(
                                  vendor.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          decoration: _inputDecoration(
                            label: 'Vendor (optional)',
                            icon: Icons.store_rounded,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int?>(
                          key: ValueKey(
                            'expense-customer-${_selectedCustomerId ?? 'none'}-${_customers.length}',
                          ),
                          initialValue: _selectedCustomerId,
                          isExpanded: true,
                          onChanged: (value) =>
                              setState(() => _selectedCustomerId = value),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('No Customer'),
                            ),
                            ..._customers.map(
                              (customer) => DropdownMenuItem<int?>(
                                value: customer.customerId,
                                child: Text(
                                  customer.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          decoration: _inputDecoration(
                            label: 'Customer (optional)',
                            icon: Icons.person_rounded,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _remarkCtrl,
                          maxLines: 2,
                          decoration: _inputDecoration(
                            label: 'Remark (optional)',
                            icon: Icons.notes_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.15),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          color: LoginColors.surface,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(
                _isEditMode ? 'Update Expense' : 'Create Expense',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: LoginColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: LoginColors.primary, size: 18),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: LoginColors.borderLight, height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 13, color: LoginColors.textSecondary),
      prefixIcon: Icon(icon, size: 18, color: LoginColors.textTertiary),
      filled: true,
      fillColor: LoginColors.fieldFill,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: LoginColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: LoginColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: LoginColors.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: LoginColors.error),
      ),
    );
  }
}
