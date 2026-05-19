import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
import 'package:coreflow/domain/model/main_model/analytics/employee_analytics.dart';
import 'package:coreflow/domain/model/employee_model/employee_detail.dart';
import 'package:coreflow/features/employee_feature/employees/view_model/employee_detail_view_model.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EmployeeDetailPage extends StatelessWidget {
  final int companyId;
  final int employeeId;

  const EmployeeDetailPage({
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
          create: (_) => EmployeeDetailViewModel(
            employeeRepository: EmployeeRepository(),
            companyId: companyId,
            employeeId: employeeId,
          ),
        ),
      ],
      child: const _EmployeeDetailScreen(),
    );
  }
}

class _EmployeeDetailScreen extends StatelessWidget {
  const _EmployeeDetailScreen();

  Future<void> _handleMenuAction(
    BuildContext context,
    EmployeeDetailViewModel vm,
    String value,
  ) async {
    switch (value) {
      case 'edit':
        await context.push(
          CfRoutes.employeeUpdate(vm.companyId, vm.employeeId),
        );
        vm.loadEmployeeDetail();
        break;
      case 'deactivate':
      case 'activate':
        final activate = value == 'activate';
        final ok = activate
            ? await vm.activateEmployee()
            : await vm.deactivateEmployee();
        if (!context.mounted) return;
        final text = ok
            ? (vm.message ??
                (activate ? 'Employee activated' : 'Employee deactivated'))
            : (vm.errorMessage ??
                (activate
                    ? 'Failed to activate employee'
                    : 'Failed to deactivate employee'));
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(text)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardVm = context.watch<DashboardViewModel>();
    final vm = context.watch<EmployeeDetailViewModel>();

    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          vm.employee?.employeeName ?? 'Employee Details',
          style: TextStyle(
            color: LoginColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        foregroundColor: LoginColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: LoginColors.background,
        actions: [
          if (!vm.isLoading && vm.employee != null)
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, vm, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: vm.isActive ? 'deactivate' : 'activate',
                  enabled: !vm.isTogglingStatus,
                  child: Row(
                    children: [
                      Icon(
                        vm.isActive
                            ? Icons.block_outlined
                            : Icons.check_circle_outline,
                        size: 18,
                        color: vm.isActive
                            ? LoginColors.error
                            : LoginColors.success,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        vm.isTogglingStatus
                            ? 'Working...'
                            : vm.isActive
                                ? 'Deactivate'
                                : 'Activate',
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      body: RefreshIndicator(
        onRefresh: vm.loadEmployeeDetail,
        child: Builder(
          builder: (context) {
            if (vm.isLoading && vm.employee == null) {
              return const _LoadingBody();
            }
            if (vm.isError) {
              return _ErrorBody(
                message: vm.errorMessage ?? 'Failed to load employee',
                onRetry: vm.loadEmployeeDetail,
              );
            }
            if (vm.isNoData || vm.employee == null) {
              return _ErrorBody(
                message: vm.errorMessage ?? 'No employee data found',
                onRetry: vm.loadEmployeeDetail,
              );
            }
            return _EmployeeDetailBody(employee: vm.employee!, vm: vm);
          },
        ),
      ),
    );
  }
}

class _EmployeeDetailBody extends StatelessWidget {
  final EmployeeDetailData employee;
  final EmployeeDetailViewModel vm;

  const _EmployeeDetailBody({required this.employee, required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _portalAccessCard(context, vm),
        const SizedBox(height: 16),
        _analyticsOverviewCard(vm),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Basic Details',
          icon: Icons.badge_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('Employee Code', employee.employeeCode),
              _row('Employee Name', employee.employeeName),
              _row('Phone', employee.phone ?? '-'),
              _row('Email', employee.email ?? '-'),
              _row('Designation', employee.designation ?? '-'),
              _row('Joined Date', _formatDate(employee.joinedDt)),
              _statusRow(employee.isActive),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Current Salary',
          icon: Icons.account_balance_wallet_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('Salary Type', employee.currentSalaryType ?? '-'),
              _row(
                'Monthly Amount',
                employee.currentMonthlyAmount == null
                    ? '-'
                    : employee.currentMonthlyAmount!.toStringAsFixed(2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Salary History',
          icon: Icons.history_rounded,
          child: employee.salaryConfigHistory.isEmpty
              ? Text(
                  'No salary history available',
                  style: TextStyle(color: LoginColors.textSecondary),
                )
              : Column(
                  children: employee.salaryConfigHistory.map((history) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: LoginColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: LoginColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row('Type', history.salaryType),
                          _row(
                            'Monthly Amount',
                            history.monthlyAmount?.toStringAsFixed(2) ?? '-',
                          ),
                          _row(
                            'Effective From',
                            _formatDate(history.effectiveFrom),
                          ),
                          _row(
                            'Effective To',
                            _formatDate(history.effectiveTo) == '-'
                                ? 'Present'
                                : _formatDate(history.effectiveTo),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _sectionCard({
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
              Icon(icon, color: LoginColors.primary, size: 18),
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

  Widget _analyticsOverviewCard(EmployeeDetailViewModel vm) {
    final overview = vm.analyticsOverview;
    final daily = vm.dailyAnalytics;

    return _sectionCard(
      title: 'Last 30 Days Analytics',
      icon: Icons.analytics_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 18,
                color: LoginColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (vm.isAnalyticsLoading && overview == null && daily.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.1)),
            )
          else if (overview == null && daily.isEmpty)
            Text(
              'Analytics data not available yet',
              style: TextStyle(
                fontSize: 12.5,
                color: LoginColors.textSecondary,
              ),
            )
          else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _metricChip(
                  'Work Qty',
                  (overview?.approvedWorkQuantity ?? 0).toStringAsFixed(2),
                ),
                _metricChip(
                  'Work Amount',
                  '₹${(overview?.approvedWorkAmount ?? 0).toStringAsFixed(0)}',
                ),
                _metricChip(
                  'Leave Days',
                  (overview?.approvedLeaveDays ?? 0).toStringAsFixed(1),
                ),
                _metricChip(
                  'Pending',
                  '${(overview?.pendingWorkLogCount ?? 0) + (overview?.pendingLeaveLogCount ?? 0)}',
                ),
              ],
            ),
            if (daily.length > 1) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 88,
                child: CustomPaint(
                  painter: _EmployeeAnalyticsPainter(entries: daily),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: LoginColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: LoginColors.borderLight),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontSize: 11.5,
                color: LoginColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 12,
                color: LoginColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                color: LoginColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
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

  Widget _portalAccessCard(BuildContext context, EmployeeDetailViewModel vm) {
    return _sectionCard(
      title: 'Portal Access',
      icon: Icons.lock_person_outlined,
      child: Builder(
        builder: (_) {
          if (vm.isLoadingPortal && vm.portalUser == null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Loading…',
                style: TextStyle(color: LoginColors.textSecondary),
              ),
            );
          }
          final pu = vm.portalUser;
          if (pu == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No portal user. Create one so the employee can log in to the self-service portal.',
                  style: TextStyle(color: LoginColors.textSecondary),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: vm.isPortalBusy
                        ? null
                        : () => _showCreatePortalDialog(context, vm),
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Create Portal User'),
                  ),
                ),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row('Username', pu.username),
              Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      'Status',
                      style: TextStyle(
                        color: LoginColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _statusBadge(pu.isActive),
                ],
              ),
              if (pu.lastLoginDt != null) ...[
                const SizedBox(height: 8),
                _row('Last Login', _formatDate(pu.lastLoginDt)),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: vm.isPortalBusy
                          ? null
                          : () => _showResetPasswordDialog(context, vm),
                      icon: const Icon(Icons.lock_reset_outlined, size: 18),
                      label: const Text('Reset Password'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: vm.isPortalBusy
                          ? null
                          : () => _togglePortalAccess(context, vm),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            pu.isActive ? LoginColors.error : LoginColors.success,
                      ),
                      icon: Icon(
                        pu.isActive
                            ? Icons.block_outlined
                            : Icons.check_circle_outline,
                        size: 18,
                      ),
                      label: Text(pu.isActive ? 'Deactivate' : 'Activate'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statusBadge(bool isActive) {
    final color = isActive ? LoginColors.success : LoginColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _showCreatePortalDialog(
    BuildContext context,
    EmployeeDetailViewModel vm,
  ) async {
    final usernameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Portal User'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: usernameCtrl,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (v) => (v == null || v.length < 6)
                    ? 'Min 6 characters'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final success = await vm.createPortalUser(
      username: usernameCtrl.text.trim(),
      password: passwordCtrl.text,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (vm.message ?? 'Portal user created')
              : (vm.errorMessage ?? 'Failed to create portal user'),
        ),
      ),
    );
  }

  Future<void> _showResetPasswordDialog(
    BuildContext context,
    EmployeeDetailViewModel vm,
  ) async {
    final passwordCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: passwordCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password'),
            validator: (v) =>
                (v == null || v.length < 6) ? 'Min 6 characters' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final success = await vm.resetPortalPassword(passwordCtrl.text);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (vm.message ?? 'Password reset')
              : (vm.errorMessage ?? 'Failed to reset password'),
        ),
      ),
    );
  }

  Future<void> _togglePortalAccess(
    BuildContext context,
    EmployeeDetailViewModel vm,
  ) async {
    final activate = !(vm.portalUser?.isActive ?? false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(activate ? 'Activate access?' : 'Deactivate access?'),
        content: Text(
          activate
              ? 'The employee will be able to log in to the portal again.'
              : 'The employee will not be able to log in to the portal until reactivated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(activate ? 'Activate' : 'Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final success = await vm.togglePortalAccess();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (vm.message ?? 'Portal access updated')
              : (vm.errorMessage ?? 'Failed to update portal access'),
        ),
      ),
    );
  }

  Widget _statusRow(bool isActive) {
    final color = isActive ? LoginColors.success : LoginColors.error;
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            'Status',
            style: TextStyle(
              color: LoginColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '-';
    final dateTime = DateTime.tryParse(raw);
    if (dateTime == null) return raw;
    final month = _months[dateTime.month - 1];
    return '${dateTime.day.toString().padLeft(2, '0')} $month ${dateTime.year}';
  }

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
}

class _EmployeeAnalyticsPainter extends CustomPainter {
  final List<EmployeeDailyAnalyticsEntry> entries;

  const _EmployeeAnalyticsPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    final workValues = entries
        .map((entry) => entry.approvedWorkAmount)
        .toList(growable: false);
    final leaveValues = entries
        .map((entry) => entry.approvedLeaveDays)
        .toList(growable: false);
    final allValues = [...workValues, ...leaveValues];
    final maxValue = allValues.fold<double>(0, (max, value) {
      return value > max ? value : max;
    });
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    final chartHeight = size.height - 4;
    final stepX = size.width / (entries.length - 1);

    final gridPaint = Paint()
      ..color = LoginColors.borderLight
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final y = chartHeight * (i / 2);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    Path buildPath(List<double> values) {
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final x = i * stepX;
        final y = chartHeight - (values[i] / safeMax) * chartHeight;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      return path;
    }

    final workPath = buildPath(workValues);
    final leavePath = buildPath(leaveValues);

    final workPaint = Paint()
      ..color = LoginColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final leavePaint = Paint()
      ..color = LoginColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(workPath, workPaint);
    canvas.drawPath(leavePath, leavePaint);
  }

  @override
  bool shouldRepaint(covariant _EmployeeAnalyticsPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: const [
        _LoadingBlock(height: 180),
        SizedBox(height: 16),
        _LoadingBlock(height: 130),
        SizedBox(height: 16),
        _LoadingBlock(height: 200),
      ],
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  final double height;

  const _LoadingBlock({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LoginColors.borderLight),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
