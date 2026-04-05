import 'dart:async';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view/notification_page.dart';
import 'package:coreflow/features/main_feature/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/main_feature/dashboard/widget/dashboard_widgets.dart';

import 'package:coreflow/core/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/core/theme/theme_provider.dart';
import 'package:coreflow/domain/model/advertisement/advertisement.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:coreflow/features/main_feature/dashboard/widget/create_section.dart';
import 'package:coreflow/features/main_feature/dashboard/widget/dashboard_analytics_section.dart';
import 'package:coreflow/features/main_feature/dashboard/widget/quick_access_section.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, String? role});

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return const _DashboardView();
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView>
    with SingleTickerProviderStateMixin {
  static const double _contentHorizontalPadding = 16;
  static const double _promoBannerHeight = 180;

  bool _isRefreshing = false;
  late final AnimationController _refreshController = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 800),
  );

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh(DashboardViewModel vm) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    _refreshController.repeat();
    try {
      await vm.refresh();
    } finally {
      _refreshController.stop();
      _refreshController.reset();
      if (mounted) setState(() => _isRefreshing = false);
    }
  }
  static final Uri _fallbackVideoUrl = Uri.parse(
    'https://youtube.com/shorts/XgM2_m2I6sE?si=MVVTXLzD-l5AUu7e',
  );
  // Sections are now extracted into standalone widgets

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    return Consumer<DashboardViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: LoginColors.background,
          appBar: _buildAppBar(context, vm),
          body: vm.isLoading
              ? _buildSkeletonLayout()
              : RefreshIndicator(
                  onRefresh: vm.refresh,
                  backgroundColor: LoginColors.surface,
                  color: LoginColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final bannerHeight = constraints.maxWidth < 360
                                ? 164.0
                                : _promoBannerHeight;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: Container(
                                height: bannerHeight,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: LoginColors.surface,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                    bottomRight: Radius.circular(30),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: LoginColors.shadowLight
                                          .withValues(
                                        alpha: 0.12,
                                      ),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: DashboardPromoBanner(
                                    promoItems: _buildBannerItems(context, vm),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            _contentHorizontalPadding,
                            0,
                            _contentHorizontalPadding,
                            50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CreateSection(
                                vm: vm,
                                // onPlay: () => _openHowItWorksVideo(context),
                              ),
                              QuickAccessSection(vm: vm),
                              DashboardAnalyticsSection(
                                kpi: vm.kpi,
                                cashFlow: vm.cashFlow,
                                revenueExpense: vm.revenueExpense,
                                isLoading: vm.isAnalyticsLoading,
                                onPeriodChanged: vm.loadAnalyticsForPeriod,
                                companyId: vm.companyId ?? 0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  List<Widget> _buildBannerItems(BuildContext context, DashboardViewModel vm) {
    final ads = vm.advertisements;
    final cache = vm.adImageCache;

    // If we have ads with cached images, show them
    final adWidgets = <Widget>[];
    for (final ad in ads) {
      if (ad.fsId.isNotEmpty && cache.containsKey(ad.fsId)) {
        adWidgets.add(_buildAdBannerItem(context, ad, cache[ad.fsId]!));
      }
    }

    // If we have ad banners, use them; otherwise fall back to static assets
    if (adWidgets.isNotEmpty) return adWidgets;

    return [_buildStaticBannerItem(context, 'assets/image1.jpeg')];
  }

  Widget _buildAdBannerItem(
    BuildContext context,
    Advertisement ad,
    Uint8List imageBytes,
  ) {
    return Material(
      color: LoginColors.cardBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            width: double.infinity,
            filterQuality: FilterQuality.high,
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: FilledButton(
              onPressed: () => _openAdUrl(ad.actionUrl),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.75),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: const Text('View'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticBannerItem(BuildContext context, String assetPath) {
    return Material(
      color: LoginColors.cardBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            assetPath,
            fit: BoxFit.cover,
            width: double.infinity,
            filterQuality: FilterQuality.high,
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.campaign_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Place your ad · admin@coreflow.com',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAdUrl(String url) async {
    if (url.isEmpty) return;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Widget _buildSkeletonLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Skeleton(height: _promoBannerHeight, width: double.infinity),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              _contentHorizontalPadding,
              30,
              _contentHorizontalPadding,
              100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Skeleton(height: 24, width: 120),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                  children: List.generate(
                    8,
                    (index) => Column(
                      children: [
                        const Skeleton(height: 50, width: 50, borderRadius: 16),
                        const SizedBox(height: 8),
                        const Skeleton(height: 12, width: 40),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Skeleton(height: 24, width: 150),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                  children: List.generate(
                    4,
                    (index) => Column(
                      children: [
                        const Skeleton(height: 50, width: 50, borderRadius: 16),
                        const SizedBox(height: 8),
                        const Skeleton(height: 12, width: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Future<void> _openHowItWorksVideo(BuildContext context) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _AssetVideoFullscreenPage(fallbackVideoUrl: _fallbackVideoUrl),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, DashboardViewModel vm) {
    return AppBar(
      title: Text(
        vm.companyName ?? 'Select Company',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: LoginColors.textPrimary,
          letterSpacing: -0.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: true,
      backgroundColor: LoginColors.background,
      elevation: 0,
      toolbarHeight: 60,
      leading: IconButton(
        icon: Icon(
          Icons.notes_rounded,
          color: LoginColors.textPrimary,
          size: 26,
        ),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      actions: [
        RotationTransition(
          turns: _refreshController,
          child: IconButton(
            tooltip: 'Refresh',
            onPressed: _isRefreshing ? null : () => _handleRefresh(vm),
            icon: Icon(
              Icons.refresh_rounded,
              color: _isRefreshing
                  ? LoginColors.textTertiary
                  : LoginColors.textPrimary,
              size: 24,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            if (vm.companyId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationPage(companyId: vm.companyId!),
                ),
              ).then((_) => vm.refreshUnreadCount());
            }
          },
          icon: Badge(
            isLabelVisible: vm.unreadNotificationCount > 0,
            label: Text(
              vm.unreadNotificationCount > 99
                  ? '99+'
                  : vm.unreadNotificationCount.toString(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
            child: Icon(
              Icons.notifications_none_outlined,
              color: LoginColors.textPrimary,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _AssetVideoFullscreenPage extends StatefulWidget {
  final Uri fallbackVideoUrl;

  const _AssetVideoFullscreenPage({required this.fallbackVideoUrl});

  @override
  State<_AssetVideoFullscreenPage> createState() =>
      _AssetVideoFullscreenPageState();
}

class _AssetVideoFullscreenPageState extends State<_AssetVideoFullscreenPage> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final controller = VideoPlayerController.asset('assets/viedios.mp4');
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isReady = true;
      });
    } on PlatformException {
      if (mounted) setState(() => _hasError = true);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  Future<void> _openFallbackVideo() async {
    try {
      await launchUrl(
        widget.fallbackVideoUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: _hasError
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Video load failed on this device',
                            style: TextStyle(color: LoginColors.error),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _openFallbackVideo,
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: const Text('Play Externally'),
                          ),
                        ],
                      )
                    : !_isReady
                    ? const CircularProgressIndicator(color: Colors.white)
                    : FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: _controller!.value.size.width,
                          height: _controller!.value.size.height,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            if (_isReady && !_hasError)
              Positioned(
                left: 16,
                right: 16,
                bottom: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: LoginColors.primary,
                        bufferedColor: Colors.white38,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    const SizedBox(height: 14),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_controller!.value.isPlaying) {
                            _controller!.pause();
                          } else {
                            _controller!.play();
                          }
                        });
                      },
                      iconSize: 38,
                      color: Colors.white,
                      icon: Icon(
                        _controller!.value.isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_fill_rounded,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
