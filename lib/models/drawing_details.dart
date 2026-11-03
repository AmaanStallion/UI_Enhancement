// To parse this JSON data, do
//
//     final drawingDetails = drawingDetailsFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_project_masonry.dart';

DrawingDetails drawingDetailsFromJson(String str) =>
    DrawingDetails.fromJson(json.decode(str));

String drawingDetailsToJson(DrawingDetails data) => json.encode(data.toJson());

class DrawingDetails {
  DrawingDetailsResponse? response;

  DrawingDetails({
    this.response,
  });

  factory DrawingDetails.fromJson(Map<String, dynamic> json) => DrawingDetails(
        response: json["Response"] == null
            ? null
            : DrawingDetailsResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class DrawingDetailsResponse {
  String? errorCode;
  String? msg;
  List<DrawingVersion>? drawings;
  String? documentPath;
  String? drawingFlag;

  DrawingDetailsResponse({
    this.errorCode,
    this.msg,
    this.drawings,
    this.documentPath,
    this.drawingFlag,
  });

  factory DrawingDetailsResponse.fromJson(Map<String, dynamic> json) =>
      DrawingDetailsResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        drawings: json["drawings"] == null
            ? []
            : List<DrawingVersion>.from(
                json["drawings"]!.map((x) => DrawingVersion.fromJson(x))),
        documentPath: json["document_path"],
        drawingFlag: json["drawing_flag"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "drawings": drawings == null
            ? []
            : List<dynamic>.from(drawings!.map((x) => x.toJson())),
        "document_path": documentPath,
        "drawing_flag": drawingFlag,
      };
}
