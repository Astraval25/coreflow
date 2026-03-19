import 'dart:typed_data';

import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/data/services/api_services.dart';
import 'package:coreflow/domain/model/items/detail_item.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/items/view/update_item_screen.dart';
import 'package:coreflow/features/items/view_model/item_detail_view_model.dart';
import 'package:coreflow/features/items/view_model/item_update_view_model.dart';
import 'package:coreflow/features/items/widget/item_detail/item_detail_content_widgets.dart';
import 'package:coreflow/features/items/widget/item_detail/item_detail_feedback_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ItemDetailView extends StatelessWidget {
  final int companyId;
  final int itemId;

  const ItemDetailView({
    super.key,
    required this.companyId,
    required this.itemId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ItemDetailViewModel(
            companyId: companyId,
            itemId: itemId,
            repository: AuthRepository(),
            apiService: ApiService(),
          )..loadItemDetail(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..loadUserData(),
        ),
      ],
      child: const _ItemDetailContent(),
    );
  }
}

class _ItemDetailContent extends StatefulWidget {
  const _ItemDetailContent();

  @override
  State<_ItemDetailContent> createState() => _ItemDetailContentState();
}

class _ItemDetailContentState extends State<_ItemDetailContent> {
  final ScrollController _scrollController = ScrollController();
  bool _showCollapsedTitle = false;

  static const double _expandedAppBarHeight = 250;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final shouldShow = _scrollController.hasClients &&
        _scrollController.offset > 40;
    if (shouldShow != _showCollapsedTitle) {
      setState(() => _showCollapsedTitle = shouldShow);
    }
  }

  Future<void> _handleMenuAction(
    _ItemDetailMenuAction action,
    ItemDetailViewModel vm,
    DetailItem item,
  ) async {
    switch (action) {
      case _ItemDetailMenuAction.edit:
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => UpdateItemViewModel(),
              child: UpdateItemScreen(
                companyId: vm.companyId,
                item: item.toItem(),
              ),
            ),
          ),
        );
        if (result == true && mounted) {
          await vm.refresh();
        }
        break;
      case _ItemDetailMenuAction.toggleStatus:
        bool statusChanged = false;
        if (item.isActive) {
          statusChanged = await vm.deactivateItem();
        } else {
          statusChanged = await vm.activateItem();
        }

        if (statusChanged && mounted) {
          Navigator.pop(context, true);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ItemDetailViewModel>();
    final item = vm.itemResponse?.responseData;
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: LoginColors.background,
      body: RefreshIndicator(
        onRefresh: () => vm.refresh(),
        backgroundColor: LoginColors.surface,
        color: LoginColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: _expandedAppBarHeight,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: LoginColors.primary,
              elevation: 0,
              title: AnimatedOpacity(
                opacity: _showCollapsedTitle ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: _CollapsedItemTitle(
                  item: item,
                  isLoadingImage: vm.isLoadingImage,
                  currentImageBytes: vm.currentImageBytes,
                ),
              ),
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (item != null)
                  PopupMenuButton<_ItemDetailMenuAction>(
                    enabled: !vm.isLoading,
                    tooltip: 'More options',
                    color: LoginColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.more_vert_rounded, size: 20),
                    ),
                    onSelected: (action) => _handleMenuAction(action, vm, item),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _ItemDetailMenuAction.edit,
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 20),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: _ItemDetailMenuAction.toggleStatus,
                        child: Row(
                          children: [
                            Icon(
                              item.isActive
                                  ? Icons.block_rounded
                                  : Icons.check_circle_outline_rounded,
                              size: 20,
                              color: item.isActive
                                  ? LoginColors.error
                                  : LoginColors.success,
                            ),
                            const SizedBox(width: 10),
                            Text(item.isActive ? 'Deactivate' : 'Activate'),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final topPadding = MediaQuery.of(context).padding.top;
                  final collapsed =
                      constraints.maxHeight <= kToolbarHeight + topPadding + 8;

                  return FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: EdgeInsets.zero,
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [LoginColors.primary, LoginColors.primaryDark],
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: collapsed ? 0 : 1,
                          child: item == null
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 18),
                                  child: ItemDetailAppBarHeader(
                                    item: item,
                                    isLoadingImage: vm.isLoadingImage,
                                    currentImageBytes: vm.currentImageBytes,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: vm.isLoading && item == null
                  ? const ItemDetailSkeletonLoading()
                  : vm.errorMessage != null
                      ? ItemDetailErrorView(
                          message: vm.errorMessage!,
                          onRetry: vm.refresh,
                        )
                      : item == null
                          ? const SizedBox.shrink()
                          : ItemDetailSections(
                              item: item,
                              currencyFormat: currencyFormat,
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsedItemTitle extends StatelessWidget {
  final DetailItem? item;
  final bool isLoadingImage;
  final Uint8List? currentImageBytes;

  const _CollapsedItemTitle({
    required this.item,
    required this.isLoadingImage,
    required this.currentImageBytes,
  });

  @override
  Widget build(BuildContext context) {
    final title = item?.itemName ?? 'Item Detail';

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 28,
            height: 28,
            color: Colors.white.withOpacity(0.2),
            child: isLoadingImage
                ? const Center(
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : currentImageBytes != null
                ? Image.memory(currentImageBytes!, fit: BoxFit.cover)
                : const Icon(
                    Icons.image_not_supported_rounded,
                    size: 14,
                    color: Colors.white70,
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

enum _ItemDetailMenuAction { edit, toggleStatus }
