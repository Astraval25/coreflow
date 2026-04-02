import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class PurchaseBodyMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const PurchaseBodyMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      children: [
        const SizedBox(height: 120),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: LoginColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LoginColors.border),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 56,
                color: LoginColors.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: LoginColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(color: LoginColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(seconds: 2),
                      content: Text('Create purchase order coming soon.'),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: LoginColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
