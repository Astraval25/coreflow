import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/theme/theme_provider.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/core/widgets/searchable_entity_app_bar.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/presentation/payment/send_payment/viewmodel/send_payment_view_model.dart';
import 'package:coreflow/features/presentation/payment/send_payment/widgets/payment_body_message.dart';
import 'package:coreflow/features/presentation/payment/send_payment/widgets/payment_card.dart';
import 'package:coreflow/features/presentation/payment/send_payment/widgets/payment_empty_state.dart';
import 'package:coreflow/features/presentation/payment/send_payment/widgets/payment_loading_body.dart';
import 'package:coreflow/features/presentation/payment/send_payment/widgets/payment_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return Consumer<DashboardViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const PaymentSkeleton();
        }

        final companyId = vm.companyId;
        if (companyId == null) {
          return const PaymentEmptyState(
            title: 'Payment',
            subtitle: 'Company not selected.',
          );
        }

        return ChangeNotifierProvider<SendPaymentViewModel>(
          create: (_) => SendPaymentViewModel(
            repository: AuthRepository(),
            companyId: companyId,
          )..fetchPaymentsSentSummary(),
          child: const _PaymentContent(),
        );
      },
    );
  }
}

class _PaymentContent extends StatefulWidget {
  const _PaymentContent();

  @override
  State<_PaymentContent> createState() => _PaymentContentState();
}

class _PaymentContentState extends State<_PaymentContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _disabledSearchController =
      TextEditingController();
  _PaymentTopTab _selectedTopTab = _PaymentTopTab.payments;

  @override
  void dispose() {
    _disabledSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final dashboardVm = context.watch<DashboardViewModel>();

    return Consumer<SendPaymentViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: LoginColors.background,
          drawerEnableOpenDragGesture: true,
          drawer: AppDrawer(vm: dashboardVm),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: _buildCreateButton(),
          appBar: SearchableEntityAppBar(
            isSearchOpen: false,
            onSearchToggle: () {},
            searchQuery: '',
            searchController: _disabledSearchController,
            onSearchChanged: (_) {},
            onClearSearch: () {},
            scaffoldKey: _scaffoldKey,
            title: '',
            searchHint: '',
            showSearchAction: false,
            tabs: const [
              SearchableEntityTab(label: 'Payments'),
              // SearchableEntityTab(label: 'Paid Orders'),
            ],
            selectedTabIndex: _selectedTopTab.index,
            onTabSelected: (index) {
              setState(() => _selectedTopTab = _PaymentTopTab.values[index]);
            },
          ),
          body: RefreshIndicator(onRefresh: vm.refresh, child: _buildBody(vm)),
        );
      },
    );
  }

  Widget _buildBody(SendPaymentViewModel vm) {
    if (vm.isLoading) {
      return const PaymentLoadingBody();
    }

    if (vm.errorMessage != null && vm.payments.isEmpty) {
      return PaymentBodyMessage(
        icon: Icons.error_outline_rounded,
        title: 'Payment',
        subtitle: vm.errorMessage!,
      );
    }

    if (vm.payments.isEmpty) {
      return const PaymentBodyMessage(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Payment',
        subtitle: 'No payments found.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: vm.payments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final payment = vm.payments[index];
        return PaymentCard(payment: payment);
      },
    );
  }

  Widget _buildCreateButton() {
    return FloatingActionButton(
      backgroundColor: LoginColors.primary,
      foregroundColor: Colors.white,
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create payment entry coming soon.')),
        );
      },
      child: const Icon(Icons.add_rounded),
    );
  }
}

enum _PaymentTopTab { payments, paidOrders }
