// To parse this JSON data, do
//
//     final sopListModal = sopListModalFromJson(jsonString);

import 'dart:convert';

SopListModal sopListModalFromJson(String str) =>
    SopListModal.fromJson(json.decode(str));

String sopListModalToJson(SopListModal data) => json.encode(data.toJson());

class SopListModal {
  Response? response;

  SopListModal({
    this.response,
  });

  factory SopListModal.fromJson(Map<String, dynamic> json) => SopListModal(
        response: json["Response"] == null
            ? null
            : Response.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class Response {
  String? errorCode;
  String? msg;
  List<SopList>? sopList;

  Response({
    this.errorCode,
    this.msg,
    this.sopList,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        errorCode: json["error_code"],
        msg: json["msg"],
        sopList: json["sop_list"] == null
            ? []
            : List<SopList>.from(
                json["sop_list"]!.map((x) => SopList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "sop_list": sopList == null
            ? []
            : List<dynamic>.from(sopList!.map((x) => x.toJson())),
      };
}

class SopList {
  String? id;
  String? name;
  String? towarId;
  String? projectId;
  String? pdfFlag;
  String? totalCount;
  String? completedCount;

  SopList({
    this.id,
    this.name,
    this.towarId,
    this.projectId,
    this.pdfFlag,
    this.totalCount,
    this.completedCount,
  });

  factory SopList.fromJson(Map<String, dynamic> json) => SopList(
        id: json["id"],
        name: json["name"],
        towarId: json["towar_id"],
        projectId: json["project_id"],
        pdfFlag: json["pdf_flag"],
        totalCount: json["total_count"],
        completedCount: json["completed_count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "towar_id": towarId,
        "project_id": projectId,
        "pdf_flag": pdfFlag,
        "total_count": totalCount,
        "completed_count": completedCount,
      };
}
