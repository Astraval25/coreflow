class CustomerEditRequest {
  final String customerName;
  final String displayName;
  final String? email;
  final String? phone;
  final String lang;
  final String? pan;
  final String? gst;
  final double? dueAmount;
  final bool sameAsBillingAddress;
  final BillingAddress? billingAddress;
  final ShippingAddress? shippingAddress;

  CustomerEditRequest({
    required this.customerName,
    required this.displayName,
    this.email,
    this.phone,
    required this.lang,
    this.pan,
    this.gst,
    this.dueAmount,
    this.sameAsBillingAddress = true,
    this.billingAddress,
    this.shippingAddress,
  });

  Map<String, dynamic> toJson() => {
    'customerName': customerName,
    'displayName': displayName,
    'email': email,
    'phone': phone,
    'lang': lang,
    'pan': pan,
    'gst': gst,
    'dueAmount': dueAmount,
    'sameAsBillingAddress': sameAsBillingAddress,
    if (billingAddress != null) 'billingAddress': billingAddress!.toJson(),
    if (shippingAddress != null) 'shippingAddress': shippingAddress!.toJson(),
  };
}

class BillingAddress {
  final String? attentionName;
  final String country;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final int pincode;
  final String? phone;
  final String? email;

  BillingAddress({
    this.attentionName,
    required this.country,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    this.phone,
    this.email,
  });

  Map<String, dynamic> toJson() => {
    'attentionName': attentionName,
    'country': country,
    'line1': line1,
    'line2': line2,
    'city': city,
    'state': state,
    'pincode': pincode,
    'phone': phone,
    'email': email,
  };
}

class ShippingAddress {
  final String? attentionName;
  final String country;
  final String line1;
  final String? line2;
  final String city;
  final String state;
  final int pincode;
  final String? phone;
  final String? email;

  ShippingAddress({
    this.attentionName,
    required this.country,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.pincode,
    this.phone,
    this.email,
  });

  Map<String, dynamic> toJson() => {
    'attentionName': attentionName,
    'country': country,
    'line1': line1,
    'line2': line2,
    'city': city,
    'state': state,
    'pincode': pincode,
    'phone': phone,
    'email': email,
  };
}
