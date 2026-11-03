// To parse this JSON data, do
//
//     final dprPreviewHtml = dprPreviewHtmlFromJson(jsonString);

import 'dart:convert';

DprPreviewHtml dprPreviewHtmlFromJson(String str) =>
    DprPreviewHtml.fromJson(json.decode(str));

String dprPreviewHtmlToJson(DprPreviewHtml data) => json.encode(data.toJson());

class DprPreviewHtml {
  ResponseDprPreviewHtml? response;

  DprPreviewHtml({
    this.response,
  });

  factory DprPreviewHtml.fromJson(Map<String, dynamic> json) => DprPreviewHtml(
        response: json["Response"] == null
            ? null
            : ResponseDprPreviewHtml.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseDprPreviewHtml {
  String? errorCode;
  String? msg;
  String? dprHtml;
  String? filePath;
  String? fileName;

  ResponseDprPreviewHtml({
    this.errorCode,
    this.msg,
    this.dprHtml,
    this.filePath,
    this.fileName,
  });

  factory ResponseDprPreviewHtml.fromJson(Map<String, dynamic> json) =>
      ResponseDprPreviewHtml(
        errorCode: json["error_code"],
        msg: json["msg"],
        dprHtml: json["dpr_html"],
        filePath: json["filePath"],
        fileName: json["fileName"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "dpr_html": dprHtml,
        "filePath": filePath,
        "fileName": fileName,
      };
}
