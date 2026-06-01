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
import 'package:shared_preferences/shared_preferences.dart';

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

class _EmployeePortalScreenState extends State<_EmployeePortalScreen> {
  final GlobalKey<PortalWorkBasedSectionState> _workSectionKey =
      GlobalKey<PortalWorkBasedSectionState>();
  int _activeTabIndex = 0;

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? LoginColors.error : LoginColors.success,
      ),
    );
  }

  String _todayPretty() => portalDisplayDate(portalFormatDate(DateTime.now()));

  Future<bool> _handleUnsavedWorkEntries(EmployeePortalViewModel vm) async {
    final workState = _workSectionKey.currentState;
    if (!(vm.isWorkBased && workState != null && workState.hasUnsavedChanges)) {
      return true;
    }

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

    if (!mounted || action == null || action == _UnsavedAction.cancel) {
      return false;
    }

    if (action == _UnsavedAction.save) {
      final ok = await workState.saveAllDrafts();
      if (!mounted) return false;
      if (!ok) {
        _showMessage(
          vm.error ?? 'Please fix errors before leaving',
          isError: true,
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _handleBackNavigation(EmployeePortalViewModel vm) async {
    final canContinue = await _handleUnsavedWorkEntries(vm);
    if (!canContinue || !mounted) return;

    final didPop = await Navigator.of(context).maybePop();
    if (!didPop) {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmployeePortalViewModel>();
    final name = vm.profile?.employeeName ?? 'Employee';

    return PopScope(
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
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                final canContinue = await _handleUnsavedWorkEntries(vm);
                if (!canContinue || !mounted) return;
                await vm.logout();
                if (context.mounted) context.go(CfRoutes.login);
              },
            ),
          ],
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
            : IndexedStack(
                index: _activeTabIndex,
                children: [
                  _buildHomeTab(vm),
                  PortalSalaryTab(vm: vm),
                  PortalProfileTab(vm: vm),
                ],
              ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _activeTabIndex,
          onTap: (index) => setState(() => _activeTabIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payments_rounded),
              label: 'Salary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
        floatingActionButton: _activeTabIndex == 0 && vm.isWorkBased
            ? FloatingActionButton.extended(
                onPressed: vm.isTodayLocked
                    ? null
                    : () => _openTodayWorkEntries(vm),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Work'),
              )
            : null,
      ),
    );
  }

  // ------------------------------ HOME TAB ---------------------------------

  Widget _buildHomeTab(EmployeePortalViewModel vm) {
    return RefreshIndicator(
      onRefresh: vm.loadPortal,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (vm.isTodayLocked) _lockedBanner(vm),
          if (vm.isWorkBased) _addTodayWorkCard(vm),
          if (vm.isMonthly) ..._monthlySection(vm),
          const SizedBox(height: 4),
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

  Widget _addTodayWorkCard(EmployeePortalViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: Row(
        children: [
          Wrap(
            children: [
              OutlinedButton.icon(
                onPressed: vm.isTodayLocked ? null : () => _openLeaveDialog(vm),
                icon: const Icon(Icons.event_note_rounded),
                label: const Text('Leave Request'),
              ),
              const SizedBox(width: 14),

              FilledButton.icon(
                onPressed: vm.isTodayLocked
                    ? null
                    : () => _openTodayWorkEntries(vm),
                icon: const Icon(Icons.add_task_rounded),
                label: const Text('Today Work'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openTodayWorkEntries(EmployeePortalViewModel vm) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => _TodayWorkEntriesPage(vm: vm)),
    );
    if (!mounted || saved != true) return;
    _showMessage('Work entries submitted');
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
                  '${log.leaveType} - ${log.leaveCategory} - ${log.status}',
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
    final entries = <_PortalActivityEntry>[
      if (vm.isWorkBased) ...vm.workLogs.map(_PortalActivityEntry.work),
      ...vm.leaveLogs.map(_PortalActivityEntry.leave),
    ]..sort((a, b) => b.date.compareTo(a.date));

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
        else if (entries.isEmpty)
          const PortalEmptyCard(
            icon: Icons.inbox_rounded,
            title: 'No activity for this range',
            subtitle: 'Activity from the last 30 days will appear here.',
          )
        else
          ...List.generate(entries.length, (index) {
            final item = entries[index];
            final previous = index > 0 ? entries[index - 1] : null;
            final showDateHeader =
                previous == null ||
                !_isSameCalendarDay(previous.date, item.date);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showDateHeader) ...[
                  if (index != 0) const SizedBox(height: 14),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        portalDisplayDate(item.dateKey),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: LoginColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
                _activityEntryCard(item),
              ],
            );
          }),
      ],
    );
  }

  bool _isSameCalendarDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _activityEntryCard(_PortalActivityEntry entry) {
    final actionLabel = entry.isWork ? 'Work Log' : 'Leave';
    final actionColor = entry.isWork ? LoginColors.primary : LoginColors.accent;
    final actionIcon = entry.isWork
        ? Icons.handyman_rounded
        : Icons.event_busy_rounded;
    final status = entry.status;
    final title = entry.isWork
        ? entry.workLog!.workName
        : '${entry.leaveLog!.leaveCategory} - ${entry.leaveLog!.leaveType}';
    final subtitle = entry.isWork
        ? '${entry.workLog!.quantity ?? '-'} ${entry.workLog!.unit}'
        : (entry.leaveLog!.reason?.trim().isNotEmpty ?? false)
        ? entry.leaveLog!.reason!.trim()
        : 'No reason provided';
    final earnedAmount = entry.isWork ? entry.workLog!.amountEarned : null;

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
              _actionChip(
                label: actionLabel,
                icon: actionIcon,
                color: actionColor,
              ),
              const Spacer(),
              PortalStatusBadge(status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: LoginColors.textSecondary),
          ),
          if (earnedAmount != null) ...[
            const SizedBox(height: 2),
            Text(
              'Earned: \u20B9${earnedAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: LoginColors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalActivityEntry {
  final String dateKey;
  final DateTime date;
  final WorkLogData? workLog;
  final LeaveLogData? leaveLog;

  const _PortalActivityEntry._({
    required this.dateKey,
    required this.date,
    this.workLog,
    this.leaveLog,
  });

  bool get isWork => workLog != null;
  String get status => isWork ? workLog!.status : leaveLog!.status;

  factory _PortalActivityEntry.work(WorkLogData log) {
    return _PortalActivityEntry._(
      dateKey: log.logDate,
      date:
          DateTime.tryParse(log.logDate) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      workLog: log,
    );
  }

  factory _PortalActivityEntry.leave(LeaveLogData log) {
    return _PortalActivityEntry._(
      dateKey: log.leaveDate,
      date:
          DateTime.tryParse(log.leaveDate) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      leaveLog: log,
    );
  }
}

class _TodayWorkEntriesPage extends StatefulWidget {
  final EmployeePortalViewModel vm;
  const _TodayWorkEntriesPage({required this.vm});

  @override
  State<_TodayWorkEntriesPage> createState() => _TodayWorkEntriesPageState();
}

class _TodayWorkEntriesPageState extends State<_TodayWorkEntriesPage> {
  final GlobalKey<PortalWorkBasedSectionState> _workKey =
      GlobalKey<PortalWorkBasedSectionState>();
  Set<String> _pinnedWorkKeys = <String>{};
  static const _pinnedWorkPrefKey = 'employee_portal_pinned_work_keys_v1';

  @override
  void initState() {
    super.initState();
    _loadPinnedWorkKeys();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? LoginColors.error : LoginColors.success,
      ),
    );
  }

  String _workPinKey(int workDefId) => 'W:$workDefId';

  bool _isWorkPinned(int workDefId) =>
      _pinnedWorkKeys.contains(_workPinKey(workDefId));

  Future<void> _loadPinnedWorkKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_pinnedWorkPrefKey) ?? const <String>[];
    if (!mounted) return;
    setState(() => _pinnedWorkKeys = values.toSet());
  }

  Future<void> _toggleWorkPin(int workDefId) async {
    final key = _workPinKey(workDefId);
    setState(() {
      if (_pinnedWorkKeys.contains(key)) {
        _pinnedWorkKeys.remove(key);
      } else {
        _pinnedWorkKeys.add(key);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_pinnedWorkPrefKey, _pinnedWorkKeys.toList());
  }

  Future<void> _submit() async {
    final vm = widget.vm;
    final ok = await _workKey.currentState?.saveAllDrafts() ?? false;
    if (!mounted) return;
    if (!ok) {
      _showMessage(vm.error ?? 'Failed to submit work entries', isError: true);
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: const Text('Today Work Entries'),
        backgroundColor: LoginColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PortalWorkBasedSection(
            key: _workKey,
            vm: vm,
            showSaveButton: false,
            showTopSpacing: false,
            showPinActions: true,
            isPinned: _isWorkPinned,
            onTogglePin: _toggleWorkPin,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: vm.isSubmitting || vm.isTodayLocked ? null : _submit,
            child: Text(vm.isSubmitting ? 'Submitting...' : 'Submit'),
          ),
        ),
      ),
    );
  }
}
