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
  final int serialNumber;

  const EmployeeListItem({
    super.key,
    required this.employee,
    required this.companyId,
    required this.serialNumber,
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
                  Positioned(
                    right: -2,
                    top: -2,
                    child: _NumberBadge(value: serialNumber),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.employeeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: LoginColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _statusBadge(employee.isActive),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.employeeCode,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if ((employee.designation ?? '').trim().isNotEmpty)
                          _tag(
                            icon: Icons.work_outline_rounded,
                            text: employee.designation!,
                            color: LoginColors.primary,
                          ),
                        if ((employee.phone ?? '').trim().isNotEmpty)
                          _tag(
                            icon: Icons.call_outlined,
                            text: employee.phone!,
                            color: LoginColors.textSecondary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (employee.currentMonthlyAmount != null) ...[
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (employee.unreadCount > 0) ...[
                      _UnreadCountBadge(count: employee.unreadCount),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      employee.currentSalaryType ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        color: LoginColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.currentMonthlyAmount!.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.success,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.withValues(alpha: 0.75)),
          const SizedBox(width: 4),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(bool isActive) {
    final color = isActive ? LoginColors.success : LoginColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int value;
  const _NumberBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: LoginColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$value',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
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
