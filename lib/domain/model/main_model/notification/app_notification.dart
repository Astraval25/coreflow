class AppNotification {
  final int notificationId;
  final String title;
  final String message;
  final String type;
  final String actionLabel;
  final String actionUrl;
  final String entityKey;
  final int entityUnreadCount;
  final int fromCompanyId;
  final int toCompanyId;
  final bool isRead;
  final String createdDt;
  final String? readDt;

  AppNotification({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.type,
    required this.actionLabel,
    required this.actionUrl,
    required this.entityKey,
    required this.entityUnreadCount,
    required this.fromCompanyId,
    required this.toCompanyId,
    required this.isRead,
    required this.createdDt,
    this.readDt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    return AppNotification(
      notificationId: toInt(json['notificationId']),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      actionLabel: json['actionLabel'] ?? '',
      actionUrl: json['actionUrl'] ?? '',
      entityKey: json['entityKey'] ?? '',
      entityUnreadCount: toInt(json['entityUnreadCount']),
      fromCompanyId: toInt(json['fromCompanyId']),
      toCompanyId: toInt(json['toCompanyId']),
      isRead: json['isRead'] ?? false,
      createdDt: json['createdDt'] ?? '',
      readDt: json['readDt'],
    );
  }

  AppNotification copyWith({bool? isRead, String? readDt}) {
    return AppNotification(
      notificationId: notificationId,
      title: title,
      message: message,
      type: type,
      actionLabel: actionLabel,
      actionUrl: actionUrl,
      entityKey: entityKey,
      entityUnreadCount: entityUnreadCount,
      fromCompanyId: fromCompanyId,
      toCompanyId: toCompanyId,
      isRead: isRead ?? this.isRead,
      createdDt: createdDt,
      readDt: readDt ?? this.readDt,
    );
  }
}
