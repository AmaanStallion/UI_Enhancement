// // To parse this JSON data, do
// //
// //     final notificationResponse = notificationResponseFromJson(jsonString);

// import 'dart:convert';

// NotificationResponse notificationResponseFromJson(String str) =>
//     NotificationResponse.fromJson(json.decode(str));

// String notificationResponseToJson(NotificationResponse data) =>
//     json.encode(data.toJson());

// class NotificationResponse {
//   ResponseNotificationResponse? response;

//   NotificationResponse({
//     this.response,
//   });

//   factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
//       NotificationResponse(
//         response: json["Response"] == null
//             ? null
//             : ResponseNotificationResponse.fromJson(json["Response"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "Response": response?.toJson(),
//       };
// }

// class ResponseNotificationResponse {
//   String? errorCode;
//   String? msg;
//   List<NotificationList>? notificationList;

//   ResponseNotificationResponse({
//     this.errorCode,
//     this.msg,
//     this.notificationList,
//   });

//   factory ResponseNotificationResponse.fromJson(Map<String, dynamic> json) =>
//       ResponseNotificationResponse(
//         errorCode: json["error_code"],
//         msg: json["msg"],
//         notificationList: json["notification_list"] == null
//             ? []
//             : List<NotificationList>.from(json["notification_list"]!
//                 .map((x) => NotificationList.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "error_code": errorCode,
//         "msg": msg,
//         "notification_list": notificationList == null
//             ? []
//             : List<dynamic>.from(notificationList!.map((x) => x.toJson())),
//       };
// }

// class NotificationList {
//   String? mstNotificationId;
//   String? msg;
//   String? notificationType;
//   dynamic response;
//   String? projectName;
//   String? projectLocation;
//   String? projectId;
//   String? showStatus;
//   DateTime? updateAt;
//   DateTime? createdAt;
//   String? towarIdFk;
//   String? notificationModuleType;

//   NotificationList({
//     this.mstNotificationId,
//     this.msg,
//     this.notificationType,
//     this.response,
//     this.projectName,
//     this.projectLocation,
//     this.projectId,
//     this.showStatus,
//     this.updateAt,
//     this.createdAt,
//     this.towarIdFk,
//     this.notificationModuleType,
//   });

//   factory NotificationList.fromJson(Map<String, dynamic> json) =>
//       NotificationList(
//         mstNotificationId: json["mst_notification_id"],
//         msg: json["msg"],
//         notificationType: json["notification_type"],
//         response: json["response"],
//         projectName: json["project_name"],
//         projectLocation: json["project_location"],
//         projectId: json["project_id"],
//         showStatus: json["show_status"],
//         updateAt: json["update_at"] == null
//             ? null
//             : DateTime.parse(json["update_at"]),
//         createdAt: json["created_at"] == null
//             ? null
//             : DateTime.parse(json["created_at"]),
//         towarIdFk: json["towar_id_fk"],
//         notificationModuleType: json["notification_module_type"],
//       );

//   Map<String, dynamic> toJson() => {
//         "mst_notification_id": mstNotificationId,
//         "msg": msg,
//         "notification_type": notificationType,
//         "response": response,
//         "project_name": projectName,
//         "project_location": projectLocation,
//         "project_id": projectId,
//         "show_status": showStatus,
//         "update_at": updateAt?.toIso8601String(),
//         "created_at": createdAt?.toIso8601String(),
//         "towar_id_fk": towarIdFk,
//         "notification_module_type": notificationModuleType,
//       };
// }

// // enum ProjectLocation { AURANGABAD, BREACH_CANDY, DADAR, SANTACRUZ }

// // final projectLocationValues = EnumValues({
// //   "Aurangabad ": ProjectLocation.AURANGABAD,
// //   "Breach Candy": ProjectLocation.BREACH_CANDY,
// //   "Dadar": ProjectLocation.DADAR,
// //   "Santacruz": ProjectLocation.SANTACRUZ
// // });

// // enum ProjectName { BLISS, ESCAPE, ESCAPE_A_WING, PADDY_TEST, SAACHAI_GADIYA }

