import 'package:flutter/material.dart';
import 'package:coreflow/core/theme/colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 96, color: LoginColors.textTertiary),
          const SizedBox(height: 24),
          const Text('No items found'),
        ],
      ),
    );
  }
}
