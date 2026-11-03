// To parse this JSON data, do
//
//     final permissionPersionResponse = permissionPersionResponseFromJson(jsonString);

import 'dart:convert';

PermissionPersionResponse permissionPersionResponseFromJson(String str) =>
    PermissionPersionResponse.fromJson(json.decode(str));

String permissionPersionResponseToJson(PermissionPersionResponse data) =>
    json.encode(data.toJson());

class PermissionPersionResponse {
  final ResponsePermissionPersionResponse? response;

  PermissionPersionResponse({
    this.response,
  });

  factory PermissionPersionResponse.fromJson(Map<String, dynamic> json) =>
      PermissionPersionResponse(
        response: json["Response"] == null
            ? null
            : ResponsePermissionPersionResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponsePermissionPersionResponse {
  final String? errorCode;
  final String? msg;
  final RemarkData? remarkData;

  ResponsePermissionPersionResponse({
    this.errorCode,
    this.msg,
    this.remarkData,
  });

  factory ResponsePermissionPersionResponse.fromJson(
          Map<String, dynamic> json) =>
      ResponsePermissionPersionResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        remarkData: json["remark_data"] == null
            ? null
            : RemarkData.fromJson(json["remark_data"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "remark_data": remarkData?.toJson(),
      };
}

class RemarkData {
  final String? expDate;
  final String? remark;

  RemarkData({
    this.expDate,
    this.remark,
  });

  factory RemarkData.fromJson(Map<String, dynamic> json) => RemarkData(
        expDate: json["exp_date"],
        remark: json["remark"],
      );

  Map<String, dynamic> toJson() => {
        "exp_date": expDate,
        "remark": remark,
      };
}
