class Item {
  final int itemId;
  final String itemName;
  final String itemType;
  final String unit;
  final double baseSalesPrice;
  final double? basePurchasePrice;
  final bool isActive;
  final bool isSellable;
  final bool isPurchasable;

  Item({
    required this.itemId,
    required this.itemName,
    required this.itemType,
    required this.unit,
    required this.baseSalesPrice,
    this.basePurchasePrice,
    required this.isActive,
    required this.isSellable,
    required this.isPurchasable,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json['itemId'],
      itemName: json['itemName'],
      itemType: json['itemType'],
      unit: json['unit'],
      baseSalesPrice: (json['baseSalesPrice'] as num).toDouble(),
      basePurchasePrice: json['basePurchasePrice'] != null
          ? (json['basePurchasePrice'] as num).toDouble()
          : null,
      isActive: json['isActive'],
      isSellable: json['isSellable'],
      isPurchasable: json['isPurchasable'],
    );
  }
}
