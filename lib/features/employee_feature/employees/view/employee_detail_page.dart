import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/data/repositories/employee_repository/employee_repository.dart';
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
              onSelected: (value) async {
                switch (value) {
                  case 'edit':
                    await context.push(
                      CfRoutes.employeeUpdate(vm.companyId, vm.employeeId),
                    );
                    vm.loadEmployeeDetail();
                    break;
                  case 'deactivate':
                    final ok = await vm.deactivateEmployee();
                    if (!context.mounted) return;
                    final text = ok
                        ? (vm.message ?? 'Employee deactivated successfully')
                        : (vm.errorMessage ?? 'Failed to deactivate employee');
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(text)));
                    break;
                }
              },
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
                if (vm.isActive)
                  PopupMenuItem(
                    value: 'deactivate',
                    enabled: !vm.isDeactivating,
                    child: Row(
                      children: [
                        Icon(
                          Icons.block_outlined,
                          size: 18,
                          color: LoginColors.error,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          vm.isDeactivating ? 'Deactivating...' : 'Deactivate',
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
            return _EmployeeDetailBody(employee: vm.employee!);
          },
        ),
      ),
    );
  }
}

class _EmployeeDetailBody extends StatelessWidget {
  final EmployeeDetailData employee;

  const _EmployeeDetailBody({required this.employee});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
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
