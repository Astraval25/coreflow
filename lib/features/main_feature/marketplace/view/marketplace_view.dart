import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/domain/model/company/marketplace_company.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/main_feature/marketplace/view_model/marketplace_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MarketplaceView extends StatefulWidget {
  const MarketplaceView({super.key});

  @override
  State<MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends State<MarketplaceView> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  bool _isSearchOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchOpen = !_isSearchOpen;
      if (!_isSearchOpen) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MarketplaceViewModel>();
    final dashboardVm = context.watch<DashboardViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVm),
      appBar: SearchableEntityAppBar(
        isSearchOpen: _isSearchOpen,
        onSearchToggle: _toggleSearch,
        searchQuery: _searchQuery,
        searchController: _searchController,
        onSearchChanged: (value) => setState(() => _searchQuery = value),
        onClearSearch: () {
          _searchController.clear();
          setState(() => _searchQuery = '');
        },
        scaffoldKey: _scaffoldKey,
        title: 'Marketplace',
        searchHint: 'Search companies...',
      ),
      body: RefreshIndicator(
        backgroundColor: LoginColors.surface,
        color: LoginColors.primary,
        onRefresh: () => vm.loadCompanies(),
        child: _buildBody(vm),
      ),
    );
  }

  Widget _buildBody(MarketplaceViewModel vm) {
    if (vm.isLoading && !vm.hasData) {
      return const Center(
        child: CircularProgressIndicator(color: LoginColors.primary),
      );
    }

    if (vm.hasError && !vm.hasData) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: LoginColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              vm.error ?? 'Something went wrong',
              style: TextStyle(color: LoginColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: vm.loadCompanies,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filtered = vm.companies.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.companyName.toLowerCase().contains(query) ||
          (c.industry?.toLowerCase().contains(query) ?? false);
    }).toList();

    if (filtered.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              children: [
                Icon(Icons.store_mall_directory_outlined,
                    size: 56, color: LoginColors.textTertiary),
                const SizedBox(height: 12),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No companies match "$_searchQuery"'
                      : 'No companies found',
                  style: TextStyle(
                    color: LoginColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return _CompanyListItem(company: filtered[index]);
      },
    );
  }
}

class _CompanyListItem extends StatelessWidget {
  final MarketplaceCompany company;

  const _CompanyListItem({required this.company});

  @override
  Widget build(BuildContext context) {
    final initial = company.companyName.isNotEmpty
        ? company.companyName[0].toUpperCase()
        : '?';

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
        onTap: () => context.push(CfRoutes.marketplaceCompany(company.companyId)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: LoginColors.primary.withValues(alpha: 0.12),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: LoginColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    if (company.industry != null &&
                        company.industry!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        company.industry!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: LoginColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: company.isGstVerified
                      ? LoginColors.success.withValues(alpha:0.12)
                      : LoginColors.textTertiary.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  company.isGstVerified
                      ? Icons.verified_rounded
                      : Icons.gpp_maybe_outlined,
                  size: 20,
                  color: company.isGstVerified
                      ? LoginColors.success
                      : LoginColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
