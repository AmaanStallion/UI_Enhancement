// To parse this JSON data, do
//
//     final webgetSalePreview = webgetSalePreviewFromJson(jsonString);

import 'dart:convert';

WebgetSalePreview webgetSalePreviewFromJson(String str) =>
    WebgetSalePreview.fromJson(json.decode(str));

String webgetSalePreviewToJson(WebgetSalePreview data) =>
    json.encode(data.toJson());

class WebgetSalePreview {
  ResponseWebgetSalePreview? response;

  WebgetSalePreview({
    this.response,
  });

  factory WebgetSalePreview.fromJson(Map<String, dynamic> json) =>
      WebgetSalePreview(
        response: json["Response"] == null
            ? null
            : ResponseWebgetSalePreview.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseWebgetSalePreview {
  String? msg;
  String? errorCode;
  BeforeSellTemplate? beforeSellTemplate;
  String? filePath;
  String? fileName;

  ResponseWebgetSalePreview({
    this.msg,
    this.errorCode,
    this.beforeSellTemplate,
    this.filePath,
    this.fileName,
  });

  factory ResponseWebgetSalePreview.fromJson(Map<String, dynamic> json) =>
      ResponseWebgetSalePreview(
        msg: json["msg"],
        errorCode: json["error_code"],
        beforeSellTemplate: json["before_sell_template"] == null
            ? null
            : BeforeSellTemplate.fromJson(json["before_sell_template"]),
        filePath: json["filePath"],
        fileName: json["fileName"],
      );

  Map<String, dynamic> toJson() => {
        "msg": msg,
        "error_code": errorCode,
        "before_sell_template": beforeSellTemplate?.toJson(),
        "filePath": filePath,
        "fileName": fileName,
      };
}

class BeforeSellTemplate {
  String? subject;
  String? content;

  BeforeSellTemplate({
    this.subject,
    this.content,
  });

  factory BeforeSellTemplate.fromJson(Map<String, dynamic> json) =>
      BeforeSellTemplate(
        subject: json["subject"],
        content: json["content"],
      );

  Map<String, dynamic> toJson() => {
        "subject": subject,
        "content": content,
      };
}
