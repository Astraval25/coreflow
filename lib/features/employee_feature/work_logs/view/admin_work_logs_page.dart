import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/features/employee_feature/work_logs/view_model/admin_work_logs_view_model.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminWorkLogsPage extends StatelessWidget {
  final int companyId;

  const AdminWorkLogsPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(
          create: (_) => AdminWorkLogsViewModel(EmployeeRepository()),
        ),
      ],
      child: _AdminWorkLogsView(companyId: companyId),
    );
  }
}

class _AdminWorkLogsView extends StatefulWidget {
  final int companyId;

  const _AdminWorkLogsView({required this.companyId});

  @override
  State<_AdminWorkLogsView> createState() => _AdminWorkLogsViewState();
}

class _AdminWorkLogsViewState extends State<_AdminWorkLogsView> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isSearchOpen = false;
  bool _showPendingOnly = false;
  String _searchQuery = '';
  int? _selectedEmployeeFilterId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdminWorkLogsViewModel>().loadInitial(widget.companyId);
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

  Future<void> _pickRange(AdminWorkLogsViewModel vm) async {
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

    await vm.updateDateRange(
      fromDate: _formatDate(pickedFrom),
      toDate: _formatDate(pickedTo),
    );
  }

  Future<void> _showCreateDialog(AdminWorkLogsViewModel vm) async {
    final formKey = GlobalKey<FormState>();
    final workBasedEmployees = _workBasedEmployees(vm);
    int? selectedEmployeeId = workBasedEmployees.isNotEmpty
        ? workBasedEmployees.first.employeeId
        : null;
    int? selectedWorkDefId = vm.workDefinitions.isNotEmpty
        ? vm.workDefinitions.first.workDefId
        : null;
    final dateController = TextEditingController(
      text: _formatDate(DateTime.now()),
    );
    final quantityController = TextEditingController();
    final remarksController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Work Log'),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField<int>(
                          initialValue: selectedEmployeeId,
                          decoration: const InputDecoration(
                            labelText: 'Employee',
                            border: OutlineInputBorder(),
                          ),
                          items: workBasedEmployees.map((employee) {
                            return DropdownMenuItem<int>(
                              value: employee.employeeId,
                              child: Text(
                                '${employee.employeeName} (${employee.employeeCode})',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedEmployeeId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Select an employee' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: selectedWorkDefId,
                          decoration: const InputDecoration(
                            labelText: 'Work Definition',
                            border: OutlineInputBorder(),
                          ),
                          items: vm.workDefinitions.map((work) {
                            return DropdownMenuItem<int>(
                              value: work.workDefId,
                              child: Text(
                                '${work.workName} (${work.workCode})',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedWorkDefId = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Select a work definition' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: dateController,
                          readOnly: true,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  DateTime.tryParse(dateController.text) ??
                                  DateTime.now(),
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365 * 2),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null) {
                              dateController.text = _formatDate(picked);
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Log Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Select log date'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Enter quantity';
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return 'Enter a valid quantity';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: remarksController,
                          minLines: 2,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Remarks',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                          if (!formKey.currentState!.validate()) return;
                          final ok = await vm.createWorkLog(
                            CreateWorkLogRequest(
                              employeeId: selectedEmployeeId,
                              workDefId: selectedWorkDefId!,
                              logDate: dateController.text,
                              quantity: double.parse(
                                quantityController.text.trim(),
                              ),
                              employeeRemarks:
                                  remarksController.text.trim().isEmpty
                                  ? null
                                  : remarksController.text.trim(),
                            ),
                          );
                          if (!context.mounted) return;
                          if (ok) {
                            Navigator.of(dialogContext).pop(true);
                          } else if (mounted) {
                            _showMessage(
                              vm.error ?? 'Failed to create work log',
                              isError: true,
                            );
                          }
                        },
                  child: Text(vm.isSaving ? 'Saving...' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || created != true) return;
    _showMessage(vm.message ?? 'Work log created successfully');
  }

  Future<void> _showReviewDialog(
    AdminWorkLogsViewModel vm,
    WorkLogData log,
    String status,
  ) async {
    final remarksController = TextEditingController(
      text: log.adminRemarks ?? '',
    );
    final reviewed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            status == 'APPROVED' ? 'Approve Work Log' : 'Reject Work Log',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${log.employeeName} - ${log.workName}'),
              const SizedBox(height: 4),
              Text('Date: ${log.logDate}'),
              const SizedBox(height: 4),
              Text('Quantity: ${log.quantity ?? '-'} ${log.unit}'),
              const SizedBox(height: 12),
              TextField(
                controller: remarksController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Admin Remarks',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
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
                      final ok = await vm.reviewWorkLog(
                        logId: log.logId,
                        status: status,
                        adminRemarks: remarksController.text.trim().isEmpty
                            ? null
                            : remarksController.text.trim(),
                      );
                      if (!context.mounted) return;
                      if (ok) {
                        Navigator.of(dialogContext).pop(true);
                      } else if (mounted) {
                        _showMessage(
                          vm.error ?? 'Failed to review work log',
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

    if (!mounted || reviewed != true) return;
    _showMessage(
      vm.message ??
          (status == 'APPROVED'
              ? 'Work log approved successfully'
              : 'Work log rejected successfully'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminWorkLogsViewModel>();
    final dashboardVm = context.watch<DashboardViewModel>();
    final workBasedEmployees = _workBasedEmployees(vm);

    return Scaffold(
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
        title: 'Work Logs',
        searchHint: 'Search work logs...',
      ),
      body: RefreshIndicator(
        onRefresh: vm.refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _toggleCard(),
            const SizedBox(height: 16),
            _employeeFilterCard(vm),
            const SizedBox(height: 16),
            if (!_showPendingOnly) ...[
              _rangeCard(vm),
              const SizedBox(height: 16),
            ],
            _listSection(vm),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: LoginColors.primary,
        foregroundColor: Colors.white,
        onPressed:
            workBasedEmployees.isEmpty ||
                vm.workDefinitions.isEmpty ||
                vm.isSaving
            ? null
            : () => _showCreateDialog(vm),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
    );
  }

  List<Employee> _workBasedEmployees(AdminWorkLogsViewModel vm) {
    return vm.employees
        .where(
          (employee) =>
              (employee.currentSalaryType ?? '').toUpperCase() == 'WORK_BASED',
        )
        .toList();
  }

  int? _activeEmployeeFilterId(AdminWorkLogsViewModel vm) {
    final employees = _workBasedEmployees(vm);
    final selectedId = _selectedEmployeeFilterId;
    if (selectedId == null) return null;
    final exists = employees.any(
      (employee) => employee.employeeId == selectedId,
    );
    return exists ? selectedId : null;
  }

  Widget _toggleCard() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: ChoiceChip(
              label: const Text('All Logs'),
              selected: !_showPendingOnly,
              onSelected: (_) => setState(() => _showPendingOnly = false),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceChip(
              label: const Text('Pending Review'),
              selected: _showPendingOnly,
              onSelected: (_) => setState(() => _showPendingOnly = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _employeeFilterCard(AdminWorkLogsViewModel vm) {
    final employees = _workBasedEmployees(vm);
    final selectedEmployeeId = _activeEmployeeFilterId(vm);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: DropdownButtonFormField<int?>(
        initialValue: selectedEmployeeId,
        decoration: const InputDecoration(
          labelText: 'Filter by Employee',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('All Employees'),
          ),
          ...employees.map((employee) {
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

  Widget _rangeCard(AdminWorkLogsViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _rangeValue('', vm.fromDate),
          _rangeValue('To', vm.toDate),
          OutlinedButton.icon(
            onPressed: () => _pickRange(vm),
            icon: const Icon(Icons.edit_calendar_rounded, size: 16),
            label: const Text('Change'),
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

  Widget _rangeValue(String label, String value) {
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

  Widget _listSection(AdminWorkLogsViewModel vm) {
    if (vm.isLoading && vm.workLogs.isEmpty && vm.pendingWorkLogs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final workBasedEmployeeIds = _workBasedEmployees(
      vm,
    ).map((employee) => employee.employeeId).toSet();
    final source = _showPendingOnly ? vm.pendingWorkLogs : vm.workLogs;
    final selectedEmployeeId = _activeEmployeeFilterId(vm);
    final filtered = source.where((log) {
      if (!workBasedEmployeeIds.contains(log.employeeId)) {
        return false;
      }
      final query = _searchQuery.toLowerCase();
      if (selectedEmployeeId != null && log.employeeId != selectedEmployeeId) {
        return false;
      }
      if (query.isEmpty) return true;
      return log.employeeName.toLowerCase().contains(query) ||
          log.workName.toLowerCase().contains(query) ||
          log.logDate.toLowerCase().contains(query) ||
          log.status.toLowerCase().contains(query);
    }).toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Center(
          child: Text(
            _showPendingOnly
                ? 'No pending work logs'
                : 'No work logs found for the selected range',
            style: TextStyle(color: LoginColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: filtered.map((log) => _workLogCard(vm, log)).toList(),
    );
  }

  Widget _workLogCard(AdminWorkLogsViewModel vm, WorkLogData log) {
    final canReview = log.status.toUpperCase() == 'PENDING';
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
              Expanded(
                child: Text(
                  '${log.employeeName} - ${log.workName}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
              ),
              _statusChip(log.status),
            ],
          ),
          const SizedBox(height: 10),
          _detailRow('Date', log.logDate),
          _detailRow('Quantity', '${log.quantity ?? '-'} ${log.unit}'),
          _detailRow(
            'Rate',
            log.rateSnapshot == null
                ? '-'
                : '${log.rateSnapshot!.toStringAsFixed(2)} / ${log.unit}',
          ),
          _detailRow('Earned', log.amountEarned?.toStringAsFixed(2) ?? '-'),
          if ((log.employeeRemarks ?? '').trim().isNotEmpty)
            _detailRow('Remarks', log.employeeRemarks!),
          if ((log.adminRemarks ?? '').trim().isNotEmpty)
            _detailRow('Admin Notes', log.adminRemarks!),
          if (canReview) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: vm.isSaving
                        ? null
                        : () => _showReviewDialog(vm, log, 'REJECTED'),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: vm.isSaving
                        ? null
                        : () => _showReviewDialog(vm, log, 'APPROVED'),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
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
            width: 88,
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
    final normalized = status.toUpperCase();
    final color = switch (normalized) {
      'APPROVED' => LoginColors.success,
      'REJECTED' => LoginColors.error,
      _ => LoginColors.primary,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        normalized,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
