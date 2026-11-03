// To parse this JSON data, do
//
//     final slaseLeadPdf = slaseLeadPdfFromJson(jsonString);

import 'dart:convert';

SlaseLeadPdf slaseLeadPdfFromJson(String str) =>
    SlaseLeadPdf.fromJson(json.decode(str));

String slaseLeadPdfToJson(SlaseLeadPdf data) => json.encode(data.toJson());

class SlaseLeadPdf {
  SlaseLeadPdfResponse? response;

  SlaseLeadPdf({
    this.response,
  });

  factory SlaseLeadPdf.fromJson(Map<String, dynamic> json) => SlaseLeadPdf(
        response: json["Response"] == null
            ? null
            : SlaseLeadPdfResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class SlaseLeadPdfResponse {
  String? errorCode;
  String? msg;
  Filename? filename;

  SlaseLeadPdfResponse({
    this.errorCode,
    this.msg,
    this.filename,
  });

  factory SlaseLeadPdfResponse.fromJson(Map<String, dynamic> json) =>
      SlaseLeadPdfResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        filename: json["filename"] == null
            ? null
            : Filename.fromJson(json["filename"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "filename": filename?.toJson(),
      };
}

class Filename {
  String? filePath;
  String? fileName;

  Filename({
    this.filePath,
    this.fileName,
  });

  factory Filename.fromJson(Map<String, dynamic> json) => Filename(
        filePath: json["filePath"],
        fileName: json["fileName"],
      );

  Map<String, dynamic> toJson() => {
        "filePath": filePath,
        "fileName": fileName,
      };
}
