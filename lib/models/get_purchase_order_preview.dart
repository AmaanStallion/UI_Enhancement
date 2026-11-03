// To parse this JSON data, do
//
//     final getPoPreviewHtml = getPoPreviewHtmlFromJson(jsonString);

import 'dart:convert';

GetPoPreviewHtml getPurchaseOrderPreviewHtmlFromJson(String str) =>
    GetPoPreviewHtml.fromJson(json.decode(str));

String getPurchaseOrderPreviewHtmlToJson(GetPoPreviewHtml data) =>
    json.encode(data.toJson());

class GetPoPreviewHtml {
  GetPoPreviewHtml({
    this.response,
  });

  ResponseGetPoPreviewHtml? response;

  factory GetPoPreviewHtml.fromJson(Map<String, dynamic> json) =>
      GetPoPreviewHtml(
        response: ResponseGetPoPreviewHtml.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetPoPreviewHtml {
  ResponseGetPoPreviewHtml({
    this.poPreview,
    this.errorCode,
    this.msg,
    this.filePath,
    this.fileName,
  });

  PoPreview? poPreview;
  String? errorCode;
  String? msg;
  String? filePath;
  String? fileName;
  factory ResponseGetPoPreviewHtml.fromJson(Map<String, dynamic> json) =>
      ResponseGetPoPreviewHtml(
        poPreview: PoPreview.fromJson(json["po_preview"]),
        errorCode: json["error_code"],
        msg: json["msg"],
        filePath: json["filePath"],
        fileName: json["fileName"],
      );

  Map<String, dynamic> toJson() => {
        "po_preview": poPreview?.toJson(),
        "error_code": errorCode,
        "msg": msg,
        "filePath": filePath,
        "fileName": fileName,
      };
}

class PoPreview {
  PoPreview({
    this.content,
    this.subject,
  });

  String? content;
  String? subject;

  factory PoPreview.fromJson(Map<String, dynamic> json) => PoPreview(
        content: json["content"],
        subject: json["subject"],
      );

  Map<String, dynamic> toJson() => {
        "content": content,
        "subject": subject,
      };
}
