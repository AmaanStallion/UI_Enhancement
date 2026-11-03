// To parse this JSON data, do
//
//     final leadPhoneNumberResponse = leadPhoneNumberResponseFromJson(jsonString);

import 'dart:convert';

LeadPhoneNumberResponse leadPhoneNumberResponseFromJson(String str) =>
    LeadPhoneNumberResponse.fromJson(json.decode(str));

String leadPhoneNumberResponseToJson(LeadPhoneNumberResponse data) =>
    json.encode(data.toJson());

class LeadPhoneNumberResponse {
  ResponseLeadPhoneNumberResponse? response;

  LeadPhoneNumberResponse({
    this.response,
  });

  factory LeadPhoneNumberResponse.fromJson(Map<String, dynamic> json) =>
      LeadPhoneNumberResponse(
        response: json["Response"] == null
            ? null
            : ResponseLeadPhoneNumberResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseLeadPhoneNumberResponse {
  String? errorCode;
  String? msg;

  ResponseLeadPhoneNumberResponse({
    this.errorCode,
    this.msg,
  });

  factory ResponseLeadPhoneNumberResponse.fromJson(Map<String, dynamic> json) =>
      ResponseLeadPhoneNumberResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
      };
}
