import 'package:coreflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class ProcessLoadingScreen extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  final String? title;
  final bool showProgress;

  const ProcessLoadingScreen({
    super.key,
    required this.steps,
    required this.currentStep,
    this.title,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: LoginColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: LoginColors.borderLight),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress)
                CircularProgressIndicator(color: LoginColors.primary),
              if (showProgress) const SizedBox(height: 24),
              if (title != null) ...[
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
              ...List.generate(steps.length, (index) {
                final isCompleted = index < currentStep;
                final isCurrent = index == currentStep;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle
                            : isCurrent
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                        color: isCompleted
                            ? Colors.green
                            : isCurrent
                                ? LoginColors.primary
                                : LoginColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          steps[index],
                          style: TextStyle(
                            color: isCurrent
                                ? LoginColors.textPrimary
                                : LoginColors.textSecondary,
                            fontWeight:
                                isCurrent ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
