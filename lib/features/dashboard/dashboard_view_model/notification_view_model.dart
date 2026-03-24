import 'package:flutter/material.dart';
import 'package:coreflow/data/repositories/auth_repository.dart';
import 'package:coreflow/domain/model/notification/app_notification.dart';

class NotificationViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final int companyId;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  bool _hasNext = false;
  int _currentPage = 0;
  bool _isLoadingMore = false;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get hasNext => _hasNext;
  bool get isLoadingMore => _isLoadingMore;

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
      final result = await _repository.getNotifications(companyId, page: _currentPage);
      _notifications.addAll(result.notifications);
      _hasNext = result.hasNext;
    } catch (e) {
      debugPrint('Load more notifications error: $e');
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final success = await _repository.markNotificationRead(companyId, notificationId);
    if (success) {
      final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final success = await _repository.markAllNotificationsRead(companyId);
    if (success) {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadNotifications();
  }
}
