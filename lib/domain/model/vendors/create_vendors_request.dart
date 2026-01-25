import 'package:coreflow/domain/model/customer/customer_edit_request.dart';

class CreateVendorsRequest {
  final String vendorName;
  final String displayName;
  final String? email;
  final String? phone;
  final String? lang;
  final String? pan;
  final String? gst;
  final double dueAmount;
  final bool sameAsBillingAddress;
  final BillingAddress? billingAddress;
  final ShippingAddress shippingAddress;

  CreateVendorsRequest({
    required this.vendorName,
    required this.displayName,
    this.email,
    this.phone,
    this.lang,
    this.pan,
    this.gst,
    this.dueAmount = 0.0,
    this.sameAsBillingAddress = false,
    this.billingAddress,
    required this.shippingAddress,
  });

  Map<String, dynamic> toJson() => {
    'vendorName': vendorName,
    'displayName': displayName,
    'email': email,
    'phone': phone,
    'lang': lang,
    'pan': pan,
    'gst': gst,
    'dueAmount': dueAmount,
    'sameAsBillingAddress': sameAsBillingAddress,
    if (billingAddress != null) 'billingAddress': billingAddress!.toJson(),
    'shippingAddress': shippingAddress.toJson(),
  };
}
