import 'package:flutter/material.dart';
import 'package:coreflow/core/theme/colors.dart';

class StatusToggleTabs extends StatelessWidget {
  final bool isActiveSelected;
  final String activeLabel;
  final String inactiveLabel;
  final VoidCallback onActiveTap;
  final VoidCallback onInactiveTap;

  const StatusToggleTabs({
    super.key,
    required this.isActiveSelected,
    this.activeLabel = 'Active',
    this.inactiveLabel = 'Inactive',
    required this.onActiveTap,
    required this.onInactiveTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = LoginColors.success;
    final inactiveColor = LoginColors.error;

    return Container(
      color: LoginColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: LoginColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: LoginColors.border.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: LoginColors.shadowLight.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double toggleWidth = (constraints.maxWidth - 8) / 2;

            return Stack(
              children: [
                // ── Luxury Sliding Background ──
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  left: isActiveSelected ? 4 : 4 + toggleWidth,
                  top: 4,
                  bottom: 4,
                  child: Container(
                    width: toggleWidth,
                    decoration: BoxDecoration(
                      color: LoginColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isActiveSelected ? activeColor : inactiveColor)
                                  .withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          LoginColors.surface,
                          LoginColors.surface.withOpacity(0.95),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Tab Items ──
                Row(
                  children: [
                    Expanded(
                      child: _StatusTabItem(
                        label: activeLabel,
                        isSelected: isActiveSelected,
                        color: activeColor,
                        onTap: onActiveTap,
                      ),
                    ),
                    Expanded(
                      child: _StatusTabItem(
                        label: inactiveLabel,
                        isSelected: !isActiveSelected,
                        color: inactiveColor,
                        onTap: onInactiveTap,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusTabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _StatusTabItem({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        splashColor: color.withOpacity(0.08),
        highlightColor: color.withOpacity(0.04),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: isSelected ? 7 : 6,
                height: isSelected ? 7 : 6,
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.35),
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.45),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 8),

              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : LoginColors.textSecondary,
                  letterSpacing: 0.2,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
