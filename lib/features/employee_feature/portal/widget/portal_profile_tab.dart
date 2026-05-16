import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/employee_feature/portal/view_model/employee_portal_view_model.dart';
import 'package:coreflow/features/employee_feature/portal/widget/portal_common.dart';
import 'package:flutter/material.dart';

class PortalProfileTab extends StatelessWidget {
  final EmployeePortalViewModel vm;
  const PortalProfileTab({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
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
            portalDisplayDate(p.joinedDt ?? '-'),
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
