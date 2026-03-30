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
          constraints: BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: LoginColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: LoginColors.borderLight, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: LoginColors.shadowLight.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress) ...[
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: LoginColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: LoginColors.primary,
                      strokeWidth: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
              if (title != null) ...[
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we process your request',
                  style: TextStyle(
                    fontSize: 14,
                    color: LoginColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],
              ...List.generate(steps.length, (index) {
                final isCompleted = index < currentStep;
                final isCurrent = index == currentStep;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < steps.length - 1 ? 20 : 0,
                  ),
                  child: Row(
                    children: [
                      // Step indicator
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.withValues(alpha: 0.15)
                              : isCurrent
                              ? LoginColors.primary.withValues(alpha: 0.15)
                              : LoginColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted
                                ? Colors.green
                                : isCurrent
                                ? LoginColors.primary
                                : LoginColors.borderLight,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: isCompleted
                                ? Icon(
                                    Icons.check_rounded,
                                    color: Colors.green,
                                    size: 22,
                                    key: ValueKey('check_$index'),
                                  )
                                : isCurrent
                                ? Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: LoginColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    key: ValueKey('dot_$index'),
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: LoginColors.textTertiary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    key: ValueKey('number_$index'),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Step text
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: Duration(milliseconds: 300),
                          style: TextStyle(
                            color: isCompleted
                                ? LoginColors.textSecondary
                                : isCurrent
                                ? LoginColors.textPrimary
                                : LoginColors.textTertiary,
                            fontWeight: isCurrent
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: isCurrent ? 16 : 15,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: LoginColors.textTertiary,
                          ),
                          child: Text(
                            steps[index],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      // Status badge
                      if (isCompleted)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (isCurrent)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: LoginColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: LoginColors.primary,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Processing',
                                style: TextStyle(
                                  color: LoginColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
