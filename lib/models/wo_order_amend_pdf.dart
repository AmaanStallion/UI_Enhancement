// To parse this JSON data, do
//
//     final woOrderAmendPdf = woOrderAmendPdfFromJson(jsonString);

import 'dart:convert';

WoOrderAmendPdf woOrderAmendPdfFromJson(String str) =>
    WoOrderAmendPdf.fromJson(json.decode(str));

String woOrderAmendPdfToJson(WoOrderAmendPdf data) =>
    json.encode(data.toJson());

class WoOrderAmendPdf {
  WoOrderAmendPdfResponse? response;

  WoOrderAmendPdf({
    this.response,
  });

  factory WoOrderAmendPdf.fromJson(Map<String, dynamic> json) =>
      WoOrderAmendPdf(
        response: json["Response"] == null
            ? null
            : WoOrderAmendPdfResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class WoOrderAmendPdfResponse {
  String? errorCode;
  String? msg;
  String? filePath;

  WoOrderAmendPdfResponse({
    this.errorCode,
    this.msg,
    this.filePath,
  });

  factory WoOrderAmendPdfResponse.fromJson(Map<String, dynamic> json) =>
      WoOrderAmendPdfResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        filePath: json["file_path"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "file_path": filePath,
      };
}
