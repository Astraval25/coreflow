class Company {
  final int companyId;
  final String companyName;
  final String industry;
  final String? shortName;
  final bool isActive;

  Company({
    required this.companyId,
    required this.companyName,
    required this.industry,
    this.shortName,
    required this.isActive,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyId: json['companyId'] ?? 0,
      companyName: json['companyName'] ?? '',
      industry: json['industry'] ?? '',
      shortName: json['shortName'],
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'companyName': companyName,
      'industry': industry,
      'shortName': shortName,
      'isActive': isActive,
    };
  }
}
