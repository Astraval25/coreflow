import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/company/view_model/company_view_model.dart';
import 'package:coreflow/features/company/view/company_form_page.dart';
import 'package:coreflow/domain/model/company/company.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageCompaniesPage extends StatelessWidget {
  const ManageCompaniesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompanyViewModel()..loadCompanies(),
      child: const _ManageCompaniesBody(),
    );
  }
}

class _ManageCompaniesBody extends StatelessWidget {
  const _ManageCompaniesBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompanyViewModel>();

    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: const Text(
          'Manage Companies',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: LoginColors.surface,
        foregroundColor: LoginColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: vm.isLoading ? null : () => vm.loadCompanies(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        backgroundColor: LoginColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business_rounded),
        label: const Text(
          'Add Company',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildBody(context, vm),
    );
  }

  Widget _buildBody(BuildContext context, CompanyViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: LoginColors.primary),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: LoginColors.error),
            const SizedBox(height: 16),
            Text(
              vm.errorMessage!,
              style: TextStyle(color: LoginColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => vm.loadCompanies(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (vm.companies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: LoginColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No companies yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: LoginColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to create your first company',
              style: TextStyle(color: LoginColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: LoginColors.primary,
      onRefresh: () => vm.loadCompanies(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: vm.companies.length,
        itemBuilder: (context, index) {
          final company = vm.companies[index];
          return _CompanyCard(company: company);
        },
      ),
    );
  }

  void _navigateToForm(BuildContext context) {
    final vm = context.read<CompanyViewModel>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: const CompanyFormPage(),
        ),
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final Company company;

  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<CompanyViewModel>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: LoginColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: company.isActive
              ? LoginColors.border
              : LoginColors.error.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: LoginColors.shadowLight.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: company.isActive
                    ? LoginColors.primary.withOpacity(0.08)
                    : LoginColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.business_rounded,
                color: company.isActive ? LoginColors.primary : LoginColors.error,
                size: 24,
              ),
            ),
            title: Text(
              company.companyName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (company.industry.isNotEmpty)
                  Text(
                    company.industry,
                    style: TextStyle(
                      fontSize: 13,
                      color: LoginColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: company.isActive
                        ? LoginColors.success.withOpacity(0.1)
                        : LoginColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    company.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: company.isActive ? LoginColors.success : LoginColors.error,
                    ),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: LoginColors.textSecondary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: vm,
                          child: CompanyFormPage(company: company),
                        ),
                      ),
                    );
                    break;
                  case 'toggle':
                    _confirmToggleStatus(context, vm, company);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_rounded, size: 18, color: LoginColors.primary),
                      const SizedBox(width: 10),
                      const Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        company.isActive
                            ? Icons.block_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 18,
                        color: company.isActive ? LoginColors.error : LoginColors.success,
                      ),
                      const SizedBox(width: 10),
                      Text(company.isActive ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (company.shortName != null ||
              company.pan != null ||
              company.gstNo != null ||
              company.hsnCode != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  if (company.shortName != null && company.shortName!.isNotEmpty)
                    _InfoChip(label: company.shortName!),
                  if (company.gstNo != null && company.gstNo!.isNotEmpty)
                    _InfoChip(label: 'GST: ${company.gstNo}'),
                  if (company.hsnCode != null && company.hsnCode!.isNotEmpty)
                    _InfoChip(label: 'HSN: ${company.hsnCode}'),
                ],
              ),
            )
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _confirmToggleStatus(
    BuildContext context,
    CompanyViewModel vm,
    Company company,
  ) {
    final action = company.isActive ? 'deactivate' : 'activate';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${action[0].toUpperCase()}${action.substring(1)} Company'),
        content: Text(
          'Are you sure you want to $action "${company.companyName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  company.isActive ? LoginColors.error : LoginColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await vm.toggleCompanyStatus(company);
              if (context.mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(vm.errorMessage ?? 'Operation failed'),
                    backgroundColor: LoginColors.error,
                  ),
                );
              }
            },
            child: Text(action[0].toUpperCase() + action.substring(1)),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: LoginColors.fieldFill,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: LoginColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
