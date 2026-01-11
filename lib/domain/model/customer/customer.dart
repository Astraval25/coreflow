class Customer {
  final int customerId;
  final String displayName;
  final String customerCompanyName;
  final String? email;

  Customer({
    required this.customerId,
    required this.displayName,
    required this.customerCompanyName,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customerId'] ?? 0,
      displayName: json['displayName'] ?? '',
      customerCompanyName: json['customerCompanyName'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'displayName': displayName,
      'customerCompanyName': customerCompanyName,
      'email': email,
    };
  }
}
