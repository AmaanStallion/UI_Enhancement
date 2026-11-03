// To parse this JSON data, do
//
//     final sopDocUpload = sopDocUploadFromJson(jsonString);

import 'dart:convert';

SopDocUpload sopDocUploadFromJson(String str) =>
    SopDocUpload.fromJson(json.decode(str));

String sopDocUploadToJson(SopDocUpload data) => json.encode(data.toJson());

class SopDocUpload {
  SopDocUploadResponse? response;

  SopDocUpload({
    this.response,
  });

  factory SopDocUpload.fromJson(Map<String, dynamic> json) => SopDocUpload(
        response: json["Response"] == null
            ? null
            : SopDocUploadResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class SopDocUploadResponse {
  String? errorCode;
  String? msg;
  String? fileName;
  String? filePath;

  SopDocUploadResponse({
    this.errorCode,
    this.msg,
    this.fileName,
    this.filePath,
  });

  factory SopDocUploadResponse.fromJson(Map<String, dynamic> json) =>
      SopDocUploadResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        fileName: json["file_name"],
        filePath: json["file_path"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "file_name": fileName,
        "file_path": filePath,
      };
}
