import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/core/widgets/status_toggle_tabs.dart';
import 'package:coreflow/features/employee_feature/employees/view_model/employees_view_model.dart';
import 'package:coreflow/features/employee_feature/employees/widget/employee_empty_view.dart';
import 'package:coreflow/features/employee_feature/employees/widget/employee_error_view.dart';
import 'package:coreflow/features/employee_feature/employees/widget/employee_loading_view.dart';
import 'package:coreflow/features/employee_feature/employees/widget/employees_list_view.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EmployeesView extends StatefulWidget {
  final int companyId;

  const EmployeesView({super.key, required this.companyId});

  @override
  State<EmployeesView> createState() => _EmployeesViewState();
}

class _EmployeesViewState extends State<EmployeesView> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _searchQuery = '';
  bool _isSearchOpen = false;

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
    final viewModel = context.watch<EmployeesViewModel>();
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
        title: 'Employees',
        searchHint: 'Search employees...',
      ),
      body: Column(
        children: [
          _buildTopToggleTabs(viewModel),
          Expanded(
            child: RefreshIndicator(
              backgroundColor: LoginColors.surface,
              color: LoginColors.primary,
              onRefresh: viewModel.refresh,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
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
                child: _buildBody(viewModel),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: LoginColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () async {
          final result = await context.push<bool>(
            CfRoutes.employeeCreate(widget.companyId),
          );
          if (result == true && context.mounted) {
            context.read<EmployeesViewModel>().refresh();
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
  }

  Widget _buildBody(EmployeesViewModel viewModel) {
    if (viewModel.isLoading && !viewModel.hasData) {
      return const KeyedSubtree(
        key: ValueKey('employees-loading'),
        child: EmployeeLoadingView(),
      );
    }

    if (viewModel.hasError) {
      return KeyedSubtree(
        key: ValueKey('employees-error'),
        child: EmployeeErrorView(
          error: viewModel.error ?? 'Something went wrong',
          onRetry: () => viewModel.loadEmployees(widget.companyId),
        ),
      );
    }

    final query = _searchQuery.toLowerCase();
    final filtered = viewModel.employees.where((employee) {
      return employee.employeeName.toLowerCase().contains(query) ||
          employee.employeeCode.toLowerCase().contains(query) ||
          (employee.designation?.toLowerCase().contains(query) ?? false) ||
          (employee.phone?.toLowerCase().contains(query) ?? false);
    }).toList();

    if (filtered.isEmpty) {
      return KeyedSubtree(
        key: ValueKey('employees-empty-${viewModel.showActiveOnly}-$query'),
        child: EmployeeEmptyView(
          companyId: widget.companyId,
          searchQuery: _searchQuery,
        ),
      );
    }

    return KeyedSubtree(
      key: ValueKey(
        'employees-list-${viewModel.showActiveOnly}-$query-${filtered.length}',
      ),
      child: EmployeesListView(
        employees: filtered,
        companyId: widget.companyId,
      ),
    );
  }

  Widget _buildTopToggleTabs(EmployeesViewModel viewModel) {
    return StatusToggleTabs(
      isActiveSelected: viewModel.showActiveOnly,
      activeLabel: 'Active',
      inactiveLabel: 'Inactive',
      onActiveTap: () {
        if (!viewModel.showActiveOnly) {
          viewModel.toggleActiveFilter();
        }
      },
      onInactiveTap: () {
        if (viewModel.showActiveOnly) {
          viewModel.toggleActiveFilter();
        }
      },
    );
  }
}
