import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:flutter/material.dart';

class EmployeeLoadingView extends StatelessWidget {
  const EmployeeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LoginColors.borderLight, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: LoginColors.shadowLight.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Skeleton(height: 52, width: 52, borderRadius: 26),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Skeleton(height: 18, width: 140),
                      const SizedBox(height: 8),
                      const Skeleton(height: 14, width: 200),
                      const SizedBox(height: 4),
                      const Skeleton(height: 14, width: 120),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: LoginColors.textTertiary),
              ],
            ),
          ),
        );
      },
    );
  }
}
