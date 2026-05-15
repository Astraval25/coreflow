import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/repositories/main_repository/expense_repository.dart';
import 'package:coreflow/domain/model/main_model/expense/expense_account.dart';
import 'package:coreflow/domain/model/main_model/expense/expense_requests.dart';
import 'package:flutter/material.dart';

class CreateExpenseTypePage extends StatefulWidget {
  final int companyId;
  final ExpenseAccount? expenseAccount;

  const CreateExpenseTypePage({
    super.key,
    required this.companyId,
    this.expenseAccount,
  });

  @override
  State<CreateExpenseTypePage> createState() => _CreateExpenseTypePageState();
}

class _CreateExpenseTypePageState extends State<CreateExpenseTypePage> {
  final ExpenseRepository _repository = ExpenseRepository();
  final TextEditingController _nameCtrl = TextEditingController();
  List<String> _types = const ['Expense', 'Other Expense'];
  String _selectedType = 'Expense';
  bool _isLoading = false;
  String? _error;

  bool get _isUpdate => widget.expenseAccount != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.expenseAccount?.accountName ?? '';
    _selectedType = widget.expenseAccount?.accountType ?? _selectedType;
    _loadTypes();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTypes() async {
    final types = await _repository.getExpenseAccountTypes(widget.companyId);
    if (!mounted || types.isEmpty) return;
    setState(() {
      _types = types;
      if (!_types.contains(_selectedType)) {
        _selectedType = _types.first;
      }
    });
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Expense type name is required');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final request = ExpenseAccountRequest(
      accountType: _selectedType,
      accountName: name,
    );

    final result = _isUpdate
        ? await _repository.updateExpenseAccount(
            widget.companyId,
            widget.expenseAccount!.expenseAccountId,
            request,
          )
        : await _repository.createExpenseAccount(widget.companyId, request);

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (!result.success) {
      setState(() => _error = result.message);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isUpdate
              ? 'Expense type updated successfully'
              : 'Expense type created successfully',
        ),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        backgroundColor: LoginColors.background,
        elevation: 0,
        foregroundColor: LoginColors.textPrimary,
        title: Text(
          _isUpdate ? 'Update Expense Type' : 'Create Expense Type',
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          if (_error != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LoginColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: LoginColors.error.withValues(alpha: 0.2),
                ),
              ),
              child: Text(_error!, style: TextStyle(color: LoginColors.error)),
            ),
          ],
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LoginColors.borderLight),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Expense Type Name',
                    hintText: 'Transport, Utilities, Salary...',
                    filled: true,
                    fillColor: LoginColors.fieldFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: LoginColors.borderLight),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedType = value);
                  },
                  items: _types
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Account Type',
                    filled: true,
                    fillColor: LoginColors.fieldFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: LoginColors.borderLight),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_isUpdate ? 'Update Type' : 'Create Type'),
                    style: FilledButton.styleFrom(
                      backgroundColor: LoginColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
