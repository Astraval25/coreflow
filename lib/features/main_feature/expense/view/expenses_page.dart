import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/utils/common_formatters.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/data/repositories/main_repository/expense_repository.dart';
import 'package:coreflow/domain/model/main_model/expense/expense.dart';
import 'package:coreflow/domain/model/main_model/expense/expense_account.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'create_expense_page.dart';
import 'expense_type_picker_page.dart';

class ExpensesPage extends StatefulWidget {
  final int companyId;

  const ExpensesPage({super.key, required this.companyId});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final ExpenseRepository _expenseRepository = ExpenseRepository();
  bool _isSearchOpen = false;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  List<Expense> _expenses = const [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _expenseRepository.getExpenses(
        widget.companyId,
        activeOnly: true,
      );
      if (!mounted) return;
      data.sort(
        (a, b) => _safeDate(b.expenseDate).compareTo(_safeDate(a.expenseDate)),
      );
      setState(() => _expenses = data);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load expenses');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
      if (!_isSearchOpen) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  List<Expense> get _filteredExpenses {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return _expenses;
    return _expenses.where((expense) {
      return (expense.expenseAccountName ?? '').toLowerCase().contains(q) ||
          (expense.expenseAccountType ?? '').toLowerCase().contains(q) ||
          (expense.invoiceNo ?? '').toLowerCase().contains(q) ||
          (expense.vendorName ?? '').toLowerCase().contains(q) ||
          (expense.customerName ?? '').toLowerCase().contains(q) ||
          (expense.remark ?? '').toLowerCase().contains(q) ||
          expense.amount.toStringAsFixed(2).contains(q) ||
          expense.paymentMode.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openNewExpenseFlow() async {
    final selectedType = await Navigator.push<ExpenseAccount>(
      context,
      MaterialPageRoute(
        builder: (_) => ExpenseTypePickerPage(companyId: widget.companyId),
      ),
    );
    if (selectedType == null || !mounted) return;

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateExpensePage(
          companyId: widget.companyId,
          selectedAccount: selectedType,
        ),
      ),
    );
    if (created == true && mounted) {
      _loadExpenses();
    }
  }

  Future<void> _openExpenseDetail(Expense expense) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateExpensePage(
          companyId: widget.companyId,
          expenseId: expense.expenseId,
        ),
      ),
    );
    if (updated == true && mounted) {
      _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardVm = context.watch<DashboardViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      backgroundColor: LoginColors.background,
      appBar: SearchableEntityAppBar(
        isSearchOpen: _isSearchOpen,
        onSearchToggle: _toggleSearch,
        searchQuery: _searchQuery,
        searchController: _searchController,
        onSearchChanged: (value) => setState(() => _searchQuery = value),
        onClearSearch: () {
          _searchController.clear();
          setState(() => _searchQuery = '');
        },
        scaffoldKey: _scaffoldKey,
        title: 'Expenses',
        searchHint: 'Search expenses...',
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: LoginColors.primary,
        foregroundColor: Colors.white,
        onPressed: _openNewExpenseFlow,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Expense',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadExpenses,
        backgroundColor: LoginColors.surface,
        color: LoginColors.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _expenses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _expenses.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Text(_error!, style: TextStyle(color: LoginColors.error)),
          ),
        ],
      );
    }
    if (_filteredExpenses.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: LoginColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'No expenses found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: LoginColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: _filteredExpenses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final expense = _filteredExpenses[index];
        final party = (expense.vendorName ?? '').isNotEmpty
            ? expense.vendorName!
            : (expense.customerName ?? '').isNotEmpty
            ? expense.customerName!
            : '-';
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openExpenseDetail(expense),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: LoginColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        expense.expenseAccountName ?? 'Expense',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: LoginColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      formatMoney(expense.amount),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: LoginColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatDate(expense.expenseDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: LoginColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        expense.paymentMode.replaceAll('_', ' '),
                        style: TextStyle(
                          fontSize: 10.5,
                          color: LoginColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Type: ${expense.expenseAccountType ?? '-'}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: LoginColors.textSecondary,
                  ),
                ),
                Text(
                  'Party: $party',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: LoginColors.textSecondary,
                  ),
                ),
                if ((expense.remark ?? '').trim().isNotEmpty)
                  Text(
                    'Remark: ${expense.remark!.trim()}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: LoginColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  DateTime _safeDate(String raw) {
    return DateTime.tryParse(raw) ?? DateTime(1970);
  }

  String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('dd MMM yyyy').format(parsed);
  }
}
