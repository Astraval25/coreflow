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
  bool _hasInitializedEmployeeFilter = false;
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

    _initializeEmployeeFilter(workBasedEmployees);

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
            _toggleCard(vm),
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

  void _initializeEmployeeFilter(List<Employee> employees) {
    if (_hasInitializedEmployeeFilter || employees.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasInitializedEmployeeFilter) return;
      setState(() {
        _selectedEmployeeFilterId = employees.first.employeeId;
        _hasInitializedEmployeeFilter = true;
      });
    });
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

  Widget _toggleCard(AdminWorkLogsViewModel vm) {
    final workBasedEmployeeIds = _workBasedEmployees(
      vm,
    ).map((employee) => employee.employeeId).toSet();
    final allLogsCount = vm.workLogs
        .where((log) => workBasedEmployeeIds.contains(log.employeeId))
        .length;
    final pendingLogsCount = vm.pendingWorkLogs
        .where((log) => workBasedEmployeeIds.contains(log.employeeId))
        .length;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: _viewToggleOption(
              label: 'All Logs',
              caption: allLogsCount == 1 ? '1 record' : '$allLogsCount records',
              count: allLogsCount,
              icon: Icons.list_alt_rounded,
              isSelected: !_showPendingOnly,
              onTap: () => setState(() => _showPendingOnly = false),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _viewToggleOption(
              label: 'Pending Review',
              caption: pendingLogsCount == 1
                  ? '1 awaiting action'
                  : '$pendingLogsCount awaiting action',
              count: pendingLogsCount,
              icon: Icons.pending_actions_rounded,
              isSelected: _showPendingOnly,
              onTap: () => setState(() => _showPendingOnly = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewToggleOption({
    required String label,
    required String caption,
    required int count,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final foregroundColor = isSelected ? Colors.white : LoginColors.textPrimary;
    final secondaryColor = isSelected
        ? Colors.white.withValues(alpha: 0.78)
        : LoginColors.textSecondary;
    final backgroundColor = isSelected
        ? LoginColors.primary
        : LoginColors.surfaceSecondary;
    final borderColor = isSelected
        ? LoginColors.primary
        : LoginColors.borderLight;
    final badgeBackground = isSelected
        ? Colors.white.withValues(alpha: 0.16)
        : LoginColors.background;
    final iconBackground = isSelected
        ? Colors.white.withValues(alpha: 0.14)
        : LoginColors.primary.withValues(alpha: 0.1);
    final iconColor = isSelected ? Colors.white : LoginColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: foregroundColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: foregroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
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
        key: ValueKey(selectedEmployeeId),
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
            _hasInitializedEmployeeFilter = true;
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
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous day',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: vm.isLoading ? null : () => vm.shiftDay(-1),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _pickRange(vm),
              child: Center(child: _rangeValue('', vm.fromDate)),
            ),
          ),
          IconButton(
            tooltip: 'Next day',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: vm.isLoading ? null : () => vm.shiftDay(1),
          ),
          TextButton(
            onPressed: vm.isLoading ? null : () => vm.goToToday(),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Today'),
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
    final remarks = (log.employeeRemarks ?? '').trim();
    final adminNotes = (log.adminRemarks ?? '').trim();
    final hasNotes = remarks.isNotEmpty || adminNotes.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: name + work
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.workName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    Text(
                      log.employeeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Middle: qty x unit
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${log.quantity ?? '-'} ${log.unit}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    Text(
                      log.amountEarned == null
                          ? '-'
                          : '₹${log.amountEarned!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right: status + actions
              if (canReview)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconBtn(
                      icon: Icons.close_rounded,
                      color: LoginColors.error,
                      tooltip: 'Reject',
                      onTap: vm.isSaving
                          ? null
                          : () => _showReviewDialog(vm, log, 'REJECTED'),
                    ),
                    const SizedBox(width: 4),
                    _iconBtn(
                      icon: Icons.check_rounded,
                      color: LoginColors.success,
                      tooltip: 'Approve',
                      onTap: vm.isSaving
                          ? null
                          : () => _showReviewDialog(vm, log, 'APPROVED'),
                    ),
                  ],
                )
              else
                _statusChip(log.status),
            ],
          ),
          if (hasNotes) ...[
            const SizedBox(height: 6),
            Text(
              [
                if (remarks.isNotEmpty) remarks,
                if (adminNotes.isNotEmpty) 'Admin: $adminNotes',
              ].join('  ·  '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: LoginColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback? onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
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
