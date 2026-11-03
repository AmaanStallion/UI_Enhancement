// // To parse this JSON data, do
// //
// //     final rccIssueReportsData = rccIssueReportsDataFromJson(jsonString);

// import 'dart:convert';

// import 'package:stallion/models/get_project_management.dart';

// RccIssueReportsData rccIssueReportsDataFromJson(String str) =>
//     RccIssueReportsData.fromJson(json.decode(str));

// String rccIssueReportsDataToJson(RccIssueReportsData data) =>
//     json.encode(data.toJson());

// class RccIssueReportsData {
//   RccIssueReportsData({
//     required this.response,
//   });

//   final RccIssueReportsDataResponse response;

//   factory RccIssueReportsData.fromJson(Map<String, dynamic> json) =>
//       RccIssueReportsData(
//         response: RccIssueReportsDataResponse.fromJson(json["Response"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "Response": response.toJson(),
//       };
// }

// class RccIssueReportsDataResponse {
//   RccIssueReportsDataResponse({
//     required this.errorCode,
//     required this.msg,
//     required this.slabIssueReport,
//   });

//   final String errorCode;
//   final String msg;
//   final List<SlabIssueReport> slabIssueReport;

//   factory RccIssueReportsDataResponse.fromJson(Map<String, dynamic> json) =>
//       RccIssueReportsDataResponse(
//         errorCode: json["error_code"],
//         msg: json["msg"],
//         slabIssueReport: List<SlabIssueReport>.from(
//             json["slab_issue_report"].map((x) => SlabIssueReport.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "error_code": errorCode,
//         "msg": msg,
//         "slab_issue_report":
//             List<dynamic>.from(slabIssueReport.map((x) => x.toJson())),
//       };
// }

// // class SlabIssueReport {
// //   SlabIssueReport({
// //     this.mstSlabIssuerReportId,
// //     this.issueIn,
// //     this.reports,
// //     this.extracomment,
// //     this.submitdate,
// //     this.resolvedate,
// //     this.userIdFk,
// //     this.issueResolve,
// //     this.issusInName,
// //     this.reportBy,
// //     this.reportedBy,
// //     this.reportToName,
// //     this.reportTo,
// //     this.issueResolveBtn,
// //     this.resolvedDate,
// //     this.slabVedio,
// //     this.image,
// //     this.imagePath,
// //     this.empname,
// //   });

// //   final String? mstSlabIssuerReportId;
// //   final String? issueIn;
// //   final String? reports;
// //   final String? extracomment;
// //   final String? submitdate;
// //   final String? resolvedate;
// //   final String? userIdFk;
// //   final String? issueResolve;
// //   final String? issusInName;
// //   final String? reportBy;
// //   final String? reportToName;
// //   final String? reportTo;
// //   final String? reportedBy;
// //   final String? empname;
// //   final String? issueResolveBtn;
// //   final String? resolvedDate;
// //   final List<String>? image;
// //   List<String>? slabVedio;

// //   final String? imagePath;

// //   factory SlabIssueReport.fromJson(Map<String, dynamic> json) =>
// //       SlabIssueReport(
// //         mstSlabIssuerReportId: json["mst_slab_issuer_report_id"],
// //         issueIn: json["issue_in"],
// //         reports: json["reports"],
// //         extracomment: json["extracomment"],
// //         submitdate: json["submitdate"],
// //         resolvedate: json["resolvedate"],
// //         userIdFk: json["user_id_fk"],
// //         issueResolve: json["issue_resolve"],
// //         issusInName: json["issus_in_name"],
// //         reportBy: json["report_by"],
// //         reportedBy: json["reported_by"],
// //         reportToName: json["report_to_name"],
// //         reportTo: json["report_to"],
// //         issueResolveBtn: json["issue_resolve_btn"],
// //         resolvedDate: json["resolved_date"],
// //         image: List<String>.from(json["image"].map((x) => x)),
// //         imagePath: json["image_path"],
// //         empname: json["empname"],
// //         slabVedio: json["slab_vedio"] == null
// //             ? []
// //             : List<String>.from(json["slab_vedio"]!.map((x) => x)),
// //       );

// //   Map<String, dynamic> toJson() => {
// //         "mst_slab_issuer_report_id": mstSlabIssuerReportId,
// //         "issue_in": issueIn,
// //         "reports": reports,
// //         "extracomment": extracomment,
// //         "submitdate": submitdate,
// //         "resolvedate": resolvedate,
// //         "user_id_fk": userIdFk,
// //         "issue_resolve": issueResolve,
// //         "issus_in_name": issusInName,
// //         "report_by": reportBy,
// //         "reported_by": reportedBy,
// //         "report_to_name": reportToName,
// //         "report_to": reportTo,
// //         "issue_resolve_btn": issueResolveBtn,
// //         "resolved_date": resolvedDate,
// //         "image": List<dynamic>.from(image!.map((x) => x)),
// //         "image_path": imagePath,
// //         "empname": empname,
// //         "slab_vedio": slabVedio == null
// //             ? []
// //             : List<dynamic>.from(slabVedio!.map((x) => x)),
// //       };
// // }

