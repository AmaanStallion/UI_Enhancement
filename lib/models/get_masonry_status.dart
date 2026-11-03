// To parse this JSON data, do
//
//     final getMasonryStatus = getMasonryStatusFromJson(jsonString);

import 'dart:convert';

GetMasonryStatus getMasonryStatusFromJson(String str) =>
    GetMasonryStatus.fromJson(json.decode(str));

String getMasonryStatusToJson(GetMasonryStatus data) =>
    json.encode(data.toJson());

class GetMasonryStatus {
  GetMasonryStatusResponse? response;

  GetMasonryStatus({
    this.response,
  });

  factory GetMasonryStatus.fromJson(Map<String, dynamic> json) =>
      GetMasonryStatus(
        response: json["Response"] == null
            ? null
            : GetMasonryStatusResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetMasonryStatusResponse {
  String? errorCode;
  String? msg;
  List<MasonryReport>? masonryReport;
  String? expire;

  GetMasonryStatusResponse({
    this.errorCode,
    this.msg,
    this.masonryReport,
    this.expire,
  });

  factory GetMasonryStatusResponse.fromJson(Map<String, dynamic> json) =>
      GetMasonryStatusResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        masonryReport: json["masonry_report"] == null
            ? []
            : List<MasonryReport>.from(
                json["masonry_report"]!.map((x) => MasonryReport.fromJson(x))),
        expire: json["expire"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "masonry_report": masonryReport == null
            ? []
            : List<dynamic>.from(masonryReport!.map((x) => x.toJson())),
        "expire": expire,
      };
}

class MasonryReport {
  String? masonryStartDate;
  String? masonryReportReview;
  String? masonryReportOkId;
  String? submitDate;
  String? estCompletDate;
  List<String>? image;
  List<String>? reportVedio;

  MasonryReport({
    this.masonryStartDate,
    this.masonryReportReview,
    this.masonryReportOkId,
    this.submitDate,
    this.estCompletDate,
    this.image,
    this.reportVedio,
  });

  factory MasonryReport.fromJson(Map<String, dynamic> json) => MasonryReport(
        masonryStartDate: json["masonry_start_date"],
        masonryReportReview: json["masonry_report_review"],
        masonryReportOkId: json["masonry_report_ok_id"],
        submitDate: json["submit_date"],
        estCompletDate: json["est_complet_date"],
        image: json["image"] == null
            ? []
            : List<String>.from(json["image"]!.map((x) => x)),
        reportVedio: json["report_vedio"] == null
            ? []
            : List<String>.from(json["report_vedio"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "masonry_start_date": masonryStartDate,
        "masonry_report_review": masonryReportReview,
        "masonry_report_ok_id": masonryReportOkId,
        "submit_date": submitDate,
        "est_complet_date": estCompletDate,
        "image": image == null ? [] : List<dynamic>.from(image!.map((x) => x)),
        "report_vedio": reportVedio == null
            ? []
            : List<dynamic>.from(reportVedio!.map((x) => x)),
      };
}
