import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:flutter/material.dart';

class ItemDetailSkeletonLoading extends StatelessWidget {
  const ItemDetailSkeletonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: LoginColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: LoginColors.borderLight, width: 1),
            ),
            child: Row(
              children: [
                const Skeleton(height: 100, width: 100, borderRadius: 16),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Skeleton(height: 24, width: 160),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Skeleton(height: 20, width: 60, borderRadius: 8),
                          const SizedBox(width: 8),
                          const Skeleton(height: 20, width: 40, borderRadius: 8),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Skeleton(height: 16, width: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Skeleton(height: 180, width: double.infinity, borderRadius: 24),
          const SizedBox(height: 24),
          const Skeleton(height: 180, width: double.infinity, borderRadius: 24),
        ],
      ),
    );
  }
}

class ItemDetailErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ItemDetailErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: LoginColors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: LoginColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: LoginColors.primary,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
