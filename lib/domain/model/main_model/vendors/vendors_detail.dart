import 'package:coreflow/domain/model/main_model/company/company.dart';

class Address {
  final int addressId;
  final String? attentionName;
  final String? city;
  final String? country;
  final int createdBy;
  final String createdDt;
  final String? email;
  final bool isActive;
  final int lastModifiedBy;
  final String lastModifiedDt;
  final String? line1;
  final String? line2;
  final String? phone;
  final int pincode;
  final String? state;

  Address({
    required this.addressId,
    this.attentionName,
    this.city,
    this.country,
    required this.createdBy,
    required this.createdDt,
    this.email,
    required this.isActive,
    required this.lastModifiedBy,
    required this.lastModifiedDt,
    this.line1,
    this.line2,
    this.phone,
    required this.pincode,
    this.state,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['addressId'] ?? 0,
      attentionName: json['attentionName'],
      city: json['city'],
      country: json['country'],
      createdBy: json['createdBy'] ?? 0,
      createdDt: json['createdDt'] ?? '',
      email: json['email'],
      isActive: json['isActive'] ?? false,
      lastModifiedBy: json['lastModifiedBy'] ?? 0,
      lastModifiedDt: json['lastModifiedDt'] ?? '',
      line1: json['line1'],
      line2: json['line2'],
      phone: json['phone'],
      pincode: json['pincode'] ?? 0,
      state: json['state'],
    );
  }
}

class VendorsDetailResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final VendorsDetailData? responseData;

  VendorsDetailResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    this.responseData,
  });

  factory VendorsDetailResponse.fromJson(Map<String, dynamic> json) {
    return VendorsDetailResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'] != null
          ? VendorsDetailData.fromJson(json['responseData'])
          : null,
    );
  }
}

class VendorsDetailData {
  final int vendorId;
  final Company company;
  final VendorCompany? vendorCompany;
  final int? acceptedInvitationId;
  final String vendorName;
  final String displayName;
  final String? email;
  final String? phone;
  final String? lang;
  final String? pan;
  final String? gst;
  final double? dueAmount;
  final bool sameAsBillingAddress;
  final Address? billingAddress;
  final Address? shippingAddress;
  final bool isActive;
  final int createdBy;
  final String createdDt;
  final int lastModifiedBy;
  final String lastModifiedDt;

  VendorsDetailData({
    required this.vendorId,
    required this.company,
    this.vendorCompany,
    this.acceptedInvitationId,
    required this.vendorName,
    required this.displayName,
    this.email,
    this.phone,
    this.lang,
    this.pan,
    this.gst,
    this.dueAmount,
    required this.sameAsBillingAddress,
    this.billingAddress,
    this.shippingAddress,
    required this.isActive,
    required this.createdBy,
    required this.createdDt,
    required this.lastModifiedBy,
    required this.lastModifiedDt,
  });

  factory VendorsDetailData.fromJson(Map<String, dynamic> json) {
    return VendorsDetailData(
      vendorId: json['vendorId'] ?? 0,
      company: Company.fromJson(json['company'] ?? {}),
      vendorCompany: json['vendorCompany'] != null
          ? VendorCompany.fromJson(json['vendorCompany'])
          : null,
      acceptedInvitationId: json['acceptedInvitationId'] != null
          ? int.tryParse(json['acceptedInvitationId'].toString())
          : null,
      vendorName: json['vendorName'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'],
      phone: json['phone'],
      lang: json['lang'],
      pan: json['pan'],
      gst: json['gst'],
      dueAmount: _parseDouble(json['dueAmount']),
      sameAsBillingAddress: json['sameAsBillingAddress'] ?? false,

      billingAddress: json['billingAddrId'] != null
          ? Address.fromJson(json['billingAddrId'])
          : null,
      shippingAddress: json['shippingAddrId'] != null
          ? Address.fromJson(json['shippingAddrId'])
          : null,
      isActive: json['isActive'] ?? false,
      createdBy: json['createdBy'] ?? 0,
      createdDt: json['createdDt'] ?? '',
      lastModifiedBy: json['lastModifiedBy'] ?? 0,
      lastModifiedDt: json['lastModifiedDt'] ?? '',
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class VendorCompany {
  final int? companyId;
  final String? companyName;

  VendorCompany({this.companyId, this.companyName});

  factory VendorCompany.fromJson(Map<String, dynamic> json) {
    return VendorCompany(
      companyId: json['companyId'],
      companyName: json['companyName'],
    );
  }
}
