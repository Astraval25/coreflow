import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
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

  Future<void> _pickMonth(AdminSalaryViewModel vm) async {
    final initial = _monthFromPeriod(vm.selectedPeriod);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 5),
      lastDate: DateTime(initial.year + 5),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked == null) return;
    await vm.updatePeriod(DateTime(picked.year, picked.month));
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

  Future<void> _showSalaryDetail(
    AdminSalaryViewModel vm,
    SalaryPeriodSummary period,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${period.employeeName} - Salary Detail'),
          content: SizedBox(
            width: 520,
            child: FutureBuilder<SalaryPeriodDetailData?>(
              future: vm.getSalaryPeriodDetail(period.salaryPeriodId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 140,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return const Text('Failed to load salary detail');
                }

                final detail = snapshot.data;
                if (detail == null) {
                  return const Text('Failed to load salary detail');
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow('Employee', detail.employeeName),
                      _detailRow('Code', detail.employeeCode),
                      _detailRow('Period', detail.period),
                      _detailRow('From', detail.fromDate),
                      _detailRow('To', detail.toDate),
                      _detailRow('Type', detail.salaryType),
                      _detailRow(
                        'Gross',
                        detail.grossAmount?.toStringAsFixed(2) ?? '-',
                      ),
                      _detailRow(
                        'Net',
                        detail.netAmount?.toStringAsFixed(2) ?? '-',
                      ),
                      _detailRow('Status', detail.status),
                      if ((detail.paymentRef ?? '').trim().isNotEmpty)
                        _detailRow('Payment Ref', detail.paymentRef!),
                      const SizedBox(height: 12),
                      Text(
                        'Lines',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: LoginColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...detail.lines.map((line) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: LoginColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: LoginColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                line.description,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: LoginColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Type: ${line.lineType}'),
                              Text(
                                'Amount: ${line.amount?.toStringAsFixed(2) ?? '-'}',
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
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

  Future<void> _markSalaryPaid(
    AdminSalaryViewModel vm,
    SalaryPeriodSummary period,
  ) async {
    final controller = TextEditingController();
    final paid = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mark Salary as Paid'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Payment Ref (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: vm.isSaving
                  ? null
                  : () async {
                      final ok = await vm.markSalaryPaid(
                        salaryPeriodId: period.salaryPeriodId,
                        paymentRef: controller.text.trim().isEmpty
                            ? null
                            : controller.text.trim(),
                      );
                      if (!context.mounted) return;
                      if (ok) {
                        Navigator.of(dialogContext).pop(true);
                      } else if (mounted) {
                        _showMessage(
                          vm.error ?? 'Failed to mark salary as paid',
                          isError: true,
                        );
                      }
                    },
              child: Text(vm.isSaving ? 'Saving...' : 'Confirm'),
            ),
          ],
        );
      },
    );

    if (!mounted || paid != true) return;
    _showMessage(vm.message ?? 'Salary marked as paid successfully');
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
              if (vm.salaryReport != null) ...[_reportCard(vm.salaryReport!)],
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
          // OutlinedButton.icon(
          //   onPressed: () => _pickMonth(vm),
          //   icon: const Icon(Icons.calendar_month_rounded, size: 16),
          //   label: const Text('Month'),
          //   style: OutlinedButton.styleFrom(
          //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          //     visualDensity: VisualDensity.compact,
          //     textStyle: const TextStyle(
          //       fontSize: 12,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
          OutlinedButton.icon(
            onPressed: () => _pickRange(vm),
            icon: const Icon(Icons.date_range_rounded, size: 16),
            label: const Text('Range'),
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
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: vm.isSaving ? null : () => _calculateSalary(vm),
            icon: const Icon(Icons.calculate_rounded),
            label: Text(vm.isSaving ? 'Calculating...' : 'Calculate Salary'),
          ),
        ],
      ),
    );
  }

  Widget _reportCard(SalaryReportData report) {
    return Container(
      padding: const EdgeInsets.all(8),
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
          _detailRow('Employee', report.totalEmployees.toString()),
          _detailRow(
            'Gross',
            report.totalGrossAmount?.toStringAsFixed(2) ?? '-',
          ),
          _detailRow('Net', report.totalNetAmount?.toStringAsFixed(2) ?? '-'),
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

    final filtered = vm.salaryPeriods.where((period) {
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

    return Column(
      children: filtered.map((period) => _salaryCard(vm, period)).toList(),
    );
  }

  Widget _salaryCard(AdminSalaryViewModel vm, SalaryPeriodSummary period) {
    final status = period.status.toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
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
              Expanded(
                child: Text(
                  '${period.employeeName} (${period.employeeCode})',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
              ),
              _statusChip(status),
            ],
          ),
          // const SizedBox(height: 10),
          // _detailRow('Period', period.period),
          _detailRow('From', period.fromDate),
          _detailRow('To', period.toDate),
          // _detailRow('Type', period.salaryType),
          // _detailRow('Gross', period.grossAmount?.toStringAsFixed(2) ?? '-'),
          _detailRow('Net', period.netAmount?.toStringAsFixed(2) ?? '-'),
          // const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              // OutlinedButton.icon(
              //   onPressed: () => _showSalaryDetail(vm, period),
              //   icon: const Icon(Icons.visibility_outlined),
              //   label: const Text('View Detail'),
              // ),
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
              if (status == 'APPROVED')
                FilledButton.icon(
                  onPressed: vm.isSaving
                      ? null
                      : () => _markSalaryPaid(vm, period),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Mark Paid'),
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

  Widget _statusChip(String status) {
    final color = switch (status) {
      'PAID' => LoginColors.success,
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

  DateTime _monthFromPeriod(String period) {
    if (period.length < 6) return DateTime.now();
    final year = int.tryParse(period.substring(0, 4));
    final month = int.tryParse(period.substring(4, 6));
    if (year == null || month == null) return DateTime.now();
    return DateTime(year, month);
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
