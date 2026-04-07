import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/features/employee_feature/salary/service/salary_file_service.dart';
import 'package:coreflow/features/employee_feature/portal/view_model/employee_portal_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EmployeePortalPage extends StatelessWidget {
  const EmployeePortalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EmployeePortalViewModel(),
      child: const _EmployeePortalScreen(),
    );
  }
}

class _EmployeePortalScreen extends StatefulWidget {
  const _EmployeePortalScreen();

  @override
  State<_EmployeePortalScreen> createState() => _EmployeePortalScreenState();
}

class _EmployeePortalScreenState extends State<_EmployeePortalScreen> {
  final _workFormKey = GlobalKey<FormState>();
  final _leaveFormKey = GlobalKey<FormState>();

  final _workDateController = TextEditingController();
  final _quantityController = TextEditingController();
  final _workRemarksController = TextEditingController();

  final _leaveDateController = TextEditingController();
  final _leaveReasonController = TextEditingController();

  int? _selectedWorkDefId;
  String _leaveType = 'FULL_DAY';
  String _leaveCategory = 'CASUAL';
  int? _downloadingSalaryPeriodId;

  @override
  void dispose() {
    _workDateController.dispose();
    _quantityController.dispose();
    _workRemarksController.dispose();
    _leaveDateController.dispose();
    _leaveReasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(controller.text.trim()) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      controller.text = '$y-$m-$d';
    }
  }

  Future<void> _submitWorkLog(EmployeePortalViewModel vm) async {
    if (!_workFormKey.currentState!.validate()) return;
    final workDefId = _resolvedWorkDefId(vm);
    if (workDefId == null) {
      _showMessage('Select a work definition', isError: true);
      return;
    }

    final ok = await vm.createWorkLog(
      workDefId: workDefId,
      logDate: _workDateController.text.trim(),
      quantity: double.parse(_quantityController.text.trim()),
      remarks: _workRemarksController.text.trim().isEmpty
          ? null
          : _workRemarksController.text.trim(),
    );

    if (!mounted) return;
    _showMessage(
      ok
          ? (vm.message ?? 'Work log submitted successfully')
          : (vm.error ?? 'Submit failed'),
      isError: !ok,
    );
    if (ok) {
      _quantityController.clear();
      _workRemarksController.clear();
    }
  }

  int? _resolvedWorkDefId(EmployeePortalViewModel vm) {
    if (vm.workDefinitions.isEmpty) return null;
    final currentSelection = _selectedWorkDefId;
    if (currentSelection != null &&
        vm.workDefinitions.any((work) => work.workDefId == currentSelection)) {
      return currentSelection;
    }
    return vm.workDefinitions.first.workDefId;
  }

  WorkDefinitionData? _selectedWorkDefinition(EmployeePortalViewModel vm) {
    final selectedId = _resolvedWorkDefId(vm);
    if (selectedId == null) return null;
    for (final work in vm.workDefinitions) {
      if (work.workDefId == selectedId) return work;
    }
    return null;
  }

  Future<void> _submitLeave(EmployeePortalViewModel vm) async {
    if (!_leaveFormKey.currentState!.validate()) return;

    final ok = await vm.createLeaveLog(
      leaveDate: _leaveDateController.text.trim(),
      leaveType: _leaveType,
      leaveCategory: _leaveCategory,
      reason: _leaveReasonController.text.trim().isEmpty
          ? null
          : _leaveReasonController.text.trim(),
    );

    if (!mounted) return;
    _showMessage(
      ok
          ? (vm.message ?? 'Leave request submitted successfully')
          : (vm.error ?? 'Submit failed'),
      isError: !ok,
    );
    if (ok) {
      _leaveReasonController.clear();
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? LoginColors.error : null,
      ),
    );
  }

  Future<void> _pickSalaryReportRange(EmployeePortalViewModel vm) async {
    final fromInitial =
        DateTime.tryParse(vm.salaryReportFromDate) ?? DateTime.now();
    final pickedFrom = await showDatePicker(
      context: context,
      initialDate: fromInitial,
      firstDate: DateTime(fromInitial.year - 2),
      lastDate: DateTime(fromInitial.year + 2),
    );
    if (pickedFrom == null || !mounted) return;

    final toInitial = DateTime.tryParse(vm.salaryReportToDate) ?? pickedFrom;
    final pickedTo = await showDatePicker(
      context: context,
      initialDate: pickedFrom.isAfter(toInitial) ? pickedFrom : toInitial,
      firstDate: pickedFrom,
      lastDate: DateTime(pickedFrom.year + 2),
    );
    if (pickedTo == null) return;

    await vm.updateSalaryReportRange(
      fromDate: _formatDate(pickedFrom),
      toDate: _formatDate(pickedTo),
    );
  }

  Future<void> _downloadSalarySlip(
    EmployeePortalViewModel vm,
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

      final fileName = 'salary-slip-${period.period}.pdf';
      await SalaryFileService.shareSalarySlip(
        bytes: bytes,
        fileName: fileName,
      );
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

  Future<void> _showSalaryDetail(
    BuildContext context,
    EmployeePortalViewModel vm,
    SalaryPeriodSummary summary,
  ) async {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Salary Detail'),
          content: SizedBox(
            width: 500,
            child: FutureBuilder<SalaryPeriodDetailData?>(
              future: vm.getSalaryDetail(summary.salaryPeriodId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  );
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
                      _detailRow('Period', detail.period),
                      _detailRow('From', detail.fromDate),
                      _detailRow('To', detail.toDate),
                      _detailRow('Status', detail.status),
                      _detailRow(
                        'Net Amount',
                        detail.netAmount?.toStringAsFixed(2) ?? '-',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Lines',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: LoginColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...detail.lines.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: LoginColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: LoginColors.borderLight,
                              ),
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
                                Text(
                                  'Amount: ${line.amount?.toStringAsFixed(2) ?? '-'}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: LoginColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: LoginColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployeePortalViewModel>();
    final employeeName = vm.profile?.employeeName ?? 'Employee Portal';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: LoginColors.background,
        appBar: AppBar(
          backgroundColor: LoginColors.background,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            employeeName,
            style: TextStyle(
              color: LoginColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Logout',
              onPressed: () async {
                await vm.logout();
                if (context.mounted) {
                  context.go(CfRoutes.login);
                }
              },
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Action'),
              Tab(text: 'Salary'),
            ],
          ),
        ),
        body: vm.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: LoginColors.primary),
              )
            : vm.profile == null
            ? Center(child: Text(vm.error ?? 'Failed to load portal'))
            : TabBarView(
                children: [
                  _buildProfileTab(vm),
                  _buildActionTab(vm),
                  _buildSalaryTab(vm),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileTab(EmployeePortalViewModel vm) {
    final profile = vm.profile!;
    return RefreshIndicator(
      onRefresh: vm.loadPortal,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            title: 'My Profile',
            icon: Icons.person_outline_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Code', profile.employeeCode),
                _detailRow('Name', profile.employeeName),
                _detailRow('Phone', profile.phone ?? '-'),
                _detailRow('Email', profile.email ?? '-'),
                _detailRow('Designation', profile.designation ?? '-'),
                _detailRow('Joined', profile.joinedDt ?? '-'),
                _detailRow('Salary Type', profile.currentSalaryType ?? '-'),
                _detailRow(
                  'Monthly Amount',
                  profile.currentMonthlyAmount?.toStringAsFixed(2) ?? '-',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(
            title: 'Available Work Definitions',
            icon: Icons.workspaces_outline,
            child: Column(
              children: vm.workDefinitions.isEmpty
                  ? [
                      Text(
                        'No work definitions available right now.',
                        style: TextStyle(color: LoginColors.textSecondary),
                      ),
                    ]
                  : vm.workDefinitions.map((work) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: LoginColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LoginColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    work.workName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: LoginColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${work.workCode}  ${work.ratePerUnit?.toStringAsFixed(2) ?? '-'} / ${work.unit}',
                                    style: TextStyle(
                                      color: LoginColors.textSecondary,
                                    ),
                                  ),
                                  if ((work.description ?? '')
                                      .trim()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      work.description!,
                                      style: TextStyle(
                                        color: LoginColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTab(EmployeePortalViewModel vm) {
    final selectedWork = _selectedWorkDefinition(vm);
    final selectedWorkId = selectedWork?.workDefId;

    return RefreshIndicator(
      onRefresh: vm.loadPortal,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (vm.isWorkBased)
            _card(
              title: 'Create Work Log',
              icon: Icons.post_add_rounded,
              child: Form(
                key: _workFormKey,
                child: Column(
                  children: [
                    if (vm.workDefinitions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: LoginColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LoginColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No work definitions are available to select.',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: LoginColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Ask the admin to create work definitions, then pull to refresh this page.',
                              style: TextStyle(
                                color: LoginColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      DropdownButtonFormField<int>(
                        key: ValueKey(selectedWorkId),
                        initialValue: selectedWorkId,
                        decoration: InputDecoration(
                          labelText: 'Work Definition',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: vm.workDefinitions.map((work) {
                          return DropdownMenuItem<int>(
                            value: work.workDefId,
                            child: Text('${work.workName} (${work.workCode})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedWorkDefId = value;
                          });
                        },
                      ),
                      if (selectedWork != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: LoginColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: LoginColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedWork.workName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: LoginColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Code: ${selectedWork.workCode}',
                                style: TextStyle(
                                  color: LoginColors.textSecondary,
                                ),
                              ),
                              Text(
                                'Rate: ${selectedWork.ratePerUnit?.toStringAsFixed(2) ?? '-'} / ${selectedWork.unit}',
                                style: TextStyle(
                                  color: LoginColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _workDateController,
                      readOnly: true,
                      onTap: () => _pickDate(_workDateController),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Select log date'
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Log Date',
                        suffixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Quantity is required';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Enter a valid quantity';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _workRemarksController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Remarks',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: vm.isSubmitting || vm.workDefinitions.isEmpty
                          ? null
                          : () => _submitWorkLog(vm),
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        vm.isSubmitting ? 'Submitting...' : 'Submit Work Log',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (vm.isMonthly)
            _card(
              title: 'Request Leave',
              icon: Icons.event_busy_outlined,
              child: Form(
                key: _leaveFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _leaveDateController,
                      readOnly: true,
                      onTap: () => _pickDate(_leaveDateController),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Select leave date'
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Leave Date',
                        suffixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _leaveType,
                      decoration: InputDecoration(
                        labelText: 'Leave Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                          setState(() {
                            _leaveType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _leaveCategory,
                      decoration: InputDecoration(
                        labelText: 'Leave Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                          setState(() {
                            _leaveCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _leaveReasonController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Reason',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: vm.isSubmitting
                          ? null
                          : () => _submitLeave(vm),
                      icon: const Icon(Icons.send_outlined),
                      label: Text(
                        vm.isSubmitting
                            ? 'Submitting...'
                            : 'Submit Leave Request',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          _card(
            title: vm.isWorkBased ? 'My Work Logs' : 'My Leave Logs',
            icon: vm.isWorkBased
                ? Icons.history_rounded
                : Icons.event_note_rounded,
            child: Column(
              children: vm.isWorkBased
                  ? (vm.workLogs.isEmpty
                        ? [const Text('No work logs yet')]
                        : vm.workLogs.map(_workLogTile).toList())
                  : (vm.leaveLogs.isEmpty
                        ? [const Text('No leave requests yet')]
                        : vm.leaveLogs.map(_leaveLogTile).toList()),
            ),
          ),
          if (vm.error != null) ...[
            const SizedBox(height: 12),
            Text(vm.error!, style: TextStyle(color: LoginColors.error)),
          ],
        ],
      ),
    );
  }

  Widget _buildSalaryTab(EmployeePortalViewModel vm) {
    return RefreshIndicator(
      onRefresh: vm.loadPortal,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(
            title: 'Salary Report Range',
            icon: Icons.summarize_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('From', vm.salaryReportFromDate),
                _detailRow('To', vm.salaryReportToDate),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: vm.isSalaryLoading
                        ? null
                        : () => _pickSalaryReportRange(vm),
                    icon: const Icon(Icons.date_range_rounded),
                    label: const Text('Change Range'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(
            title: 'My Salary Report',
            icon: Icons.analytics_outlined,
            child: vm.isSalaryLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _salaryReportContent(vm),
          ),
          const SizedBox(height: 16),
          _card(
            title: 'My Salary Periods',
            icon: Icons.account_balance_wallet_outlined,
            child: Column(
              children: vm.salaryPeriods.isEmpty
                  ? [const Text('No salary periods available')]
                  : vm.salaryPeriods.map((period) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: LoginColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LoginColors.borderLight),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  '${period.period}  ${period.netAmount?.toStringAsFixed(2) ?? '-'}',
                                ),
                                subtitle: Text(
                                  '${period.fromDate} to ${period.toDate}\n${period.status}',
                                ),
                                isThreeLine: true,
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                ),
                                onTap: () =>
                                    _showSalaryDetail(context, vm, period),
                              ),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _showSalaryDetail(context, vm, period),
                                    icon: const Icon(
                                      Icons.visibility_outlined,
                                    ),
                                    label: const Text('View Detail'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed:
                                        _downloadingSalaryPeriodId ==
                                            period.salaryPeriodId
                                        ? null
                                        : () => _downloadSalarySlip(vm, period),
                                    icon:
                                        _downloadingSalaryPeriodId ==
                                            period.salaryPeriodId
                                        ? const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.download_rounded),
                                    label: Text(
                                      _downloadingSalaryPeriodId ==
                                              period.salaryPeriodId
                                          ? 'Preparing...'
                                          : 'Download Slip',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _salaryReportContent(EmployeePortalViewModel vm) {
    final report = vm.salaryReport;
    if (report == null) {
      return Text(
        'No salary report available for the selected range',
        style: TextStyle(color: LoginColors.textSecondary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailRow('Employees', report.totalEmployees.toString()),
        _detailRow('Gross', report.totalGrossAmount?.toStringAsFixed(2) ?? '-'),
        _detailRow(
          'Deductions',
          report.totalDeductions?.toStringAsFixed(2) ?? '-',
        ),
        _detailRow('Net', report.totalNetAmount?.toStringAsFixed(2) ?? '-'),
        const SizedBox(height: 12),
        Text(
          'Report Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: LoginColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (report.salaryDetails.isEmpty)
          Text(
            'No salary entries found for the selected range',
            style: TextStyle(color: LoginColors.textSecondary),
          )
        else
          ...report.salaryDetails.map((detail) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LoginColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LoginColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.period,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: LoginColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _detailRow('From', detail.fromDate),
                  _detailRow('To', detail.toDate),
                  _detailRow(
                    'Gross',
                    detail.grossAmount?.toStringAsFixed(2) ?? '-',
                  ),
                  _detailRow('Net', detail.netAmount?.toStringAsFixed(2) ?? '-'),
                  _detailRow('Status', detail.status),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: LoginColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _workLogTile(WorkLogData log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LoginColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
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
          const SizedBox(height: 4),
          Text('${log.logDate}  Qty: ${log.quantity ?? '-'} ${log.unit}'),
          const SizedBox(height: 4),
          Text('Status: ${log.status}'),
        ],
      ),
    );
  }

  Widget _leaveLogTile(LeaveLogData log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LoginColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${log.leaveCategory}  ${log.leaveType}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(log.leaveDate),
          const SizedBox(height: 4),
          Text('Status: ${log.status}'),
          if ((log.reason ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(log.reason!),
          ],
        ],
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
