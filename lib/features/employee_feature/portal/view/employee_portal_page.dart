import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/employee_model/employee_module_models.dart';
import 'package:coreflow/features/employee_feature/portal/view_model/employee_portal_view_model.dart';
import 'package:coreflow/features/employee_feature/portal/widget/portal_common.dart';
import 'package:coreflow/features/employee_feature/portal/widget/portal_profile_tab.dart';
import 'package:coreflow/features/employee_feature/portal/widget/portal_salary_tab.dart';
import 'package:coreflow/features/employee_feature/portal/widget/portal_workbased_section.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum _UnsavedAction { cancel, discard, save }

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
  late final TabController _tabController;
  final GlobalKey<PortalWorkBasedSectionState> _workSectionKey =
      GlobalKey<PortalWorkBasedSectionState>();
  int _activeTabIndex = 0;

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
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? LoginColors.error : LoginColors.success,
      ),
    );
  }

  String _todayPretty() => portalDisplayDate(portalFormatDate(DateTime.now()));

  void _handleTabChange() {
    if (!mounted || _activeTabIndex == _tabController.index) return;
    setState(() => _activeTabIndex = _tabController.index);
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

    await onRangeSelected(
      portalFormatDate(pickedFrom),
      portalFormatDate(pickedTo),
    );
  }

  Future<void> _pickAppBarRange(EmployeePortalViewModel vm) async {
    if (_activeTabIndex == 0) {
      await _pickRange(
        fromDate: vm.activityFromDate,
        toDate: vm.activityToDate,
        onRangeSelected: (f, t) =>
            vm.updateActivityRange(fromDate: f, toDate: t),
      );
      return;
    }
    if (_activeTabIndex == 1) {
      await _pickRange(
        fromDate: vm.salaryReportFromDate,
        toDate: vm.salaryReportToDate,
        onRangeSelected: (f, t) =>
            vm.updateSalaryReportRange(fromDate: f, toDate: t),
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
    return '${portalDisplayDate(fromDate)} - ${portalDisplayDate(toDate)}';
  }

  Future<void> _handleBackNavigation(EmployeePortalViewModel vm) async {
    final workState = _workSectionKey.currentState;
    if (vm.isWorkBased && workState != null && workState.hasUnsavedChanges) {
      final action = await showDialog<_UnsavedAction>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Unsaved work entries'),
          content: const Text(
            'You have unsaved work entries. Save before leaving?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, _UnsavedAction.cancel),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, _UnsavedAction.discard),
              child: const Text('Discard'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, _UnsavedAction.save),
              child: const Text('Save'),
            ),
          ],
        ),
      );

      if (!mounted || action == null || action == _UnsavedAction.cancel) return;
      if (action == _UnsavedAction.save) {
        final ok = await workState.saveAllDrafts();
        if (!mounted) return;
        if (!ok) {
          _showMessage(
            vm.error ?? 'Please fix errors before leaving',
            isError: true,
          );
          return;
        }
      }
    }

    final didPop = await Navigator.of(context).maybePop();
    if (!didPop) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployeePortalViewModel>();
    final name = vm.profile?.employeeName ?? 'Employee';

    return DefaultTabController(
      length: 3,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await _handleBackNavigation(vm);
        },
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
                  final workState = _workSectionKey.currentState;
                  if (vm.isWorkBased &&
                      workState != null &&
                      workState.hasUnsavedChanges) {
                    _showMessage(
                      'Please save or discard work entries first',
                      isError: true,
                    );
                    return;
                  }
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
                    PortalSalaryTab(vm: vm),
                    PortalProfileTab(vm: vm),
                  ],
                ),
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
          if (vm.isWorkBased)
            PortalWorkBasedSection(key: _workSectionKey, vm: vm),
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

  // ----------------------------- LEAVE / MONTHLY ---------------------------

  List<Widget> _monthlySection(EmployeePortalViewModel vm) {
    final todayLeave = vm.findLeaveForToday();
    return [
      Row(
        children: [
          Icon(Icons.event_note_rounded, color: LoginColors.primary, size: 22),
          const SizedBox(width: 8),
          Text(
            "Today's Status",
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
        _disabledLockBanner()
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

  Widget _disabledLockBanner() {
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
    return showDialog<String>(
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
                        : portalDisplayDate(portalFormatDate(picked!)),
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
                final dateStr = portalFormatDate(picked!);
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
          const PortalEmptyCard(
            icon: Icons.inbox_rounded,
            title: 'No activity for this range',
            subtitle: 'Change the date range to see another month.',
          ),
        ...logs.map(_recentWorkTile),
        ...leaves.map(_recentLeaveTile),
      ],
    );
  }

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
                  '${portalDisplayDate(log.logDate)} · ${log.quantity ?? '-'} ${log.unit}',
                  style: TextStyle(
                    fontSize: 12,
                    color: LoginColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          PortalStatusBadge(log.status),
        ],
      ),
    );
  }

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
                  portalDisplayDate(log.leaveDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: LoginColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          PortalStatusBadge(log.status),
        ],
      ),
    );
  }
}
