import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:flutter/material.dart';

class CompanyHeader extends StatelessWidget {
  final DashboardViewModel vm;

  const CompanyHeader({super.key, required this.vm});

  bool get _canChangeCompany => !vm.isCompaniesLoading && vm.availableCompanies.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 32),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          children: [
            _buildIconTapArea(context),
            const SizedBox(width: 18),
            Expanded(child: _buildCompanyText(context)),
            _buildArrowTapArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIconTapArea(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _canChangeCompany ? () => _showCompaniesBottomSheet(context) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.business_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildCompanyText(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _canChangeCompany ? () => _showCompaniesBottomSheet(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vm.companyName ?? 'Select Company',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to switch company',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrowTapArea(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _canChangeCompany ? () => _showCompaniesBottomSheet(context) : null,
      child: Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 28,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  void _showCompaniesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CompaniesBottomSheet(vm: vm),
    );
  }
}

class _CompaniesBottomSheet extends StatelessWidget {
  final DashboardViewModel vm;

  const _CompaniesBottomSheet({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Company',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (vm.isCompaniesLoading)
            const CircularProgressIndicator()
          else if (vm.availableCompanies.isEmpty)
            const Text('No companies available')
          else
            ...vm.availableCompanies.map((company) {
              return ListTile(
                key: ValueKey(company),
                leading: Icon(
                  Icons.business_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  company,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  vm.selectCompany(company);
                  Navigator.pop(context);
                },
              );
            }).toList(),
        ],
      ),
    );
  }
}
