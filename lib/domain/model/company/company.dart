class Company {
  final int companyId;
  final String companyName;
  final String industry;
  final String? shortName;
  final String? pan;
  final String? gstNo;
  final String? hsnCode;
  final bool isActive;

  Company({
    required this.companyId,
    required this.companyName,
    required this.industry,
    this.shortName,
    this.pan,
    this.gstNo,
    this.hsnCode,
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
    };
  }
}
