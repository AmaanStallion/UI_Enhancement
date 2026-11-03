// To parse this JSON data, do
//
//     final rccTaskDetail = rccTaskDetailFromJson(jsonString);

import 'dart:convert';

RccTaskDetail rccTaskDetailFromJson(String str) =>
    RccTaskDetail.fromJson(json.decode(str));

String rccTaskDetailToJson(RccTaskDetail data) => json.encode(data.toJson());

class RccTaskDetail {
  RccTaskDetailResponse? response;

  RccTaskDetail({
    this.response,
  });

  factory RccTaskDetail.fromJson(Map<String, dynamic> json) => RccTaskDetail(
        response: json["Response"] == null
            ? null
            : RccTaskDetailResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class RccTaskDetailResponse {
  String? errorCode;
  String? msg;
  DprTaskDetails? dprTaskDetails;

  RccTaskDetailResponse({
    this.errorCode,
    this.msg,
    this.dprTaskDetails,
  });

  factory RccTaskDetailResponse.fromJson(Map<String, dynamic> json) =>
      RccTaskDetailResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        dprTaskDetails: json["dpr_task_details"] == null
            ? null
            : DprTaskDetails.fromJson(json["dpr_task_details"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "dpr_task_details": dprTaskDetails?.toJson(),
      };
}

class DprTaskDetails {
  String? dprTaskId;
  String? projectIdFk;
  String? towarIdFk;
  String? dprTaskTitle;
  String? dprTaskAssignId;
  String? taskRemark;
  DateTime? deadline;
  String? completedDate;
  DateTime? assingOn;
  String? slabName;
  String? assignName;
  String? completedName;
  String? dprTaskStatus;
  String? taskDeadlineStatus;
  String? statusText;
  List<ExtendDetail>? extendDetails;
  List<dynamic>? uploadedDocument;

  DprTaskDetails({
    this.dprTaskId,
    this.projectIdFk,
    this.towarIdFk,
    this.dprTaskTitle,
    this.dprTaskAssignId,
    this.taskRemark,
    this.deadline,
    this.completedDate,
    this.assingOn,
    this.slabName,
    this.assignName,
    this.completedName,
    this.dprTaskStatus,
    this.taskDeadlineStatus,
    this.statusText,
    this.extendDetails,
    this.uploadedDocument,
  });

  factory DprTaskDetails.fromJson(Map<String, dynamic> json) => DprTaskDetails(
        dprTaskId: json["dpr_task_id"],
        projectIdFk: json["project_id_fk"],
        towarIdFk: json["towar_id_fk"],
        dprTaskTitle: json["dpr_task_title"],
        dprTaskAssignId: json["dpr_task_assign_id"],
        taskRemark: json["task_remark"],
        deadline:
            json["deadline"] == null ? null : DateTime.parse(json["deadline"]),
        completedDate: json["completed_date"],
        assingOn: json["assing_on"] == null
            ? null
            : DateTime.parse(json["assing_on"]),
        slabName: json["slab_name"],
        assignName: json["assign_name"],
        completedName: json["completed_name"],
        dprTaskStatus: json["dpr_task_status"],
        taskDeadlineStatus: json["task_deadline_status"],
        statusText: json["status_text"],
        extendDetails: json["extend_details"] == null
            ? []
            : List<ExtendDetail>.from(
                json["extend_details"]!.map((x) => ExtendDetail.fromJson(x))),
        uploadedDocument: json["uploaded_document"] == null
            ? []
            : List<dynamic>.from(json["uploaded_document"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "dpr_task_id": dprTaskId,
        "project_id_fk": projectIdFk,
        "towar_id_fk": towarIdFk,
        "dpr_task_title": dprTaskTitle,
        "dpr_task_assign_id": dprTaskAssignId,
        "task_remark": taskRemark,
        "deadline":
            "${deadline!.year.toString().padLeft(4, '0')}-${deadline!.month.toString().padLeft(2, '0')}-${deadline!.day.toString().padLeft(2, '0')}",
        "completed_date": completedDate,
        "assing_on": assingOn?.toIso8601String(),
        "slab_name": slabName,
        "assign_name": assignName,
        "completed_name": completedName,
        "dpr_task_status": dprTaskStatus,
        "task_deadline_status": taskDeadlineStatus,
        "status_text": statusText,
        "extend_details": extendDetails == null
            ? []
            : List<dynamic>.from(extendDetails!.map((x) => x.toJson())),
        "uploaded_document": uploadedDocument == null
            ? []
            : List<dynamic>.from(uploadedDocument!.map((x) => x)),
      };
}

class ExtendDetail {
  String? userName;
  DateTime? dprExtendedDate;
  String? userIdFk;
  String? remark;

  ExtendDetail({
    this.userName,
    this.dprExtendedDate,
    this.userIdFk,
    this.remark,
  });

  factory ExtendDetail.fromJson(Map<String, dynamic> json) => ExtendDetail(
        userName: json["user_name"],
        dprExtendedDate: json["dpr_extended_date"] == null
            ? null
            : DateTime.parse(json["dpr_extended_date"]),
        userIdFk: json["user_id_fk"],
        remark: json["remark"],
      );

  Map<String, dynamic> toJson() => {
        "user_name": userName,
        "dpr_extended_date":
            "${dprExtendedDate!.year.toString().padLeft(4, '0')}-${dprExtendedDate!.month.toString().padLeft(2, '0')}-${dprExtendedDate!.day.toString().padLeft(2, '0')}",
        "user_id_fk": userIdFk,
        "remark": remark,
      };
}
