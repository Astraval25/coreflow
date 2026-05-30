import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';

class CompanyHeader extends StatelessWidget {
  final DashboardViewModel vm;

  const CompanyHeader({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    final companyName = vm.companyName?.trim();
    final linkedCount = vm.availableCompanies.length;
    final subtitle = vm.isCompaniesLoading
        ? 'Loading company details'
        : linkedCount > 1
        ? '$linkedCount linked companies'
        : 'Update company details in Profile';

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 28),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: LoginColors.shadowLight.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [LoginColors.primary, LoginColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: LoginColors.primary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName?.isNotEmpty == true
                      ? companyName!
                      : 'No Active Company',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: LoginColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
