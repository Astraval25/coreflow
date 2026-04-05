import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:flutter/material.dart';

class PaymentSkeleton extends StatelessWidget {
  const PaymentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            const Skeleton(height: 100, width: double.infinity),
            const SizedBox(height: 24),
            const Skeleton(height: 100, width: double.infinity),
            const SizedBox(height: 24),
            const Skeleton(height: 100, width: double.infinity),
          ],
        ),
      ),
    );
  }
}
