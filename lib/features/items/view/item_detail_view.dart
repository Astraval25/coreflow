import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/items/detail_item.dart';
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
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemDetailViewModel(
        companyId: companyId,
        itemId: itemId,
        repository: AuthRepository(),
        apiService: ApiService(),
      )..loadItemDetail(),
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
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
        title: Text(item?.itemName ?? 'Item Detail'),
        backgroundColor: LoginColors.surface,
        foregroundColor: LoginColors.textPrimary,
        elevation: 0,
      ),
      body: vm.isLoading && item == null
          ? const Center(child: CircularProgressIndicator())
          : vm.errorMessage != null
          ? _ErrorView(message: vm.errorMessage!, onRetry: vm.refresh)
          : RefreshIndicator(
              onRefresh: () => _onRefresh(vm),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 700;
                        return isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: _BasicInfoSection(item: item),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    flex: 4,
                                    child: _ImageSection(vm: vm),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _ImageSection(vm: vm),
                                  const SizedBox(height: 24),
                                  _BasicInfoSection(item: item),
                                ],
                              );
                      },
                    ),

                    const SizedBox(height: 32),

                    /// PRICING
                    _DropdownSection(
                      title: 'Pricing',
                      children: [
                        _InfoRow(
                          'Sales Price',
                          '₹${item?.salesPrice?.toStringAsFixed(2) ?? '-'}',
                        ),
                        _InfoRow(
                          'Purchase Price',
                          '₹${item?.purchasePrice?.toStringAsFixed(2) ?? '-'}',
                        ),
                        _InfoRow(
                          'Tax Rate',
                          '${item?.taxRate?.toStringAsFixed(2) ?? '-'} %',
                        ),
                      ],
                    ),

                    /// DESCRIPTIONS
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

                    /// PREFERENCES
                    if (item?.preferredCustomerDisplayName?.isNotEmpty ==
                            true ||
                        item?.preferredVendorDisplayName?.isNotEmpty == true)
                      _DropdownSection(
                        title: 'Preferences',
                        children: [
                          if (item?.preferredCustomerDisplayName?.isNotEmpty ==
                              true)
                            _InfoRow(
                              'Preferred Customer',
                              item!.preferredCustomerDisplayName!,
                            ),
                          if (item?.preferredVendorDisplayName?.isNotEmpty ==
                              true)
                            _InfoRow(
                              'Preferred Vendor',
                              item!.preferredVendorDisplayName!,
                            ),
                        ],
                      ),

                    /// METADATA
                    // _DropdownSection(
                    //   title: 'Metadata',
                    //   children: [
                    //     _InfoRow(
                    //       'Created By',
                    //       item?.createdBy.toString() ?? '-',
                    //     ),
                    //     _InfoRow('Created Date', item?.createdDt ?? '-'),
                    //     _InfoRow(
                    //       'Last Modified By',
                    //       item?.lastModifiedBy.toString() ?? '-',
                    //     ),
                    //     _InfoRow(
                    //       'Last Modified Date',
                    //       item?.lastModifiedDt ?? '-',
                    //     ),
                    //     _InfoRow(
                    //       'Active',
                    //       item?.isActive == true ? 'Yes' : 'No',
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// IMAGE (RIGHT SIDE)
class _ImageSection extends StatelessWidget {
  final ItemDetailViewModel vm;
  const _ImageSection({required this.vm});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: vm.currentImageBytes != null
            ? Image.memory(vm.currentImageBytes!, fit: BoxFit.cover)
            : Container(
                color: LoginColors.fieldFill,
                child: const Center(
                  child: Icon(Icons.image_not_supported_rounded, size: 64),
                ),
              ),
      ),
    );
  }
}

/// BASIC INFO (LEFT, ALWAYS VISIBLE)
class _BasicInfoSection extends StatelessWidget {
  final DetailItem? item;

  const _BasicInfoSection({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        _InfoRow('Item Name', item?.itemName ?? '-'),
        _InfoRow('Item Type', item?.itemType ?? '-'),
        _InfoRow('HSN Code', item?.hsnCode ?? '-'),
        _InfoRow('Unit', item?.unit ?? '-'),
      ],
    );
  }
}

/// DROPDOWN SECTION
class _DropdownSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DropdownSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      children: children,
    );
  }
}

/// INFO ROW
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(color: LoginColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// DESCRIPTION
class _DescriptionText extends StatelessWidget {
  final String label;
  final String text;

  const _DescriptionText(this.label, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(text, style: TextStyle(color: LoginColors.textSecondary)),
        ],
      ),
    );
  }
}

/// ERROR
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 72),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
