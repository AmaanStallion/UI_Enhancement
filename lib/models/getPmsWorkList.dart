// To parse this JSON data, do
//
//     final getPmsWorkList = getPmsWorkListFromJson(jsonString);

import 'dart:convert';

GetPmsWorkList getPmsWorkListFromJson(String str) =>
    GetPmsWorkList.fromJson(json.decode(str));

String getPmsWorkListToJson(GetPmsWorkList data) => json.encode(data.toJson());

class GetPmsWorkList {
  ResponseGetPmsWorkList? response;

  GetPmsWorkList({
    this.response,
  });

  factory GetPmsWorkList.fromJson(Map<String, dynamic> json) => GetPmsWorkList(
        response: json["Response"] == null
            ? null
            : ResponseGetPmsWorkList.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetPmsWorkList {
  String? errorCode;
  String? msg;
  int? offset;
  List<WorkOrderList>? workOrderList;

  ResponseGetPmsWorkList({
    this.errorCode,
    this.msg,
    this.offset,
    this.workOrderList,
  });

  factory ResponseGetPmsWorkList.fromJson(Map<String, dynamic> json) =>
      ResponseGetPmsWorkList(
        errorCode: json["error_code"],
        msg: json["msg"],
        offset: json["offset"],
        workOrderList: json["work_order_list"] == null
            ? []
            : List<WorkOrderList>.from(
                json["work_order_list"]!.map((x) => WorkOrderList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "offset": offset,
        "work_order_list": workOrderList == null
            ? []
            : List<dynamic>.from(workOrderList!.map((x) => x.toJson())),
      };
}

class WorkOrderList {
  String? workOrderId;
  String? workOrderNumber;
  String? companyIdFk;
  String? mstCompanyName;
  String? companyType;
  String? typeMagIdFk;
  String? gradeTypeIdFk;
  String? skillType;

  WorkOrderList({
    this.workOrderId,
    this.workOrderNumber,
    this.companyIdFk,
    this.mstCompanyName,
    this.companyType,
    this.typeMagIdFk,
    this.gradeTypeIdFk,
    this.skillType,
  });

  factory WorkOrderList.fromJson(Map<String, dynamic> json) => WorkOrderList(
        workOrderId: json["work_order_id"],
        workOrderNumber: json["work_order_number"],
        companyIdFk: json["company_id_fk"],
        mstCompanyName: json["mst_company_name"],
        companyType: json["company_type"],
        typeMagIdFk: json["type_mag_id_fk"],
        gradeTypeIdFk: json["grade_type_id_fk"],
        skillType: json["skill_type"],
      );

  Map<String, dynamic> toJson() => {
        "work_order_id": workOrderId,
        "work_order_number": workOrderNumber,
        "company_id_fk": companyIdFk,
        "mst_company_name": mstCompanyName,
        "company_type": companyType,
        "type_mag_id_fk": typeMagIdFk,
        "grade_type_id_fk": gradeTypeIdFk,
        "skill_type": skillType,
      };
}