// // final projectNameValues = EnumValues({
// //   "Bliss": ProjectName.BLISS,
// //   "ESCAPE": ProjectName.ESCAPE,
// //   "ESCAPE (A Wing)": ProjectName.ESCAPE_A_WING,
// //   "Paddy Test": ProjectName.PADDY_TEST,
// //   "Saachai Gadiya": ProjectName.SAACHAI_GADIYA
// // });

// class ResponseClass {
//   String? slabId;
//   String? towarId;
//   String? projectId;
//   String? slabName;
//   String? orderId;
//   String? permissionId;
//   String? slabNo;
//   List<UserTask>? userTask;

//   ResponseClass({
//     this.slabId,
//     this.towarId,
//     this.projectId,
//     this.slabName,
//     this.orderId,
//     this.permissionId,
//     this.slabNo,
//     this.userTask,
//   });

//   factory ResponseClass.fromJson(Map<String, dynamic> json) => ResponseClass(
//         slabId: json["slab_id"],
//         towarId: json["towar_id"],
//         projectId: json["project_id"],
//         slabName: json["slab_name"],
//         orderId: json["order_id"],
//         permissionId: json["permission_id"],
//         slabNo: json["slab_no"],
//         userTask: json["user_task"] == null
//             ? []
//             : List<UserTask>.from(
//                 json["user_task"]!.map((x) => UserTask.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "slab_id": slabId,
//         "towar_id": towarId,
//         "project_id": projectId,
//         "slab_name": slabName,
//         "order_id": orderId,
//         "permission_id": permissionId,
//         "slab_no": slabNo,
//         "user_task": userTask == null
//             ? []
//             : List<dynamic>.from(userTask!.map((x) => x.toJson())),
//       };
// }

// // enum SlabNo { THE_1_ST_BASEMENT, THE_7_TH_SLAB }

// // final slabNoValues = EnumValues({
// //   "1st Basement": SlabNo.THE_1_ST_BASEMENT,
// //   "7th Slab": SlabNo.THE_7_TH_SLAB
// // });

// class UserTask {
//   String? projectIdFk;
//   String? mettingIdFk;
//   String? taskId;
//   String? taskTitle;
//   String? taskDeadline;
//   String? taskCompleteStatus;
//   String? taskCompleteDate;
//   String? taskCreateAt;
//   String? taskCompletedBy;
//   String? taskRemark;
//   String? assignBy;
//   List<dynamic>? shareDetails;
//   String? mettingTitle;
//   String? projectName;
//   String? taskDeadlineStatus;
//   List<String>? taskExtendDates;
//   String? assignTo;
//   List<String>? images;
//   List<TaskExtendDetail>? taskExtendDetails;

//   UserTask({
//     this.projectIdFk,
//     this.mettingIdFk,
//     this.taskId,
//     this.taskTitle,
//     this.taskDeadline,
//     this.taskCompleteStatus,
//     this.taskCompleteDate,
//     this.taskCreateAt,
//     this.taskCompletedBy,
//     this.taskRemark,
//     this.assignBy,
//     this.shareDetails,
//     this.mettingTitle,
//     this.projectName,
//     this.taskDeadlineStatus,
//     this.taskExtendDates,
//     this.assignTo,
//     this.images,
//     this.taskExtendDetails,
//   });

