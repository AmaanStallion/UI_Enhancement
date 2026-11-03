// To parse this JSON data, do
//
//     final getEditDprResponse = getEditDprResponseFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_project_dpr_contractor.dart';

GetEditDprResponse getEditDprResponseFromJson(String str) =>
    GetEditDprResponse.fromJson(json.decode(str));

String getEditDprResponseToJson(GetEditDprResponse data) =>
    json.encode(data.toJson());

class GetEditDprResponse {
  Response? response;

  GetEditDprResponse({
    this.response,
  });

  factory GetEditDprResponse.fromJson(Map<String, dynamic> json) =>
      GetEditDprResponse(
        response: json["Response"] == null
            ? null
            : Response.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class Response {
  String? errorCode;
  String? msg;
  ProjectDprDetails? projectDprDetails;

  Response({
    this.errorCode,
    this.msg,
    this.projectDprDetails,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        errorCode: json["error_code"],
        msg: json["msg"],
        projectDprDetails: json["project_dpr_details"] == null
            ? null
            : ProjectDprDetails.fromJson(json["project_dpr_details"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "project_dpr_details": projectDprDetails?.toJson(),
      };
}

class ProjectDprDetails {
  String? mstProjectDprId;
  String? userIdFk;
  String? projectIdFk;
  String? towarIdFk;
  String? slabIdFk;
  List<ContrctorList>? consultantJson;
  List<WorkProgress>? drpWorkJson;
  List<CustomType>? drpLabourJson;
  List<Skill>? dprActivityJson;
  List<dynamic>? dprOrderDelivered;
  String? drpSrNo;
  String? drpStartNo;
  DateTime? drpIssueDate;
  String? drpTotalManPower;
  DateTime? drpUpdatedAt;
  DateTime? drpCreatedAt;
  String? drpStatus;
  dynamic drpFileName;
  String? drpUploadDoc;
  String? drpWorkType;
  String? dropUserIdFk;
  List<DprYesterdayActivity>? dprTodayPlanActivity;
  List<DprYesterdayActivity>? dprYesterdayActivity;
  String? dprDifficultiRequirement;
  String? fileDelete;
  List<String>? uploadImage;
  String? dprVisitors;
  List<DprStaffList>? dprStaffJson;

  ProjectDprDetails({
    this.mstProjectDprId,
    this.userIdFk,
    this.projectIdFk,
    this.towarIdFk,
    this.slabIdFk,
    this.consultantJson,
    this.drpWorkJson,
    this.drpLabourJson,
    this.dprActivityJson,
    this.dprOrderDelivered,
    this.drpSrNo,
    this.drpStartNo,
    this.drpIssueDate,
    this.drpTotalManPower,
    this.drpUpdatedAt,
    this.drpCreatedAt,
    this.drpStatus,
    this.drpFileName,
    this.drpUploadDoc,
    this.drpWorkType,
    this.dropUserIdFk,
    this.dprTodayPlanActivity,
    this.dprYesterdayActivity,
    this.dprDifficultiRequirement,
    this.fileDelete,
    this.uploadImage,
    this.dprVisitors,
    this.dprStaffJson,
  });

  factory ProjectDprDetails.fromJson(Map<String, dynamic> json) =>
      ProjectDprDetails(
        mstProjectDprId: json["mst_project_dpr_id"],
        userIdFk: json["user_id_fk"],
        projectIdFk: json["project_id_fk"],
        towarIdFk: json["towar_id_fk"],
        slabIdFk: json["slab_id_fk"],
        consultantJson: json["consultant_json"] == null
            ? []
            : List<ContrctorList>.from(
                json["consultant_json"]!.map((x) => ContrctorList.fromJson(x))),
        drpWorkJson: json["drp_work_json"] == null
            ? []
            : List<WorkProgress>.from(
                json["drp_work_json"]!.map((x) => WorkProgress.fromJson(x))),
        drpLabourJson: json["drp_labour_json"] == null
            ? []
            : List<CustomType>.from(
                json["drp_labour_json"]!.map((x) => CustomType.fromJson(x))),
        dprActivityJson: json["dpr_activity_json"] == null
            ? []
            : List<Skill>.from(
                json["dpr_activity_json"]!.map((x) => Skill.fromJson(x))),
        dprOrderDelivered: json["dpr_order_delivered"] == null
            ? []
            : List<dynamic>.from(json["dpr_order_delivered"]!.map((x) => x)),
        drpSrNo: json["drp_sr_no"],
        drpStartNo: json["drp_start_no"],
        drpIssueDate: json["drp_issue_date"] == null
            ? null
            : DateTime.parse(json["drp_issue_date"]),
        drpTotalManPower: json["drp_total_man_power"],
        drpUpdatedAt: json["drp_updated_at"] == null
            ? null
            : DateTime.parse(json["drp_updated_at"]),
        drpCreatedAt: json["drp_created_at"] == null
            ? null
            : DateTime.parse(json["drp_created_at"]),
        drpStatus: json["drp_status"],
        drpFileName: json["drp_file_name"],
        drpUploadDoc: json["drp_upload_doc"],
        drpWorkType: json["drp_work_type"],
        dropUserIdFk: json["drop_user_id_fk"],
        dprTodayPlanActivity: json["dpr_today_plan_activity"] == null
            ? []
            : List<DprYesterdayActivity>.from(json["dpr_today_plan_activity"]!
                .map((x) => DprYesterdayActivity.fromJson(x))),
        dprYesterdayActivity: json["dpr_yesterday_activity"] == null
            ? []
            : List<DprYesterdayActivity>.from(json["dpr_yesterday_activity"]!
                .map((x) => DprYesterdayActivity.fromJson(x))),
        dprDifficultiRequirement: json["dpr_difficulti_requirement"],
        fileDelete: json["file_delete"],
        uploadImage: json["upload_image"] == null
            ? []
            : List<String>.from(json["upload_image"]!.map((x) => x)),
        dprVisitors: json["dpr_visitors"],
        dprStaffJson: json["dpr_staff_json"] == null
            ? []
            : List<DprStaffList>.from(
                json["dpr_staff_json"]!.map((x) => DprStaffList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "mst_project_dpr_id": mstProjectDprId,
        "user_id_fk": userIdFk,
        "project_id_fk": projectIdFk,
        "towar_id_fk": towarIdFk,
        "slab_id_fk": slabIdFk,
        "consultant_json": consultantJson == null
            ? []
            : List<dynamic>.from(consultantJson!.map((x) => x.toJson())),
        "drp_work_json": drpWorkJson == null
            ? []
            : List<dynamic>.from(drpWorkJson!.map((x) => x.toJson())),
        "drp_labour_json": drpLabourJson == null
            ? []
            : List<dynamic>.from(drpLabourJson!.map((x) => x.toJson())),
        "dpr_activity_json": dprActivityJson == null
            ? []
            : List<dynamic>.from(dprActivityJson!.map((x) => x.toJson())),
        "dpr_order_delivered": dprOrderDelivered == null
            ? []
            : List<dynamic>.from(dprOrderDelivered!.map((x) => x)),
        "drp_sr_no": drpSrNo,
        "drp_start_no": drpStartNo,
        "drp_issue_date": drpIssueDate?.toIso8601String(),
        "drp_total_man_power": drpTotalManPower,
        "drp_updated_at": drpUpdatedAt?.toIso8601String(),
        "drp_created_at": drpCreatedAt?.toIso8601String(),
        "drp_status": drpStatus,
        "drp_file_name": drpFileName,
        "drp_upload_doc": drpUploadDoc,
        "drp_work_type": drpWorkType,
        "drop_user_id_fk": dropUserIdFk,
        "dpr_today_plan_activity": dprTodayPlanActivity == null
            ? []
            : List<dynamic>.from(dprTodayPlanActivity!.map((x) => x.toJson())),
        "dpr_yesterday_activity": dprYesterdayActivity == null
            ? []
            : List<dynamic>.from(dprYesterdayActivity!.map((x) => x.toJson())),
        "dpr_difficulti_requirement": dprDifficultiRequirement,
        "file_delete": fileDelete,
        "upload_image": uploadImage == null
            ? []
            : List<dynamic>.from(uploadImage!.map((x) => x)),
        "dpr_visitors": dprVisitors,
        "dpr_staff_json": dprStaffJson == null
            ? []
            : List<dynamic>.from(dprStaffJson!.map((x) => x.toJson())),
      };
}
