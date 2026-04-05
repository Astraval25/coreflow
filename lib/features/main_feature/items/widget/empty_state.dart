import 'package:flutter/material.dart';
import 'package:coreflow/core/theme/colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: LoginColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 72,
                color: LoginColors.textTertiary.withValues(alpha:0.6),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No items found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: LoginColors.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Try adjusting your search or add a new item\nusing the + button below',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                color: LoginColors.textTertiary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
