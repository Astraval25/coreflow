import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/domain/model/items/item.dart';
import 'package:coreflow/features/items/view/item_detail_view.dart';
import 'package:coreflow/features/items/view_model/items_view_model.dart';

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),

        title: Text(
          item.itemName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.itemType} • ${item.unit}',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                item.isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 12,
                  color: item.isActive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.baseSalesPrice.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            if (item.isPurchasable && item.basePurchasePrice != null)
              Text(
                'Buy: ${item.basePurchasePrice!.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),

        onTap: () {
          final companyId = context.read<ItemsViewModel>().companyId;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ItemDetailView(companyId: companyId, itemId: item.itemId),
            ),
          );
        },
      ),
    );
  }
}
