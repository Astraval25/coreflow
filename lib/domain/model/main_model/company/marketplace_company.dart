class MarketplaceCompany {
  final int companyId;
  final String companyName;
  final String? industry;
  final String? shortName;
  final String? fsId;
  final String? contactPerson;
  final String? contactEmail;
  final String? contactPhone;
  final String? website;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? publicDescription;
  final String? gstNo;
  final String? hsnCode;
  final String? pan;
  final bool isActive;
  final String? createdDt;
  final String? lastModifiedDt;

  MarketplaceCompany({
    required this.companyId,
    required this.companyName,
    this.industry,
    this.shortName,
    this.fsId,
    this.contactPerson,
    this.contactEmail,
    this.contactPhone,
    this.website,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.publicDescription,
    this.gstNo,
    this.hsnCode,
    this.pan,
    this.isActive = true,
    this.createdDt,
    this.lastModifiedDt,
  });

  factory MarketplaceCompany.fromJson(Map<String, dynamic> json) {
    return MarketplaceCompany(
      companyId: json['companyId'] ?? 0,
      companyName: json['companyName'] ?? '',
      industry: json['industry'],
      shortName: json['shortName'],
      fsId: json['fsId']?.toString(),
      contactPerson: json['contactPerson']?.toString(),
      contactEmail: json['contactEmail']?.toString(),
      contactPhone: json['contactPhone']?.toString(),
      website: json['website']?.toString(),
      addressLine1: json['addressLine1']?.toString(),
      addressLine2: json['addressLine2']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      postalCode: json['postalCode']?.toString(),
      publicDescription: json['publicDescription']?.toString(),
      gstNo: json['gstNo'],
      hsnCode: json['hsnCode'],
      pan: json['pan'],
      isActive: json['isActive'] ?? true,
      createdDt: json['createdDt']?.toString(),
      lastModifiedDt: json['lastModifiedDt']?.toString(),
    );
  }

  bool get isGstVerified => gstNo != null && gstNo!.isNotEmpty;
}
