
class Vendor {
  final int vendorId;
  final String displayName;
  final String vendorCompanyName;
  final String? email;

  Vendor({
    required this.vendorId,
    required this.displayName,
    required this.vendorCompanyName,
    this.email,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      vendorId: json['vendorId'] ?? 0,
      displayName: json['displayName'] ?? '',
      vendorCompanyName: json['vendorCompanyName'] ?? '',
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'displayName': displayName,
      'vendorCompanyName': vendorCompanyName,
      'email': email,
    };
  }
}