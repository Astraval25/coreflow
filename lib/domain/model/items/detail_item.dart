<<<<<<< HEAD
import 'item.dart';

=======
>>>>>>> main
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
<<<<<<< HEAD
      responseData: DetailItem.fromJson(
        json['responseData'] as Map<String, dynamic>,
      ),
=======
      responseData: DetailItem.fromJson(json['responseData'] as Map<String, dynamic>),
>>>>>>> main
    );
  }
}

class DetailItem {
  final int createdBy;
  final String createdDt;
  final String hsnCode;
  final bool isActive;
<<<<<<< HEAD
  final bool isPurchasable;
  final bool isSellable;
=======
>>>>>>> main
  final int itemId;
  final String? itemImage;
  final String itemName;
  final String itemType;
  final int lastModifiedBy;
  final String lastModifiedDt;
<<<<<<< HEAD

  final String? purchaseDescription;
  final double? basePurchasePrice;
  final String? salesDescription;
  final double? baseSalesPrice;
=======
  final String? preferredCustomer;
  final String? preferredCustomerDisplayName;
  final int? preferredCustomerId;
  final String? preferredVendorDisplayName;
  final int? preferredVendorId;
  final String? purchaseDescription;
  final double? purchasePrice;
  final String? salesDescription;
  final double? salesPrice;
>>>>>>> main
  final double? taxRate;
  final String? unit;

  DetailItem({
    required this.createdBy,
    required this.createdDt,
    required this.hsnCode,
    required this.isActive,
<<<<<<< HEAD
    required this.isPurchasable,
    required this.isSellable,
=======
>>>>>>> main
    required this.itemId,
    this.itemImage,
    required this.itemName,
    required this.itemType,
    required this.lastModifiedBy,
    required this.lastModifiedDt,
<<<<<<< HEAD
    this.purchaseDescription,
    this.basePurchasePrice,
    this.salesDescription,
    this.baseSalesPrice,
=======
    this.preferredCustomer,
    this.preferredCustomerDisplayName,
    this.preferredCustomerId,
    this.preferredVendorDisplayName,
    this.preferredVendorId,
    this.purchaseDescription,
    this.purchasePrice,
    this.salesDescription,
    this.salesPrice,
>>>>>>> main
    this.taxRate,
    this.unit,
  });

<<<<<<< HEAD
  Item toItem() {
    return Item(
      itemId: itemId,
      itemName: itemName,
      itemType: itemType,
      unit: unit ?? 'Unit',
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
=======
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
>>>>>>> main
    );
  }
}
