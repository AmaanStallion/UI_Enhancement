// To parse this JSON data, do
//
//     final brokerMettingDetailModal = brokerMettingDetailModalFromJson(jsonString);

import 'dart:convert';

BrokerMettingDetailModal brokerMettingDetailModalFromJson(String str) =>
    BrokerMettingDetailModal.fromJson(json.decode(str));

String brokerMettingDetailModalToJson(BrokerMettingDetailModal data) =>
    json.encode(data.toJson());

class BrokerMettingDetailModal {
  BrokerMettingDetailModalResponse? response;

  BrokerMettingDetailModal({
    this.response,
  });

  factory BrokerMettingDetailModal.fromJson(Map<String, dynamic> json) =>
      BrokerMettingDetailModal(
        response: json["Response"] == null
            ? null
            : BrokerMettingDetailModalResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class BrokerMettingDetailModalResponse {
  String? errorCode;
  String? msg;
  List<BrokerMeetingList>? brokerMeetingList;

  BrokerMettingDetailModalResponse({
    this.errorCode,
    this.msg,
    this.brokerMeetingList,
  });

  factory BrokerMettingDetailModalResponse.fromJson(
          Map<String, dynamic> json) =>
      BrokerMettingDetailModalResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        brokerMeetingList: json["broker_meeting_list"] == null
            ? []
            : List<BrokerMeetingList>.from(json["broker_meeting_list"]!
                .map((x) => BrokerMeetingList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "broker_meeting_list": brokerMeetingList == null
            ? []
            : List<dynamic>.from(brokerMeetingList!.map((x) => x.toJson())),
      };
}

class BrokerMeetingList {
  String? id;
  String? projectIdFk;
  String? towarIdFk;
  String? brokerIdFk;
  DateTime? date;
  String? remark;
  String? userIdFk;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? brokerName;
  String? userName;

  BrokerMeetingList({
    this.id,
    this.projectIdFk,
    this.towarIdFk,
    this.brokerIdFk,
    this.date,
    this.remark,
    this.userIdFk,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.brokerName,
    this.userName,
  });

  factory BrokerMeetingList.fromJson(Map<String, dynamic> json) =>
      BrokerMeetingList(
        id: json["id"],
        projectIdFk: json["project_id_fk"],
        towarIdFk: json["towar_id_fk"],
        brokerIdFk: json["broker_id_fk"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        remark: json["remark"],
        userIdFk: json["user_id_fk"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        brokerName: json["broker_name"],
        userName: json["user_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "project_id_fk": projectIdFk,
        "towar_id_fk": towarIdFk,
        "broker_id_fk": brokerIdFk,
        "date":
            "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "remark": remark,
        "user_id_fk": userIdFk,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "broker_name": brokerName,
        "user_name": userName,
      };
}
