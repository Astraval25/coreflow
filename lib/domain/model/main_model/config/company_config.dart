class CompanyConfig {
  final Map<String, String> values;

  CompanyConfig({required this.values});

  factory CompanyConfig.fromJson(Map<String, dynamic> json) {
    return CompanyConfig(
      values: json.map((key, value) => MapEntry(key, value?.toString() ?? '')),
    );
  }

  String? get salesOrderPrefix => values['sales_order_prefix'];
  String? get purchaseOrderPrefix => values['purchase_order_prefix'];
  String? get paymentOutPrefix => values['payment_out_prefix'];
  String? get paymentInPrefix => values['payment_in_prefix'];
  String? get numberFormat => values['number_format'];
  String? get seqPadding => values['seq_padding'];
}
