import 'package:flutter/material.dart';
import 'package:coreflow/core/theme/colors.dart';

class VendorEmptyState extends StatelessWidget {
  const VendorEmptyState({super.key});

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
                color: LoginColors.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_off_rounded,
                size: 64,
                color: LoginColors.textTertiary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No vendor data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: LoginColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Vendor information is not available for this record.',
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