//   factory UserTask.fromJson(Map<String, dynamic> json) => UserTask(
//         projectIdFk: json["project_id_fk"],
//         mettingIdFk: json["metting_id_fk"],
//         taskId: json["task_id"],
//         taskTitle: json["task_title"],
//         taskDeadline: json["task_deadline"],
//         taskCompleteStatus: json["task_complete_status"],
//         taskCompleteDate: json["task_complete_date"],
//         taskCreateAt: json["task_create_at"],
//         taskCompletedBy: json["task_completed_by"],
//         taskRemark: json["task_remark"],
//         assignBy: json["assign_by"],
//         shareDetails: json["share_details"] == null
//             ? []
//             : List<dynamic>.from(json["share_details"]!.map((x) => x)),
//         mettingTitle: json["metting_title"],
//         projectName: json["project_name"],
//         taskDeadlineStatus: json["task_deadline_status"],
//         taskExtendDates: json["task_extend_dates"] == null
//             ? []
//             : List<String>.from(json["task_extend_dates"]!.map((x) => x)),
//         assignTo: json["assign_to"],
//         images: json["images"] == null
//             ? []
//             : List<String>.from(json["images"]!.map((x) => x)),
//         taskExtendDetails: json["task_extend_details"] == null
//             ? []
//             : List<TaskExtendDetail>.from(json["task_extend_details"]!
//                 .map((x) => TaskExtendDetail.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "project_id_fk": projectIdFk,
//         "metting_id_fk": mettingIdFk,
//         "task_id": taskId,
//         "task_title": taskTitle,
//         "task_deadline": taskDeadline,
//         "task_complete_status": taskCompleteStatus,
//         "task_complete_date": taskCompleteDate,
//         "task_create_at": taskCreateAt,
//         "task_completed_by": taskCompletedBy,
//         "task_remark": taskRemark,
//         "assign_by": assignBy,
//         "share_details": shareDetails == null
//             ? []
//             : List<dynamic>.from(shareDetails!.map((x) => x)),
//         "metting_title": mettingTitle,
//         "project_name": projectName,
//         "task_deadline_status": taskDeadlineStatus,
//         "task_extend_dates": taskExtendDates == null
//             ? []
//             : List<dynamic>.from(taskExtendDates!.map((x) => x)),
//         "assign_to": assignTo,
//         "images":
//             images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
//         "task_extend_details": taskExtendDetails == null
//             ? []
//             : List<dynamic>.from(taskExtendDetails!.map((x) => x.toJson())),
//       };
// }

// class TaskExtendDetail {
//   String? extendedDate;
//   String? extendedBy;

//   TaskExtendDetail({
//     this.extendedDate,
//     this.extendedBy,
//   });

//   factory TaskExtendDetail.fromJson(Map<String, dynamic> json) =>
//       TaskExtendDetail(
//         extendedDate: json["extended_date"],
//         extendedBy: json["extended_by"],
//       );

//   Map<String, dynamic> toJson() => {
//         "extended_date": extendedDate,
//         "extended_by": extendedBy,
//       };
// }

// // class EnumValues<T> {
// //   Map<String, T> map;
// //   late Map<T, String> reverseMap;

// //   EnumValues(this.map);

// //   Map<T, String> get reverse {
// //     reverseMap = map.map((k, v) => MapEntry(v, k));
// //     return reverseMap;
// //   }
// // }
// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_user_task_by_id.dart';

NotificationResponse notificationResponseFromJson(String str) =>
    NotificationResponse.fromJson(json.decode(str));

String notificationResponseToJson(NotificationResponse data) =>
    json.encode(data.toJson());

class NotificationResponse {
  ResponseNotificationResponse? response;

