import 'package:coreflow/features/customers/view_model/customers_view_model.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/dashboard/widget/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import '../widget/custom_app_bar.dart';
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
        ChangeNotifierProvider<DashboardViewModel>(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final viewModel = Provider.of<ActiveCustomersViewModel>(context);
          final dashboardVm = Provider.of<DashboardViewModel>(context);

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
            appBar: CustomAppBar(
              companyId: widget.companyId,
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
            ),
            body: _buildBody(viewModel, _searchQuery),
          );
        },
      ),
    );
  }

  Widget _buildBody(ActiveCustomersViewModel viewModel, String searchQuery) {
    if (viewModel.isLoading && !viewModel.hasData) {
      return const LoadingView();
    }

    if (viewModel.hasError) {
      return ErrorView(
        error: viewModel.error ?? 'Something went wrong',
        onRetry: () {
          setState(() => _hasLoaded = false);
          viewModel.loadCustomers(widget.companyId);
        },
      );
    }

    final filteredCustomers = viewModel.customers.where((customer) {
      final query = searchQuery.toLowerCase();
      return customer.displayName.toLowerCase().contains(query) ||
          customer.customerCompanyName.toLowerCase().contains(query) ||
          (customer.email?.toLowerCase().contains(query) ?? false);
    }).toList();

    if (filteredCustomers.isEmpty) {
      return EmptyCustomersView(searchQuery: searchQuery);
    }

    return CustomersList(
      customers: filteredCustomers,
      companyId: widget.companyId,
    );
  }
}
