// To parse this JSON data, do
//
//     final getChalanList = getChalanListFromJson(jsonString);

import 'dart:convert';

GetChalanList getChalanListFromJson(String str) =>
    GetChalanList.fromJson(json.decode(str));

String getChalanListToJson(GetChalanList data) => json.encode(data.toJson());

class GetChalanList {
  GetChalanListResponse? response;

  GetChalanList({
    this.response,
  });

  factory GetChalanList.fromJson(Map<String, dynamic> json) => GetChalanList(
        response: json["Response"] == null
            ? null
            : GetChalanListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetChalanListResponse {
  String? errorCode;
  String? msg;
  List<ChallanReportList>? challanReportList;

  GetChalanListResponse({
    this.errorCode,
    this.msg,
    this.challanReportList,
  });

  factory GetChalanListResponse.fromJson(Map<String, dynamic> json) =>
      GetChalanListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        challanReportList: json["challan_report_list"] == null
            ? []
            : List<ChallanReportList>.from(json["challan_report_list"]!
                .map((x) => ChallanReportList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "challan_report_list": challanReportList == null
            ? []
            : List<dynamic>.from(challanReportList!.map((x) => x.toJson())),
      };
}

class ChallanReportList {
  String? poChallanReportId;
  String? orderIdFk;
  String? poChallanRemarks;
  String? poChallanReport;
  String? poChallanStatus;
  DateTime? poChallanUpdatedAt;
  DateTime? poChallanCretatedAt;
  String? fileDelete;

  ChallanReportList({
    this.poChallanReportId,
    this.orderIdFk,
    this.poChallanRemarks,
    this.poChallanReport,
    this.poChallanStatus,
    this.poChallanUpdatedAt,
    this.poChallanCretatedAt,
    this.fileDelete,
  });

  factory ChallanReportList.fromJson(Map<String, dynamic> json) =>
      ChallanReportList(
        poChallanReportId: json["po_challan_report_id"],
        orderIdFk: json["order_id_fk"],
        poChallanRemarks: json["po_challan_remarks"],
        poChallanReport: json["po_challan_report"],
        poChallanStatus: json["po_challan_status"],
        poChallanUpdatedAt: json["po_challan_updated_at"] == null
            ? null
            : DateTime.parse(json["po_challan_updated_at"]),
        poChallanCretatedAt: json["po_challan_cretated_at"] == null
            ? null
            : DateTime.parse(json["po_challan_cretated_at"]),
        fileDelete: json["file_delete"],
      );

  Map<String, dynamic> toJson() => {
        "po_challan_report_id": poChallanReportId,
        "order_id_fk": orderIdFk,
        "po_challan_remarks": poChallanRemarks,
        "po_challan_report": poChallanReport,
        "po_challan_status": poChallanStatus,
        "po_challan_updated_at": poChallanUpdatedAt?.toIso8601String(),
        "po_challan_cretated_at": poChallanCretatedAt?.toIso8601String(),
        "file_delete": fileDelete,
      };
}
