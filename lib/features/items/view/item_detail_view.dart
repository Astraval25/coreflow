import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/items/detail_item.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/dashboard/widget/menu.dart';
import 'package:coreflow/features/items/view_model/item_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemDetailView extends StatelessWidget {
  final int companyId;
  final int itemId;

  const ItemDetailView({
    super.key,
    required this.companyId,
    required this.itemId,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ItemDetailViewModel(
            companyId: companyId,
            itemId: itemId,
            repository: AuthRepository(),
            apiService: ApiService(),
          )..loadItemDetail(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
      ],
      child: const _ItemDetailContent(),
    );
  }
}

class _ItemDetailContent extends StatefulWidget {
  const _ItemDetailContent();

  @override
  State<_ItemDetailContent> createState() => _ItemDetailContentState();
}

class _ItemDetailContentState extends State<_ItemDetailContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh(ItemDetailViewModel vm) async {
    await vm.refresh();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ItemDetailViewModel>();
    final item = vm.itemResponse?.responseData;

    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          item?.itemName ?? 'Item Detail',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),

        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                LoginColors.surface,
                LoginColors.surface.withOpacity(0.96),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: LoginColors.shadowLight.withOpacity(0.14),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        foregroundColor: LoginColors.textPrimary,
        scrolledUnderElevation: 0,
      ),
      drawer: Consumer<DashboardViewModel>(
        builder: (context, dashboardVM, _) {
          if (dashboardVM.isLoading) {
            return Drawer(child: Center(child: CircularProgressIndicator()));
          }
          return AppDrawer(vm: dashboardVM);
        },
      ),
      body: vm.isLoading && item == null
          ? const Center(
              child: CircularProgressIndicator(color: LoginColors.primary),
            )
          : vm.errorMessage != null
          ? _ErrorView(message: vm.errorMessage!, onRetry: vm.refresh)
          : RefreshIndicator(
              color: LoginColors.primary,
              onRefresh: () => _onRefresh(vm),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _ImageSection(vm: vm)),
                          const SizedBox(width: 28),
                          Expanded(
                            flex: 5,
                            child: _BasicInfoSection(item: item),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 44),

                    _DropdownSection(
                      title: 'Pricing',
                      children: [
                        _InfoRow(
                          'Sales Price',
                          '₹${item?.baseSalesPrice?.toStringAsFixed(2) ?? '-'}',
                          isPrice: true,
                        ),
                        _InfoRow(
                          'Purchase Price',
                          '₹${item?.basePurchasePrice?.toStringAsFixed(2) ?? '-'}',
                          isPrice: true,
                        ),
                        _InfoRow(
                          'Tax Rate',
                          '${item?.taxRate?.toStringAsFixed(2) ?? '-'} %',
                        ),
                      ],
                    ),

                    if (item?.salesDescription?.isNotEmpty == true ||
                        item?.purchaseDescription?.isNotEmpty == true)
                      _DropdownSection(
                        title: 'Descriptions',
                        children: [
                          if (item?.salesDescription?.isNotEmpty == true)
                            _DescriptionText(
                              'Sales Description',
                              item!.salesDescription!,
                            ),
                          if (item?.purchaseDescription?.isNotEmpty == true)
                            _DescriptionText(
                              'Purchase Description',
                              item!.purchaseDescription!,
                            ),
                        ],
                      ),

                    _DropdownSection(
                      title: 'Status',
                      children: [
                        _InfoRow(
                          'Active',
                          item?.isActive == true ? 'Yes' : 'No',
                          isStatus: true,
                        ),
                        _InfoRow(
                          'Purchasable',
                          item?.isPurchasable == true ? 'Yes' : 'No',
                          isStatus: true,
                        ),
                        _InfoRow(
                          'Sellable',
                          item?.isSellable == true ? 'Yes' : 'No',
                          isStatus: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  final ItemDetailViewModel vm;

  const _ImageSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LoginColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: LoginColors.shadowLight.withOpacity(0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (vm.isLoadingImage)
                Container(
                  color: LoginColors.fieldFill,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: LoginColors.primary,
                    ),
                  ),
                )
              else if (vm.currentImageBytes != null)
                Image.memory(vm.currentImageBytes!, fit: BoxFit.cover)
              else
                Container(
                  color: LoginColors.fieldFill,
                  child: Icon(
                    Icons.image_not_supported_rounded,
                    size: 72,
                    color: LoginColors.textTertiary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BasicInfoSection extends StatelessWidget {
  final DetailItem? item;

  const _BasicInfoSection({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item Name',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: LoginColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        _InfoRow('Name:', item?.itemName ?? '-'),
        _InfoRow('Type:', item?.itemType ?? '-'),
        _InfoRow('Code:', item?.hsnCode ?? '-'),
        _InfoRow('Unit:', item?.unit ?? '-'),
      ],
    );
  }
}

class _DropdownSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DropdownSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: LoginColors.surface,
      shadowColor: LoginColors.shadowLight.withOpacity(0.20),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 12),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: LoginColors.textPrimary,
              letterSpacing: 0.15,
            ),
          ),
          collapsedIconColor: LoginColors.primary,
          iconColor: LoginColors.primaryDark,
          children: children,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrice;
  final bool isStatus;

  const _InfoRow(
    this.label,
    this.value, {
    this.isPrice = false,
    this.isStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    Color valueColor = LoginColors.textSecondary;

    if (isPrice) {
      valueColor = LoginColors.primaryDark;
    } else if (isStatus) {
      valueColor = value == 'Yes' ? LoginColors.success : LoginColors.error;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: LoginColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              maxLines: 1, // 🔒 single line
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor,
                fontWeight: isPrice ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionText extends StatelessWidget {
  final String label;
  final String text;

  const _DescriptionText(this.label, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: LoginColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(color: LoginColors.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: LoginColors.error.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: LoginColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: LoginColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
