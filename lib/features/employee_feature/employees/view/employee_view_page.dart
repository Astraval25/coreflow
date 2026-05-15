import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/features/employee_feature/employees/view_model/employee_view_model.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EmployeeViewPage extends StatelessWidget {
  final int companyId;
  final int employeeId;

  const EmployeeViewPage({
    super.key,
    required this.companyId,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
        ChangeNotifierProvider(
          create: (_) => EmployeeViewModel(
            repository: EmployeeRepository(),
            companyId: companyId,
            employeeId: employeeId,
          ),
        ),
      ],
      child: const _EmployeeViewScreen(),
    );
  }
}

class _EmployeeViewScreen extends StatefulWidget {
  const _EmployeeViewScreen();

  @override
  State<_EmployeeViewScreen> createState() => _EmployeeViewScreenState();
}

class _EmployeeViewScreenState extends State<_EmployeeViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EmployeeViewModel>().load();
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployeeViewModel>();
    final dashboardVm = context.watch<DashboardViewModel>();
    final employee = vm.employee;
    final employeeName = (employee?.employeeName ?? '').trim();
    final avatarText = employeeName.isEmpty
        ? 'E'
        : employeeName.characters.first.toUpperCase();

    return Scaffold(
      backgroundColor: LoginColors.background,
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      appBar: AppBar(
        backgroundColor: LoginColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: employee == null
              ? null
              : () {
                  context.push(
                    CfRoutes.employeeProfile(vm.companyId, vm.employeeId),
                  );
                },
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: LoginColors.primary.withValues(alpha: 0.14),
                child: Text(
                  avatarText,
                  style: TextStyle(
                    color: LoginColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee?.employeeName ?? 'Employee',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    Text(
                      employee?.employeeCode ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (employee != null)
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    await context.push(
                      CfRoutes.employeeUpdate(vm.companyId, vm.employeeId),
                    );
                    if (mounted) {
                      await vm.load();
                    }
                    break;
                  case 'activate':
                  case 'deactivate':
                    final ok = value == 'activate'
                        ? await vm.activateEmployee()
                        : await vm.deactivateEmployee();
                    if (!mounted) return;
                    _showMessage(
                      ok
                          ? (vm.message ?? 'Employee updated successfully')
                          : (vm.error ?? 'Failed to update employee'),
                      isError: !ok,
                    );
                    break;
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: employee.isActive ? 'deactivate' : 'activate',
                  child: Row(
                    children: [
                      Icon(
                        employee.isActive
                            ? Icons.block_outlined
                            : Icons.check_circle_outline,
                        size: 18,
                        color: employee.isActive
                            ? LoginColors.error
                            : LoginColors.success,
                      ),
                      const SizedBox(width: 10),
                      Text(employee.isActive ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(onRefresh: vm.refresh, child: _buildBody(vm)),
    );
  }

  Widget _buildBody(EmployeeViewModel vm) {
    if (vm.isLoading && vm.employee == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null && vm.employee == null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.error_outline, size: 56, color: LoginColors.error),
          const SizedBox(height: 12),
          Center(
            child: Text(vm.error!, style: TextStyle(color: LoginColors.error)),
          ),
        ],
      );
    }

    final activityItems = <_ActivityEntry>[
      ...vm.workLogs.map(_ActivityEntry.work),
      ...vm.leaveLogs.map(_ActivityEntry.leave),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
      children: [
        _createActions(vm),
        const SizedBox(height: 8),
        if (activityItems.isEmpty)
          _emptyCard('No work/leave logs available')
        else
          ...activityItems.map((item) {
            if (item.isWork && item.workLog != null) {
              return _workCard(vm, item.workLog!);
            }
            return _leaveCard(vm, item.leaveLog!);
          }),
      ],
    );
  }

  Widget _createActions(EmployeeViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: vm.isSaving
                  ? null
                  : () => _showCreateWorkLogsSheet(vm),
              icon: const Icon(Icons.work_history_rounded),
              label: const Text('Add Work '),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: vm.isSaving
                  ? null
                  : () => _showCreateLeaveLogSheet(vm),
              icon: const Icon(Icons.event_note_rounded),
              label: const Text('Add Leave'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Text(text, style: TextStyle(color: LoginColors.textSecondary)),
    );
  }

  Widget _workCard(EmployeeViewModel vm, WorkLogData log) {
    final status = log.status.toUpperCase();
    final canReview = status == 'PENDING';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.workName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${log.logDate} · ${log.quantity ?? '-'} ${log.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${(log.amountEarned ?? 0).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _statusChip(status),
            ],
          ),
          if ((log.employeeRemarks ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              log.employeeRemarks!.trim(),
              style: TextStyle(
                fontSize: 11.5,
                color: LoginColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _actionBtn(
                icon: Icons.edit_rounded,
                color: LoginColors.primary,
                label: 'Edit',
                onTap: vm.isSaving ? null : () => _editWorkLog(vm, log),
              ),
              _actionBtn(
                icon: Icons.delete_outline_rounded,
                color: LoginColors.error,
                label: 'Delete',
                onTap: vm.isSaving ? null : () => _deleteWorkLog(vm, log),
              ),
              _actionBtn(
                icon: Icons.close_rounded,
                color: LoginColors.error,
                label: 'Reject',
                onTap: vm.isSaving || !canReview
                    ? null
                    : () => _reviewWorkLog(vm, log, 'REJECTED'),
              ),
              _actionBtn(
                icon: Icons.check_rounded,
                color: LoginColors.success,
                label: 'Accept',
                onTap: vm.isSaving || !canReview
                    ? null
                    : () => _reviewWorkLog(vm, log, 'APPROVED'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _leaveCard(EmployeeViewModel vm, LeaveLogData leave) {
    final status = leave.status.toUpperCase();
    final canReview = status == 'PENDING';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${leave.leaveDate} · ${leave.leaveCategory}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      leave.leaveType,
                      style: TextStyle(
                        fontSize: 12,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _statusChip(status),
            ],
          ),
          if ((leave.reason ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              leave.reason!.trim(),
              style: TextStyle(
                fontSize: 11.5,
                color: LoginColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _actionBtn(
                icon: Icons.edit_rounded,
                color: LoginColors.primary,
                label: 'Edit',
                onTap: vm.isSaving ? null : () => _editLeaveLog(vm, leave),
              ),
              _actionBtn(
                icon: Icons.delete_outline_rounded,
                color: LoginColors.error,
                label: 'Delete',
                onTap: vm.isSaving ? null : () => _deleteLeaveLog(vm, leave),
              ),
              _actionBtn(
                icon: Icons.close_rounded,
                color: LoginColors.error,
                label: 'Reject',
                onTap: vm.isSaving || !canReview
                    ? null
                    : () => _reviewLeaveLog(vm, leave, 'REJECTED'),
              ),
              _actionBtn(
                icon: Icons.check_rounded,
                color: LoginColors.success,
                label: 'Accept',
                onTap: vm.isSaving || !canReview
                    ? null
                    : () => _reviewLeaveLog(vm, leave, 'APPROVED'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: onTap == null
              ? LoginColors.surfaceSecondary
              : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: onTap == null ? Colors.grey : color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: onTap == null ? Colors.grey : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = switch (status) {
      'APPROVED' => LoginColors.success,
      'REJECTED' => LoginColors.error,
      _ => LoginColors.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _showCreateWorkLogsSheet(EmployeeViewModel vm) async {
    var selectedDate = _todayDateString();
    var remarks = '';
    final qtyValues = <int, String>{
      for (final def in vm.workDefinitions) def.workDefId: '',
    };
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: LoginColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.82,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Work Logs',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: LoginColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: ValueKey('work_date_$selectedDate'),
                        initialValue: selectedDate,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Log Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.tryParse(selectedDate) ??
                                DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            final month = picked.month.toString().padLeft(
                              2,
                              '0',
                            );
                            final day = picked.day.toString().padLeft(2, '0');
                            setState(() {
                              selectedDate = '${picked.year}-$month-$day';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.separated(
                          itemCount: vm.workDefinitions.length,
                          separatorBuilder: (_, index) => Divider(
                            color: LoginColors.borderLight,
                            height: 1,
                          ),
                          itemBuilder: (_, index) {
                            final def = vm.workDefinitions[index];
                            final qtyValue = qtyValues[def.workDefId] ?? '';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          def.workName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: LoginColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          '${def.workCode} · ${def.unit}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: LoginColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 110,
                                    child: TextFormField(
                                      key: ValueKey(
                                        'qty_${def.workDefId}_$qtyValue',
                                      ),
                                      initialValue: qtyValue,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d*\.?\d*'),
                                        ),
                                      ],
                                      decoration: const InputDecoration(
                                        labelText: 'Qty',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        qtyValues[def.workDefId] = value;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Remarks (optional)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          remarks = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: vm.isSaving
                              ? null
                              : () async {
                                  final entries = <int, double>{};
                                  for (final def in vm.workDefinitions) {
                                    final raw = (qtyValues[def.workDefId] ?? '')
                                        .trim();
                                    if (raw.isEmpty) continue;
                                    final qty = double.tryParse(raw);
                                    if (qty != null && qty > 0) {
                                      entries[def.workDefId] = qty;
                                    }
                                  }
                                  final ok = await vm.createWorkLogs(
                                    logDate: selectedDate,
                                    quantityByWorkDefId: entries,
                                    employeeRemarks: remarks.trim().isEmpty
                                        ? null
                                        : remarks.trim(),
                                  );
                                  if (!mounted) return;
                                  if (ok) {
                                    if (!sheetContext.mounted) return;
                                    Navigator.of(sheetContext).pop(true);
                                  } else {
                                    _showMessage(
                                      vm.error ?? 'Failed to create work logs',
                                      isError: true,
                                    );
                                  }
                                },
                          child: Text(
                            vm.isSaving ? 'Saving...' : 'Save Work Logs',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    if (!mounted || saved != true) return;
    _showMessage(vm.message ?? 'Work logs saved successfully');
  }

  Future<void> _showCreateLeaveLogSheet(EmployeeViewModel vm) async {
    var leaveType = 'FULL_DAY';
    var leaveCategory = 'CASUAL';
    var selectedDate = _todayDateString();
    var reason = '';
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: LoginColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Leave Log',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: LoginColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: ValueKey('leave_date_$selectedDate'),
                        initialValue: selectedDate,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Leave Date',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.tryParse(selectedDate) ??
                                DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            final month = picked.month.toString().padLeft(
                              2,
                              '0',
                            );
                            final day = picked.day.toString().padLeft(2, '0');
                            setState(() {
                              selectedDate = '${picked.year}-$month-$day';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
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
                          if (value != null) {
                            setState(() => leaveType = value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
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
                          DropdownMenuItem(value: 'SICK', child: Text('SICK')),
                          DropdownMenuItem(
                            value: 'UNPAID',
                            child: Text('UNPAID'),
                          ),
                          DropdownMenuItem(value: 'LOP', child: Text('LOP')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => leaveCategory = value);
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        minLines: 2,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Reason (optional)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          reason = value;
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: vm.isSaving
                              ? null
                              : () async {
                                  final ok = await vm.createLeaveLog(
                                    leaveDate: selectedDate,
                                    leaveType: leaveType,
                                    leaveCategory: leaveCategory,
                                    reason: reason.trim().isEmpty
                                        ? null
                                        : reason.trim(),
                                  );
                                  if (!mounted) return;
                                  if (ok) {
                                    if (!sheetContext.mounted) return;
                                    Navigator.of(sheetContext).pop(true);
                                  } else {
                                    _showMessage(
                                      vm.error ?? 'Failed to create leave log',
                                      isError: true,
                                    );
                                  }
                                },
                          child: Text(
                            vm.isSaving ? 'Saving...' : 'Save Leave Log',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    if (!mounted || saved != true) return;
    _showMessage(vm.message ?? 'Leave log saved successfully');
  }

  String _todayDateString() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Future<void> _reviewWorkLog(
    EmployeeViewModel vm,
    WorkLogData log,
    String status,
  ) async {
    final remarksController = TextEditingController(
      text: log.adminRemarks ?? '',
    );
    final remarks = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == 'APPROVED' ? 'Accept Work Log' : 'Reject Work Log',
        ),
        content: TextField(
          controller: remarksController,
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Admin Remarks',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              remarksController.text.trim().isEmpty
                  ? null
                  : remarksController.text.trim(),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (!mounted) return;

    final ok = await vm.reviewWorkLog(
      logId: log.logId,
      status: status,
      adminRemarks: remarks,
    );
    if (!mounted) return;
    _showMessage(
      ok
          ? (vm.message ?? 'Work log updated')
          : (vm.error ?? 'Failed to update'),
      isError: !ok,
    );
  }

  Future<void> _editWorkLog(EmployeeViewModel vm, WorkLogData log) async {
    final qtyController = TextEditingController(
      text: log.quantity?.toString() ?? '',
    );
    final remarksController = TextEditingController(
      text: log.employeeRemarks ?? '',
    );
    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final quantity = double.tryParse(qtyController.text.trim());
          final canSave = quantity != null && quantity > 0;
          return AlertDialog(
            title: const Text('Edit Work Log'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: qtyController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: canSave
                    ? () async {
                        final ok = await vm.updateWorkLog(
                          logId: log.logId,
                          workDefId: log.workDefId,
                          logDate: log.logDate,
                          quantity: quantity,
                          employeeRemarks: remarksController.text.trim().isEmpty
                              ? null
                              : remarksController.text.trim(),
                        );
                        if (!mounted) return;
                        if (ok) {
                          if (!dialogContext.mounted) return;
                          Navigator.of(dialogContext).pop(true);
                        } else {
                          _showMessage(
                            vm.error ?? 'Failed to update work log',
                            isError: true,
                          );
                        }
                      }
                    : null,
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
    if (!mounted || updated != true) return;
    _showMessage(vm.message ?? 'Work log updated successfully');
  }

  Future<void> _deleteWorkLog(EmployeeViewModel vm, WorkLogData log) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Work Log'),
        content: Text('Delete ${log.workName} on ${log.logDate}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: LoginColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirm != true) return;
    final ok = await vm.deleteWorkLog(log.logId);
    if (!mounted) return;
    _showMessage(
      ok ? (vm.message ?? 'Work log deleted') : (vm.error ?? 'Delete failed'),
      isError: !ok,
    );
  }

  Future<void> _reviewLeaveLog(
    EmployeeViewModel vm,
    LeaveLogData leave,
    String status,
  ) async {
    final ok = await vm.reviewLeaveLog(leaveId: leave.leaveId, status: status);
    if (!mounted) return;
    _showMessage(
      ok
          ? (vm.message ?? 'Leave updated')
          : (vm.error ?? 'Leave update failed'),
      isError: !ok,
    );
  }

  Future<void> _editLeaveLog(EmployeeViewModel vm, LeaveLogData leave) async {
    var leaveType = leave.leaveType;
    var leaveCategory = leave.leaveCategory;
    final reasonController = TextEditingController(text: leave.reason ?? '');
    final dateController = TextEditingController(text: leave.leaveDate);

    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Leave Log'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Leave Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.tryParse(dateController.text) ??
                            DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        final month = picked.month.toString().padLeft(2, '0');
                        final day = picked.day.toString().padLeft(2, '0');
                        dateController.text = '${picked.year}-$month-$day';
                      }
                    },
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
                      setState(() => leaveType = value);
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
                      DropdownMenuItem(value: 'CASUAL', child: Text('CASUAL')),
                      DropdownMenuItem(value: 'SICK', child: Text('SICK')),
                      DropdownMenuItem(value: 'UNPAID', child: Text('UNPAID')),
                      DropdownMenuItem(value: 'LOP', child: Text('LOP')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => leaveCategory = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
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
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final ok = await vm.updateLeaveLog(
                    leaveId: leave.leaveId,
                    leaveDate: dateController.text.trim(),
                    leaveType: leaveType,
                    leaveCategory: leaveCategory,
                    reason: reasonController.text.trim().isEmpty
                        ? null
                        : reasonController.text.trim(),
                  );
                  if (!mounted) return;
                  if (ok) {
                    if (!dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop(true);
                  } else {
                    _showMessage(
                      vm.error ?? 'Failed to update leave log',
                      isError: true,
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    if (!mounted || updated != true) return;
    _showMessage(vm.message ?? 'Leave log updated successfully');
  }

  Future<void> _deleteLeaveLog(EmployeeViewModel vm, LeaveLogData leave) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Leave Log'),
        content: Text('Delete leave on ${leave.leaveDate}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: LoginColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirm != true) return;
    final ok = await vm.deleteLeaveLog(leave.leaveId);
    if (!mounted) return;
    _showMessage(
      ok ? (vm.message ?? 'Leave log deleted') : (vm.error ?? 'Delete failed'),
      isError: !ok,
    );
  }
}

class _ActivityEntry {
  final bool isWork;
  final DateTime date;
  final WorkLogData? workLog;
  final LeaveLogData? leaveLog;

  const _ActivityEntry._({
    required this.isWork,
    required this.date,
    this.workLog,
    this.leaveLog,
  });

  factory _ActivityEntry.work(WorkLogData log) {
    return _ActivityEntry._(
      isWork: true,
      date:
          DateTime.tryParse(log.logDate) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      workLog: log,
    );
  }

  factory _ActivityEntry.leave(LeaveLogData log) {
    return _ActivityEntry._(
      isWork: false,
      date:
          DateTime.tryParse(log.leaveDate) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      leaveLog: log,
    );
  }
}
