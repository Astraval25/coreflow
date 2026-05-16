class Company {
  final int companyId;
  final String companyName;
  final String industry;
  final String? shortName;
  final String? pan;
  final String? gstNo;
  final String? hsnCode;
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
  final bool isActive;

  Company({
    required this.companyId,
    required this.companyName,
    required this.industry,
    this.shortName,
    this.pan,
    this.gstNo,
    this.hsnCode,
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
    required this.isActive,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyId: json['companyId'] ?? 0,
      companyName: json['companyName'] ?? '',
      industry: json['industry'] ?? '',
      shortName: json['shortName'],
      pan: json['pan'],
      gstNo: json['gstNo'],
      hsnCode: json['hsnCode'],
      fsId: json['fsId'],
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
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'companyName': companyName,
      'industry': industry,
      'shortName': shortName,
      'pan': pan,
      'gstNo': gstNo,
      'hsnCode': hsnCode,
      'fsId': fsId,
      'contactPerson': contactPerson,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'website': website,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'publicDescription': publicDescription,
      'isActive': isActive,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'companyName': companyName,
      'industry': industry,
      'pan': pan,
      'gstNo': gstNo,
      'hsnCode': hsnCode,
      'shortName': shortName,
      'contactPerson': contactPerson,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'website': website,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'publicDescription': publicDescription,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'companyName': companyName,
      'industry': industry,
      'pan': pan,
      'gstNo': gstNo,
      'hsnCode': hsnCode,
      'shortName': shortName,
      'contactPerson': contactPerson,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'website': website,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'publicDescription': publicDescription,
    };
  }
}
