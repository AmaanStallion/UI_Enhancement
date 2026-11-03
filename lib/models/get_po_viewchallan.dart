// To parse this JSON data, do
//
//     final getPoViewChallan = getPoViewChallanFromJson(jsonString);

import 'dart:convert';

GetPoViewChallan getPoViewChallanFromJson(String str) =>
    GetPoViewChallan.fromJson(json.decode(str));

String getPoViewChallanToJson(GetPoViewChallan data) =>
    json.encode(data.toJson());

class GetPoViewChallan {
  GetPoViewChallan({
    this.response,
  });

  ResponseGetPoViewChallan? response;

  factory GetPoViewChallan.fromJson(Map<String, dynamic> json) =>
      GetPoViewChallan(
        response: ResponseGetPoViewChallan.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetPoViewChallan {
  ResponseGetPoViewChallan({
    this.errorCode,
    this.msg,
    this.challanReportList,
  });

  String? errorCode;
  String? msg;
  List<ChallanReportList>? challanReportList;

  factory ResponseGetPoViewChallan.fromJson(Map<String, dynamic> json) =>
      ResponseGetPoViewChallan(
        errorCode: json["error_code"],
        msg: json["msg"],
        challanReportList: List<ChallanReportList>.from(
            json["challan_report_list"]
                .map((x) => ChallanReportList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "challan_report_list":
            List<dynamic>.from(challanReportList!.map((x) => x.toJson())),
      };
}

class ChallanReportList {
  ChallanReportList({
    this.poChallanReportId,
    this.orderIdFk,
    this.poChallanRemarks,
    this.poChallanReport,
    this.poChallanStatus,
    this.poChallanUpdatedAt,
    this.poChallanCretatedAt,
  });

  String? poChallanReportId;
  String? orderIdFk;
  String? poChallanRemarks;
  String? poChallanReport;
  String? poChallanStatus;
  DateTime? poChallanUpdatedAt;
  DateTime? poChallanCretatedAt;

  factory ChallanReportList.fromJson(Map<String, dynamic> json) =>
      ChallanReportList(
        poChallanReportId: json["po_challan_report_id"],
        orderIdFk: json["order_id_fk"],
        poChallanRemarks: json["po_challan_remarks"],
        poChallanReport: json["po_challan_report"],
        poChallanStatus: json["po_challan_status"],
        poChallanUpdatedAt: DateTime.parse(json["po_challan_updated_at"]),
        poChallanCretatedAt: DateTime.parse(json["po_challan_cretated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "po_challan_report_id": poChallanReportId,
        "order_id_fk": orderIdFk,
        "po_challan_remarks": poChallanRemarks,
        "po_challan_report": poChallanReport,
        "po_challan_status": poChallanStatus,
        "po_challan_updated_at": poChallanUpdatedAt?.toIso8601String(),
        "po_challan_cretated_at": poChallanCretatedAt?.toIso8601String(),
      };
}
