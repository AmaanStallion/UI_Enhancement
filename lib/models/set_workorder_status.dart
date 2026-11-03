// To parse this JSON data, do
//
//     final getDefaultWorkorderQuantityCreate = getDefaultWorkorderQuantityCreateFromJson(jsonString);

import 'dart:convert';

SetWorkOrderStatus getSetWorkOrderStatusFromJson(String str) =>
    SetWorkOrderStatus.fromJson(json.decode(str));

String getSetWorkOrderStatusToJson(SetWorkOrderStatus data) =>
    json.encode(data.toJson());

class SetWorkOrderStatus {
  SetWorkOrderStatus({
    this.response,
  });

  ResponseSetWorkOrderStatus? response;

  factory SetWorkOrderStatus.fromJson(Map<String, dynamic> json) =>
      SetWorkOrderStatus(
        response: ResponseSetWorkOrderStatus.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response!.toJson(),
      };
}

class ResponseSetWorkOrderStatus {
  ResponseSetWorkOrderStatus({
    this.errorCode,
    this.msg,
  });

  String? errorCode;
  String? msg;

  factory ResponseSetWorkOrderStatus.fromJson(Map<String, dynamic> json) =>
      ResponseSetWorkOrderStatus(
        errorCode: json["error_code"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
      };
}
