// To parse this JSON data, do
//
//     final getProjectMprList = getProjectMprListFromJson(jsonString);

import 'dart:convert';

GetProjectMprList getProjectMprListFromJson(String str) =>
    GetProjectMprList.fromJson(json.decode(str));

String getProjectMprListToJson(GetProjectMprList data) =>
    json.encode(data.toJson());

class GetProjectMprList {
  GetProjectMprListResponse? response;

  GetProjectMprList({
    this.response,
  });

  factory GetProjectMprList.fromJson(Map<String, dynamic> json) =>
      GetProjectMprList(
        response: json["Response"] == null
            ? null
            : GetProjectMprListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetProjectMprListResponse {
  String? errorCode;
  String? msg;
  List<MonthlyReport>? monthlyReport;

  GetProjectMprListResponse({
    this.errorCode,
    this.msg,
    this.monthlyReport,
  });

  factory GetProjectMprListResponse.fromJson(Map<String, dynamic> json) =>
      GetProjectMprListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        monthlyReport: json["monthly_report"] == null
            ? []
            : List<MonthlyReport>.from(
                json["monthly_report"]!.map((x) => MonthlyReport.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "monthly_report": monthlyReport == null
            ? []
            : List<dynamic>.from(monthlyReport!.map((x) => x.toJson())),
      };
}

class MonthlyReport {
  String? slabMonthlyId;
  String? projectIdFk;
  String? towarIdFk;
  String? slabMonDocument;
  String? slabMonDescription;
  String? userIdFk;
  String? slabMonthlyStatus;
  DateTime? slabMonthlyUpdateAt;
  DateTime? slabMonthlyCreatedAt;
  String? generatedBy;
  String? createdOn;
  String? imagePath;

  MonthlyReport({
    this.slabMonthlyId,
    this.projectIdFk,
    this.towarIdFk,
    this.slabMonDocument,
    this.slabMonDescription,
    this.userIdFk,
    this.slabMonthlyStatus,
    this.slabMonthlyUpdateAt,
    this.slabMonthlyCreatedAt,
    this.generatedBy,
    this.createdOn,
    this.imagePath,
  });

  factory MonthlyReport.fromJson(Map<String, dynamic> json) => MonthlyReport(
        slabMonthlyId: json["slab_monthly_id"],
        projectIdFk: json["project_id_fk"],
        towarIdFk: json["towar_id_fk"],
        slabMonDocument: json["slab_mon_document"],
        slabMonDescription: json["slab_mon_description"],
        userIdFk: json["user_id_fk"],
        slabMonthlyStatus: json["slab_monthly_status"],
        slabMonthlyUpdateAt: json["slab_monthly_update_at"] == null
            ? null
            : DateTime.parse(json["slab_monthly_update_at"]),
        slabMonthlyCreatedAt: json["slab_monthly_created_at"] == null
            ? null
            : DateTime.parse(json["slab_monthly_created_at"]),
        generatedBy: json["generated_by"],
        createdOn: json["created_on"],
        imagePath: json["image_path"],
      );

  Map<String, dynamic> toJson() => {
        "slab_monthly_id": slabMonthlyId,
        "project_id_fk": projectIdFk,
        "towar_id_fk": towarIdFk,
        "slab_mon_document": slabMonDocument,
        "slab_mon_description": slabMonDescription,
        "user_id_fk": userIdFk,
        "slab_monthly_status": slabMonthlyStatus,
        "slab_monthly_update_at": slabMonthlyUpdateAt?.toIso8601String(),
        "slab_monthly_created_at": slabMonthlyCreatedAt?.toIso8601String(),
        "generated_by": generatedBy,
        "created_on": createdOn,
        "image_path": imagePath,
      };
}
