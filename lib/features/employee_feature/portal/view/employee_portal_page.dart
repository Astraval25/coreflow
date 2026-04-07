import 'dart:async';

import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/features/employee_feature/portal/view_model/employee_portal_view_model.dart';
import 'package:coreflow/features/employee_feature/salary/service/salary_file_service.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _EmployeePortalScreenState extends State<_EmployeePortalScreen>
    with SingleTickerProviderStateMixin {
  // Per-work-definition input controllers + debounce timers + state.
  final Map<int, TextEditingController> _qtyControllers = {};
  final Map<int, Timer> _debounceTimers = {};
  final Map<int, _SaveState> _saveStates = {};
  late final TabController _tabController;
  int _activeTabIndex = 0;
  int? _downloadingSalaryPeriodId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    for (final t in _debounceTimers.values) {
      t.cancel();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int workDefId) {
    return _qtyControllers.putIfAbsent(
      workDefId,
      () => TextEditingController(),
    );
  }

  void _onQtyChanged(
    EmployeePortalViewModel vm,
    WorkDefinitionData work, {
    bool isUpdate = false,
  }) {
    final id = work.workDefId;
    _debounceTimers[id]?.cancel();
    final text = _controllerFor(id).text.trim();

    if (text.isEmpty) {
      setState(() => _saveStates[id] = _SaveState.idle);
      return;
    }
    final qty = double.tryParse(text);
    if (qty == null || qty <= 0) {
      setState(() => _saveStates[id] = _SaveState.invalid);
      return;
    }

    setState(() => _saveStates[id] = _SaveState.pending);
    _debounceTimers[id] = Timer(const Duration(milliseconds: 1200), () async {
      if (!mounted) return;
      setState(() => _saveStates[id] = _SaveState.saving);
      final ok = isUpdate
          ? await vm.updateWorkLog(
              workDefId: id,
              logDate: vm.today,
              quantity: qty,
            )
          : await vm.createWorkLog(
              workDefId: id,
              logDate: vm.today,
              quantity: qty,
            );
      if (!mounted) return;
      setState(() {
        _saveStates[id] = ok ? _SaveState.saved : _SaveState.error;
      });
      if (ok && !isUpdate) {
        _controllerFor(id).clear();
      }
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? LoginColors.error : LoginColors.success,
      ),
    );
  }

  String _todayPretty() {
    return _displayDate(_formatDate(DateTime.now()));
  }

  void _handleTabChange() {
    if (!mounted || _activeTabIndex == _tabController.index) return;
    setState(() {
      _activeTabIndex = _tabController.index;
    });
  }

  bool get _showRangeChip => _activeTabIndex == 0 || _activeTabIndex == 1;

  Future<void> _pickRange({
    required String fromDate,
    required String toDate,
    required Future<void> Function(String fromDate, String toDate)
    onRangeSelected,
  }) async {
    final fromInitial = DateTime.tryParse(fromDate) ?? DateTime.now();
    final pickedFrom = await showDatePicker(
      context: context,
      initialDate: fromInitial,
      firstDate: DateTime(fromInitial.year - 2),
      lastDate: DateTime(fromInitial.year + 2),
    );
    if (pickedFrom == null || !mounted) return;

    final toInitial = DateTime.tryParse(toDate) ?? pickedFrom;
    final pickedTo = await showDatePicker(
      context: context,
      initialDate: pickedFrom.isAfter(toInitial) ? pickedFrom : toInitial,
      firstDate: pickedFrom,
      lastDate: DateTime(pickedFrom.year + 2),
    );
    if (pickedTo == null) return;

    await onRangeSelected(_formatDate(pickedFrom), _formatDate(pickedTo));
  }

  Future<void> _pickAppBarRange(EmployeePortalViewModel vm) async {
    if (_activeTabIndex == 0) {
      await _pickRange(
        fromDate: vm.activityFromDate,
        toDate: vm.activityToDate,
        onRangeSelected: (fromDate, toDate) =>
            vm.updateActivityRange(fromDate: fromDate, toDate: toDate),
      );
      return;
    }

    if (_activeTabIndex == 1) {
      await _pickRange(
        fromDate: vm.salaryReportFromDate,
        toDate: vm.salaryReportToDate,
        onRangeSelected: (fromDate, toDate) =>
            vm.updateSalaryReportRange(fromDate: fromDate, toDate: toDate),
      );
    }
  }

  String _currentRangeLabel(EmployeePortalViewModel vm) {
    final fromDate = _activeTabIndex == 1
        ? vm.salaryReportFromDate
        : vm.activityFromDate;
    final toDate = _activeTabIndex == 1
        ? vm.salaryReportToDate
        : vm.activityToDate;
    return '${_displayDate(fromDate)} - ${_displayDate(toDate)}';
  }

  String _displayDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$day-$month-$year';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployeePortalViewModel>();
    final name = vm.profile?.employeeName ?? 'Employee';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: LoginColors.background,
        appBar: AppBar(
          backgroundColor: LoginColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, $name',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    _todayPretty(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  if (_showRangeChip)
                    InkWell(
                      onTap: (vm.isActivityLoading || vm.isSalaryLoading)
                          ? null
                          : () => _pickAppBarRange(vm),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _currentRangeLabel(vm),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                await vm.logout();
                if (context.mounted) context.go(CfRoutes.login);
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            tabs: const [
              Tab(icon: Icon(Icons.work_history_rounded), text: 'Today'),
              Tab(icon: Icon(Icons.payments_rounded), text: 'Salary'),
              Tab(icon: Icon(Icons.person_rounded), text: 'Profile'),
            ],
          ),
        ),
        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : vm.profile == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    vm.error ?? 'Failed to load. Please pull to refresh.',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildTodayTab(vm),
                  _buildSalaryTab(vm),
                  _buildProfileTab(vm),
                ],
              ),
      ),
    );
  }

  // ----------------------------- TODAY TAB ---------------------------------

  Widget _buildTodayTab(EmployeePortalViewModel vm) {
    return RefreshIndicator(
      onRefresh: vm.loadPortal,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (vm.isTodayLocked) _lockedBanner(vm),
          if (vm.isWorkBased) ..._workBasedSection(vm),
          if (vm.isMonthly) ..._monthlySection(vm),
          const SizedBox(height: 24),
          _activitySection(vm),
        ],
      ),
    );
  }

  Widget _lockedBanner(EmployeePortalViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LoginColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_rounded, color: LoginColors.error, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today is locked',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: LoginColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vm.lockedMessage ??
                      'Salary is already calculated for today. You cannot add work or leave for today. Please contact the admin.',
                  style: TextStyle(color: LoginColors.textPrimary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _workBasedSection(EmployeePortalViewModel vm) {
    return [
      const SizedBox(height: 14),
      if (vm.workDefinitions.isEmpty)
        _emptyCard(
          icon: Icons.workspaces_outline,
          title: 'No work types available',
          subtitle: 'Ask your admin to set up work types.',
        )
      else
        ...vm.workDefinitions.map((work) => _workDefRow(vm, work)),
    ];
  }

  Widget _workDefRow(EmployeePortalViewModel vm, WorkDefinitionData work) {
    final existing = vm.findLogForToday(work.workDefId);
    // final state = _saveStates[work.workDefId] ?? _SaveState.idle;
    final locked = vm.isTodayLocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
      
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              work.workName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child:
                existing != null && existing.status.toUpperCase() == 'APPROVED'
                ? _submittedRow(existing)
                : existing != null
                ? _editableRow(vm, work, existing)
                : locked
                ? _disabledLockRow()
                : _qtyInputRow(vm, work),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              work.unit,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: LoginColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submittedRow(WorkLogData log) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: LoginColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        '${log.quantity ?? '-'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: LoginColors.success,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _editableRow(
    EmployeePortalViewModel vm,
    WorkDefinitionData work,
    WorkLogData existing,
  ) {
    final controller = _controllerFor(work.workDefId);
    if (controller.text.isEmpty &&
        _saveStates[work.workDefId] == null &&
        existing.quantity != null) {
      controller.text = existing.quantity!.toString();
    }

    return _workInputField(
      controller: controller,
      hintText: work.unit,
      onChanged: (_) => _onQtyChanged(vm, work, isUpdate: true),
    );
  }

  Widget _disabledLockRow() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: LoginColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        'Locked',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: LoginColors.textSecondary,
        ),
      ),
    );
  }

  Widget _qtyInputRow(EmployeePortalViewModel vm, WorkDefinitionData work) {
    final controller = _controllerFor(work.workDefId);
    return _workInputField(
      controller: controller,
      hintText: work.unit,
      onChanged: (_) => _onQtyChanged(vm, work),
    );
  }

  Widget _workInputField({
    required TextEditingController controller,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: LoginColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: LoginColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: LoginColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: LoginColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: LoginColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: LoginColors.primary, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }

  // ----------------------------- LEAVE / MONTHLY ---------------------------

  List<Widget> _monthlySection(EmployeePortalViewModel vm) {
    final todayLeave = vm.findLeaveForToday();
    return [
      Row(
        children: [
          Icon(Icons.event_note_rounded, color: LoginColors.primary, size: 22),
          const SizedBox(width: 8),
          Text(
            'Today\'s Status',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: LoginColors.textPrimary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (todayLeave != null)
        _todayLeaveCard(todayLeave)
      else if (vm.isTodayLocked)
        _disabledLockRow()
      else
        _leaveActionCard(vm),
      const SizedBox(height: 18),
      Center(
        child: TextButton.icon(
          onPressed: vm.isTodayLocked ? null : () => _openLeaveDialog(vm),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Request leave for another day'),
        ),
      ),
    ];
  }

  Widget _todayLeaveCard(LeaveLogData log) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LoginColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: LoginColors.success,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave submitted',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: LoginColors.textPrimary,
                  ),
                ),
                Text(
                  '${log.leaveType} · ${log.leaveCategory} · ${log.status}',
                  style: TextStyle(color: LoginColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _leaveActionCard(EmployeePortalViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        children: [
          Text(
            'Need to take leave today?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _bigLeaveButton(
                  icon: Icons.event_busy_rounded,
                  label: 'Full Day',
                  color: LoginColors.error,
                  onTap: () => _quickLeave(vm, 'FULL_DAY'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _bigLeaveButton(
                  icon: Icons.brightness_4_rounded,
                  label: 'Half Day',
                  color: LoginColors.accent,
                  onTap: () => _quickLeave(vm, 'HALF_DAY'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bigLeaveButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _quickLeave(EmployeePortalViewModel vm, String leaveType) async {
    final reason = await _askReason();
    if (reason == null) return;
    final ok = await vm.createLeaveLog(
      leaveDate: vm.today,
      leaveType: leaveType,
      leaveCategory: 'CASUAL',
      reason: reason.isEmpty ? null : reason,
    );
    if (!mounted) return;
    _showMessage(
      ok ? 'Leave submitted' : (vm.error ?? 'Failed to submit leave'),
      isError: !ok,
    );
  }

  Future<String?> _askReason() async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reason (optional)'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Why are you taking leave?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _openLeaveDialog(EmployeePortalViewModel vm) async {
    DateTime? picked = DateTime.now().add(const Duration(days: 1));
    String type = 'FULL_DAY';
    String category = 'CASUAL';
    final reasonCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Request Leave'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: Text(
                    picked == null
                        ? 'Pick a date'
                        : _displayDate(_formatDate(picked!)),
                  ),
                  onTap: () async {
                    final p = await showDatePicker(
                      context: ctx,
                      initialDate: picked ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (p != null) setLocal(() => picked = p);
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  items: const [
                    DropdownMenuItem(
                      value: 'FULL_DAY',
                      child: Text('Full Day'),
                    ),
                    DropdownMenuItem(
                      value: 'HALF_DAY',
                      child: Text('Half Day'),
                    ),
                  ],
                  onChanged: (v) => setLocal(() => type = v ?? type),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  items: const [
                    DropdownMenuItem(value: 'CASUAL', child: Text('Casual')),
                    DropdownMenuItem(value: 'SICK', child: Text('Sick')),
                    DropdownMenuItem(value: 'UNPAID', child: Text('Unpaid')),
                    DropdownMenuItem(value: 'LOP', child: Text('Loss of Pay')),
                  ],
                  onChanged: (v) => setLocal(() => category = v ?? category),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Reason (optional)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (picked == null) return;
                final dateStr =
                    '${picked!.year}-${picked!.month.toString().padLeft(2, '0')}-${picked!.day.toString().padLeft(2, '0')}';
                Navigator.pop(dctx);
                final ok = await vm.createLeaveLog(
                  leaveDate: dateStr,
                  leaveType: type,
                  leaveCategory: category,
                  reason: reasonCtrl.text.trim().isEmpty
                      ? null
                      : reasonCtrl.text.trim(),
                );
                if (!mounted) return;
                _showMessage(
                  ok ? 'Leave requested' : (vm.error ?? 'Failed'),
                  isError: !ok,
                );
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------- ACTIVITY SECTION --------------------------

  Widget _activitySection(EmployeePortalViewModel vm) {
    final logs = vm.isWorkBased
        ? List<WorkLogData>.from(vm.workLogs)
        : <WorkLogData>[];
    final leaves = List<LeaveLogData>.from(vm.leaveLogs);
    logs.sort((a, b) => b.logDate.compareTo(a.logDate));
    leaves.sort((a, b) => b.leaveDate.compareTo(a.leaveDate));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history_rounded, color: LoginColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Activity',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: LoginColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (vm.isActivityLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (logs.isEmpty && leaves.isEmpty)
          _emptyCard(
            icon: Icons.inbox_rounded,
            title: 'No activity for this range',
            subtitle: 'Change the date range to see another month.',
          ),
        ...logs.map(_recentWorkTileFormatted),
        ...leaves.map(_recentLeaveTileFormatted),
      ],
    );
  }

  Widget _recentWorkTileFormatted(WorkLogData log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(Icons.handyman_rounded, color: LoginColors.primary, size: 20),
          const SizedBox(width: 10),
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
                Text(
                  '${_displayDate(log.logDate)} · ${log.quantity ?? '-'} ${log.unit}',
                  style: TextStyle(
                    fontSize: 12,
                    color: LoginColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _statusBadge(log.status),
        ],
      ),
    );
  }

  Widget _recentLeaveTileFormatted(LeaveLogData log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(Icons.event_busy_rounded, color: LoginColors.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${log.leaveCategory} · ${log.leaveType}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
                Text(
                  _displayDate(log.leaveDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: LoginColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _statusBadge(log.status),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _recentWorkTile(WorkLogData log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(Icons.handyman_rounded, color: LoginColors.primary, size: 20),
          const SizedBox(width: 10),
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
                Text(
                  '${log.logDate} · ${log.quantity ?? '-'} ${log.unit}',
                  style: TextStyle(
                    fontSize: 12,
                    color: LoginColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _statusBadge(log.status),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _recentLeaveTile(LeaveLogData log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(Icons.event_busy_rounded, color: LoginColors.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${log.leaveCategory} · ${log.leaveType}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
                Text(
                  log.leaveDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: LoginColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _statusBadge(log.status),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return LoginColors.success;
      case 'REJECTED':
        return LoginColors.error;
      default:
        return LoginColors.primary;
    }
  }

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: LoginColors.textTertiary),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: LoginColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ----------------------------- SALARY TAB --------------------------------

  Widget _buildSalaryTab(EmployeePortalViewModel vm) {
    return RefreshIndicator(
      onRefresh: vm.loadPortal,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (vm.isSalaryLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (vm.salaryReport != null) ...[
              _salarySummaryCard(vm.salaryReport!),
              const SizedBox(height: 16),
            ],
            if (vm.salaryPeriods.isEmpty)
              _emptyCard(
                icon: Icons.payments_rounded,
                title: 'No salary for this range',
                subtitle: 'Change the date range to view another month.',
              )
            else
              ...vm.salaryPeriods.map((p) => _salaryPeriodCard(vm, p)),
          ],
        ],
      ),
    );
  }

  Widget _salarySummaryCard(SalaryReportData report) {
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
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow('From', _displayDate(report.fromDate)),
          _summaryRow('To', _displayDate(report.toDate)),
          _summaryRow('Net', report.totalNetAmount?.toStringAsFixed(2) ?? '-'),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: TextStyle(color: LoginColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _salaryPeriodCard(
    EmployeePortalViewModel vm,
    SalaryPeriodSummary period,
  ) {
    final downloading = _downloadingSalaryPeriodId == period.salaryPeriodId;
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: LoginColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: LoginColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      period.period,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${_displayDate(period.fromDate)} to ${_displayDate(period.toDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(period.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'You will get',
                style: TextStyle(
                  color: LoginColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                '₹${period.netAmount?.toStringAsFixed(2) ?? '-'}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: LoginColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: downloading ? null : () => _downloadSlip(vm, period),
              icon: downloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(downloading ? 'Preparing...' : 'Download Slip'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadSlip(
    EmployeePortalViewModel vm,
    SalaryPeriodSummary period,
  ) async {
    setState(() => _downloadingSalaryPeriodId = period.salaryPeriodId);
    try {
      final bytes = await vm.downloadSalarySlip(period.salaryPeriodId);
      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        _showMessage('Failed to download', isError: true);
        return;
      }
      await SalaryFileService.shareSalarySlip(
        bytes: bytes,
        fileName: 'salary-slip-${period.period}.pdf',
      );
    } catch (e) {
      if (mounted) _showMessage('Failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _downloadingSalaryPeriodId = null);
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // ----------------------------- PROFILE TAB -------------------------------

  Widget _buildProfileTab(EmployeePortalViewModel vm) {
    final p = vm.profile!;
    return RefreshIndicator(
      onRefresh: vm.loadPortal,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: LoginColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    (p.employeeName.isNotEmpty ? p.employeeName[0] : '?')
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  p.employeeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  p.designation ?? '-',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _infoTile(Icons.badge_rounded, 'Code', p.employeeCode),
          _infoTile(Icons.phone_rounded, 'Phone', p.phone ?? '-'),
          _infoTile(Icons.email_rounded, 'Email', p.email ?? '-'),
          _infoTile(
            Icons.calendar_today_rounded,
            'Joined',
            _displayDate(p.joinedDt ?? '-'),
          ),
          _infoTile(
            Icons.payments_rounded,
            'Salary Type',
            p.currentSalaryType ?? '-',
          ),
          if (p.currentMonthlyAmount != null)
            _infoTile(
              Icons.account_balance_wallet_rounded,
              'Monthly',
              '₹${p.currentMonthlyAmount!.toStringAsFixed(2)}',
            ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, color: LoginColors.primary, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: LoginColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: LoginColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SaveState { idle, invalid, pending, saving, saved, error }
