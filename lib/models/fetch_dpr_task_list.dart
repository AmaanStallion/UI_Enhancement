// To parse this JSON data, do
//
//     final fetchDprTaskList = fetchDprTaskListFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/sales_lead_filter.dart';

FetchDprTaskList fetchDprTaskListFromJson(String str) =>
    FetchDprTaskList.fromJson(json.decode(str));

String fetchDprTaskListToJson(FetchDprTaskList data) =>
    json.encode(data.toJson());

class FetchDprTaskList {
  FetchDprTaskListResponse? response;

  FetchDprTaskList({
    this.response,
  });

  factory FetchDprTaskList.fromJson(Map<String, dynamic> json) =>
      FetchDprTaskList(
        response: json["Response"] == null
            ? null
            : FetchDprTaskListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class FetchDprTaskListResponse {
  String? errorCode;
  String? msg;
  String? offset;
  List<DprTaskList>? dprTaskList;
  String? pendingCount;
  String? completeCount;
  List<FilterList>? filterArr;

  FetchDprTaskListResponse({
    this.errorCode,
    this.msg,
    this.offset,
    this.dprTaskList,
    this.pendingCount,
    this.completeCount,
    this.filterArr,
  });

  factory FetchDprTaskListResponse.fromJson(Map<String, dynamic> json) =>
      FetchDprTaskListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        offset: json["offset"],
        dprTaskList: json["dpr_task_list"] == null
            ? []
            : List<DprTaskList>.from(
                json["dpr_task_list"]!.map((x) => DprTaskList.fromJson(x))),
        pendingCount: json["pending_count"],
        completeCount: json["complete_count"],
        filterArr: json["filter_arr"] == null
            ? []
            : List<FilterList>.from(
                json["filter_arr"]!.map((x) => FilterList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "offset": offset,
        "dpr_task_list": dprTaskList == null
            ? []
            : List<dynamic>.from(dprTaskList!.map((x) => x.toJson())),
        "pending_count": pendingCount,
        "complete_count": completeCount,
        "filter_arr": filterArr == null
            ? []
            : List<dynamic>.from(filterArr!.map((x) => x.toJson())),
      };
}

class DprTaskList {
  String? dprTaskId;
  String? projectIdFk;
  String? towarIdFk;
  String? dprTaskTitle;
  String? dprTaskAssignId;
  String? taskRemark;
  DateTime? deadline;
  DateTime? completedDate;
  DateTime? assingOn;
  String? slabName;
  String? assignName;
  String? completedName;
  String? dprTaskStatus;
  String? taskDeadlineStatus;
  String? statusText;

  DprTaskList({
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
  });

  factory DprTaskList.fromJson(Map<String, dynamic> json) => DprTaskList(
        dprTaskId: json["dpr_task_id"],
        projectIdFk: json["project_id_fk"],
        towarIdFk: json["towar_id_fk"],
        dprTaskTitle: json["dpr_task_title"],
        dprTaskAssignId: json["dpr_task_assign_id"],
        taskRemark: json["task_remark"],
        deadline:
            json["deadline"] == null ? null : DateTime.parse(json["deadline"]),
        // completedDate: json["completed_date"],
        completedDate: json['completed_date'] != "0000-00-00"
            ? DateTime.tryParse(json['completed_date'])
            : null,
        assingOn: json["assing_on"] == null
            ? null
            : DateTime.parse(json["assing_on"]),
        slabName: json["slab_name"],
        assignName: json["assign_name"],
        completedName: json["completed_name"],
        dprTaskStatus: json["dpr_task_status"],
        taskDeadlineStatus: json["task_deadline_status"],
        statusText: json["status_text"],
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
        // "completed_date": completedDate,
        'completed_date': completedDate != null
            ? completedDate!.toIso8601String()
            : "0000-00-00",
        "assing_on": assingOn?.toIso8601String(),
        "slab_name": slabName,
        "assign_name": assignName,
        "completed_name": completedName,
        "dpr_task_status": dprTaskStatus,
        "task_deadline_status": taskDeadlineStatus,
        "status_text": statusText,
      };
}

// class FilterArr {
//   String? name;
//   String? id;
//   List<Detail>? details;

//   FilterArr({
//     this.name,
//     this.id,
//     this.details,
//   });

//   factory FilterArr.fromJson(Map<String, dynamic> json) => FilterArr(
//         name: json["name"],
//         id: json["id"],
//         details: json["details"] == null
//             ? []
//             : List<Detail>.from(
//                 json["details"]!.map((x) => Detail.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name,
//         "id": id,
//         "details": details == null
//             ? []
//             : List<dynamic>.from(details!.map((x) => x.toJson())),
//       };
// }

// class Detail {
//   String? id;
//   String? name;

//   Detail({
//     this.id,
//     this.name,
//   });

//   factory Detail.fromJson(Map<String, dynamic> json) => Detail(
//         id: json["id"],
//         name: json["name"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//       };
// }
