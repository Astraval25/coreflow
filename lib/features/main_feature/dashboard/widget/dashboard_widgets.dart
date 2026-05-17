import 'dart:async';
import 'package:flutter/material.dart';
import 'package:coreflow/core/theme/colors.dart';

class DashboardPromoBanner extends StatefulWidget {
  final List<Widget> promoItems;

  const DashboardPromoBanner({super.key, required this.promoItems});

  @override
  State<DashboardPromoBanner> createState() => _DashboardPromoBannerState();
}

class _DashboardPromoBannerState extends State<DashboardPromoBanner> {
  late final PageController _controller;
  Timer? _timer;
  int _currentPage = 0;
  int _initialPage = 0;

  @override
  void initState() {
    super.initState();
    final itemCount = widget.promoItems.length;
    if (itemCount > 0) {
      _initialPage = itemCount * 1000;
      _currentPage = _initialPage;
    }
    _controller = PageController(initialPage: _initialPage);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (widget.promoItems.isEmpty) return;
      if (_controller.hasClients) {
        _currentPage++;
        _controller.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promoItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemCount = widget.promoItems.length;
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: LoginColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRect(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                if (!mounted) return;
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return widget.promoItems[index % itemCount];
              },
            ),
          ),
          Positioned(bottom: 16, left: 20, child: _buildPageIndicator()),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    final itemCount = widget.promoItems.length;
    final currentPage = _currentPage % itemCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final bool isActive = currentPage == index;
        return GestureDetector(
          onTap: () {
            final targetPage =
                _currentPage - (_currentPage % itemCount) + index;
            _controller.animateToPage(
              targetPage,
              duration: Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
            );
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 400),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 24 : 6,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: isActive
                  ? Colors.black87
                  : Colors.black.withValues(alpha: 0.15),
            ),
          ),
        );
      }),
    );
  }
}

class PromoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final Color backgroundColor;
  final Widget illustration;

  const PromoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.backgroundColor,
    required this.illustration,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight <= 140;

        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: LinearGradient(
              colors: [backgroundColor, backgroundColor.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.all(isCompact ? 16 : 24),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 8 : 10,
                        vertical: isCompact ? 2 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'PROMO',
                        style: TextStyle(
                          fontSize: isCompact ? 9 : 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: isCompact ? 3 : 8),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isCompact ? 18 : 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.5,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: isCompact ? 1 : 4),
                    Flexible(
                      child: Text(
                        subtitle,
                        maxLines: isCompact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isCompact ? 10 : 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B).withValues(alpha: 0.7),
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: isCompact ? 4 : 12),
                    Material(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 10 : 16,
                            vertical: isCompact ? 5 : 8,
                          ),
                          child: Text(
                            buttonText,
                            style: TextStyle(
                              fontSize: isCompact ? 11 : 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isCompact ? 8 : 12),
              Expanded(
                flex: 2,
                child: Transform.rotate(angle: 0.1, child: illustration),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTap,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: LoginColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                if (title == 'Create') ...[
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onPlay,
                    child: const Icon(
                      Icons.play_circle_fill,
                      color: Colors.redAccent,
                      size: 22,
                    ),
                  ),
                ],
              ],
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class DashboardGridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final int badgeCount;
  final bool isPinned;
  final bool showPinnedIndicator;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const DashboardGridItem({
    super.key,
    required this.icon,
    required this.label,
    this.color,
    this.badgeCount = 0,
    this.isPinned = false,
    this.showPinnedIndicator = true,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: LoginColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: LoginColors.shadowLight.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: LoginColors.border.withValues(alpha: 0.1),
                  ),
                ),
                child: Icon(
                  icon,
                  color: color ?? LoginColors.primary,
                  size: 26,
                ),
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: _DashboardCountBadge(count: badgeCount),
                ),
              if (isPinned && showPinnedIndicator)
                Positioned(
                  left: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: LoginColors.primary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: LoginColors.surface, width: 1),
                    ),
                    child: const Icon(
                      Icons.push_pin_rounded,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: LoginColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCountBadge extends StatelessWidget {
  final int count;

  const _DashboardCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: LoginColors.error,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LoginColors.surface, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
