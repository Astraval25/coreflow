import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/features/employee_feature/leave_logs/view_model/admin_leave_logs_view_model.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminLeaveLogsPage extends StatelessWidget {
  final int companyId;

  const AdminLeaveLogsPage({super.key, required this.companyId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider(
          create: (_) => AdminLeaveLogsViewModel(EmployeeRepository()),
        ),
      ],
      child: _AdminLeaveLogsView(companyId: companyId),
    );
  }
}

class _AdminLeaveLogsView extends StatefulWidget {
  final int companyId;

  const _AdminLeaveLogsView({required this.companyId});

  @override
  State<_AdminLeaveLogsView> createState() => _AdminLeaveLogsViewState();
}

class _AdminLeaveLogsViewState extends State<_AdminLeaveLogsView> {
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
      context.read<AdminLeaveLogsViewModel>().loadInitial(widget.companyId);
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

  Future<void> _pickRange(AdminLeaveLogsViewModel vm) async {
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

  Future<void> _showCreateDialog(AdminLeaveLogsViewModel vm) async {
    final formKey = GlobalKey<FormState>();
    final monthlyEmployees = _monthlyEmployees(vm);
    int? selectedEmployeeId = monthlyEmployees.isNotEmpty
        ? monthlyEmployees.first.employeeId
        : null;
    String leaveType = 'FULL_DAY';
    String leaveCategory = 'CASUAL';
    final dateController = TextEditingController(
      text: _formatDate(DateTime.now()),
    );
    final reasonController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Leave Request'),
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
                          items: monthlyEmployees.map((employee) {
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
                            labelText: 'Leave Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Select leave date'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: leaveType,
                          decoration: const InputDecoration(
                            labelText: 'Leave Type',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'FULL_DAY',
                              child: Text('FULL_DAY'),
                            ),
                            DropdownMenuItem(
                              value: 'HALF_DAY',
                              child: Text('HALF_DAY'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              leaveType = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: leaveCategory,
                          decoration: const InputDecoration(
                            labelText: 'Leave Category',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'CASUAL',
                              child: Text('CASUAL'),
                            ),
                            DropdownMenuItem(
                              value: 'SICK',
                              child: Text('SICK'),
                            ),
                            DropdownMenuItem(
                              value: 'UNPAID',
                              child: Text('UNPAID'),
                            ),
                            DropdownMenuItem(value: 'LOP', child: Text('LOP')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setDialogState(() {
                              leaveCategory = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: reasonController,
                          minLines: 2,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Reason',
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
                          final ok = await vm.createLeaveLog(
                            CreateLeaveLogRequest(
                              employeeId: selectedEmployeeId,
                              leaveDate: dateController.text,
                              leaveType: leaveType,
                              leaveCategory: leaveCategory,
                              reason: reasonController.text.trim().isEmpty
                                  ? null
                                  : reasonController.text.trim(),
                            ),
                          );
                          if (!context.mounted) return;
                          if (ok) {
                            Navigator.of(dialogContext).pop(true);
                          } else if (mounted) {
                            _showMessage(
                              vm.error ?? 'Failed to create leave request',
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
    _showMessage(vm.message ?? 'Leave request created successfully');
  }

  Future<void> _reviewLeave(
    AdminLeaveLogsViewModel vm,
    LeaveLogData leave,
    String status,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(status == 'APPROVED' ? 'Approve Leave' : 'Reject Leave'),
          content: Text(
            'Do you want to ${status == 'APPROVED' ? 'approve' : 'reject'} the leave request for ${leave.employeeName} on ${leave.leaveDate}?',
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
                      final ok = await vm.reviewLeaveLog(
                        leaveId: leave.leaveId,
                        status: status,
                      );
                      if (!context.mounted) return;
                      if (ok) {
                        Navigator.of(dialogContext).pop(true);
                      } else if (mounted) {
                        _showMessage(
                          vm.error ?? 'Failed to review leave request',
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

    if (!mounted || confirmed != true) return;
    _showMessage(
      vm.message ??
          (status == 'APPROVED'
              ? 'Leave request approved successfully'
              : 'Leave request rejected successfully'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminLeaveLogsViewModel>();
    final dashboardVm = context.watch<DashboardViewModel>();
    final monthlyEmployees = _monthlyEmployees(vm);

    _initializeEmployeeFilter(monthlyEmployees);

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
        title: 'Leave Requests',
        searchHint: 'Search leave requests...',
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
        onPressed: monthlyEmployees.isEmpty || vm.isSaving
            ? null
            : () => _showCreateDialog(vm),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
    );
  }

  List<Employee> _monthlyEmployees(AdminLeaveLogsViewModel vm) {
    return vm.employees
        .where(
          (employee) =>
              (employee.currentSalaryType ?? '').toUpperCase() == 'MONTHLY',
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

  int? _activeEmployeeFilterId(AdminLeaveLogsViewModel vm) {
    final employees = _monthlyEmployees(vm);
    final selectedId = _selectedEmployeeFilterId;
    if (selectedId == null) return null;
    final exists = employees.any(
      (employee) => employee.employeeId == selectedId,
    );
    return exists ? selectedId : null;
  }

  Widget _toggleCard(AdminLeaveLogsViewModel vm) {
    final monthlyEmployeeIds = _monthlyEmployees(
      vm,
    ).map((employee) => employee.employeeId).toSet();
    final allRequestsCount = vm.leaveLogs
        .where((leave) => monthlyEmployeeIds.contains(leave.employeeId))
        .length;
    final pendingRequestsCount = vm.pendingLeaveLogs
        .where((leave) => monthlyEmployeeIds.contains(leave.employeeId))
        .length;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: LoginColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Stack(
        children: [
          IgnorePointer(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: _showPendingOnly
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: LoginColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _viewToggleOption(
                  label: 'All Requests',
                  count: allRequestsCount,
                  icon: Icons.fact_check_outlined,
                  isSelected: !_showPendingOnly,
                  onTap: () => setState(() => _showPendingOnly = false),
                ),
              ),
              Expanded(
                child: _viewToggleOption(
                  label: 'Pending Review',
                  count: pendingRequestsCount,
                  icon: Icons.pending_actions_rounded,
                  isSelected: _showPendingOnly,
                  onTap: () => setState(() => _showPendingOnly = true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _viewToggleOption({
    required String label,
    required int count,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final foregroundColor = isSelected ? Colors.white : LoginColors.textPrimary;
    final badgeBackground = isSelected
        ? Colors.white.withValues(alpha: 0.16)
        : LoginColors.background;
    final iconColor = isSelected ? Colors.white : LoginColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: foregroundColor,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBackground,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: foregroundColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _employeeFilterCard(AdminLeaveLogsViewModel vm) {
    final employees = _monthlyEmployees(vm);
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

  Widget _rangeCard(AdminLeaveLogsViewModel vm) {
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

  Widget _listSection(AdminLeaveLogsViewModel vm) {
    if (vm.isLoading && vm.leaveLogs.isEmpty && vm.pendingLeaveLogs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final monthlyEmployeeIds = _monthlyEmployees(
      vm,
    ).map((employee) => employee.employeeId).toSet();
    final source = _showPendingOnly ? vm.pendingLeaveLogs : vm.leaveLogs;
    final selectedEmployeeId = _activeEmployeeFilterId(vm);
    final filtered = source.where((leave) {
      if (!monthlyEmployeeIds.contains(leave.employeeId)) {
        return false;
      }
      final query = _searchQuery.toLowerCase();
      if (selectedEmployeeId != null &&
          leave.employeeId != selectedEmployeeId) {
        return false;
      }
      if (query.isEmpty) return true;
      return leave.employeeName.toLowerCase().contains(query) ||
          leave.leaveDate.toLowerCase().contains(query) ||
          leave.leaveCategory.toLowerCase().contains(query) ||
          leave.status.toLowerCase().contains(query);
    }).toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Center(
          child: Text(
            _showPendingOnly
                ? 'No pending leave requests'
                : 'No leave requests found for the selected range',
            style: TextStyle(color: LoginColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: filtered.map((leave) => _leaveCard(vm, leave)).toList(),
    );
  }

  Widget _leaveCard(AdminLeaveLogsViewModel vm, LeaveLogData leave) {
    final canReview = leave.status.toUpperCase() == 'PENDING';
    final reason = (leave.reason ?? '').trim();
    final isHalfDay = leave.leaveType.toUpperCase() == 'HALF_DAY';
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
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.employeeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${leave.leaveCategory} · ${isHalfDay ? 'Half Day' : 'Full Day'}',
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
              const SizedBox(width: 8),
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
                          : () => _reviewLeave(vm, leave, 'REJECTED'),
                    ),
                    const SizedBox(width: 4),
                    _iconBtn(
                      icon: Icons.check_rounded,
                      color: LoginColors.success,
                      tooltip: 'Approve',
                      onTap: vm.isSaving
                          ? null
                          : () => _reviewLeave(vm, leave, 'APPROVED'),
                    ),
                  ],
                )
              else
                _statusChip(leave.status),
            ],
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              reason,
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
