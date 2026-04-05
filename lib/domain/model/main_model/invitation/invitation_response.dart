class InvitationResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;
  final InvitationData? responseData;

  InvitationResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
    this.responseData,
  });

  factory InvitationResponse.fromJson(Map<String, dynamic> json) {
    return InvitationResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
      responseData: json['responseData'] != null
          ? InvitationData.fromJson(json['responseData'])
          : null,
    );
  }
}

class InvitationData {
  final String invitationCode;
  final String inviteId;

  InvitationData({
    required this.invitationCode,
    required this.inviteId,
  });

  factory InvitationData.fromJson(Map<String, dynamic> json) {
    return InvitationData(
      invitationCode: json['invitationCode'] ?? '',
      inviteId: json['inviteId']?.toString() ?? '',
    );
  }
}

class AcceptInvitationResponse {
  final bool responseStatus;
  final int responseCode;
  final String responseMessage;

  AcceptInvitationResponse({
    required this.responseStatus,
    required this.responseCode,
    required this.responseMessage,
  });

  factory AcceptInvitationResponse.fromJson(Map<String, dynamic> json) {
    return AcceptInvitationResponse(
      responseStatus: json['responseStatus'] ?? false,
      responseCode: json['responseCode'] ?? 0,
      responseMessage: json['responseMessage'] ?? '',
    );
  }
}
