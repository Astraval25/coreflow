import 'package:coreflow/domain/model/company/company.dart';

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

class CustomerDetailResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final CustomerDetailData? responseData;

  CustomerDetailResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    this.responseData,
  });

  factory CustomerDetailResponse.fromJson(Map<String, dynamic> json) {
    return CustomerDetailResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'] != null 
          ? CustomerDetailData.fromJson(json['responseData'])
          : null,
    );
  }
}

class CustomerDetailData {
  final int customerId;
  final Company company;
  final CustomerCompany? customerCompany;
  final int? acceptedInvitationId;
  final String customerName;
  final String displayName;
  final String? email;
  final String? phone;
  final String? lang;
  final String? pan;
  final String? gst;
  final double? advanceAmount;
  final bool sameAsBillingAddress;
  final Address? billingAddress;    
  final Address? shippingAddress;     
  final bool isActive;
  final int createdBy;
  final String createdDt;
  final int lastModifiedBy;
  final String lastModifiedDt;

  CustomerDetailData({
    required this.customerId,
    required this.company,
    this.customerCompany,
    this.acceptedInvitationId,
    required this.customerName,
    required this.displayName,
    this.email,
    this.phone,
    this.lang,
    this.pan,
    this.gst,
    this.advanceAmount,
    required this.sameAsBillingAddress,
    this.billingAddress,             
    this.shippingAddress,            
    required this.isActive,
    required this.createdBy,
    required this.createdDt,
    required this.lastModifiedBy,
    required this.lastModifiedDt,
  });

  factory CustomerDetailData.fromJson(Map<String, dynamic> json) {
    return CustomerDetailData(
      customerId: json['customerId'] ?? 0,
      company: Company.fromJson(json['company'] ?? {}),
      customerCompany: json['customerCompany'] != null
          ? CustomerCompany.fromJson(json['customerCompany'])
          : null,
      acceptedInvitationId: json['acceptedInvitationId'],
      customerName: json['customerName'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'],
      phone: json['phone'],
      lang: json['lang'],
      pan: json['pan'],
      gst: json['gst'],
      advanceAmount: _parseDouble(json['advanceAmount']),
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

class CustomerCompany {
  final int? companyId;
  final String? companyName;

  CustomerCompany({this.companyId, this.companyName});

  factory CustomerCompany.fromJson(Map<String, dynamic> json) {
    return CustomerCompany(
      companyId: json['companyId'],
      companyName: json['companyName'],
    );
  }
}
