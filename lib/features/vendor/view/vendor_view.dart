import 'package:coreflow/features/customers/widget/custom_app_bar.dart';
import 'package:coreflow/features/customers/widget/error_view.dart';
import 'package:coreflow/features/customers/widget/loading_view.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/dashboard/widget/menu.dart';
import 'package:coreflow/features/vendor/view_model/vendor_view_model.dart';
import 'package:coreflow/features/vendor/widget/empty_customers_view.dart';
import 'package:coreflow/features/vendor/widget/vendor_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';

class ActiveVendorView extends StatefulWidget {
  final int companyId;

  const ActiveVendorView({super.key, required this.companyId});

  @override
  State<ActiveVendorView> createState() => _ActiveVendorViewState();
}

class _ActiveVendorViewState extends State<ActiveVendorView> {
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
          create: (_) => ActiveVendorViewModel(_authRepository),
        ),
        ChangeNotifierProvider<DashboardViewModel>(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final viewModel = Provider.of<ActiveVendorViewModel>(context);
          final dashboardVm = Provider.of<DashboardViewModel>(context);

          if (!_hasLoaded && !viewModel.hasData && !viewModel.isLoading) {
            _hasLoaded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewModel.loadVendor(widget.companyId);
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

  Widget _buildBody(ActiveVendorViewModel viewModel, String searchQuery) {
    if (viewModel.isLoading && !viewModel.hasData) {
      return const LoadingView();
    }

    if (viewModel.hasError) {
      return ErrorView(
        error: viewModel.error ?? 'Something went wrong',
        onRetry: () {
          setState(() => _hasLoaded = false);
          viewModel.loadVendor(widget.companyId);
        },
      );
    }

    final filteredVendor = viewModel.vendor.where((vendor) {
      final query = searchQuery.toLowerCase();
      return vendor.displayName.toLowerCase().contains(query) ||
          vendor.vendorCompanyName.toLowerCase().contains(query) ||
          (vendor.email?.toLowerCase().contains(query) ?? false);
    }).toList();

    if (filteredVendor.isEmpty) {
      return EmptyVendorView(searchQuery: searchQuery);
    }

    return VendorsList(vendors: filteredVendor, companyId: widget.companyId);
  }
}


