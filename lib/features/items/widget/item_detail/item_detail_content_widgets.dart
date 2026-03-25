import 'dart:typed_data';

import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/items/detail_item.dart';
import 'package:coreflow/features/items/widget/item_section_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemDetailSections extends StatelessWidget {
  final DetailItem item;
  final NumberFormat currencyFormat;

  const ItemDetailSections({
    super.key,
    required this.item,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemSectionCard(
            title: 'Pricing & Tax',
            icon: Icons.sell_rounded,
            iconColor: const Color(0xFF10B981),
            children: [
              ItemDetailInfoRow(
                label: 'Sales Price',
                value: item.baseSalesPrice != null
                    ? currencyFormat.format(item.baseSalesPrice)
                    : '-',
                icon: Icons.payments_rounded,
                color: const Color(0xFF10B981),
              ),
              ItemDetailInfoRow(
                label: 'Purchase Price',
                value: item.basePurchasePrice != null
                    ? currencyFormat.format(item.basePurchasePrice)
                    : '-',
                icon: Icons.shopping_bag_rounded,
                color: const Color(0xFFF59E0B),
              ),
              ItemDetailInfoRow(
                label: 'Tax Rate',
                value: item.taxRate != null
                    ? '${item.taxRate!.toStringAsFixed(1)}%'
                    : '-',
                icon: Icons.percent_rounded,
                color: const Color(0xFFEF4444),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ItemSectionCard(
            title: 'Additional Info',
            icon: Icons.info_rounded,
            iconColor: const Color(0xFF6366F1),
            children: [
              ItemDetailInfoRow(
                label: 'HSN Code',
                value: item.hsnCode,
                icon: Icons.qr_code_2_rounded,
                color: const Color(0xFF6366F1),
              ),
              ItemDetailInfoRow(
                label: 'Unit',
                value: item.unit ?? '-',
                icon: Icons.straighten_rounded,
                color: const Color(0xFF0D9488),
              ),
              ItemDetailInfoRow(
                label: 'Status',
                value: item.isActive ? 'Active' : 'Inactive',
                icon: Icons.check_circle_rounded,
                color: item.isActive ? LoginColors.success : LoginColors.error,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (item.salesDescription?.isNotEmpty == true ||
              item.purchaseDescription?.isNotEmpty == true)
            ItemSectionCard(
              title: 'Descriptions',
              icon: Icons.description_rounded,
              iconColor: const Color(0xFF8B5CF6),
              children: [
                if (item.salesDescription?.isNotEmpty == true)
                  ItemDetailDescriptionBlock(
                    label: 'Sales Description',
                    text: item.salesDescription!,
                    icon: Icons.rate_review_rounded,
                  ),
                if (item.purchaseDescription?.isNotEmpty == true &&
                    item.salesDescription?.isNotEmpty == true)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                if (item.purchaseDescription?.isNotEmpty == true)
                  ItemDetailDescriptionBlock(
                    label: 'Purchase Description',
                    text: item.purchaseDescription!,
                    icon: Icons.shopping_cart_checkout_rounded,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class ItemDetailAppBarHeader extends StatelessWidget {
  final DetailItem item;
  final bool isLoadingImage;
  final Uint8List? currentImageBytes;

  const ItemDetailAppBarHeader({
    super.key,
    required this.item,
    required this.isLoadingImage,
    required this.currentImageBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 92,
            height: 92,
            color: Colors.white.withOpacity(0.15),
            child: isLoadingImage
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : currentImageBytes != null
                    ? Image.memory(currentImageBytes!, fit: BoxFit.cover)
                    : const Icon(
                        Icons.image_not_supported_rounded,
                        size: 34,
                        color: Colors.white70,
                      ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.itemName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ItemDetailHeaderChip(label: item.itemType, color: Colors.white),
                  ItemDetailHeaderChip(label: '#${item.itemId}', color: Colors.white70),
                  ItemDetailHeaderChip(
                    label: item.isActive ? 'Active' : 'Inactive',
                    color: item.isActive ? LoginColors.success : LoginColors.error,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'HSN: ${item.hsnCode.isEmpty ? '-' : item.hsnCode}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ItemDetailHeaderChip extends StatelessWidget {
  final String label;
  final Color color;

  const ItemDetailHeaderChip({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ItemDetailInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const ItemDetailInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.withOpacity(0.7)),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: LoginColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: LoginColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemDetailDescriptionBlock extends StatelessWidget {
  final String label;
  final String text;
  final IconData icon;

  const ItemDetailDescriptionBlock({
    super.key,
    required this.label,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: LoginColors.textTertiary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: LoginColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: LoginColors.fieldFill,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: LoginColors.textPrimary,
              height: 1.5,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
