
import 'package:coreflow/domain/model/main_model/customer/customer_edit_request.dart';

class VendorsEditRequest {
  final String vendorName;
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

  VendorsEditRequest({
    required this.vendorName,
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
    if (shippingAddress != null) 'shippingAddress': shippingAddress!.toJson(),
  };
}
