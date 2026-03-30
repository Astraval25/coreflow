import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:coreflow/core/theme/colors.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/dashboard_view_model.dart';
import 'package:coreflow/features/dashboard/dashboard_view_model/notification_view_model.dart';
import 'package:coreflow/domain/model/notification/app_notification.dart';

class NotificationPage extends StatefulWidget {
  final int companyId;

  const NotificationPage({super.key, required this.companyId});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late final NotificationViewModel _vm;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _vm = NotificationViewModel(companyId: widget.companyId);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _vm.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _vm.dispose();
    super.dispose();
  }

  void _onNotificationTap(AppNotification notification) {
    if (!notification.isRead) {
      _vm.markAsRead(notification.notificationId);
      final dashVm = context.read<DashboardViewModel>();
      dashVm.decrementUnreadCount();
    }
    _navigateToAction(notification.actionUrl);
  }

  void _navigateToAction(String actionUrl) {
    if (actionUrl.isEmpty) return;
    // actionUrl format: /companies/{companyId}/purchase/orders etc.
    final parts = actionUrl.split('/');
    // e.g. ["", "companies", "3", "purchase", "orders"]
    if (parts.length >= 4) {
      final companyId = parts[2];
      final rest = parts.sublist(3).join('/');
      if (rest == 'purchase/orders') {
        context.push('/purchase');
      } else if (rest == 'sales/orders') {
        context.push('/sales');
      } else if (rest.startsWith('customers')) {
        context.push('/customers/$companyId');
      } else if (rest.startsWith('vendors')) {
        context.push('/vendors/$companyId');
      } else {
        context.push('/dashboard');
      }
    }
  }

  Future<void> _markAllRead() async {
    await _vm.markAllAsRead();
    if (mounted) {
      final dashVm = context.read<DashboardViewModel>();
      dashVm.clearUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: LoginColors.textPrimary,
          ),
        ),
        backgroundColor: LoginColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: LoginColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ListenableBuilder(
            listenable: _vm,
            builder: (context, _) {
              final hasUnread = _vm.notifications.any((n) => !n.isRead);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: _markAllRead,
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: LoginColors.primary,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          if (_vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_vm.notifications.isEmpty) {
            return RefreshIndicator(
              onRefresh: _vm.refresh,
              backgroundColor: LoginColors.surface,
              color: LoginColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          size: 100,
                          color: LoginColors.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No new notifications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: LoginColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _vm.refresh,
            backgroundColor: LoginColors.surface,
            color: LoginColors.primary,
            child: ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _vm.notifications.length + (_vm.hasNext ? 1 : 0),
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: LoginColors.borderLight),
              itemBuilder: (context, index) {
                if (index == _vm.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _NotificationTile(
                  notification: _vm.notifications[index],
                  onTap: () => _onNotificationTap(_vm.notifications[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : LoginColors.primary.withValues(alpha: 0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _icon,
                size: 20,
                color: _iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          notification.isRead ? FontWeight.w500 : FontWeight.w700,
                      color: LoginColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: LoginColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notification.createdDt),
                    style: TextStyle(
                      fontSize: 11,
                      color: LoginColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: LoginColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    switch (notification.type) {
      case 'PURCHASE_ORDER_CREATED':
        return Icons.shopping_bag_rounded;
      case 'SALES_ORDER_CREATED':
        return Icons.receipt_long_rounded;
      case 'PAYMENT_RECEIVED':
        return Icons.payments_rounded;
      case 'PAYMENT_SENT':
        return Icons.send_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'PURCHASE_ORDER_CREATED':
        return Colors.orange.shade700;
      case 'SALES_ORDER_CREATED':
        return Colors.blue.shade600;
      case 'PAYMENT_RECEIVED':
        return Colors.green.shade600;
      case 'PAYMENT_SENT':
        return Colors.purple.shade600;
      default:
        return LoginColors.primary;
    }
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }
}
