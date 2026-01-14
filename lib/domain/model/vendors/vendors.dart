class Vendors {
  final int customerId;
  final String displayName;
  final String customerCompanyName;
  final String? email;

  Vendors({
    required this.customerId,
    required this.displayName,
    required this.customerCompanyName,
    required this.email,
  });

  factory Vendors.fromJson(Map<String, dynamic> json) {
    return Vendors(
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
