class ItemResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final DetailItem responseData;

  ItemResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });

  factory ItemResponse.fromJson(Map<String, dynamic> json) {
    return ItemResponse(
      responseStatus: json['responseStatus'] as bool,
      responseCode: json['responseCode'] as int,
      responseMessage: json['responseMessage'] as String,
      responseData: DetailItem.fromJson(json['responseData'] as Map<String, dynamic>),
    );
  }
}

class DetailItem {
  final int createdBy;
  final String createdDt;
  final String hsnCode;
  final bool isActive;
  final int itemId;
  final String? itemImage;
  final String itemName;
  final String itemType;
  final int lastModifiedBy;
  final String lastModifiedDt;
  final String? preferredCustomer;
  final String? preferredCustomerDisplayName;
  final int? preferredCustomerId;
  final String? preferredVendorDisplayName;
  final int? preferredVendorId;
  final String? purchaseDescription;
  final double? purchasePrice;
  final String? salesDescription;
  final double? salesPrice;
  final double? taxRate;
  final String? unit;

  DetailItem({
    required this.createdBy,
    required this.createdDt,
    required this.hsnCode,
    required this.isActive,
    required this.itemId,
    this.itemImage,
    required this.itemName,
    required this.itemType,
    required this.lastModifiedBy,
    required this.lastModifiedDt,
    this.preferredCustomer,
    this.preferredCustomerDisplayName,
    this.preferredCustomerId,
    this.preferredVendorDisplayName,
    this.preferredVendorId,
    this.purchaseDescription,
    this.purchasePrice,
    this.salesDescription,
    this.salesPrice,
    this.taxRate,
    this.unit,
  });

  factory DetailItem.fromJson(Map<String, dynamic> json) {
    return DetailItem(
      createdBy: json['createdBy'] as int,
      createdDt: json['createdDt'] as String,
      hsnCode: json['hsnCode'] as String,
      isActive: json['isActive'] as bool,
      itemId: json['itemId'] as int,
      itemImage: json['itemImage'] as String?,
      itemName: json['itemName'] as String,
      itemType: json['itemType'] as String,
      lastModifiedBy: json['lastModifiedBy'] as int,
      lastModifiedDt: json['lastModifiedDt'] as String,
      preferredCustomer: json['preferredCustomer'] as String?,
      preferredCustomerDisplayName: json['preferredCustomerDisplayName'] as String?,
      preferredCustomerId: json['preferredCustomerId'] as int?,
      preferredVendorDisplayName: json['preferredVendorDisplayName'] as String?,
      preferredVendorId: json['preferredVendorId'] as int?,
      purchaseDescription: json['purchaseDescription'] as String?,
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
      salesDescription: json['salesDescription'] as String?,
      salesPrice: (json['salesPrice'] as num?)?.toDouble(),
      taxRate: (json['taxRate'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );
  }
}
