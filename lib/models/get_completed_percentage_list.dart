// To parse this JSON data, do
//
//     final getCompletedPercentageList = getCompletedPercentageListFromJson(jsonString);

import 'dart:convert';

GetCompletedPercentageList getCompletedPercentageListFromJson(String str) =>
    GetCompletedPercentageList.fromJson(json.decode(str));

String getCompletedPercentageListToJson(GetCompletedPercentageList data) =>
    json.encode(data.toJson());

class GetCompletedPercentageList {
  GetCompletedPercentageList({
    this.response,
  });

  ResponseGetCompletedPercentageList? response;

  factory GetCompletedPercentageList.fromJson(Map<String, dynamic> json) =>
      GetCompletedPercentageList(
        response: ResponseGetCompletedPercentageList.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetCompletedPercentageList {
  ResponseGetCompletedPercentageList({
    this.errorCode,
    this.msg,
    this.quatificationList,
    this.imageUrl,
  });

  String? errorCode;
  String? msg;
  List<QuatificationList>? quatificationList;
  String? imageUrl;

  factory ResponseGetCompletedPercentageList.fromJson(
          Map<String, dynamic> json) =>
      ResponseGetCompletedPercentageList(
        errorCode: json["error_code"],
        msg: json["msg"],
        quatificationList: List<QuatificationList>.from(
            json["quatification_list"]
                .map((x) => QuatificationList.fromJson(x))),
        imageUrl: json["image_url"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "quatification_list":
            List<dynamic>.from(quatificationList!.map((x) => x.toJson())),
        "image_url": imageUrl,
      };
}

class QuatificationList {
  QuatificationList({
    this.mstWoQuatificationId,
    this.transWoIdFk,
    this.woQuatificationValue,
    this.userIdFk,
    this.woQuatificationUpdateAt,
    this.woQuatificationCreatedAt,
    this.woQuatificationRemark,
    this.username,
    this.labReport,
  });

  String? mstWoQuatificationId;
  String? transWoIdFk;
  String? woQuatificationValue;
  String? userIdFk;
  DateTime? woQuatificationUpdateAt;
  DateTime? woQuatificationCreatedAt;
  String? woQuatificationRemark;
  String? username;
  List<dynamic>? labReport;

  factory QuatificationList.fromJson(Map<String, dynamic> json) =>
      QuatificationList(
        mstWoQuatificationId: json["mst_wo_quatification_id"],
        transWoIdFk: json["trans_wo_id_fk"],
        woQuatificationValue: json["wo_quatification_value"],
        userIdFk: json["user_id_fk"],
        woQuatificationUpdateAt:
            DateTime.parse(json["wo_quatification_update_at"]),
        woQuatificationCreatedAt:
            DateTime.parse(json["wo_quatification_created_at"]),
        woQuatificationRemark: json["wo_quatification_remark"],
        username: json["username"],
        labReport: List<dynamic>.from(json["lab_report"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "mst_wo_quatification_id": mstWoQuatificationId,
        "trans_wo_id_fk": transWoIdFk,
        "wo_quatification_value": woQuatificationValue,
        "user_id_fk": userIdFk,
        "wo_quatification_update_at":
            woQuatificationUpdateAt?.toIso8601String(),
        "wo_quatification_created_at":
            woQuatificationCreatedAt?.toIso8601String(),
        "wo_quatification_remark": woQuatificationRemark,
        "username": username,
        "lab_report": List<dynamic>.from(labReport!.map((x) => x)),
      };
}
