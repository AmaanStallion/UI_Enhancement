// To parse this JSON data, do
//
//     final getMasonryIssueReport = getMasonryIssueReportFromJson(jsonString);

import 'dart:convert';

GetMasonryIssueReport getMasonryIssueReportFromJson(String str) =>
    GetMasonryIssueReport.fromJson(json.decode(str));

String getMasonryIssueReportToJson(GetMasonryIssueReport data) =>
    json.encode(data.toJson());

class GetMasonryIssueReport {
  GetMasonryIssueReportResponse? response;

  GetMasonryIssueReport({
    this.response,
  });

  factory GetMasonryIssueReport.fromJson(Map<String, dynamic> json) =>
      GetMasonryIssueReport(
        response: json["Response"] == null
            ? null
            : GetMasonryIssueReportResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetMasonryIssueReportResponse {
  String? errorCode;
  String? msg;
  List<MasonryIssueReport>? masonryIssueReport;

  GetMasonryIssueReportResponse({
    this.errorCode,
    this.msg,
    this.masonryIssueReport,
  });

  factory GetMasonryIssueReportResponse.fromJson(Map<String, dynamic> json) =>
      GetMasonryIssueReportResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        masonryIssueReport: json["masonry_issue_report"] == null
            ? []
            : List<MasonryIssueReport>.from(json["masonry_issue_report"]!
                .map((x) => MasonryIssueReport.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "masonry_issue_report": masonryIssueReport == null
            ? []
            : List<dynamic>.from(masonryIssueReport!.map((x) => x.toJson())),
      };
}

class MasonryIssueReport {
  String? masonryApprovedById;
  String? mstMasonryIssueReportId;
  String? issueIn;
  String? reports;
  String? extracomment;
  String? submitdate;
  DateTime? resolvedate;
  String? userIdFk;
  String? issueResolve;
  String? empname;
  String? issusInName;
  String? reportBy;
  String? reportToName;
  String? reportTo;
  String? resolvedDate;
  List<String>? image;
  List<dynamic>? reportVedio;
  String? issueResolveBtn;

  MasonryIssueReport({
    this.masonryApprovedById,
    this.mstMasonryIssueReportId,
    this.issueIn,
    this.reports,
    this.extracomment,
    this.submitdate,
    this.resolvedate,
    this.userIdFk,
    this.issueResolve,
    this.empname,
    this.issusInName,
    this.reportBy,
    this.reportToName,
    this.reportTo,
    this.resolvedDate,
    this.image,
    this.reportVedio,
    this.issueResolveBtn,
  });

  factory MasonryIssueReport.fromJson(Map<String, dynamic> json) =>
      MasonryIssueReport(
        masonryApprovedById: json["masonry_approved_by_id"],
        mstMasonryIssueReportId: json["mst_masonry_issue_report_id"],
        issueIn: json["issue_in"],
        reports: json["reports"],
        extracomment: json["extracomment"],
        submitdate: json["submitdate"],
        resolvedate: json["resolvedate"] == null
            ? null
            : DateTime.parse(json["resolvedate"]),
        userIdFk: json["user_id_fk"],
        issueResolve: json["issue_resolve"],
        empname: json["empname"],
        issusInName: json["issus_in_name"],
        reportBy: json["report_by"],
        reportToName: json["report_to_name"],
        reportTo: json["report_to"],
        resolvedDate: json["resolved_date"],
        image: json["image"] == null
            ? []
            : List<String>.from(json["image"]!.map((x) => x)),
        reportVedio: json["report_vedio"] == null
            ? []
            : List<dynamic>.from(json["report_vedio"]!.map((x) => x)),
        issueResolveBtn: json["issue_resolve_btn"],
      );

  Map<String, dynamic> toJson() => {
        "masonry_approved_by_id": masonryApprovedById,
        "mst_masonry_issue_report_id": mstMasonryIssueReportId,
        "issue_in": issueIn,
        "reports": reports,
        "extracomment": extracomment,
        "submitdate": submitdate,
        "resolvedate": resolvedate?.toIso8601String(),
        "user_id_fk": userIdFk,
        "issue_resolve": issueResolve,
        "empname": empname,
        "issus_in_name": issusInName,
        "report_by": reportBy,
        "report_to_name": reportToName,
        "report_to": reportTo,
        "resolved_date": resolvedDate,
        "image": image == null ? [] : List<dynamic>.from(image!.map((x) => x)),
        "report_vedio": reportVedio == null
            ? []
            : List<dynamic>.from(reportVedio!.map((x) => x)),
        "issue_resolve_btn": issueResolveBtn,
      };
}
