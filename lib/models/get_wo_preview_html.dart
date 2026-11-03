// To parse this JSON data, do
//
//     final getWoPreviewHtml = getWoPreviewHtmlFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_po_requistion_vendor_list.dart';

GetWoPreviewHtml getWoPreviewHtmlFromJson(String str) =>
    GetWoPreviewHtml.fromJson(json.decode(str));

String getWoPreviewHtmlToJson(GetWoPreviewHtml data) =>
    json.encode(data.toJson());

class GetWoPreviewHtml {
  GetWoPreviewHtml({
    this.response,
  });

  ResponseGetWoPreviewHtml? response;

  factory GetWoPreviewHtml.fromJson(Map<String, dynamic> json) =>
      GetWoPreviewHtml(
        response: ResponseGetWoPreviewHtml.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetWoPreviewHtml {
  ResponseGetWoPreviewHtml({
    this.errorCode,
    this.msg,
    this.signatureUpload,
    this.showAccounts,
    this.woOrderHtml,
    this.woStatus,
    this.wo_pdf,
    this.wo_file_name,
    this.filePath,
    this.fileName,
    this.authorizeFlag,
    this.workUserTrack,
    this.assingToList,
  });
  String? workUserTrack;
  List<AssingToList>? assingToList;

  String? errorCode;
  String? msg;
  String? signatureUpload;
  String? showAccounts;
  String? woOrderHtml;
  String? woStatus;
  String? wo_pdf;
  String? wo_file_name;
  String? filePath;
  String? fileName;
  String? authorizeFlag;

  factory ResponseGetWoPreviewHtml.fromJson(Map<String, dynamic> json) =>
      ResponseGetWoPreviewHtml(
        errorCode: json["error_code"],
        workUserTrack: json["work_user_track"],
        assingToList: json["assing_to_list"] == null
            ? []
            : List<AssingToList>.from(
                json["assing_to_list"]!.map((x) => AssingToList.fromJson(x))),
        msg: json["msg"],
        wo_pdf: json["wo_pdf"] ?? "",
        wo_file_name: json["wo_file_name"] ?? "",
        signatureUpload: json["signature_upload"],
        showAccounts: json["show_accounts"],
        woOrderHtml: json["wo_order_html"],
        woStatus: json["wo_status"],
        filePath: json["filePath"],
        fileName: json["fileName"],
        authorizeFlag: json["authorize_flag"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "work_user_track": workUserTrack,
        "assing_to_list": assingToList == null
            ? []
            : List<dynamic>.from(assingToList!.map((x) => x.toJson())),
        "msg": msg,
        "wo_pdf": wo_pdf,
        "wo_file_name": wo_file_name,
        "signature_upload": signatureUpload,
        "show_accounts": showAccounts,
        "wo_order_html": woOrderHtml,
        "wo_status": woStatus,
        "filePath": filePath,
        "fileName": fileName,
        "authorize_flag": authorizeFlag,
      };
}
