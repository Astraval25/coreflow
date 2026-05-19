import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/employee_model/employee.dart';
import 'package:coreflow/features/employee_feature/employees/view_model/employees_view_model.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EmployeeListItem extends StatelessWidget {
  final Employee employee;
  final int companyId;

  const EmployeeListItem({
    super.key,
    required this.employee,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context) {
    final name = employee.employeeName.trim();
    final avatarText = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1.5,
      color: LoginColors.surface,
      shadowColor: LoginColors.shadowLight.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: LoginColors.borderLight, width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: LoginColors.primaryLight.withValues(alpha: 0.12),
        highlightColor: LoginColors.primaryLight.withValues(alpha: 0.06),
        onTap: () async {
          await context.push(
            CfRoutes.employeeDetail(companyId, employee.employeeId),
          );
          if (context.mounted) {
            await context.read<EmployeesViewModel>().refresh();
            await context.read<DashboardViewModel>().refreshUnreadCount();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: LoginColors.primary.withValues(
                      alpha: 0.15,
                    ),
                    child: Text(
                      avatarText,
                      style: TextStyle(
                        color: LoginColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.employeeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.employeeCode,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (employee.pendingTotalCount > 0) ...[
                    _PendingCountBadge(total: employee.pendingTotalCount),
                    const SizedBox(height: 2),
                    Text(
                      'W:${employee.pendingWorkLogCount} L:${employee.pendingLeaveLogCount}',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: LoginColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  if (employee.unreadCount > 0) ...[
                    _UnreadCountBadge(count: employee.unreadCount),
                    const SizedBox(height: 6),
                  ],
                  Icon(
                    Icons.chevron_right_rounded,
                    color: LoginColors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnreadCountBadge extends StatelessWidget {
  final int count;

  const _UnreadCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: LoginColors.error,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PendingCountBadge extends StatelessWidget {
  final int total;

  const _PendingCountBadge({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: LoginColors.accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'P:$total',
        style: TextStyle(
          color: LoginColors.accent,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
