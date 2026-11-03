// To parse this JSON data, do
//
//     final getAvailableInventeryPdf = getAvailableInventeryPdfFromJson(jsonString);

import 'dart:convert';

GetAvailableInventeryPdf getAvailableInventeryPdfFromJson(String str) =>
    GetAvailableInventeryPdf.fromJson(json.decode(str));

String getAvailableInventeryPdfToJson(GetAvailableInventeryPdf data) =>
    json.encode(data.toJson());

class GetAvailableInventeryPdf {
  GetAvailableInventeryPdfResponse? response;

  GetAvailableInventeryPdf({
    this.response,
  });

  factory GetAvailableInventeryPdf.fromJson(Map<String, dynamic> json) =>
      GetAvailableInventeryPdf(
        response: json["Response"] == null
            ? null
            : GetAvailableInventeryPdfResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetAvailableInventeryPdfResponse {
  String? errorCode;
  String? msg;
  String? filePath;
  String? fileName;

  GetAvailableInventeryPdfResponse({
    this.errorCode,
    this.msg,
    this.filePath,
    this.fileName,
  });

  factory GetAvailableInventeryPdfResponse.fromJson(
          Map<String, dynamic> json) =>
      GetAvailableInventeryPdfResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        filePath: json["file_path"],
        fileName: json["file_name"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "file_path": filePath,
        "file_name": fileName,
      };
}
