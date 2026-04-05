import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/features/main_feature/vendor/view_model/vendor_view_model.dart';

import 'package:coreflow/features/main_feature/vendor/widget/empty_vendor_view.dart';
import 'package:coreflow/features/main_feature/vendor/widget/error_view.dart';
import 'package:coreflow/features/main_feature/vendor/widget/loading_view.dart';
import 'package:coreflow/features/main_feature/vendor/widget/vendor_list.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/core/widgets/status_toggle_tabs.dart';

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
          final viewModel = context.watch<ActiveVendorViewModel>();
          final dashboardVm = context.watch<DashboardViewModel>();

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
              title: 'Vendors',
              searchHint: 'Search vendors...',
            ),
            body: Column(
              children: [
                _buildTopToggleTabs(context, viewModel),
                Expanded(
                  child: RefreshIndicator(
                    backgroundColor: LoginColors.surface,
                    color: LoginColors.primary,
                    onRefresh: () async {
                      setState(() => _hasLoaded = false);
                      await viewModel.loadVendor(widget.companyId);
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
                  CfRoutes.vendorCreate(widget.companyId),
                );
                if (result == true && context.mounted) {
                  context.read<ActiveVendorViewModel>().refresh();
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

  Widget _buildBody(ActiveVendorViewModel viewModel, String searchQuery) {
    if (viewModel.isLoading && !viewModel.hasData) {
      return const KeyedSubtree(
        key: ValueKey('vendor-loading'),
        child: LoadingDisplayView(),
      );
    }

    if (viewModel.hasError) {
      return KeyedSubtree(
        key: ValueKey('vendor-error-${viewModel.error}'),
        child: ErrorDisplayView(
          error: viewModel.error ?? 'Something went wrong',
          onRetry: () {
            setState(() => _hasLoaded = false);
            viewModel.loadVendor(widget.companyId);
          },
        ),
      );
    }

    if (viewModel.hasError) {
      return ErrorDisplayView(
        error: viewModel.error ?? 'Something went wrong',
        onRetry: () {
          setState(() => _hasLoaded = false);
          viewModel.loadVendor(widget.companyId);
        },
      );
      return const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: LoadingDisplayView(),
      );
    }

    if (viewModel.hasError) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ErrorDisplayView(
          error: viewModel.error ?? 'Something went wrong',
          onRetry: () {
            setState(() => _hasLoaded = false);
            viewModel.loadVendor(widget.companyId);
          },
        ),
      );
    }

    final filteredVendor = viewModel.vendor.where((vendor) {
      final query = searchQuery.toLowerCase();
      return vendor.displayName.toLowerCase().contains(query) ||
          vendor.vendorCompanyName.toLowerCase().contains(query) ||
          (vendor.email?.toLowerCase().contains(query) ?? false);
    }).toList();

    if (filteredVendor.isEmpty) {
      return KeyedSubtree(
        key: ValueKey('vendor-empty-${viewModel.showActiveOnly}-$searchQuery'),
        child: EmptyVendorView(
          searchQuery: searchQuery,
          companyId: widget.companyId,
        ),
      );
    }

    return KeyedSubtree(
      key: ValueKey(
        'vendor-list-${viewModel.showActiveOnly}-$searchQuery-${filteredVendor.length}',
      ),
      child: VendorsList(
        vendors: filteredVendor,
        companyId: widget.companyId,
        pinnedVendorIds: viewModel.pinnedVendorIds,
        onTogglePin: (vendorId) {
          viewModel.togglePinVendor(vendorId);
        },
      ),
    );
  }

  Widget _buildTopToggleTabs(
    BuildContext context,
    ActiveVendorViewModel viewModel,
  ) {
    return StatusToggleTabs(
      isActiveSelected: viewModel.showActiveOnly,
      activeLabel: 'Active',
      inactiveLabel: 'Inactive',
      onActiveTap: () {
        if (!viewModel.showActiveOnly) viewModel.toggleActiveFilter();
      },
      onInactiveTap: () {
        if (viewModel.showActiveOnly) viewModel.toggleActiveFilter();
      },
    );
  }
}
