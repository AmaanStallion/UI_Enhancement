// To parse this JSON data, do
//
//     final uploadPermissionDiagraMResponse = uploadPermissionDiagraMResponseFromJson(jsonString);

import 'dart:convert';

UploadPermissionDiagraMResponse uploadPermissionDiagraMResponseFromJson(
        String str) =>
    UploadPermissionDiagraMResponse.fromJson(json.decode(str));

String uploadPermissionDiagraMResponseToJson(
        UploadPermissionDiagraMResponse data) =>
    json.encode(data.toJson());

class UploadPermissionDiagraMResponse {
  final UploadPermissionDiagraMResponseResponse? response;

  UploadPermissionDiagraMResponse({
    this.response,
  });

  factory UploadPermissionDiagraMResponse.fromJson(Map<String, dynamic> json) =>
      UploadPermissionDiagraMResponse(
        response: json["Response"] == null
            ? null
            : UploadPermissionDiagraMResponseResponse.fromJson(
                json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class UploadPermissionDiagraMResponseResponse {
  final String? errorCode;
  final String? msg;
  final String? documentName;

  UploadPermissionDiagraMResponseResponse({
    this.errorCode,
    this.msg,
    this.documentName,
  });

  factory UploadPermissionDiagraMResponseResponse.fromJson(
          Map<String, dynamic> json) =>
      UploadPermissionDiagraMResponseResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        documentName: json["document_name"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "document_name": documentName,
      };
}
