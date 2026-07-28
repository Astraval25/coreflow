import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/app_drawer.dart';
import 'package:coreflow/features/main_feature/customers/view/customer_details_view_page.dart';
import 'package:coreflow/domain/model/main_model/customer/customer_detail.dart';
import 'package:coreflow/routing/cf_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/body/customer_expand_more_option.dart';
import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/customer_detail_body.dart';
import 'package:coreflow/features/main_feature/customers/widget/detail/customer_error_state.dart';
import 'package:url_launcher/url_launcher.dart';
import '../view_model/customer_detail_view_model.dart';
import '../../dashboard/dashboard_view_model/dashboard_view_model.dart';

class CustomerDetailContent extends StatelessWidget {
  const CustomerDetailContent({super.key});

  @override
  Widget build(BuildContext context) {
    LoginColors.setBrightness(Theme.of(context).brightness);
    final dashboardVM = context.read<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DashboardColors.headerGradientStart,
                DashboardColors.headerGradientEnd,
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Consumer<CustomerDetailViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading || vm.customer == null) {
              return const Text(
                'Customer Details',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              );
            }
            final customer = vm.customer!;
            return InkWell(
              onTap: () => _openCustomerDetailsPage(context, customer),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        customer.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          Consumer<CustomerDetailViewModel>(
            builder: (context, vm, child) {
              if (vm.customer == null || vm.isLoading) {
                return const SizedBox(width: 10);
              }
              final phone = vm.customer!.phone?.trim() ?? '';

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (phone.isNotEmpty) ...[
                    IconButton(
                      onPressed: () => _openWhatsApp(context, phone),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _makeCall(context, phone),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                    color: LoginColors.surface,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: LoginColors.borderLight),
                    ),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await context.push(
                          CfRoutes.customerUpdate(vm.companyId, vm.customerId),
                        );
                        vm.loadCustomerDetail();
                      } else if (value == 'activate') {
                        await _changeCustomerActiveStatus(
                          context,
                          vm,
                          makeActive: true,
                        );
                      } else if (value == 'deactivate') {
                        await _changeCustomerActiveStatus(
                          context,
                          vm,
                          makeActive: false,
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      final isActive = vm.customer?.isActive ?? false;
                      return [
                        PopupMenuItem(
                          value: 'edit',
                          textStyle: TextStyle(
                            color: LoginColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_rounded,
                                size: 18,
                                color: LoginColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  color: LoginColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 6),
                        PopupMenuItem(
                          value: isActive ? 'deactivate' : 'activate',
                          textStyle: TextStyle(
                            color: isActive
                                ? LoginColors.error
                                : LoginColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isActive
                                    ? Icons.toggle_off_rounded
                                    : Icons.toggle_on_rounded,
                                size: 20,
                                color: isActive
                                    ? LoginColors.error
                                    : LoginColors.success,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isActive ? 'Set Inactive' : 'Set Active',
                                style: TextStyle(
                                  color: isActive
                                      ? LoginColors.error
                                      : LoginColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawerEnableOpenDragGesture: false,
      drawer: AppDrawer(vm: dashboardVM),
      body: Consumer<CustomerDetailViewModel>(
        builder: (context, vm, child) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async => vm.loadCustomerDetail(),
                backgroundColor: LoginColors.surface,
                color: LoginColors.primary,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.maxScrollExtent <= 0) return false;
                    final triggerOffset =
                        notification.metrics.maxScrollExtent * 0.85;
                    if (notification.metrics.pixels >= triggerOffset) {
                      vm.loadMoreOrdersPaymentsIfNeeded();
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height -
                            AppBar().preferredSize.height -
                            MediaQuery.of(context).padding.top,
                      ),
                      child: _buildBody(context, vm),
                    ),
                  ),
                ),
              ),
              if (!vm.isLoading &&
                  !vm.isError &&
                  !vm.isNoData &&
                  vm.customer != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: CustomerBottomOptionsPanel(
                    vm: vm,
                    customer: vm.customer!,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CustomerDetailViewModel vm) {
    if (vm.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Skeleton
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: LoginColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: LoginColors.borderLight, width: 1),
              ),
              child: Row(
                children: [
                  const Skeleton(height: 70, width: 70, borderRadius: 35),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Skeleton(height: 24, width: 180),
                        const SizedBox(height: 12),
                        const Skeleton(height: 16, width: 120),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Body Skeletons
            const Skeleton(
              height: 200,
              width: double.infinity,
              borderRadius: 24,
            ),
            const SizedBox(height: 24),
            const Skeleton(
              height: 180,
              width: double.infinity,
              borderRadius: 24,
            ),
          ],
        ),
      );
    }

    if (vm.isError) {
      return CustomerErrorState(
        message: vm.errorMessage ?? 'Failed to load customer data',
        onRetry: vm.loadCustomerDetail,
      );
    }

    return Column(children: [CustomerDetailBody(customer: vm.customer!)]);
  }

  void _openCustomerDetailsPage(
    BuildContext context,
    CustomerDetailData customer,
  ) {
    final vm = context.read<CustomerDetailViewModel>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: CustomerDetailsViewPage(customer: customer),
        ),
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final whatsappPhone = cleanPhone.startsWith('+')
        ? cleanPhone.substring(1)
        : cleanPhone;
    final launched = await launchUrl(
      Uri.parse('https://wa.me/$whatsappPhone'),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
    }
  }

  Future<void> _makeCall(BuildContext context, String phone) async {
    final launched = await launchUrl(
      Uri.parse('tel:$phone'),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not start call')));
    }
  }

  Future<void> _changeCustomerActiveStatus(
    BuildContext context,
    CustomerDetailViewModel vm, {
    required bool makeActive,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          makeActive ? 'Set customer active?' : 'Set customer inactive?',
        ),
        content: Text(
          makeActive
              ? 'This customer will become active again.'
              : 'This customer will be marked inactive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(makeActive ? 'Set Active' : 'Set Inactive'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = makeActive
        ? await vm.activateCustomer()
        : await vm.deactivateCustomer();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (makeActive ? 'Customer set active' : 'Customer set inactive')
              : (vm.errorMessage ?? 'Failed to update customer status'),
        ),
        backgroundColor: success ? LoginColors.success : LoginColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
