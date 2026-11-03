// // To parse this JSON data, do
// //
// //     final notificationFilter = notificationFilterFromJson(jsonString);

// import 'dart:convert';

// NotificationFilter notificationFilterFromJson(String str) =>
//     NotificationFilter.fromJson(json.decode(str));

// String notificationFilterToJson(NotificationFilter data) =>
//     json.encode(data.toJson());

// class NotificationFilter {
//   NotificationFilterResponse? response;

//   NotificationFilter({
//     this.response,
//   });

//   factory NotificationFilter.fromJson(Map<String, dynamic> json) =>
//       NotificationFilter(
//         response: json["Response"] == null
//             ? null
//             : NotificationFilterResponse.fromJson(json["Response"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "Response": response?.toJson(),
//       };
// }

// class NotificationFilterResponse {
//   String? errorCode;
//   String? msg;
//   List<NotificationFillter>? notificationFillter;

//   NotificationFilterResponse({
//     this.errorCode,
//     this.msg,
//     this.notificationFillter,
//   });

//   factory NotificationFilterResponse.fromJson(Map<String, dynamic> json) =>
//       NotificationFilterResponse(
//         errorCode: json["error_code"],
//         msg: json["msg"],
//         notificationFillter: json["notification_fillter"] == null
//             ? []
//             : List<NotificationFillter>.from(json["notification_fillter"]!
//                 .map((x) => NotificationFillter.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "error_code": errorCode,
//         "msg": msg,
//         "notification_fillter": notificationFillter == null
//             ? []
//             : List<dynamic>.from(notificationFillter!.map((x) => x.toJson())),
//       };
// }

// class NotificationFillter {
//   String? id;
//   String? name;
//   List<NotificationFillterDetail>? details;

//   NotificationFillter({
//     this.id,
//     this.name,
//     this.details,
//   });

//   factory NotificationFillter.fromJson(Map<String, dynamic> json) =>
//       NotificationFillter(
//         id: json["id"],
//         name: json["name"],
//         details: json["details"] == null
//             ? []
//             : List<NotificationFillterDetail>.from(json["details"]!
//                 .map((x) => NotificationFillterDetail.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "details": details == null
//             ? []
//             : List<dynamic>.from(details!.map((x) => x.toJson())),
//       };
// }

// class NotificationFillterDetail {
//   String? id;
//   String? name;
//   bool? isSelected = false;
//   int ct = 0;
//   List<NotificationFillterDetail>? details;

//   NotificationFillterDetail({
//     this.id,
//     this.name,
//     this.details,
//     this.isSelected = false,
//     this.ct = 0,
//   });

//   factory NotificationFillterDetail.fromJson(Map<String, dynamic> json) =>
//       NotificationFillterDetail(
//         id: json["id"],
//         name: json["name"],
//         ct: 0,
//         isSelected: false,
//         details: json["details"] == null
//             ? []
//             : List<NotificationFillterDetail>.from(json["details"]!
//                 .map((x) => NotificationFillterDetail.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         // "isSelected": isSelected,
//         "details": details == null
//             ? []
//             : List<dynamic>.from(details!.map((x) => x.toJson())),
//       };
// }

// // class PurpleDetail {
// //   String? id;
// //   String? name;
// //   List<FluffyDetail>? details;

// //   PurpleDetail({
// //     this.id,
// //     this.name,
// //     this.details,
// //   });

// //   factory PurpleDetail.fromJson(Map<String, dynamic> json) => PurpleDetail(
// //         id: json["id"],
// //         name: json["name"],
// //         details: json["details"] == null
// //             ? []
// //             : List<FluffyDetail>.from(
// //                 json["details"]!.map((x) => FluffyDetail.fromJson(x))),
// //       );

// //   Map<String, dynamic> toJson() => {
// //         "id": id,
// //         "name": name,
// //         "details": details == null
// //             ? []
// //             : List<dynamic>.from(details!.map((x) => x.toJson())),
// //       };
// // }

// // class FluffyDetail {
// //   String? id;
// //   String? name;

// //   FluffyDetail({
// //     this.id,
// //     this.name,
// //   });

// //   factory FluffyDetail.fromJson(Map<String, dynamic> json) => FluffyDetail(
// //         id: json["id"],
// //         name: json["name"],
// //       );

// //   Map<String, dynamic> toJson() => {
// //         "id": id,
// //         "name": name,
// //       };
// // }

// To parse this JSON data, do
//
//     final notificationFilter = notificationFilterFromJson(jsonString);

import 'dart:convert';

NotificationFilter notificationFilterFromJson(String str) =>
    NotificationFilter.fromJson(json.decode(str));

String notificationFilterToJson(NotificationFilter data) =>
    json.encode(data.toJson());

class NotificationFilter {
  NotificationFilterResponse? response;

  NotificationFilter({
    this.response,
  });

  factory NotificationFilter.fromJson(Map<String, dynamic> json) =>
      NotificationFilter(
        response: json["Response"] == null
            ? null
            : NotificationFilterResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class NotificationFilterResponse {
  String? errorCode;
  String? msg;
  List<NotificationFillter>? notificationFillter;

  NotificationFilterResponse({
    this.errorCode,
    this.msg,
    this.notificationFillter,
  });

  factory NotificationFilterResponse.fromJson(Map<String, dynamic> json) =>
      NotificationFilterResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        notificationFillter: json["notification_fillter"] == null
            ? []
            : List<NotificationFillter>.from(json["notification_fillter"]!
                .map((x) => NotificationFillter.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "notification_fillter": notificationFillter == null
            ? []
            : List<dynamic>.from(notificationFillter!.map((x) => x.toJson())),
      };
}

class NotificationFillter {
  String? id;
  String? name;
  List<NotificationFillter>? details;
  String? type;
  bool? isSelected = false;
  int ct = 0;

  NotificationFillter({
    this.id,
    this.name,
    this.details,
    this.type,
    this.isSelected = false,
    this.ct = 0,
  });

  factory NotificationFillter.fromJson(Map<String, dynamic> json) =>
      NotificationFillter(
        id: json["id"],
        name: json["name"],
        details: json["details"] == null
            ? []
            : List<NotificationFillter>.from(
                json["details"]!.map((x) => NotificationFillter.fromJson(x))),
        type: json["type"],
        isSelected: false,
        ct: 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
        "type": type,
      };
}
