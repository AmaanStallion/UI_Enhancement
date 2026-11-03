// To parse this JSON data, do
//
//     final getUserMeetingById = getUserMeetingByIdFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_all_members_by_project.dart';
import 'package:stallion/models/get_user_task_by_id.dart';

GetUserMeetingById getUserMeetingByIdFromJson(String str) =>
    GetUserMeetingById.fromJson(json.decode(str));

String getUserMeetingByIdToJson(GetUserMeetingById data) =>
    json.encode(data.toJson());

class GetUserMeetingById {
  GetUserMeetingByIdResponse? response;

  GetUserMeetingById({
    this.response,
  });

  factory GetUserMeetingById.fromJson(Map<String, dynamic> json) =>
      GetUserMeetingById(
        response: json["Response"] == null
            ? null
            : GetUserMeetingByIdResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetUserMeetingByIdResponse {
  String? errorCode;
  String? msg;
  String? totalTaskPending;
  List<MettingDatum>? mettingData;
  List<dynamic>? orderList;
  List<String>? filterData;

  GetUserMeetingByIdResponse({
    this.errorCode,
    this.msg,
    this.totalTaskPending,
    this.mettingData,
    this.orderList,
    this.filterData,
  });

  factory GetUserMeetingByIdResponse.fromJson(Map<String, dynamic> json) =>
      GetUserMeetingByIdResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        totalTaskPending: json["total_task_pending"],
        mettingData: json["metting_data"] == null
            ? []
            : List<MettingDatum>.from(
                json["metting_data"]!.map((x) => MettingDatum.fromJson(x))),
        orderList: json["order_list"] == null
            ? []
            : List<dynamic>.from(json["order_list"]!.map((x) => x)),
        filterData: json["filter_data"] == null
            ? []
            : List<String>.from(json["filter_data"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "total_task_pending": totalTaskPending,
        "metting_data": mettingData == null
            ? []
            : List<dynamic>.from(mettingData!.map((x) => x.toJson())),
        "order_list": orderList == null
            ? []
            : List<dynamic>.from(orderList!.map((x) => x)),
        "filter_data": filterData == null
            ? []
            : List<dynamic>.from(filterData!.map((x) => x)),
      };
}

class MettingDatum {
  String? projectName;
  String? projectId;
  String? mettingId;
  String? mettingTitle;
  String? mettingCreate;
  String? assignBy;
  String? totalParticipants;
  List<ShareDetail>? shareDetails;
  String? participants;
  List<MemberDetail>? memberDetails;
  String? taskcompleDetails;
  String? totalTaskAssign;
  String? totalTaskCompleted;
  String? taskcompleStatus;
  List<UserTask>? taskDetails;

  MettingDatum({
    this.projectName,
    this.projectId,
    this.mettingId,
    this.mettingTitle,
    this.mettingCreate,
    this.assignBy,
    this.totalParticipants,
    this.shareDetails,
    this.participants,
    this.memberDetails,
    this.taskcompleDetails,
    this.totalTaskAssign,
    this.totalTaskCompleted,
    this.taskcompleStatus,
    this.taskDetails,
  });

  factory MettingDatum.fromJson(Map<String, dynamic> json) => MettingDatum(
        projectName: json["project_name"],
        projectId: json["project_id"],
        mettingId: json["metting_id"],
        mettingTitle: json["metting_title"],
        mettingCreate: json["metting_create"],
        assignBy: json["assign_by"],
        totalParticipants: json["total_participants"],
        shareDetails: json["share_details"] == null
            ? []
            : List<ShareDetail>.from(
                json["share_details"]!.map((x) => ShareDetail.fromJson(x))),
        participants: json["participants"],
        memberDetails: json["member_details"] == null
            ? []
            : List<MemberDetail>.from(
                json["member_details"]!.map((x) => MemberDetail.fromJson(x))),
        taskcompleDetails: json["taskcomple_details"],
        totalTaskAssign: json["total_task_assign"],
        totalTaskCompleted: json["total_task_completed"],
        taskcompleStatus: json["taskcomple_status"],
        taskDetails: json["task_details"] == null
            ? []
            : List<UserTask>.from(
                json["task_details"]!.map((x) => UserTask.fromJson(x))),
      );

  factory MettingDatum.fromNewApiJson(Map<String, dynamic> json) {
    String participantsStr = json["participants_names"]?.toString() ?? '';
    List<MemberDetail> memberDetailsList = [];

    if (json["participants"] is List) {
      for (var p in json["participants"]) {
        if (p is Map) {
          memberDetailsList.add(MemberDetail(
            memberId: p["id"]?.toString(),
            memberName: p["name"]?.toString(),
            isSelected: false,
          ));
        }
      }
      if (participantsStr.isEmpty && memberDetailsList.isNotEmpty) {
        participantsStr = memberDetailsList
            .map((m) => m.memberName)
            .where((n) => n != null && n.isNotEmpty)
            .join(', ');
      }
    } else if (json["participants"] is String) {
      participantsStr = json["participants"];
    }

    return MettingDatum(
      mettingId: json["id"]?.toString(),
      mettingTitle: json["title"]?.toString(),
      mettingCreate: json["date"]?.toString(),
      participants: participantsStr,
      memberDetails: memberDetailsList,
      taskcompleDetails: json["ratio"]?.toString(),
      totalTaskAssign: json["tasks_total"]?.toString(),
      totalTaskCompleted: json["tasks_completed"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "project_name": projectName,
        "project_id": projectId,
        "metting_id": mettingId,
        "metting_title": mettingTitle,
        "metting_create": mettingCreate,
        "assign_by": assignBy,
        "total_participants": totalParticipants,
        "share_details": shareDetails == null
            ? []
            : List<dynamic>.from(shareDetails!.map((x) => x.toJson())),
        "participants": participants,
        "member_details": memberDetails == null
            ? []
            : List<dynamic>.from(memberDetails!.map((x) => x.toJson())),
        "taskcomple_details": taskcompleDetails,
        "total_task_assign": totalTaskAssign,
        "total_task_completed": totalTaskCompleted,
        "taskcomple_status": taskcompleStatus,
        "task_details": taskDetails == null
            ? []
            : List<dynamic>.from(taskDetails!.map((x) => x.toJson())),
      };
}

class ShareDetail {
  String? memberId;
  String? memberName;

  ShareDetail({
    this.memberId,
    this.memberName,
  });

  factory ShareDetail.fromJson(Map<String, dynamic> json) => ShareDetail(
        memberId: json["member_id"],
        memberName: json["member_name"],
      );

  Map<String, dynamic> toJson() => {
        "member_id": memberId,
        "member_name": memberName,
      };
}

// class MemberDetail {
//   String? memberName;
//   String? memberId;
//   String? contactNubmer;
//   String? designation;
//   String? companyId;
//   String? compayName;
//   String? typeName;

//   MemberDetail({
//     this.memberName,
//     this.memberId,
//     this.contactNubmer,
//     this.designation,
//     this.companyId,
//     this.compayName,
//     this.typeName,
//   });

//   factory MemberDetail.fromJson(Map<String, dynamic> json) => MemberDetail(
//         memberName: json["member_name"],
//         memberId: json["member_id"],
//         contactNubmer: json["contact_nubmer"],
//         designation: json["Designation"],
//         companyId: json["company_id"],
//         compayName: json["compay_name"],
//         typeName: json["type_name"],
//       );

//   Map<String, dynamic> toJson() => {
//         "member_name": memberName,
//         "member_id": memberId,
//         "contact_nubmer": contactNubmer,
//         "Designation": designation,
//         "company_id": companyId,
//         "compay_name": compayName,
//         "type_name": typeName,
//       };
// }

// class TaskDetail {
//   String? mettingIdFk;
//   String? taskId;
//   String? taskTitle;
//   String? taskDeadline;
//   String? taskCompleteStatus;
//   String? taskCompleteDate;
//   String? taskCreateAt;
//   String? taskCompletedBy;
//   String? taskRemark;
//   String? mettingTitle;
//   String? projectName;
//   String? assignBy;
//   String? taskDeadlineStatus;
//   List<dynamic>? taskExtendDates;
//   String? assignTo;
//   List<dynamic>? images;

//   TaskDetail({
//     this.mettingIdFk,
//     this.taskId,
//     this.taskTitle,
//     this.taskDeadline,
//     this.taskCompleteStatus,
//     this.taskCompleteDate,
//     this.taskCreateAt,
//     this.taskCompletedBy,
//     this.taskRemark,
//     this.mettingTitle,
//     this.projectName,
//     this.assignBy,
//     this.taskDeadlineStatus,
//     this.taskExtendDates,
//     this.assignTo,
//     this.images,
//   });

//   factory TaskDetail.fromJson(Map<String, dynamic> json) => TaskDetail(
//         mettingIdFk: json["metting_id_fk"],
//         taskId: json["task_id"],
//         taskTitle: json["task_title"],
//         taskDeadline: json["task_deadline"],
//         taskCompleteStatus: json["task_complete_status"],
//         taskCompleteDate: json["task_complete_date"],
//         taskCreateAt: json["task_create_at"],
//         taskCompletedBy: json["task_completed_by"],
//         taskRemark: json["task_remark"],
//         mettingTitle: json["metting_title"],
//         projectName: json["project_name"],
//         assignBy: json["assign_by"],
//         taskDeadlineStatus: json["task_deadline_status"],
//         taskExtendDates: json["task_extend_dates"] == null
//             ? []
//             : List<dynamic>.from(json["task_extend_dates"]!.map((x) => x)),
//         assignTo: json["assign_to"],
//         images: json["images"] == null
//             ? []
//             : List<dynamic>.from(json["images"]!.map((x) => x)),
//       );

//   Map<String, dynamic> toJson() => {
//         "metting_id_fk": mettingIdFk,
//         "task_id": taskId,
//         "task_title": taskTitle,
//         "task_deadline": taskDeadline,
//         "task_complete_status": taskCompleteStatus,
//         "task_complete_date": taskCompleteDate,
//         "task_create_at": taskCreateAt,
//         "task_completed_by": taskCompletedBy,
//         "task_remark": taskRemark,
//         "metting_title": mettingTitle,
//         "project_name": projectName,
//         "assign_by": assignBy,
//         "task_deadline_status": taskDeadlineStatus,
//         "task_extend_dates": taskExtendDates == null
//             ? []
//             : List<dynamic>.from(taskExtendDates!.map((x) => x)),
//         "assign_to": assignTo,
//         "images":
//             images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
//       };
// }