  NotificationResponse({
    this.response,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      NotificationResponse(
        response: json["Response"] == null
            ? null
            : ResponseNotificationResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseNotificationResponse {
  String? errorCode;
  String? msg;
  List<NotificationList>? notificationList;
  String? offset;

  ResponseNotificationResponse({
    this.errorCode,
    this.msg,
    this.notificationList,
    this.offset,
  });

  factory ResponseNotificationResponse.fromJson(Map<String, dynamic> json) =>
      ResponseNotificationResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        notificationList: json["notification_list"] == null
            ? []
            : List<NotificationList>.from(json["notification_list"]!
                .map((x) => NotificationList.fromJson(x))),
        offset: json["offset"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "notification_list": notificationList == null
            ? []
            : List<dynamic>.from(notificationList!.map((x) => x.toJson())),
        "offset": offset,
      };
}

class NotificationList {
  String? mstNotificationId;
  String? msg;
  String? notificationType;
  ResponseClass? response;
  String? projectName;
  String? projectLocation;
  String? projectId;
  String? showStatus;
  DateTime? updateAt;
  DateTime? createdAt;
  String? towarIdFk;
  String? notificationModuleType;
  String? categoryId;

  NotificationList({
    this.mstNotificationId,
    this.msg,
    this.notificationType,
    this.response,
    this.projectName,
    this.projectLocation,
    this.projectId,
    this.showStatus,
    this.updateAt,
    this.createdAt,
    this.towarIdFk,
    this.notificationModuleType,
    this.categoryId,
  });

  factory NotificationList.fromJson(Map<String, dynamic> json) =>
      NotificationList(
        mstNotificationId: json["mst_notification_id"]?.toString() ?? json["id"]?.toString(),
        msg: json["msg"] ?? json["body"],
        notificationType: json["notification_type"] ?? json["type"],
        response: json["response"] == null
            ? null
            : ResponseClass.fromJson(json["response"]),
        projectName: json["project_name"],
        projectLocation: json["project_location"],
        projectId: json["project_id"]?.toString(),
        showStatus: json["show_status"]?.toString(),
        updateAt: json["update_at"] == null
            ? null
            : DateTime.tryParse(json["update_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"]),
        towarIdFk: json["towar_id_fk"]?.toString() ?? json["tower_id"]?.toString() ?? json["towar_id"]?.toString(),
        notificationModuleType: json["notification_module_type"],
        categoryId: json["category_id"]?.toString() ?? json["categoryId"]?.toString() ?? json["sop_id"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "mst_notification_id": mstNotificationId,
        "msg": msg,
        "notification_type": notificationType,
        "response": response?.toJson(),
        "project_name": projectName,
        "project_location": projectLocation,
        "project_id": projectId,
        "show_status": showStatus,
        "update_at": updateAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "towar_id_fk": towarIdFk,
        "notification_module_type": notificationModuleType,
        "category_id": categoryId,
      };
}

// final projectNameValues =
//     EnumValues({"Vaibhav Commercial": ProjectName.VAIBHAV_COMMERCIAL});

class ResponseClass {
  String? projectId;
  String? permissionId;
  String? slabId;
  String? towarId;
  String? categoryId;
  String? slabNo;
  String? orderId;
  String? venderId;
  String? venderType;
  String? companyName;
  String? woOrderId;
  String? woOrderNo;
  List<UserTask>? userTask;

  ResponseClass({
    this.projectId,
    this.permissionId,
    this.slabId,
    this.towarId,
    this.categoryId,
    this.slabNo,
    this.orderId,
    this.venderId,
    this.venderType,
    this.companyName,
    this.woOrderId,
    this.woOrderNo,
    this.userTask,
  });

  factory ResponseClass.fromJson(Map<String, dynamic> json) => ResponseClass(
        projectId: json["project_id"]?.toString(),
        permissionId: json["permission_id"]?.toString(),
        slabId: json["slab_id"]?.toString(),
        towarId: json["towar_id"]?.toString() ?? json["tower_id"]?.toString(),
        categoryId: json["category_id"]?.toString() ?? json["categoryId"]?.toString() ?? json["sop_id"]?.toString(),
        slabNo: json["slab_no"]?.toString(),
        orderId: json["order_id"]?.toString(),
        venderId: json["vender_id"]?.toString(),
        venderType: json["vender_type"]?.toString(),
        companyName: json["company_name"]?.toString(),
        woOrderId: json["wo_order_id"]?.toString(),
        woOrderNo: json["wo_order_no"]?.toString(),
        userTask: json["user_task"] == null
            ? []
            : List<UserTask>.from(
                json["user_task"]!.map((x) => UserTask.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "project_id": projectId,
        "permission_id": permissionId,
        "slab_id": slabId,
        "towar_id": towarId,
        "category_id": categoryId,
        "slab_no": slabNo,
        "order_id": orderId,
        "vender_id": venderId,
        "vender_type": venderType,
        "company_name": companyName,
        "wo_order_id": woOrderId,
        "wo_order_no": woOrderNo,
        "user_task": userTask == null
            ? []
            : List<dynamic>.from(userTask!.map((x) => x.toJson())),
      };
}

// class UserTask {
//   String? projectIdFk;
//   String? mettingIdFk;
//   String? taskId;
//   String? taskTitle;
//   String? taskDeadline;
//   String? taskCompleteStatus;
//   String? taskCompleteDate;
//   String? taskCreateAt;
//   String? taskCompletedBy;
//   String? taskRemark;
//   String? assignBy;
//   List<dynamic>? shareDetails;
//   String? mettingTitle;
//   String? projectName;
//   String? taskDeadlineStatus;
//   List<String>? taskExtendDates;
//   String? assignTo;
//   List<String>? images;
//   List<TaskExtendDetail>? taskExtendDetails;

//   UserTask({
//     this.projectIdFk,
//     this.mettingIdFk,
//     this.taskId,
//     this.taskTitle,
//     this.taskDeadline,
//     this.taskCompleteStatus,
//     this.taskCompleteDate,
//     this.taskCreateAt,
//     this.taskCompletedBy,
//     this.taskRemark,
//     this.assignBy,
//     this.shareDetails,
//     this.mettingTitle,
//     this.projectName,
//     this.taskDeadlineStatus,
//     this.taskExtendDates,
//     this.assignTo,
//     this.images,
//     this.taskExtendDetails,
//   });

//   factory UserTask.fromJson(Map<String, dynamic> json) => UserTask(
//         projectIdFk: json["project_id_fk"],
//         mettingIdFk: json["metting_id_fk"],
//         taskId: json["task_id"],
//         taskTitle: json["task_title"],
//         taskDeadline: json["task_deadline"],
//         taskCompleteStatus: json["task_complete_status"],
//         taskCompleteDate: json["task_complete_date"],
//         taskCreateAt: json["task_create_at"],
//         taskCompletedBy: json["task_completed_by"],
//         taskRemark: json["task_remark"],
//         assignBy: json["assign_by"],
//         shareDetails: json["share_details"] == null
//             ? []
//             : List<dynamic>.from(json["share_details"]!.map((x) => x)),
//         mettingTitle: json["metting_title"],
//         projectName: json["project_name"],
//         taskDeadlineStatus: json["task_deadline_status"],
//         taskExtendDates: json["task_extend_dates"] == null
//             ? []
//             : List<String>.from(json["task_extend_dates"]!.map((x) => x)),
//         assignTo: json["assign_to"],
//         images: json["images"] == null
//             ? []
//             : List<String>.from(json["images"]!.map((x) => x)),
//         taskExtendDetails: json["task_extend_details"] == null
//             ? []
//             : List<TaskExtendDetail>.from(json["task_extend_details"]!
//                 .map((x) => TaskExtendDetail.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "project_id_fk": projectIdFk,
//         "metting_id_fk": mettingIdFk,
//         "task_id": taskId,
//         "task_title": taskTitle,
//         "task_deadline": taskDeadline,
//         "task_complete_status": taskCompleteStatus,
//         "task_complete_date": taskCompleteDate,
//         "task_create_at": taskCreateAt,
//         "task_completed_by": taskCompletedBy,
//         "task_remark": taskRemark,
//         "assign_by": assignBy,
//         "share_details": shareDetails == null
//             ? []
//             : List<dynamic>.from(shareDetails!.map((x) => x)),
//         "metting_title": mettingTitle,
//         "project_name": projectName,
//         "task_deadline_status": taskDeadlineStatus,
//         "task_extend_dates": taskExtendDates == null
//             ? []
//             : List<dynamic>.from(taskExtendDates!.map((x) => x)),
//         "assign_to": assignTo,
//         "images":
//             images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
//         "task_extend_details": taskExtendDetails == null
//             ? []
//             : List<dynamic>.from(taskExtendDetails!.map((x) => x.toJson())),
//       };
// }

// class TaskExtendDetail {
//   String? extendedDate;
//   String? extendedBy;

//   TaskExtendDetail({
//     this.extendedDate,
//     this.extendedBy,
//   });

//   factory TaskExtendDetail.fromJson(Map<String, dynamic> json) =>
//       TaskExtendDetail(
//         extendedDate: json["extended_date"],
//         extendedBy: json["extended_by"],
//       );

//   Map<String, dynamic> toJson() => {
//         "extended_date": extendedDate,
//         "extended_by": extendedBy,
//       };
// }
