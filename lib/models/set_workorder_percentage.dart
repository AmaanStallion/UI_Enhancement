// To parse this JSON data, do
//
//     final workordersubmit = workordersubmitFromJson(jsonString);

import 'dart:convert';

Workordersubmit workordersubmitFromJson(String str) =>
    Workordersubmit.fromJson(json.decode(str));

String workordersubmitToJson(Workordersubmit data) =>
    json.encode(data.toJson());

class Workordersubmit {
  Workordersubmit({
    this.response,
  });

  ResponseWorkordersubmit? response;

  factory Workordersubmit.fromJson(Map<String, dynamic> json) =>
      Workordersubmit(
        response: ResponseWorkordersubmit.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseWorkordersubmit {
  ResponseWorkordersubmit({
    this.errorCode,
    this.msg,
  });

  String? errorCode;
  String? msg;

  factory ResponseWorkordersubmit.fromJson(Map<String, dynamic> json) =>
      ResponseWorkordersubmit(
        errorCode: json["error_code"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
      };
}
