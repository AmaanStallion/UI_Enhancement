// To parse this JSON data, do
//
//     final getUserTaskById = getUserTaskByIdFromJson(jsonString);

import 'dart:convert';
import 'package:intl/intl.dart';

GetUserTaskById getUserTaskByIdFromJson(String str) =>
    GetUserTaskById.fromJson(json.decode(str));

String getUserTaskByIdToJson(GetUserTaskById data) =>
    json.encode(data.toJson());

class GetUserTaskById {
  GetUserTaskByIdResponse? response;

  GetUserTaskById({
    this.response,
  });

  factory GetUserTaskById.fromJson(Map<String, dynamic> json) =>
      GetUserTaskById(
        response: json["Response"] == null
            ? null
            : GetUserTaskByIdResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetUserTaskByIdResponse {
  String? errorCode;
  String? msg;
  String? totalTaskPending;
  List<UserTask>? userTask;
  dynamic orderList;
  String? offset;

  GetUserTaskByIdResponse({
    this.errorCode,
    this.msg,
    this.totalTaskPending,
    this.userTask,
    this.orderList,
    this.offset,
  });

  factory GetUserTaskByIdResponse.fromJson(Map<String, dynamic> json) =>
      GetUserTaskByIdResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        totalTaskPending: json["total_task_pending"],
        userTask: json["user_task"] == null
            ? []
            : List<UserTask>.from(
                json["user_task"]!.map((x) => UserTask.fromJson(x))),
        orderList: json["order_list"],
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "total_task_pending": totalTaskPending,
        "user_task": userTask == null
            ? []
            : List<dynamic>.from(userTask!.map((x) => x.toJson())),
        "order_list": orderList,
        "offset": offset,
      };
}

class UserTask {
  String? projectIdFk;
  String? mettingIdFk;
  String? taskId;
  String? taskTitle;
  String? taskDeadline;
  String? taskCompleteStatus;
  String? taskCompleteDate;
  String? taskCreateAt;
  String? taskCompletedBy;
  String? taskRemark;
  String? userIdFk;
  String? assignBy;
  String? mettingTitle;
  String? projectName;
  String? taskDeadlineStatus;
  List<String>? taskExtendDates;
  String? assignTo;
  List<String>? images;
  List<TaskExtendDetail>? taskExtendDetails;
  final List<String>? completeImages;

  UserTask({
    this.projectIdFk,
    this.mettingIdFk,
    this.taskId,
    this.taskTitle,
    this.taskDeadline,
    this.taskCompleteStatus,
    this.taskCompleteDate,
    this.taskCreateAt,
    this.taskCompletedBy,
    this.taskRemark,
    this.userIdFk,
    this.assignBy,
    this.mettingTitle,
    this.projectName,
    this.taskDeadlineStatus,
    this.taskExtendDates,
    this.assignTo,
    this.images,
    this.taskExtendDetails,
    this.completeImages,
  });

  factory UserTask.fromJson(Map<String, dynamic> json) {
    String? formatDate(dynamic rawDate) {
      if (rawDate == null) return null;
      String str = rawDate.toString().trim();
      if (str.isEmpty) return str;

      try {
        DateTime? dt = DateTime.tryParse(str);
        if (dt != null) {
          return DateFormat('dd/MM/yyyy').format(dt);
        }
      } catch (_) {}

      if (str.contains('-')) {
        List<String> parts = str.split('T')[0].split('-');
        if (parts.length == 3 && parts[0].length == 4) {
          return '${parts[2]}/${parts[1]}/${parts[0]}';
        }
      }
      return str;
    }

    final statusVal = json["status"] ?? json["task_complete_status"];
    final isCompleted = statusVal == "completed" || statusVal == "1";
    final hasExt = json["has_extended_deadline"] == true || json["task_deadline_status"] == "1";

    return UserTask(
      projectIdFk: json["project_id_fk"]?.toString(),
      mettingIdFk: json["metting_id_fk"]?.toString(),
      taskId: json["id"]?.toString() ?? json["task_id"]?.toString(),
      taskTitle: json["title"]?.toString() ?? json["task_title"]?.toString(),
      taskDeadline: formatDate(json["deadline"] ?? json["task_deadline"]),
      taskCompleteStatus: isCompleted ? "1" : "0",
      taskCompleteDate: formatDate(json["completed_at"] ?? json["task_complete_date"]),
      taskCreateAt: formatDate(json["assigned_on"] ?? json["task_create_at"]),
      taskCompletedBy: json["completed_by"]?.toString() ?? json["task_completed_by"]?.toString(),
      taskRemark: json["task_remark"]?.toString(),
      userIdFk: json["user_id_fk"]?.toString(),
      assignBy: json["assignor"]?.toString() ?? json["assign_by"]?.toString(),
      mettingTitle: json["metting_title"]?.toString(),
      projectName: json["module_name"]?.toString() ?? json["project_name"]?.toString(),
      taskDeadlineStatus: hasExt ? "1" : "0",
      taskExtendDates: json["task_extend_dates"] == null
          ? []
          : List<String>.from(json["task_extend_dates"]!.map((x) => x.toString())),
      assignTo: json["assigned_to"]?.toString() ?? json["assign_to"]?.toString(),
      images: json["images"] == null
          ? []
          : List<String>.from(json["images"]!.map((x) => x.toString())),
      taskExtendDetails: json["task_extend_details"] == null
          ? []
          : List<TaskExtendDetail>.from(json["task_extend_details"]!
              .map((x) => TaskExtendDetail.fromJson(x))),
      completeImages: json["complete_images"] == null
          ? []
          : List<String>.from(json["complete_images"]!.map((x) => x.toString())),
    );
  }

