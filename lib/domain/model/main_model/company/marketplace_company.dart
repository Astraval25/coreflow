class MarketplaceCompany {
  final int companyId;
  final String companyName;
  final String? industry;
  final String? shortName;
  final String? gstNo;
  final String? hsnCode;
  final String? pan;
  final bool isActive;
  final int createdBy;
  final String createdDt;
  final int lastModifiedBy;
  final String lastModifiedDt;

  MarketplaceCompany({
    required this.companyId,
    required this.companyName,
    this.industry,
    this.shortName,
    this.gstNo,
    this.hsnCode,
    this.pan,
    required this.isActive,
    required this.createdBy,
    required this.createdDt,
    required this.lastModifiedBy,
    required this.lastModifiedDt,
  });

  factory MarketplaceCompany.fromJson(Map<String, dynamic> json) {
    return MarketplaceCompany(
      companyId: json['companyId'] ?? 0,
      companyName: json['companyName'] ?? '',
      industry: json['industry'],
      shortName: json['shortName'],
      gstNo: json['gstNo'],
      hsnCode: json['hsnCode'],
      pan: json['pan'],
      isActive: json['isActive'] ?? false,
      createdBy: json['createdBy'] ?? 0,
      createdDt: json['createdDt'] ?? '',
      lastModifiedBy: json['lastModifiedBy'] ?? 0,
      lastModifiedDt: json['lastModifiedDt'] ?? '',
    );
  }

  bool get isGstVerified => gstNo != null && gstNo!.isNotEmpty;
}
