class AppNotification {
  final int notificationId;
  final String title;
  final String message;
  final String type;
  final String actionLabel;
  final String actionUrl;
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
    required this.fromCompanyId,
    required this.toCompanyId,
    required this.isRead,
    required this.createdDt,
    this.readDt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      notificationId: json['notificationId'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      actionLabel: json['actionLabel'] ?? '',
      actionUrl: json['actionUrl'] ?? '',
      fromCompanyId: json['fromCompanyId'] ?? 0,
      toCompanyId: json['toCompanyId'] ?? 0,
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
      fromCompanyId: fromCompanyId,
      toCompanyId: toCompanyId,
      isRead: isRead ?? this.isRead,
      createdDt: createdDt,
      readDt: readDt ?? this.readDt,
    );
  }
}
