// To parse this JSON data, do
//
//     final laedOtherAdd = laedOtherAddFromJson(jsonString);

import 'dart:convert';

LaedOtherAdd laedOtherAddFromJson(String str) =>
    LaedOtherAdd.fromJson(json.decode(str));

String laedOtherAddToJson(LaedOtherAdd data) => json.encode(data.toJson());

class LaedOtherAdd {
  LaedOtherAddResponse? response;

  LaedOtherAdd({
    this.response,
  });

  factory LaedOtherAdd.fromJson(Map<String, dynamic> json) => LaedOtherAdd(
        response: json["Response"] == null
            ? null
            : LaedOtherAddResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class LaedOtherAddResponse {
  String? errorCode;
  String? msg;
  int? id;

  LaedOtherAddResponse({
    this.errorCode,
    this.msg,
    this.id,
  });

  factory LaedOtherAddResponse.fromJson(Map<String, dynamic> json) =>
      LaedOtherAddResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "id": id,
      };
}
