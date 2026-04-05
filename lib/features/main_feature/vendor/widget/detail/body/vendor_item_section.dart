import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:coreflow/features/main_feature/vendor/view_model/vendor_detail_view_model.dart';
import 'package:coreflow/features/main_feature/vendor/widget/detail/body/vendor_item_pages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VendorItemSection extends StatelessWidget {
  const VendorItemSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VendorDetailViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentPurple = isDark
        ? const Color(0xFFA79BFF)
        : const Color(0xFF6D64D8);
    final boxSurface = isDark
        ? Color.alphaBlend(
            const Color.fromARGB(255, 71, 84, 104).withValues(alpha: 0.78),
            colorScheme.surface,
          )
        : const Color(0xFFF2F3F6);
    final boxFill = isDark
        ? Color.alphaBlend(
            const Color(0xFF2E3340).withValues(alpha: 0.78),
            colorScheme.surface,
          )
        : const Color(0xFFEEF0F4);
    final borderColor = isDark
        ? colorScheme.outlineVariant.withValues(alpha: 0.55)
        : const Color(0xFFE7E9EF);
    final primaryText = colorScheme.onSurface;
    final secondaryText = colorScheme.onSurface.withValues(alpha: 0.72);
    final tertiaryText = colorScheme.onSurface.withValues(alpha: 0.58);
    final activeStatusColor = LoginColors.success;
    final inactiveStatusColor = LoginColors.error;
    final vendorCompany = vm.vendor?.vendorCompany;
    final isVendorLinked = vendorCompany?.companyId != null;
    final vendorCompanyName = vendorCompany?.companyName?.trim();

    final content = vm.isMappedItemsLoading
        ? const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Column(
              children: [
                VendorItemSkeletonCard(),
                SizedBox(height: 10),
                VendorItemSkeletonCard(),
              ],
            ),
          )
        : vm.mappedItems.isEmpty
        ? Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: boxFill,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                isVendorLinked
                    ? (vendorCompanyName != null && vendorCompanyName.isNotEmpty
                        ? 'No items added yet. Please contact $vendorCompanyName to add items.'
                        : 'No items added yet. Please contact the vendor company to add items.')
                    : 'No mapped items found.',
                style: TextStyle(color: secondaryText, fontSize: 14),
              ),
            ),
          )
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            itemCount: vm.mappedItems.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = vm.mappedItems[index];
              final itemType = item.itemType.trim().toUpperCase();
              final unit = item.unit.trim();
              final canEdit = item.editable;

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: canEdit
                    ? () async {
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => UpdateVendorItemPage(
                              viewModel: vm,
                              item: item,
                            ),
                          ),
                        );
                        if (!context.mounted || updated != true) return;
                        await vm.loadMappedItems();
                      }
                    : null,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: boxSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.itemName,
                                  style: TextStyle(
                                    color: primaryText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  final isUpdating =
                                      vm.isMappedItemStatusUpdating &&
                                      vm.statusUpdatingItemId == item.itemId;
                                  final shouldActivate = !item.isActive;

                                  return OutlinedButton(
                                    onPressed: isUpdating
                                        ? null
                                        : () async {
                                            final ok = await vm
                                                .setMappedItemActiveStatus(
                                                  itemId: item.itemId,
                                                  shouldActivate:
                                                      shouldActivate,
                                                );
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                duration: Duration(
                                                  seconds: 1,
                                                ),
                                                content: Text(
                                                  ok
                                                      ? (shouldActivate
                                                            ? 'Item activated'
                                                            : 'Item deactivated')
                                                      : (vm.errorMessage ??
                                                            'Failed to update item status'),
                                                ),
                                              ),
                                            );
                                          },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: item.isActive
                                          ? activeStatusColor
                                          : inactiveStatusColor,
                                      side: BorderSide(
                                        color: item.isActive
                                            ? activeStatusColor.withValues(alpha:0.5)
                                            : inactiveStatusColor.withValues(alpha:
                                                0.5,
                                              ),
                                      ),
                                      backgroundColor: item.isActive
                                          ? activeStatusColor.withValues(
                                              alpha: 0.10,
                                            )
                                          : inactiveStatusColor.withValues(
                                              alpha:
                                              0.08,
                                            ),
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                    ),
                                    child: isUpdating
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            item.isActive
                                                ? 'Active'
                                                : 'Inactive',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ItemMetaChip(
                                label: 'ID ${item.itemId}',
                                accent: accentPurple,
                              ),
                              ItemMetaChip(
                                label: itemType,
                                accent: accentPurple,
                              ),
                              ItemMetaChip(label: unit, accent: accentPurple),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DetailLine(
                            icon: Icons.sell_outlined,
                            label: 'Purchase Price',
                            value: item.salesPrice.toStringAsFixed(2),
                            accent: accentPurple,
                          ),
                          if (item.taxRate != null) ...[
                            const SizedBox(height: 6),
                            DetailLine(
                              icon: Icons.percent_rounded,
                              label: 'Tax Rate',
                              value: '${item.taxRate!.toStringAsFixed(2)}%',
                              accent: accentPurple,
                            ),
                          ],
                          if (item.hsnCode != null) ...[
                            const SizedBox(height: 6),
                            DetailLine(
                              icon: Icons.receipt_long_outlined,
                              label: 'HSN Code',
                              value: item.hsnCode!,
                              accent: accentPurple,
                            ),
                          ],
                          if (item.salesDescription != null) ...[
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.notes_rounded,
                                  size: 16,
                                  color: tertiaryText,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.salesDescription!,
                                    style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 13.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (item.salesDescription != null && canEdit)
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentPurple.withValues(alpha:0.14),
                            border: Border.all(
                              color: accentPurple.withValues(alpha:0.24),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.edit_outlined,
                            size: 15,
                            color: accentPurple,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vendor Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: LoginColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 3,
                      width: 50,
                      decoration: BoxDecoration(
                        color: LoginColors.textPrimary.withValues(alpha:0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isVendorLinked)
                FilledButton.icon(
                  onPressed: () => _openAddItemFlow(context, vm),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text('Add Item'),
                  style: FilledButton.styleFrom(
                    backgroundColor: LoginColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: borderColor),
        content,
      ],
    );
  }

  Future<void> _openAddItemFlow(
    BuildContext context,
    VendorDetailViewModel vm,
  ) async {
    await vm.loadMappedItems();
    if (!context.mounted) return;

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SelectVendorCompanyItemPage(viewModel: vm),
      ),
    );

    if (!context.mounted || created != true) return;
    await vm.loadMappedItems();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 2),
        content: Text('Vendor item created successfully'),
      ),
    );
  }
}

class VendorItemSkeletonCard extends StatelessWidget {
  const VendorItemSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boxSurface = isDark
        ? Color.alphaBlend(
            const Color(0xFF262A34).withValues(alpha: 0.78),
            colorScheme.surface,
          )
        : const Color(0xFFF2F3F6);
    final borderColor = isDark
        ? colorScheme.outlineVariant.withValues(alpha: 0.55)
        : const Color(0xFFE7E9EF);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: boxSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Skeleton(height: 16, width: 140)),
              SizedBox(width: 12),
              Skeleton(height: 30, width: 92, borderRadius: 20),
            ],
          ),
          SizedBox(height: 12),
          Skeleton(height: 13, width: 220),
          SizedBox(height: 10),
          Skeleton(height: 14, width: 150),
          SizedBox(height: 10),
          Skeleton(height: 14, width: 120),
        ],
      ),
    );
  }
}

class ItemMetaChip extends StatelessWidget {
  final String label;
  final Color accent;

  const ItemMetaChip({super.key, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    // final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class DetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const DetailLine({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: accent),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha:0.72),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
