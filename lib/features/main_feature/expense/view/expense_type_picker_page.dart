import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/repositories/main_repository/expense_repository.dart';
import 'package:coreflow/domain/model/main_model/expense/expense_account.dart';
import 'package:flutter/material.dart';

import 'create_expense_type_page.dart';

class ExpenseTypePickerPage extends StatefulWidget {
  final int companyId;

  const ExpenseTypePickerPage({super.key, required this.companyId});

  @override
  State<ExpenseTypePickerPage> createState() => _ExpenseTypePickerPageState();
}

class _ExpenseTypePickerPageState extends State<ExpenseTypePickerPage> {
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;
  List<ExpenseAccount> _accounts = const [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final accounts = await _expenseRepository.getExpenseAccounts(
        widget.companyId,
        activeOnly: true,
      );
      if (!mounted) return;
      setState(() => _accounts = accounts);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load expense types');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<ExpenseAccount> get _filtered {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return _accounts;
    return _accounts.where((a) {
      return a.accountName.toLowerCase().contains(q) ||
          a.accountType.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openCreateType() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateExpenseTypePage(companyId: widget.companyId),
      ),
    );
    if (created == true && mounted) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'Select Expense Type (${_accounts.length})',
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: LoginColors.textPrimary,
        backgroundColor: LoginColors.background,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateType,
        backgroundColor: LoginColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Expense Type',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        backgroundColor: LoginColors.surface,
        color: LoginColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            if (_error != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: LoginColors.error.withValues(alpha: 0.08),
                  border: Border.all(
                    color: LoginColors.error.withValues(alpha: 0.25),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: LoginColors.error),
                ),
              ),
            ],
            TextField(
              controller: _searchCtrl,
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: 'Search expense types...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: LoginColors.fieldFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: LoginColors.borderLight),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_isLoading && _accounts.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'No expense types found',
                    style: TextStyle(color: LoginColors.textSecondary),
                  ),
                ),
              )
            else
              ..._filtered.map(
                (account) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: LoginColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: LoginColors.borderLight),
                  ),
                  child: ListTile(
                    onTap: () => Navigator.pop(context, account),
                    title: Text(
                      account.accountName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(account.accountType),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: LoginColors.textTertiary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
