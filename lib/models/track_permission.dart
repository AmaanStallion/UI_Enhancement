// To parse this JSON data, do
//
//     final tracklPermission = tracklPermissionFromJson(jsonString);

import 'dart:convert';

TracklPermission tracklPermissionFromJson(String str) =>
    TracklPermission.fromJson(json.decode(str));

String tracklPermissionToJson(TracklPermission data) =>
    json.encode(data.toJson());

class TracklPermission {
  TracklPermissionResponse? response;

  TracklPermission({
    this.response,
  });

  factory TracklPermission.fromJson(Map<String, dynamic> json) =>
      TracklPermission(
        response: json["Response"] == null
            ? null
            : TracklPermissionResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class TracklPermissionResponse {
  String? errorCode;
  String? msg;
  List<PermissionTrackingList>? permissionTrackingList;

  TracklPermissionResponse({
    this.errorCode,
    this.msg,
    this.permissionTrackingList,
  });

  factory TracklPermissionResponse.fromJson(Map<String, dynamic> json) =>
      TracklPermissionResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        permissionTrackingList: json["permission_tracking_list"] == null
            ? []
            : List<PermissionTrackingList>.from(
                json["permission_tracking_list"]!
                    .map((x) => PermissionTrackingList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "permission_tracking_list": permissionTrackingList == null
            ? []
            : List<dynamic>.from(
                permissionTrackingList!.map((x) => x.toJson())),
      };
}

class PermissionTrackingList {
  String? transEmpName;
  String? transEmpId;
  String? pendingCount;
  String? totalCount;

  PermissionTrackingList({
    this.transEmpName,
    this.transEmpId,
    this.pendingCount,
    this.totalCount,
  });

  factory PermissionTrackingList.fromJson(Map<String, dynamic> json) =>
      PermissionTrackingList(
        transEmpName: json["trans_emp_name"],
        transEmpId: json["trans_emp_id"],
        pendingCount: json["pending_count"],
        totalCount: json["total_count"],
      );

  Map<String, dynamic> toJson() => {
        "trans_emp_name": transEmpName,
        "trans_emp_id": transEmpId,
        "pending_count": pendingCount,
        "total_count": totalCount,
      };
}
