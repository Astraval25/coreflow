import 'package:coreflow/domain/model/customer/customer_edit_request.dart';

class CreateCustomerRequest {
  final String customerName;
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

  CreateCustomerRequest({
    required this.customerName,
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
    'customerName': customerName,
    'displayName': displayName,
    'email': email,
    'phone': phone,
    'lang': 'en',
    'pan': pan,
    'gst': gst,
    'advanceAmount': advanceAmount,
    'sameAsBillingAddress': sameAsBillingAddress,
    if (billingAddress != null) 'billingAddress': billingAddress!.toJson(),
    'shippingAddress': shippingAddress.toJson(),
  };
}
