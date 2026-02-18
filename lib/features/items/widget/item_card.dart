import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/domain/model/items/item.dart';
import 'package:coreflow/features/items/view/item_detail_view.dart';
import 'package:coreflow/features/items/view_model/items_view_model.dart';

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    final priceColor = item.isActive
        ? LoginColors.primary
        : LoginColors.textTertiary;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      elevation: 1.5,
      color: LoginColors.surface,
      shadowColor: LoginColors.shadowLight.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: LoginColors.borderLight, width: 0.8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: LoginColors.primaryLight.withOpacity(0.12),
        highlightColor: LoginColors.primaryLight.withOpacity(0.06),
        onTap: () async {
          final companyId = context.read<ItemsViewModel>().companyId;
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ItemDetailView(companyId: companyId, itemId: item.itemId),
            ),
          );

          if (result == true && context.mounted) {
            await context.read<ItemsViewModel>().fetchItems();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Item Details ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: LoginColors.textPrimary,
                        letterSpacing: 0.05,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildTag('#${item.itemId}', LoginColors.textTertiary),
                        _buildTag(
                          item.unit,
                          const Color(0xFF0D9488), // Teal
                        ),
                        _buildTag(item.itemType, LoginColors.primaryLight),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),
              // ── Pricing Column ──
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(item.baseSalesPrice),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: priceColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (item.isPurchasable && item.basePurchasePrice != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Buy: ${currencyFormat.format(item.basePurchasePrice)}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: LoginColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
