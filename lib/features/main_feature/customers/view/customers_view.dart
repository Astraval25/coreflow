import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/domain/model/main_model/customer/customer.dart';
import 'package:coreflow/features/main_feature/customers/view_model/customers_view_model.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import '../widget/customers_list.dart';
import '../widget/empty_customers_view.dart';
import '../widget/error_view.dart';
import '../widget/loading_view.dart';

class ActiveCustomersView extends StatefulWidget {
  final int companyId;
  const ActiveCustomersView({super.key, required this.companyId});

  @override
  State<ActiveCustomersView> createState() => _ActiveCustomersViewState();
}

class _ActiveCustomersViewState extends State<ActiveCustomersView> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _searchQuery = '';
  bool _isSearchOpen = false;
  late final AuthRepository _authRepository;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository();
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ActiveCustomersViewModel(_authRepository),
        ),
      ],
      child: Builder(
        builder: (context) {
          final viewModel = context.watch<ActiveCustomersViewModel>();
          final dashboardVm = context.watch<DashboardViewModel>();
          _syncBottomNavUnreadBadges(viewModel);

          if (!_hasLoaded && !viewModel.hasData && !viewModel.isLoading) {
            _hasLoaded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewModel.loadCustomers(widget.companyId);
            });
          }

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
              title: 'Customers',
              searchHint: 'Search customers...',
              onTitleTap: _openCustomerProfilePage,
              leadingActions: [
                PopupMenuButton<bool>(
                  tooltip: 'Filter status',
                  initialValue: viewModel.showActiveOnly,
                  onSelected: (showActiveOnly) {
                    if (viewModel.showActiveOnly != showActiveOnly) {
                      viewModel.toggleActiveFilter();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem<bool>(value: true, child: Text('Active')),
                    PopupMenuItem<bool>(value: false, child: Text('Inactive')),
                  ],
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: LoginColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: LoginColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.filter_list_rounded,
                      color: LoginColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    backgroundColor: LoginColors.surface,
                    color: LoginColors.primary,
                    onRefresh: () async {
                      setState(() => _hasLoaded = false);
                      await viewModel.loadCustomers(widget.companyId);
                    },
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: const Offset(0, 0.02),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: slide, child: child),
                        );
                      },
                      child: _buildBody(viewModel, _searchQuery),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: LoginColors.primary,
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onPressed: () async {
                final result = await context.push<bool>(
                  CfRoutes.customerCreate(widget.companyId),
                );
                if (result == true && context.mounted) {
                  context.read<ActiveCustomersViewModel>().refresh();
                }
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [LoginColors.primary, LoginColors.primaryDark],
                  ),
                ),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openCustomerProfilePage() async {
    final vm = context.read<ActiveCustomersViewModel>();
    final customers = vm.customers;
    if (customers.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No customers available')));
      return;
    }

    if (customers.length == 1) {
      await context.push(
        CfRoutes.customerDetail(widget.companyId, customers.first.customerId),
      );
      if (!mounted) return;
      await context.read<ActiveCustomersViewModel>().refresh();
      await context.read<DashboardViewModel>().refreshUnreadCount();
      return;
    }

    final selectedCustomer = await showModalBottomSheet<Customer>(
      context: context,
      backgroundColor: LoginColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Text(
                  'Select Customer Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: customers.length,
                  separatorBuilder: (_, index) =>
                      Divider(color: LoginColors.borderLight, height: 1),
                  itemBuilder: (_, index) {
                    final customer = customers[index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        customer.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(customer.customerCompanyName),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.pop(context, customer),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selectedCustomer == null) return;
    await context.push(
      CfRoutes.customerDetail(widget.companyId, selectedCustomer.customerId),
    );
    if (!mounted) return;
    await context.read<ActiveCustomersViewModel>().refresh();
    await context.read<DashboardViewModel>().refreshUnreadCount();
  }

  Widget _buildBody(ActiveCustomersViewModel viewModel, String searchQuery) {
    if (viewModel.isLoading && !viewModel.hasData) {
      return const KeyedSubtree(
        key: ValueKey('customers-loading'),
        child: LoadingView(),
      );
    }

    if (viewModel.hasError) {
      return KeyedSubtree(
        key: ValueKey('customers-error-${viewModel.error}'),
        child: ErrorView(
          error: viewModel.error ?? 'Something went wrong',
          onRetry: () {
            setState(() => _hasLoaded = false);
            viewModel.loadCustomers(widget.companyId);
          },
        ),
      );
    }

    final filteredCustomers = viewModel.customers.where((customer) {
      final query = searchQuery.toLowerCase();
      return customer.displayName.toLowerCase().contains(query) ||
          customer.customerCompanyName.toLowerCase().contains(query) ||
          (customer.email?.toLowerCase().contains(query) ?? false);
    }).toList();

    if (filteredCustomers.isEmpty) {
      return KeyedSubtree(
        key: ValueKey(
          'customers-empty-${viewModel.showActiveOnly}-$searchQuery',
        ),
        child: EmptyCustomersView(
          searchQuery: searchQuery,
          companyId: widget.companyId,
        ),
      );
    }

    return KeyedSubtree(
      key: ValueKey(
        'customers-list-${viewModel.showActiveOnly}-$searchQuery-${filteredCustomers.length}',
      ),
      child: CustomersList(
        customers: filteredCustomers,
        companyId: widget.companyId,
        pinnedCustomerIds: viewModel.pinnedCustomerIds,
        onTogglePin: (customerId) {
          viewModel.togglePinCustomer(customerId);
        },
      ),
    );
  }

  void _syncBottomNavUnreadBadges(ActiveCustomersViewModel viewModel) {
    final totalUnread =
        viewModel.activeCustomers.fold<int>(
          0,
          (sum, customer) => sum + customer.unreadCount,
        ) +
        viewModel.inactiveCustomers.fold<int>(
          0,
          (sum, customer) => sum + customer.unreadCount,
        );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DashboardViewModel>().updateEntityUnreadCounts(
        customerUnreadCount: totalUnread,
      );
    });
  }
}
