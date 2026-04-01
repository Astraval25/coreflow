import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CompanyHeader extends StatelessWidget {
  final DashboardViewModel vm;

  const CompanyHeader({super.key, required this.vm});

  bool get _canChangeCompany =>
      !vm.isCompaniesLoading && vm.availableCompanies.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 28),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(32),
        ),
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
          _buildIconTapArea(context),
          const SizedBox(width: 18),
          Expanded(child: _buildCompanyText(context)),
          _buildArrowTapArea(context),
        ],
      ),
    );
  }

  Widget _buildIconTapArea(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _canChangeCompany ? () => _showManageCompanyDialog(context) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              LoginColors.primary,
              LoginColors.primaryDark,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: LoginColors.primary.withValues(alpha:0.2),
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
    );
  }

  Widget _buildCompanyText(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _canChangeCompany ? () => _showManageCompanyDialog(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vm.companyName ?? 'Select Company',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: LoginColors.textPrimary,
              letterSpacing: -0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Switch Company',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: LoginColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.swap_horiz_rounded,
                size: 14,
                color: LoginColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrowTapArea(BuildContext context) {
    if (!_canChangeCompany) return const SizedBox.shrink();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showManageCompanyDialog(context),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: LoginColors.fieldFill,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 22,
          color: LoginColors.textSecondary,
        ),
      ),
    );
  }

  void _showManageCompanyDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ManageCompanyBottomSheet(vm: vm),
    );
  }
}

class _ManageCompanyBottomSheet extends StatelessWidget {
  final DashboardViewModel vm;

  const _ManageCompanyBottomSheet({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: LoginColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Company',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: LoginColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.pop(context);
                  context.push(CfRoutes.companyList);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: LoginColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.settings_rounded,
                        size: 16,
                        color: LoginColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Manage',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: LoginColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (vm.isCompaniesLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: LoginColors.primary),
              ),
            )
          else if (vm.availableCompanies.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text('No companies available'),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: vm.availableCompanies.length,
                itemBuilder: (context, index) {
                  final company = vm.availableCompanies[index];
                  final isSelected = company.companyId == vm.companyId;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? LoginColors.primary.withValues(alpha:0.06)
                          : LoginColors.fieldFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? LoginColors.primary.withValues(alpha:0.12)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? LoginColors.primary : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.business_rounded,
                          color: isSelected ? Colors.white : LoginColors.textTertiary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        company.companyName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? LoginColors.primary : LoginColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: isSelected
                          ? Text(
                              'Currently active',
                              style: TextStyle(
                                fontSize: 12,
                                color: LoginColors.primary.withValues(alpha:0.7),
                              ),
                            )
                          : Text(
                              'Tap to switch',
                              style: TextStyle(
                                fontSize: 12,
                                color: LoginColors.textTertiary,
                              ),
                            ),
                      trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: LoginColors.primary, size: 22)
                        : Icon(Icons.arrow_forward_ios_rounded, size: 14, color: LoginColors.textTertiary),
                      onTap: () {
                        vm.selectCompany(company);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
