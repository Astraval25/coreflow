import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class PaymentEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const PaymentEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: LoginColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(color: LoginColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const Icon(Icons.add, size: 64),
            ],
          ),
        ),
      ),
    );
  }
}
