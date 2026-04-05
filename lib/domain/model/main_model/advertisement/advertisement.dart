class Advertisement {
  final int adId;
  final String description;
  final String actionUrl;
  final String fsId;
  final String placement;
  final String companyName;
  final int companyId;
  final String itemName;
  final int itemId;
  final bool isActive;
  final String createdDt;

  Advertisement({
    required this.adId,
    required this.description,
    required this.actionUrl,
    required this.fsId,
    required this.placement,
    required this.companyName,
    required this.companyId,
    required this.itemName,
    required this.itemId,
    required this.isActive,
    required this.createdDt,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      adId: json['adId'] ?? 0,
      description: json['description'] ?? '',
      actionUrl: json['actionUrl'] ?? '',
      fsId: json['fsId'] ?? '',
      placement: json['placement'] ?? '',
      companyName: json['companyName'] ?? '',
      companyId: json['companyId'] ?? 0,
      itemName: json['itemName'] ?? '',
      itemId: json['itemId'] ?? 0,
      isActive: json['isActive'] ?? false,
      createdDt: json['createdDt'] ?? '',
    );
  }
}
