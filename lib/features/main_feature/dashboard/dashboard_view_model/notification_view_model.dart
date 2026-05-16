import 'package:flutter/material.dart';
import 'package:coreflow/data/repositories/auth_repository/auth_repository.dart';
import 'package:coreflow/domain/model/main_model/notification/app_notification.dart';

class NotificationViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final int companyId;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  bool _hasNext = false;
  int _currentPage = 0;
  bool _isLoadingMore = false;
  int _totalUnreadCount = 0;
  Map<String, int> _unreadCountByEntity = const {};

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasNext => _hasNext;
  bool get isLoadingMore => _isLoadingMore;
  int get totalUnreadCount => _totalUnreadCount;
  Map<String, int> get unreadCountByEntity => _unreadCountByEntity;

  NotificationViewModel({required this.companyId}) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    _currentPage = 0;
    notifyListeners();

    try {
      final result = await _repository.getNotifications(companyId, page: 0);
      _notifications = result.notifications;
      _hasNext = result.hasNext;
      _totalUnreadCount = result.totalUnreadCount;
      _unreadCountByEntity = result.unreadCountByEntity;
    } catch (e) {
      debugPrint('Load notifications error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasNext) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final result = await _repository.getNotifications(
        companyId,
        page: _currentPage,
      );
      _notifications.addAll(result.notifications);
      _hasNext = result.hasNext;
      _totalUnreadCount = result.totalUnreadCount;
      _unreadCountByEntity = result.unreadCountByEntity;
    } catch (e) {
      debugPrint('Load more notifications error: $e');
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final success = await _repository.markNotificationRead(
      companyId,
      notificationId,
    );
    if (success) {
      final index = _notifications.indexWhere(
        (n) => n.notificationId == notificationId,
      );
      if (index != -1) {
        final removed = _notifications.removeAt(index);
        final key = removed.entityKey.trim();
        if (key.isNotEmpty && _unreadCountByEntity.containsKey(key)) {
          final current = _unreadCountByEntity[key] ?? 0;
          final updated = current > 0 ? current - 1 : 0;
          _unreadCountByEntity = <String, int>{
            ..._unreadCountByEntity,
            key: updated,
          };
          if (updated == 0) {
            final copy = Map<String, int>.from(_unreadCountByEntity);
            copy.remove(key);
            _unreadCountByEntity = copy;
          }
        }
        if (_totalUnreadCount > 0) {
          _totalUnreadCount -= 1;
        }
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final success = await _repository.markAllNotificationsRead(companyId);
    if (success) {
      _notifications = [];
      _totalUnreadCount = 0;
      _unreadCountByEntity = const {};
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadNotifications();
  }
}
