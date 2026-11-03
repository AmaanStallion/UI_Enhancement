// To parse this JSON data, do
//
//     final getProjectDprList = getProjectDprListFromJson(jsonString);

import 'dart:convert';

GetProjectDprList getProjectDprListFromJson(String str) =>
    GetProjectDprList.fromJson(json.decode(str));

String getProjectDprListToJson(GetProjectDprList data) =>
    json.encode(data.toJson());

class GetProjectDprList {
  GetProjectDprListResponse? response;

  GetProjectDprList({
    this.response,
  });

  factory GetProjectDprList.fromJson(Map<String, dynamic> json) =>
      GetProjectDprList(
        response: json["Response"] == null
            ? null
            : GetProjectDprListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetProjectDprListResponse {
  String? errorCode;
  String? msg;
  String? activeContractor;
  String? skilledLabour;
  String? unskilledLabour;
  List<ProjctDprList>? projctDprList;
  String? offset;

  GetProjectDprListResponse({
    this.errorCode,
    this.msg,
    this.activeContractor,
    this.skilledLabour,
    this.unskilledLabour,
    this.projctDprList,
    this.offset,
  });

  factory GetProjectDprListResponse.fromJson(Map<String, dynamic> json) =>
      GetProjectDprListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        activeContractor: json["active_contractor"],
        skilledLabour: json["skilled_labour"],
        unskilledLabour: json["unskilled_labour"],
        projctDprList: json["projct_dpr_list"] == null
            ? []
            : List<ProjctDprList>.from(
                json["projct_dpr_list"]!.map((x) => ProjctDprList.fromJson(x))),
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "active_contractor": activeContractor,
        "skilled_labour": skilledLabour,
        "unskilled_labour": unskilledLabour,
        "projct_dpr_list": projctDprList == null
            ? []
            : List<dynamic>.from(projctDprList!.map((x) => x.toJson())),
        "offset": offset,
      };
}

class ProjctDprList {
  String? mstProjectDprId;
  String? userIdFk;
  String? projectIdFk;
  String? towarIdFk;
  String? slabIdFk;
  String? consultantJson;
  String? drpWorkJson;
  String? drpLabourJson;
  String? dprActivityJson;
  String? dprOrderDelivered;
  String? drpSrNo;
  String? drpStartNo;
  DateTime? drpIssueDate;
  String? drpTotalManPower;
  DateTime? drpUpdatedAt;
  DateTime? drpCreatedAt;
  String? drpStatus;
  String? drpFileName;
  String? drpUploadDoc;
  String? drpWorkType;
  String? dropUserIdFk;
  String? dprTodayPlanActivity;
  String? dprYesterdayActivity;
  String? dprDifficultiRequirement;
  String? fileDelete;
  String? userName;
  List<String>? uploadImage;

  ProjctDprList({
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
    this.userName,
    this.uploadImage,
  });

  factory ProjctDprList.fromJson(Map<String, dynamic> json) => ProjctDprList(
        mstProjectDprId: json["mst_project_dpr_id"],
        userIdFk: json["user_id_fk"],
        projectIdFk: json["project_id_fk"],
        towarIdFk: json["towar_id_fk"],
        slabIdFk: json["slab_id_fk"],
        consultantJson: json["consultant_json"],
        drpWorkJson: json["drp_work_json"],
        drpLabourJson: json["drp_labour_json"],
        dprActivityJson: json["dpr_activity_json"],
        dprOrderDelivered: json["dpr_order_delivered"],
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
        dprTodayPlanActivity: json["dpr_today_plan_activity"],
        dprYesterdayActivity: json["dpr_yesterday_activity"],
        dprDifficultiRequirement: json["dpr_difficulti_requirement"],
        fileDelete: json["file_delete"],
        userName: json["user_name"],
        uploadImage: json["upload_image"] == null
            ? []
            : List<String>.from(json["upload_image"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "mst_project_dpr_id": mstProjectDprId,
        "user_id_fk": userIdFk,
        "project_id_fk": projectIdFk,
        "towar_id_fk": towarIdFk,
        "slab_id_fk": slabIdFk,
        "consultant_json": consultantJson,
        "drp_work_json": drpWorkJson,
        "drp_labour_json": drpLabourJson,
        "dpr_activity_json": dprActivityJson,
        "dpr_order_delivered": dprOrderDelivered,
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
        "dpr_today_plan_activity": dprTodayPlanActivity,
        "dpr_yesterday_activity": dprYesterdayActivity,
        "dpr_difficulti_requirement": dprDifficultiRequirement,
        "file_delete": fileDelete,
        "user_name": userName,
        "upload_image": uploadImage == null
            ? []
            : List<dynamic>.from(uploadImage!.map((x) => x)),
      };
}
