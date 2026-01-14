import 'package:coreflow/domain/model/customer/customer_edit_request.dart';

class CreateVendorsRequest {
  final String vendorsName;
  final String displayName;
  final String? email;
  final String? phone;
  final String? lang;
  final String? pan;
  final String? gst;
  final double advanceAmount;
  final bool sameAsBillingAddress;
  final BillingAddress? billingAddress;
  final ShippingAddress shippingAddress;

  CreateVendorsRequest({
    required this.vendorsName,
    required this.displayName,
    this.email,
    this.phone,
    this.lang,
    this.pan,
    this.gst,
    this.advanceAmount = 0.0,
    this.sameAsBillingAddress = false,
    this.billingAddress,
    required this.shippingAddress,
  });

  Map<String, dynamic> toJson() => {
    'customerName': vendorsName,
    'displayName': displayName,
    'email': email,
    'phone': phone,
    'lang': lang,
    'pan': pan,
    'gst': gst,
    'advanceAmount': advanceAmount,
    'sameAsBillingAddress': sameAsBillingAddress,
    if (billingAddress != null) 'billingAddress': billingAddress!.toJson(),
    'shippingAddress': shippingAddress.toJson(),
  };
}
