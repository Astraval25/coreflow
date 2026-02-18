import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:flutter/material.dart';

class SalesLoadingBody extends StatelessWidget {
  const SalesLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: const [
        SizedBox(height: 24),
        Skeleton(height: 120, width: double.infinity),
        SizedBox(height: 16),
        Skeleton(height: 120, width: double.infinity),
        SizedBox(height: 16),
        Skeleton(height: 120, width: double.infinity),
      ],
    );
  }
}
