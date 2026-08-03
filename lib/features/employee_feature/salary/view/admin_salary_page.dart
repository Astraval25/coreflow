import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/features/employee_feature/salary/service/salary_file_service.dart';
import 'package:coreflow/features/employee_feature/salary/view_model/admin_salary_view_model.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminSalaryPage extends StatelessWidget {
  final int companyId;

  const AdminSalaryPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(
          create: (_) => AdminSalaryViewModel(EmployeeRepository()),
        ),
      ],
      child: _AdminSalaryView(companyId: companyId),
    );
  }
}

class _AdminSalaryView extends StatefulWidget {
  final int companyId;

  const _AdminSalaryView({required this.companyId});

  @override
  State<_AdminSalaryView> createState() => _AdminSalaryViewState();
}

class _AdminSalaryViewState extends State<_AdminSalaryView> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isSearchOpen = false;
  String _searchQuery = '';
  int? _selectedEmployeeId;
  int? _selectedEmployeeFilterId;
  int? _downloadingSalaryPeriodId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminSalaryViewModel>().loadInitial(widget.companyId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? LoginColors.error : null,
      ),
    );
  }

  Future<void> _pickRange(AdminSalaryViewModel vm) async {
    final fromInitial = DateTime.tryParse(vm.fromDate) ?? DateTime.now();
    final pickedFrom = await showDatePicker(
      context: context,
      initialDate: fromInitial,
      firstDate: DateTime(fromInitial.year - 2),
      lastDate: DateTime(fromInitial.year + 2),
    );
    if (pickedFrom == null || !mounted) return;

    final toInitial = DateTime.tryParse(vm.toDate) ?? pickedFrom;
    final pickedTo = await showDatePicker(
      context: context,
      initialDate: pickedFrom.isAfter(toInitial) ? pickedFrom : toInitial,
      firstDate: pickedFrom,
      lastDate: DateTime(pickedFrom.year + 2),
    );
    if (pickedTo == null) return;

    await vm.updateReportRange(
      fromDate: _formatDate(pickedFrom),
      toDate: _formatDate(pickedTo),
    );
  }

  Future<void> _calculateSalary(AdminSalaryViewModel vm) async {
    final targets = _calculateTargets(vm);
    if (targets.isEmpty) {
      _showMessage(
        'No employees available for salary calculation',
        isError: true,
      );
      return;
    }

    final confirmed = await _showCalculateConfirmDialog(vm, targets);
    if (!mounted || confirmed != true) return;

    final ok = await vm.calculateSalary(
      CalculateSalaryRequest(
        fromDate: vm.fromDate,
        toDate: vm.toDate,
        employeeId: _selectedEmployeeId,
      ),
    );
    if (!mounted) return;
    _showMessage(
      ok
          ? (vm.message ?? 'Salary calculated successfully')
          : (vm.error ?? 'Failed to calculate salary'),
      isError: !ok,
    );
  }

  Future<bool?> _showCalculateConfirmDialog(
    AdminSalaryViewModel vm,
    List<Employee> targets,
  ) {
    final previewNames = targets
        .take(6)
        .map(
          (employee) => '${employee.employeeName} (${employee.employeeCode})',
        )
        .toList();
    final remainingCount = targets.length - previewNames.length;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Salary Run'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please review the payroll details before running salary calculation.',
                  style: TextStyle(color: LoginColors.textSecondary),
                ),
                const SizedBox(height: 16),
                _confirmInfoRow('From', vm.fromDate),
                _confirmInfoRow('To', vm.toDate),
                _confirmInfoRow(
                  'Employees',
                  _selectedEmployeeId == null
                      ? 'All active employees (${targets.length})'
                      : previewNames.first,
                ),
                const SizedBox(height: 12),
                Text(
                  'Included in this run',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...previewNames.map(
                      (name) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: LoginColors.background,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: LoginColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    if (remainingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: LoginColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '+$remainingCount more',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: LoginColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Run Payroll'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSalaryDetail(
    AdminSalaryViewModel vm,
    SalaryPeriodSummary period,
  ) async {
    final changed = await context.push<bool>(
      CfRoutes.employeeSalaryDetail(widget.companyId, period.salaryPeriodId),
    );
    if (changed == true && mounted) {
      await vm.refresh();
    }
  }

  Future<void> _downloadSalarySlip(
    AdminSalaryViewModel vm,
    SalaryPeriodSummary period,
  ) async {
    setState(() {
      _downloadingSalaryPeriodId = period.salaryPeriodId;
    });

    try {
      final bytes = await vm.downloadSalarySlip(period.salaryPeriodId);
      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        _showMessage('Failed to download salary slip', isError: true);
        return;
      }

      final fileName =
          'salary-slip-${period.employeeCode}-${period.period}.pdf';
      await SalaryFileService.shareSalarySlip(bytes: bytes, fileName: fileName);
      if (!mounted) return;
      _showMessage('Salary slip is ready to share or save');
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to download salary slip: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _downloadingSalaryPeriodId = null;
        });
      }
    }
  }

  Future<void> _approveSalary(
    AdminSalaryViewModel vm,
    SalaryPeriodSummary period,
  ) async {
    final ok = await vm.approveSalaryPeriod(period.salaryPeriodId);
    if (!mounted) return;
    _showMessage(
      ok
          ? (vm.message ?? 'Salary period approved successfully')
          : (vm.error ?? 'Failed to approve salary period'),
      isError: !ok,
    );
  }

  Future<void> _deleteSalary(
    AdminSalaryViewModel vm,
    SalaryPeriodSummary period,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Draft Salary?'),
        content: Text(
          'Delete the draft salary calculation for ${period.employeeName}, '
          '${period.fromDate} to ${period.toDate}? This cannot be undone.',
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

    final ok = await vm.deleteSalaryPeriod(period.salaryPeriodId);
    if (!mounted) return;
    _showMessage(
      ok
          ? (vm.message ?? 'Draft salary period deleted successfully')
          : (vm.error ?? 'Failed to delete salary period'),
      isError: !ok,
    );
  }

  Future<void> _recordSalaryPayment(
    AdminSalaryViewModel vm,
    SalaryPeriodSummary period,
  ) async {
    final created = await context.push<bool>(
      CfRoutes.expenseCreate(widget.companyId),
      extra: <String, dynamic>{
        'salaryPeriodId': period.salaryPeriodId,
        'initialAmount': period.balanceAmount ?? period.netAmount,
        'initialRemark':
            'Salary payment for ${period.employeeName} (${period.employeeCode}), period ${period.period}',
        'salaryEmployeeName': '${period.employeeName} (${period.employeeCode})',
        'salaryPeriodLabel': period.period,
      },
    );
    if (created == true && mounted) {
      await vm.refresh();
    }
  }

  void _goToDashboard() {
    context.go(CfRoutes.dashboard(widget.companyId));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminSalaryViewModel>();
    final dashboardVm = context.watch<DashboardViewModel>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _goToDashboard();
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawerEnableOpenDragGesture: false,
        drawer: AppDrawer(vm: dashboardVm),
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
          title: 'Salary',
          searchHint: 'Search salary periods...',
        ),
        body: RefreshIndicator(
          onRefresh: vm.refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _periodCard(vm),
              const SizedBox(height: 16),
              _calculateCard(vm),
              const SizedBox(height: 16),
              _employeeFilterCard(vm),
              const SizedBox(height: 16),
              if (vm.salaryReport != null) ...[
                _reportCard(vm.salaryReport!),
                const SizedBox(height: 16),
              ],
              _salaryList(vm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _employeeFilterCard(AdminSalaryViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: DropdownButtonFormField<int?>(
        initialValue: _selectedEmployeeFilterId,
        decoration: const InputDecoration(
          labelText: 'View Specific Employee',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('All Employees'),
          ),
          ...vm.employees.map((employee) {
            return DropdownMenuItem<int?>(
              value: employee.employeeId,
              child: Text(
                '${employee.employeeName} (${employee.employeeCode})',
              ),
            );
          }),
        ],
        onChanged: (value) {
          setState(() {
            _selectedEmployeeFilterId = value;
          });
        },
      ),
    );
  }

  Widget _periodCard(AdminSalaryViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 16,
                color: LoginColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Salary Period',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary,
                ),
              ),
            ],
          ),
          _periodValueChip('Period', vm.selectedPeriod),
          _periodValueChip('From', vm.fromDate),
          _periodValueChip('To', vm.toDate),
          OutlinedButton.icon(
            onPressed: () => _pickRange(vm),
            icon: const Icon(Icons.date_range_rounded, size: 16),
            label: const Text('Change Range'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _periodValueChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: LoginColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: LoginColors.textSecondary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _calculateCard(AdminSalaryViewModel vm) {
    final targets = _calculateTargets(vm);

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
            'Calculate Salary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            initialValue: _selectedEmployeeId,
            decoration: const InputDecoration(
              labelText: 'Employee',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('All Active Employees'),
              ),
              ...vm.employees.map((employee) {
                return DropdownMenuItem<int?>(
                  value: employee.employeeId,
                  child: Text(
                    '${employee.employeeName} (${employee.employeeCode})',
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedEmployeeId = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: LoginColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Run Preview',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                _detailRow('Range', '${vm.fromDate} to ${vm.toDate}'),
                _detailRow(
                  'Scope',
                  _selectedEmployeeId == null
                      ? 'All active employees (${targets.length})'
                      : (targets.isEmpty
                            ? 'No employee selected'
                            : '${targets.first.employeeName} (${targets.first.employeeCode})'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: vm.isSaving ? null : () => _calculateSalary(vm),
              icon: const Icon(Icons.calculate_rounded),
              label: Text(
                vm.isSaving ? 'Calculating...' : 'Review and Calculate',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(SalaryReportData report) {
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
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _metricTile('Range', '${report.fromDate} to ${report.toDate}'),
              _metricTile('Employees', report.totalEmployees.toString()),
              _metricTile('Gross', _currency(report.totalGrossAmount)),
              _metricTile('Deductions', _currency(report.totalDeductions)),
              _metricTile('Net', _currency(report.totalNetAmount)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _salaryList(AdminSalaryViewModel vm) {
    if (vm.isLoading && vm.salaryPeriods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = _filteredSalaryPeriods(vm);

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Center(
          child: Text(
            'No salary periods found',
            style: TextStyle(color: LoginColors.textSecondary),
          ),
        ),
      );
    }

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
          _sectionTitle(
            'All Salary Periods',
            '${filtered.length} records available',
          ),
          const SizedBox(height: 12),
          ...filtered.map((period) => _salaryCard(vm, period)),
        ],
      ),
    );
  }

  Widget _salaryCard(AdminSalaryViewModel vm, SalaryPeriodSummary period) {
    final status = period.status.toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LoginColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${period.employeeName} (${period.employeeCode})',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
              ),
              _statusChip(status),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _miniInfoChip('Period', period.period),
              _miniInfoChip('Type', period.salaryType),
              _miniInfoChip('From', period.fromDate),
              _miniInfoChip('To', period.toDate),
              _miniInfoChip('Gross', _currency(period.grossAmount)),
              _miniInfoChip('Net', _currency(period.netAmount)),
              if (period.paidAmount != null)
                _miniInfoChip('Paid', _currency(period.paidAmount)),
              if (period.balanceAmount != null)
                _miniInfoChip('Balance', _currency(period.balanceAmount)),
              if (period.paymentCount != null)
                _miniInfoChip('Payments', period.paymentCount.toString()),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showSalaryDetail(vm, period),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('View Detail'),
              ),
              OutlinedButton.icon(
                onPressed: _downloadingSalaryPeriodId == period.salaryPeriodId
                    ? null
                    : () => _downloadSalarySlip(vm, period),
                icon: _downloadingSalaryPeriodId == period.salaryPeriodId
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download_rounded),
                label: Text(
                  _downloadingSalaryPeriodId == period.salaryPeriodId
                      ? 'Preparing...'
                      : 'Download Slip',
                ),
              ),
              if (status == 'DRAFT')
                FilledButton.icon(
                  onPressed: vm.isSaving
                      ? null
                      : () => _approveSalary(vm, period),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Approve'),
                ),
              if (status == 'DRAFT')
                OutlinedButton.icon(
                  onPressed: vm.isSaving
                      ? null
                      : () => _deleteSalary(vm, period),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LoginColors.error,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete Draft'),
                ),
              if (status == 'APPROVED' || status == 'PARTIALLY_PAID')
                FilledButton.icon(
                  onPressed: vm.isSaving
                      ? null
                      : () => _recordSalaryPayment(vm, period),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Record Payment'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(color: LoginColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: LoginColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: LoginColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: LoginColors.textSecondary),
        ),
      ],
    );
  }

  Widget _metricTile(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LoginColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: LoginColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: LoginColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: LoginColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: LoginColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: LoginColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = switch (status) {
      'PAID' => LoginColors.success,
      'PARTIALLY_PAID' => const Color(0xFFF59E0B),
      'APPROVED' => const Color(0xFF2563EB),
      _ => LoginColors.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  List<Employee> _calculateTargets(AdminSalaryViewModel vm) {
    if (_selectedEmployeeId == null) return vm.employees;
    return vm.employees
        .where((employee) => employee.employeeId == _selectedEmployeeId)
        .toList();
  }

  List<SalaryPeriodSummary> _filteredSalaryPeriods(AdminSalaryViewModel vm) {
    return vm.salaryPeriods.where((period) {
      final query = _searchQuery.toLowerCase();
      if (_selectedEmployeeFilterId != null &&
          period.employeeId != _selectedEmployeeFilterId) {
        return false;
      }
      if (query.isEmpty) return true;
      return period.employeeName.toLowerCase().contains(query) ||
          period.employeeCode.toLowerCase().contains(query) ||
          period.period.toLowerCase().contains(query) ||
          period.status.toLowerCase().contains(query);
    }).toList();
  }

  String _currency(double? value) {
    if (value == null) return '-';
    return value.toStringAsFixed(2);
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
