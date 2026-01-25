class Customer {
  final int customerId;
  final String displayName;
  final String customerCompanyName;
  final String? email;
  final bool isActive;

  Customer({
    required this.customerId,
    required this.displayName,
    required this.customerCompanyName,
    this.email, 
    this.isActive = true,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'] ?? 0,
      displayName: json['displayName'] ?? '',
      customerCompanyName: json['customerCompanyName'] ?? '',
      email: json['email'], 
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'displayName': displayName,
      'customerCompanyName': customerCompanyName,
      'email': email,
      'isActive': isActive,
    };
  }

  Customer copyWith({
    int? customerId,
    String? displayName,
    String? customerCompanyName,
    String? email,
    bool? isActive,
  }) {
    return Customer(
      customerId: customerId ?? this.customerId,
      displayName: displayName ?? this.displayName,
      customerCompanyName: customerCompanyName ?? this.customerCompanyName,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
    );
  }
}
