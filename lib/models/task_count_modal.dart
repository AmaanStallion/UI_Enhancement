// // To parse this JSON data, do
// //
// //     final taskCountModal = taskCountModalFromJson(jsonString);

// import 'dart:convert';

// TaskCountModal taskCountModalFromJson(String str) =>
//     TaskCountModal.fromJson(json.decode(str));

// String taskCountModalToJson(TaskCountModal data) => json.encode(data.toJson());

// class TaskCountModal {
//   TaskCountModalResponse? response;

//   TaskCountModal({
//     this.response,
//   });

//   factory TaskCountModal.fromJson(Map<String, dynamic> json) => TaskCountModal(
//         response: json["Response"] == null
//             ? null
//             : TaskCountModalResponse.fromJson(json["Response"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "Response": response?.toJson(),
//       };
// }

// class TaskCountModalResponse {
//   String? errorCode;
//   String? msg;
//   List<TaskArr>? taskArr;
//   String? assignToId;

//   TaskCountModalResponse({
//     this.errorCode,
//     this.msg,
//     this.taskArr,
//     this.assignToId,
//   });

//   factory TaskCountModalResponse.fromJson(Map<String, dynamic> json) =>
//       TaskCountModalResponse(
//         errorCode: json["error_code"],
//         msg: json["msg"],
//         taskArr: json["task_arr"] == null
//             ? []
//             : List<TaskArr>.from(
//                 json["task_arr"]!.map((x) => TaskArr.fromJson(x))),
//         assignToId: json["assign_to_id"],
//       );

//   Map<String, dynamic> toJson() => {
//         "error_code": errorCode,
//         "msg": msg,
//         "task_arr": taskArr == null
//             ? []
//             : List<dynamic>.from(taskArr!.map((x) => x.toJson())),
//         "assign_to_id": assignToId,
//       };
// }

// class TaskArr {
//   String? id;
//   String? name;
//   Details? details;

//   TaskArr({
//     this.id,
//     this.name,
//     this.details,
//   });

//   factory TaskArr.fromJson(Map<String, dynamic> json) => TaskArr(
//         id: json["id"],
//         name: json["name"],
//         details:
//             json["details"] == null ? null : Details.fromJson(json["details"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "details": details?.toJson(),
//       };
// }

// class Details {
//   String? totalMyTask;
//   String? compMyTask;
//   String? pendMyTask;
//   String? extendedTask;

//   Details({
//     this.totalMyTask,
//     this.compMyTask,
//     this.pendMyTask,
//     this.extendedTask,
//   });

//   factory Details.fromJson(Map<String, dynamic> json) => Details(
//         totalMyTask: json["total_my_task"],
//         compMyTask: json["comp_my_task"],
//         pendMyTask: json["pend_my_task"],
//         extendedTask: json["extended_task"],
//       );

//   Map<String, dynamic> toJson() => {
//         "total_my_task": totalMyTask,
//         "comp_my_task": compMyTask,
//         "pend_my_task": pendMyTask,
//         "extended_task": extendedTask,
//       };
// }
// To parse this JSON data, do
//
//     final taskCountModal = taskCountModalFromJson(jsonString);

import 'dart:convert';

TaskCountModal taskCountModalFromJson(String str) =>
    TaskCountModal.fromJson(json.decode(str));

String taskCountModalToJson(TaskCountModal data) => json.encode(data.toJson());

class TaskCountModal {
  TaskCountModalResponse? response;

  TaskCountModal({
    this.response,
  });

  factory TaskCountModal.fromJson(Map<String, dynamic> json) => TaskCountModal(
        response: json["Response"] == null
            ? null
            : TaskCountModalResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class TaskCountModalResponse {
  String? errorCode;
  String? msg;
  List<TaskArr>? taskArr;
  String? assignToId;

  TaskCountModalResponse({
    this.errorCode,
    this.msg,
    this.taskArr,
    this.assignToId,
  });

  factory TaskCountModalResponse.fromJson(Map<String, dynamic> json) =>
      TaskCountModalResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        taskArr: json["task_arr"] == null
            ? []
            : List<TaskArr>.from(
                json["task_arr"]!.map((x) => TaskArr.fromJson(x))),
        assignToId: json["assign_to_id"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "task_arr": taskArr == null
            ? []
            : List<dynamic>.from(taskArr!.map((x) => x.toJson())),
        "assign_to_id": assignToId,
      };
}

class TaskArr {
  String? id;
  String? name;
  Details? details;

  TaskArr({
    this.id,
    this.name,
    this.details,
  });

  factory TaskArr.fromJson(Map<String, dynamic> json) => TaskArr(
        id: json["id"],
        name: json["name"],
        details:
            json["details"] == null ? null : Details.fromJson(json["details"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "details": details?.toJson(),
      };
}

class Details {
  String? totalMyTask;
  String? compMyTask;
  String? pendMyTask;
  String? extendedTask;

  Details({
    this.totalMyTask,
    this.compMyTask,
    this.pendMyTask,
    this.extendedTask,
  });

  factory Details.fromJson(Map<String, dynamic> json) => Details(
        totalMyTask: json["total_my_task"],
        compMyTask: json["comp_my_task"],
        pendMyTask: json["pend_my_task"],
        extendedTask: json["extended_task"],
      );

  Map<String, dynamic> toJson() => {
        "total_my_task": totalMyTask,
        "comp_my_task": compMyTask,
        "pend_my_task": pendMyTask,
        "extended_task": extendedTask,
      };
}
