import 'item.dart';

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
      responseData: DetailItem.fromJson(
        json['responseData'] as Map<String, dynamic>,
      ),
    );
  }
}

class DetailItem {
  final int createdBy;
  final String createdDt;
  final String hsnCode;
  final bool isActive;
  final bool isPurchasable;
  final bool isSellable;
  final int itemId;
  final String? itemImage;
  final String itemName;
  final String itemType;
  final int lastModifiedBy;
  final String lastModifiedDt;

  final String? purchaseDescription;
  final double? basePurchasePrice;
  final String? salesDescription;
  final double? baseSalesPrice;
  final double? taxRate;
  final String? unit;

  DetailItem({
    required this.createdBy,
    required this.createdDt,
    required this.hsnCode,
    required this.isActive,
    required this.isPurchasable,
    required this.isSellable,
    required this.itemId,
    this.itemImage,
    required this.itemName,
    required this.itemType,
    required this.lastModifiedBy,
    required this.lastModifiedDt,
    this.purchaseDescription,
    this.basePurchasePrice,
    this.salesDescription,
    this.baseSalesPrice,
    this.taxRate,
    this.unit,
  });

  Item toItem() {
    return Item(
      itemId: itemId,
      itemName: itemName,
      itemType: itemType,
      unit: unit ?? '',
      baseSalesPrice: baseSalesPrice ?? 0.0,
      basePurchasePrice: basePurchasePrice,
      salesDescription: salesDescription,
      purchaseDescription: purchaseDescription,
      hsnCode: hsnCode.trim().isEmpty ? null : hsnCode.trim(),
      taxRate: taxRate,
      isActive: isActive,
      isSellable: isSellable,
      isPurchasable: isPurchasable,
    );
  }

  factory DetailItem.fromJson(Map<String, dynamic> json) {
    return DetailItem(
      createdBy: json['createdBy'] ?? 0,
      createdDt: json['createdDt'] ?? '',
      hsnCode: json['hsnCode'] ?? '',
      isActive: json['isActive'] ?? true,
      isPurchasable: json['isPurchasable'] ?? true,
      isSellable: json['isSellable'] ?? true,
      itemId: json['itemId'] ?? 0,
      itemImage: json['itemImage'],
      itemName: json['itemName'] ?? '',
      itemType: json['itemType'] ?? 'PRODUCT',
      lastModifiedBy: json['lastModifiedBy'] ?? 0,
      lastModifiedDt: json['lastModifiedDt'] ?? '',
      purchaseDescription: json['purchaseDescription'],
      basePurchasePrice: (json['basePurchasePrice'] as num?)?.toDouble(),
      salesDescription: json['salesDescription'],
      baseSalesPrice: (json['baseSalesPrice'] as num?)?.toDouble(),
      taxRate: (json['taxRate'] as num?)?.toDouble(),
      unit: json['unit'],
    );
  }
}
