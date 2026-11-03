// To parse this JSON data, do
//
//     final mettingDetailsByUser = mettingDetailsByUserFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_meeting_id.dart';

MettingDetailsByUser mettingDetailsByUserFromJson(String str) =>
    MettingDetailsByUser.fromJson(json.decode(str));

String mettingDetailsByUserToJson(MettingDetailsByUser data) =>
    json.encode(data.toJson());

class MettingDetailsByUser {
  MettingDetailsByUserResponse? response;

  MettingDetailsByUser({
    this.response,
  });

  factory MettingDetailsByUser.fromJson(Map<String, dynamic> json) =>
      MettingDetailsByUser(
        response: json["Response"] == null
            ? null
            : MettingDetailsByUserResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class MettingDetailsByUserResponse {
  String? errorCode;
  String? msg;
  String? totalTaskPending;
  List<MettingDatum>? mettingData;
  List<dynamic>? orderList;
  String? profileId;

  MettingDetailsByUserResponse({
    this.errorCode,
    this.msg,
    this.totalTaskPending,
    this.mettingData,
    this.orderList,
    this.profileId,
  });

  factory MettingDetailsByUserResponse.fromJson(Map<String, dynamic> json) =>
      MettingDetailsByUserResponse(
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
        profileId: json["profile_id"],
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
        "profile_id": profileId,
      };
}
