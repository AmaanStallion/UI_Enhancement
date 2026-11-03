// To parse this JSON data, do
//
//     final poApprovedByUser = poApprovedByUserFromJson(jsonString);

import 'dart:convert';

PoApprovedByUser poApprovedByUserFromJson(String str) =>
    PoApprovedByUser.fromJson(json.decode(str));

String poApprovedByUserToJson(PoApprovedByUser data) =>
    json.encode(data.toJson());

class PoApprovedByUser {
  Response? response;

  PoApprovedByUser({
    this.response,
  });

  factory PoApprovedByUser.fromJson(Map<String, dynamic> json) =>
      PoApprovedByUser(
        response: json["Response"] == null
            ? null
            : Response.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class Response {
  String? errorCode;
  String? msg;

  Response({
    this.errorCode,
    this.msg,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        errorCode: json["error_code"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
      };
}
