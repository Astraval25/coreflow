class Vendor {
  final int vendorId;
  final String displayName;
  final String vendorCompanyName;
  final int? vendorCompanyId;
  final String dueAmount;
  final String? email;
  final bool isActive;
  final String? connectionStatus;
  final int unreadCount;

  Vendor({
    required this.vendorId,
    required this.displayName,
    required this.vendorCompanyName,
    this.vendorCompanyId,
    this.dueAmount = '',
    this.email,
    this.isActive = true,
    this.connectionStatus,
    this.unreadCount = 0,
  });

  bool get isPendingConnection => connectionStatus == 'PENDING';
  bool get isAcceptedConnection => connectionStatus == 'ACCEPTED';
  bool get isRejectedConnection => connectionStatus == 'REJECTED';
  bool get hasConnectionRequest => connectionStatus != null;

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      vendorId: json['vendorId'] ?? 0,
      displayName: json['displayName'] ?? '',
      vendorCompanyName: json['vendorCompanyName'] ?? '',
      vendorCompanyId: json['vendorCompanyId'],
      dueAmount: json['dueAmount']?.toString() ?? '',
      email: json['email'],
      isActive: json['isActive'] ?? true,
      connectionStatus: json['connectionStatus'],
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'displayName': displayName,
      'vendorCompanyName': vendorCompanyName,
      'vendorCompanyId': vendorCompanyId,
      'dueAmount': dueAmount,
      'email': email,
      'isActive': isActive,
      'connectionStatus': connectionStatus,
      'unreadCount': unreadCount,
    };
  }

  Vendor copyWith({
    int? vendorId,
    String? displayName,
    String? vendorCompanyName,
    int? vendorCompanyId,
    String? dueAmount,
    String? email,
    bool? isActive,
    String? connectionStatus,
    int? unreadCount,
  }) {
    return Vendor(
      vendorId: vendorId ?? this.vendorId,
      displayName: displayName ?? this.displayName,
      vendorCompanyName: vendorCompanyName ?? this.vendorCompanyName,
      vendorCompanyId: vendorCompanyId ?? this.vendorCompanyId,
      dueAmount: dueAmount ?? this.dueAmount,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
