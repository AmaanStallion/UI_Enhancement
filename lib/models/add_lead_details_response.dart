// To parse this JSON data, do
//
//     final addLeadDetailsResponse = addLeadDetailsResponseFromJson(jsonString);

import 'dart:convert';

AddLeadDetailsResponse addLeadDetailsResponseFromJson(String str) =>
    AddLeadDetailsResponse.fromJson(json.decode(str));

String addLeadDetailsResponseToJson(AddLeadDetailsResponse data) =>
    json.encode(data.toJson());

class AddLeadDetailsResponse {
  ResponseAddLeadDetailsResponse? response;

  AddLeadDetailsResponse({
    this.response,
  });

  factory AddLeadDetailsResponse.fromJson(Map<String, dynamic> json) =>
      AddLeadDetailsResponse(
        response: json["Response"] == null
            ? null
            : ResponseAddLeadDetailsResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseAddLeadDetailsResponse {
  String? errorCode;
  String? msg;

  ResponseAddLeadDetailsResponse({
    this.errorCode,
    this.msg,
  });

  factory ResponseAddLeadDetailsResponse.fromJson(Map<String, dynamic> json) =>
      ResponseAddLeadDetailsResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
      };
}
