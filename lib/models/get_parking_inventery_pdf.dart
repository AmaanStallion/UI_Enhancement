// To parse this JSON data, do
//
//     final getParkingInventeryPdf = getParkingInventeryPdfFromJson(jsonString);

import 'dart:convert';

GetParkingInventeryPdf getParkingInventeryPdfFromJson(String str) =>
    GetParkingInventeryPdf.fromJson(json.decode(str));

String getParkingInventeryPdfToJson(GetParkingInventeryPdf data) =>
    json.encode(data.toJson());

class GetParkingInventeryPdf {
  GetParkingInventeryPdfResponse? response;

  GetParkingInventeryPdf({
    this.response,
  });

  factory GetParkingInventeryPdf.fromJson(Map<String, dynamic> json) =>
      GetParkingInventeryPdf(
        response: json["Response"] == null
            ? null
            : GetParkingInventeryPdfResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetParkingInventeryPdfResponse {
  String? errorCode;
  String? msg;
  String? filePath;
  String? fileName;

  GetParkingInventeryPdfResponse({
    this.errorCode,
    this.msg,
    this.filePath,
    this.fileName,
  });

  factory GetParkingInventeryPdfResponse.fromJson(Map<String, dynamic> json) =>
      GetParkingInventeryPdfResponse(
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
