// To parse this JSON data, do
//
//     final sopTrackModal = sopTrackModalFromJson(jsonString);

import 'dart:convert';

SopTrackModal sopTrackModalFromJson(String str) =>
    SopTrackModal.fromJson(json.decode(str));

String sopTrackModalToJson(SopTrackModal data) => json.encode(data.toJson());

class SopTrackModal {
  SopTrackModalResponse? response;

  SopTrackModal({
    this.response,
  });

  factory SopTrackModal.fromJson(Map<String, dynamic> json) => SopTrackModal(
        response: json["Response"] == null
            ? null
            : SopTrackModalResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class SopTrackModalResponse {
  String? errorCode;
  String? msg;
  List<SopAssignList>? sopAssignList;

  SopTrackModalResponse({
    this.errorCode,
    this.msg,
    this.sopAssignList,
  });

  factory SopTrackModalResponse.fromJson(Map<String, dynamic> json) =>
      SopTrackModalResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        sopAssignList: json["sop_assign_list"] == null
            ? []
            : List<SopAssignList>.from(
                json["sop_assign_list"]!.map((x) => SopAssignList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "sop_assign_list": sopAssignList == null
            ? []
            : List<dynamic>.from(sopAssignList!.map((x) => x.toJson())),
      };
}

class SopAssignList {
  String? transEmpName;
  String? transEmpId;
  String? pendingCount;
  String? totalCount;

  SopAssignList({
    this.transEmpName,
    this.transEmpId,
    this.pendingCount,
    this.totalCount,
  });

  factory SopAssignList.fromJson(Map<String, dynamic> json) => SopAssignList(
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
