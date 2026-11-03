// To parse this JSON data, do
//
//     final workorderpreview = workorderpreviewFromJson(jsonString);

import 'dart:convert';

Workorderpreview workorderpreviewFromJson(String str) =>
    Workorderpreview.fromJson(json.decode(str));

String workorderpreviewToJson(Workorderpreview data) =>
    json.encode(data.toJson());

class Workorderpreview {
  Workorderpreview({
    this.response,
  });

  ResponseWorkorderpreview? response;

  factory Workorderpreview.fromJson(Map<String, dynamic> json) =>
      Workorderpreview(
        response: ResponseWorkorderpreview.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseWorkorderpreview {
  ResponseWorkorderpreview({
    this.errorCode,
    this.msg,
    this.woPreView,
    this.fileName,
    this.filePath,
  });

  String? errorCode;
  String? msg;
  String? woPreView;
  String? fileName;
  String? filePath;

  factory ResponseWorkorderpreview.fromJson(Map<String, dynamic> json) =>
      ResponseWorkorderpreview(
        errorCode: json["error_code"],
        msg: json["msg"],
        woPreView: json["wo_pre_view"],
        fileName: json["fileName"],
        filePath: json["filePath"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "wo_pre_view": woPreView,
        "fileName": fileName,
        "filePath": filePath,
      };
}
