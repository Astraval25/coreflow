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
        title: Text(item.itemName),
        trailing: Text(item.salesPrice.toStringAsFixed(2)),
        onTap: () {
          final companyId =
              context.read<ItemsViewModel>().companyId;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ItemDetailView(
                companyId: companyId,
                itemId: item.itemId,
              ),
            ),
          );
        },
      ),
    );
  }
}
