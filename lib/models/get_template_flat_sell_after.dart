// To parse this JSON data, do
//
//     final getFlatTemplateAfter = getFlatTemplateAfterFromJson(jsonString);

import 'dart:convert';

GetFlatTemplateAfter getFlatTemplateAfterFromJson(String str) =>
    GetFlatTemplateAfter.fromJson(json.decode(str));

String getFlatTemplateAfterToJson(GetFlatTemplateAfter data) =>
    json.encode(data.toJson());

class GetFlatTemplateAfter {
  ResponseGetFlatTemplateAfter? response;

  GetFlatTemplateAfter({
    this.response,
  });

  factory GetFlatTemplateAfter.fromJson(Map<String, dynamic> json) =>
      GetFlatTemplateAfter(
        response: json["Response"] == null
            ? null
            : ResponseGetFlatTemplateAfter.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetFlatTemplateAfter {
  String? errorCode;
  String? msg;
  String? afterTempSell;
  String? filePath;
  String? fileName;
  String? parkingSoldMessage;

  ResponseGetFlatTemplateAfter({
    this.errorCode,
    this.msg,
    this.afterTempSell,
    this.filePath,
    this.fileName,
    this.parkingSoldMessage,
  });

  factory ResponseGetFlatTemplateAfter.fromJson(Map<String, dynamic> json) =>
      ResponseGetFlatTemplateAfter(
        errorCode: json["error_code"],
        msg: json["msg"],
        afterTempSell: json["after_temp_sell"],
        filePath: json["filePath"],
        fileName: json["fileName"],
        parkingSoldMessage: json["parking_sold_message"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "after_temp_sell": afterTempSell,
        "filePath": filePath,
        "fileName": fileName,
        "parking_sold_message": parkingSoldMessage,
      };
}
