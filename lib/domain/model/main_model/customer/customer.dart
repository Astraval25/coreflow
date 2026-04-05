class Customer {
  final int customerId;
  final String displayName;
  final String customerCompanyName;
  final int? customerCompanyId;
  final String dueAmount;
  final String? email;
  final bool isActive;

  Customer({
    required this.customerId,
    required this.displayName,
    required this.customerCompanyName,
    this.customerCompanyId,
    this.dueAmount = '',
    this.email,
    this.isActive = true,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'] ?? 0,
      displayName: json['displayName'] ?? '',
      customerCompanyName: json['customerCompanyName'] ?? '',
      customerCompanyId: json['customerCompanyId'],
      dueAmount: json['dueAmount']?.toString() ?? '',
      email: json['email'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'displayName': displayName,
      'customerCompanyName': customerCompanyName,
      'customerCompanyId': customerCompanyId,
      'dueAmount': dueAmount,
      'email': email,
      'isActive': isActive,
    };
  }

  Customer copyWith({
    int? customerId,
    String? displayName,
    String? customerCompanyName,
    int? customerCompanyId,
    String? dueAmount,
    String? email,
    bool? isActive,
  }) {
    return Customer(
      customerId: customerId ?? this.customerId,
      displayName: displayName ?? this.displayName,
      customerCompanyName: customerCompanyName ?? this.customerCompanyName,
      customerCompanyId: customerCompanyId ?? this.customerCompanyId,
      dueAmount: dueAmount ?? this.dueAmount,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
    );
  }
}
