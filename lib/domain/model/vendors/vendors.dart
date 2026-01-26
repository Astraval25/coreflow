class Vendor {
  final int vendorId;
  final String displayName;
  final String vendorCompanyName;
  final String? email;
  final bool isActive;

  Vendor({
    required this.vendorId,
    required this.displayName,
    required this.vendorCompanyName,
    this.email,
    this.isActive = true,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      vendorId: json['vendorId'] ?? 0,
      displayName: json['displayName'] ?? '',
      vendorCompanyName: json['vendorCompanyName'] ?? '',
      email: json['email'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'displayName': displayName,
      'vendorCompanyName': vendorCompanyName,
      'email': email,
      'isActive': isActive,
    };
  }

  Vendor copyWith({
    int? vendorId,
    String? displayName,
    String? vendorCompanyName,
    String? email,
    bool? isActive,
  }) {
    return Vendor(
      vendorId: vendorId ?? this.vendorId,
      displayName: displayName ?? this.displayName,
      vendorCompanyName: vendorCompanyName ?? this.vendorCompanyName,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
    );
  }
}
