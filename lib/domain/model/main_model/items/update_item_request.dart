class UpdateItemRequest {
  final String? itemName;
  final String? itemType;
  final String? unit;
  final bool? isSellable;
  final bool? isPurchasable;
  final String? salesDescription;
  final double? baseSalesPrice;
  final String? purchaseDescription;
  final double? basePurchasePrice;
  final String? hsnCode;
  final double? taxRate;

  UpdateItemRequest({
    this.itemName,
    this.itemType,
    this.unit,
    this.isSellable,
    this.isPurchasable,
    this.salesDescription,
    this.baseSalesPrice,
    this.purchaseDescription,
    this.basePurchasePrice,
    this.hsnCode,
    this.taxRate,
  });

  Map<String, String> toFormData() {
    final Map<String, String> data = {};

    if (itemName != null) data['itemName'] = itemName!;
    if (itemType != null) data['itemType'] = itemType!;
    if (unit != null) data['unit'] = unit!;
    if (isSellable != null) data['isSellable'] = isSellable.toString();
    if (isPurchasable != null) {
      data['isPurchasable'] = isPurchasable.toString();
    }
    if (salesDescription != null) {
      data['salesDescription'] = salesDescription!;
    }
    if (baseSalesPrice != null) {
      data['baseSalesPrice'] = baseSalesPrice.toString();
    }
    if (purchaseDescription != null) {
      data['purchaseDescription'] = purchaseDescription!;
    }
    if (basePurchasePrice != null) {
      data['basePurchasePrice'] = basePurchasePrice.toString();
    }
    if (hsnCode != null) data['hsnCode'] = hsnCode!;
    if (taxRate != null) data['taxRate'] = taxRate.toString();

    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (itemName != null) json['itemName'] = itemName;
    if (itemType != null) json['itemType'] = itemType;
    if (unit != null) json['unit'] = unit;
    if (isSellable != null) json['isSellable'] = isSellable;
    if (isPurchasable != null) json['isPurchasable'] = isPurchasable;
    if (salesDescription != null) json['salesDescription'] = salesDescription;
    if (baseSalesPrice != null) json['baseSalesPrice'] = baseSalesPrice;
    if (purchaseDescription != null) {
      json['purchaseDescription'] = purchaseDescription;
    }
    if (basePurchasePrice != null) {
      json['basePurchasePrice'] = basePurchasePrice;
    }
    if (hsnCode != null) json['hsnCode'] = hsnCode;
    if (taxRate != null) json['taxRate'] = taxRate;

    return json;
  }
}
