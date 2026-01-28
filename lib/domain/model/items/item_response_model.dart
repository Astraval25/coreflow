import 'item.dart';

class ItemResponseModel {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final List<Item> responseData;

  ItemResponseModel({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    required this.responseData,
  });

  factory ItemResponseModel.fromJson(Map<String, dynamic> json) {
    return ItemResponseModel(
      responseStatus: json['responseStatus'],
      responseCode: json['responseCode'],
      responseMessage: json['responseMessage'],
      responseData: (json['responseData'] as List)
          .map((e) => Item.fromJson(e))
          .toList(),
    );
  }
}