// To parse this JSON data, do
//
//     final rccIssueReportsData = rccIssueReportsDataFromJson(jsonString);

import 'dart:convert';

RccIssueReportsData rccIssueReportsDataFromJson(String str) =>
    RccIssueReportsData.fromJson(json.decode(str));

String rccIssueReportsDataToJson(RccIssueReportsData data) =>
    json.encode(data.toJson());

class RccIssueReportsData {
  RccIssueReportsData({
    required this.response,
  });

  final RccIssueReportsDataResponse response;

  factory RccIssueReportsData.fromJson(Map<String, dynamic> json) =>
      RccIssueReportsData(
        response: RccIssueReportsDataResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response.toJson(),
      };
}

class RccIssueReportsDataResponse {
  RccIssueReportsDataResponse({
    required this.errorCode,
    required this.msg,
    required this.slabIssueReport,
  });

  final String errorCode;
  final String msg;
  final List<SlabIssueReport> slabIssueReport;

  factory RccIssueReportsDataResponse.fromJson(Map<String, dynamic> json) =>
      RccIssueReportsDataResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        slabIssueReport: List<SlabIssueReport>.from(
            json["slab_issue_report"].map((x) => SlabIssueReport.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "slab_issue_report":
            List<dynamic>.from(slabIssueReport.map((x) => x.toJson())),
      };
}

class SlabIssueReport {
  SlabIssueReport({
    this.mstSlabIssuerReportId,
    this.issueIn,
    this.reports,
    this.extracomment,
    this.submitdate,
    this.resolvedate,
    this.userIdFk,
    this.issueResolve,
    this.issusInName,
    this.reportBy,
    this.reportedBy,
    this.reportToName,
    this.reportTo,
    this.issueResolveBtn,
    this.resolvedDate,
    this.slabVedio,
    this.image,
    this.imagePath,
    this.resolutionImages,
    this.resolutionVideos,
    this.empname,
  });

  final String? mstSlabIssuerReportId;
  final String? issueIn;
  final String? reports;
  final String? extracomment;
  final String? submitdate;
  final String? resolvedate;
  final String? userIdFk;
  final String? issueResolve;
  final String? issusInName;
  final String? reportBy;
  final String? reportToName;
  final String? reportTo;
  final String? reportedBy;
  final String? empname;

  final String? issueResolveBtn;
  final String? resolvedDate;
  final List<String>? image;
  List<String>? slabVedio;
  final List<String>? resolutionImages;
  final List<String>? resolutionVideos;

  final String? imagePath;

  factory SlabIssueReport.fromJson(Map<String, dynamic> json) =>
      SlabIssueReport(
        mstSlabIssuerReportId: json["mst_slab_issuer_report_id"],
        issueIn: json["issue_in"],
        reports: json["reports"],
        extracomment: json["extracomment"],
        submitdate: json["submitdate"],
        resolvedate: json["resolvedate"],
        userIdFk: json["user_id_fk"],
        issueResolve: json["issue_resolve"],
        issusInName: json["issus_in_name"],
        reportBy: json["report_by"],
        reportedBy: json["reported_by"],
        reportToName: json["report_to_name"],
        reportTo: json["report_to"],
        issueResolveBtn: json["issue_resolve_btn"],
        resolvedDate: json["resolved_date"],
        image: List<String>.from(json["image"].map((x) => x)),
        imagePath: json["image_path"],
        empname: json["empname"],
        slabVedio: json["slab_vedio"] == null
            ? []
            : List<String>.from(json["slab_vedio"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "mst_slab_issuer_report_id": mstSlabIssuerReportId,
        "issue_in": issueIn,
        "reports": reports,
        "extracomment": extracomment,
        "submitdate": submitdate,
        "resolvedate": resolvedate,
        "user_id_fk": userIdFk,
        "issue_resolve": issueResolve,
        "issus_in_name": issusInName,
        "report_by": reportBy,
        "reported_by": reportedBy,
        "report_to_name": reportToName,
        "report_to": reportTo,
        "issue_resolve_btn": issueResolveBtn,
        "resolved_date": resolvedDate,
        "image": List<dynamic>.from(image!.map((x) => x)),
        "image_path": imagePath,
        "empname": empname,
        "slab_vedio": slabVedio == null
            ? []
            : List<dynamic>.from(slabVedio!.map((x) => x)),
      };
}
