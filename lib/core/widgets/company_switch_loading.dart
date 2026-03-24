import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class CompanySwitchLoading extends StatelessWidget {
  final String companyName;

  const CompanySwitchLoading({super.key, required this.companyName});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LoginColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: LoginColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Switching to',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: LoginColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  companyName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: LoginColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Loading company data...',
                  style: TextStyle(
                    fontSize: 13,
                    color: LoginColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
