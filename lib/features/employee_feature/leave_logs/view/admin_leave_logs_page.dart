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

  int? _activeEmployeeFilterId(AdminLeaveLogsViewModel vm) {
    final employees = _monthlyEmployees(vm);
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
              label: const Text('All Requests'),
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

  Widget _rangeCard(AdminLeaveLogsViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
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
                  leave.employeeName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
              ),
              _statusChip(leave.status),
            ],
          ),
          const SizedBox(height: 10),
          _detailRow('Date', leave.leaveDate),
          _detailRow('Type', leave.leaveType),
          _detailRow('Category', leave.leaveCategory),
          if ((leave.reason ?? '').trim().isNotEmpty)
            _detailRow('Reason', leave.reason!),
          if (canReview) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: vm.isSaving
                        ? null
                        : () => _reviewLeave(vm, leave, 'REJECTED'),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: vm.isSaving
                        ? null
                        : () => _reviewLeave(vm, leave, 'APPROVED'),
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
