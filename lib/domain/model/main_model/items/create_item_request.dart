class CreateItemRequest {
  final String itemName;
  final String itemType;
  final String? unit;
  final bool isSellable;
  final bool isPurchasable;
  final String? salesDescription;
  final double? baseSalesPrice;
  final String? purchaseDescription;
  final double? basePurchasePrice;
  final String? hsnCode;
  final double? taxRate;

  CreateItemRequest({
    required this.itemName,
    required this.itemType,
    this.unit,
    required this.isSellable,
    required this.isPurchasable,
    this.salesDescription,
    this.baseSalesPrice,
    this.purchaseDescription,
    this.basePurchasePrice,
    this.hsnCode,
    this.taxRate,
  });

  String? validate() {
    if (itemName.trim().isEmpty) {
      return 'Item name is required';
    }
    if (itemType.trim().isEmpty) {
      return 'Item type is required';
    }
    if (!isSellable && !isPurchasable) {
      return 'Select at least one: sellable or purchasable';
    }
    return null;
  }

  Map<String, String> toFormData() {
    final Map<String, String> data = {};

    data['itemName'] = itemName;
    data['itemType'] = itemType;
    data['isSellable'] = isSellable.toString();
    data['isPurchasable'] = isPurchasable.toString();

    if (unit != null) data['unit'] = unit!;
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
    return {
      "itemName": itemName,
      "itemType": itemType,
      "isSellable": isSellable,
      "isPurchasable": isPurchasable,
      if (unit != null) "unit": unit,
      if (salesDescription != null) "salesDescription": salesDescription,
      if (baseSalesPrice != null) "baseSalesPrice": baseSalesPrice,
      if (purchaseDescription != null)
        "purchaseDescription": purchaseDescription,
      if (basePurchasePrice != null) "basePurchasePrice": basePurchasePrice,
      if (hsnCode != null) "hsnCode": hsnCode,
      if (taxRate != null) "taxRate": taxRate,
    };
  }
}