  factory UserTask.fromNewMeetingTaskJson(Map<String, dynamic> json) {
    String? formatDate(dynamic rawDate) {
      if (rawDate == null) return null;
      String str = rawDate.toString().trim();
      if (str.isEmpty) return str;

      try {
        DateTime? dt = DateTime.tryParse(str);
        if (dt != null) {
          return DateFormat('dd/MM/yyyy').format(dt);
        }
      } catch (_) {}

      if (str.contains('-')) {
        List<String> parts = str.split('T')[0].split('-');
        if (parts.length == 3 && parts[0].length == 4) {
          return '${parts[2]}/${parts[1]}/${parts[0]}';
        }
      }
      return str;
    }

    final statusStr = json["status"]?.toString().toLowerCase() ?? 'pending';
    final isCompleted = statusStr == 'completed';

    List<String> fileUrls = [];
    if (json["files"] is List) {
      for (var f in json["files"]) {
        if (f is Map && f["view_url"] != null) {
          fileUrls.add(f["view_url"].toString());
        }
      }
    }

    return UserTask(
      taskId: json["id"]?.toString(),
      taskTitle: json["description"]?.toString(),
      taskDeadline: formatDate(json["deadline"]),
      taskCompleteStatus: isCompleted ? "1" : "0",
      taskCreateAt: formatDate(json["assigned_on"]),
      assignBy: json["assignor_name"]?.toString(),
      assignTo: json["assigned_to_names"]?.toString(),
      images: fileUrls,
    );
  }

  Map<String, dynamic> toJson() => {
        "project_id_fk": projectIdFk,
        "metting_id_fk": mettingIdFk,
        "task_id": taskId,
        "task_title": taskTitle,
        "task_deadline": taskDeadline,
        "task_complete_status": taskCompleteStatus,
        "task_complete_date": taskCompleteDate,
        "task_create_at": taskCreateAt,
        "task_completed_by": taskCompletedBy,
        "task_remark": taskRemark,
        "user_id_fk": userIdFk,
        "assign_by": assignBy,
        "metting_title": mettingTitle,
        "project_name": projectName,
        "task_deadline_status": taskDeadlineStatus,
        "task_extend_dates": taskExtendDates == null
            ? []
            : List<dynamic>.from(taskExtendDates!.map((x) => x)),
        "assign_to": assignTo,
        "images":
            images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "task_extend_details": taskExtendDetails == null
            ? []
            : List<dynamic>.from(taskExtendDetails!.map((x) => x.toJson())),
        "complete_images": completeImages == null
            ? []
            : List<dynamic>.from(completeImages!.map((x) => x)),
      };
}

class TaskExtendDetail {
  String? extendedDate;
  String? extendedBy;

  TaskExtendDetail({
    this.extendedDate,
    this.extendedBy,
  });

  factory TaskExtendDetail.fromJson(Map<String, dynamic> json) =>
      TaskExtendDetail(
        extendedDate: json["extended_date"],
        extendedBy: json["extended_by"],
      );

  Map<String, dynamic> toJson() => {
        "extended_date": extendedDate,
        "extended_by": extendedBy,
      };
}
