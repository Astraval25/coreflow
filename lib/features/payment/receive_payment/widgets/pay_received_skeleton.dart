import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:flutter/material.dart';

class PayReceivedSkeleton extends StatelessWidget {
  const PayReceivedSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          SizedBox(height: 32),
          Skeleton(height: 120, width: double.infinity),
          SizedBox(height: 24),
          Skeleton(height: 120, width: double.infinity),
          SizedBox(height: 24),
          Skeleton(height: 120, width: double.infinity),
        ],
      ),
    );
  }
}
