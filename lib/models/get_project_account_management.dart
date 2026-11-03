// To parse this JSON data, do
//
//     final getProjectAccountManagement = getProjectAccountManagementFromJson(jsonString);

import 'dart:convert';

GetProjectAccountManagement getProjectAccountManagementFromJson(String str) =>
    GetProjectAccountManagement.fromJson(json.decode(str));

String getProjectAccountManagementToJson(GetProjectAccountManagement data) =>
    json.encode(data.toJson());

class GetProjectAccountManagement {
  GetProjectAccountManagement({
    this.response,
  });

  ResponseGetProjectAccountManagement? response;

  factory GetProjectAccountManagement.fromJson(Map<String, dynamic> json) =>
      GetProjectAccountManagement(
        response:
            ResponseGetProjectAccountManagement.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetProjectAccountManagement {
  ResponseGetProjectAccountManagement({
    this.errorCode,
    this.showAccounts,
    this.msg,
    this.paymentRequest,
    this.paymentApproved,
    this.woRaise,
    this.woGenerated,
    this.woIssued,
    this.poPending,
    this.poAssing,
    this.poIssued,
    this.poDispute,
    this.paymentDue,
    this.paymentOverdue,
    this.totalCost,
    this.towarList,
  });

  String? errorCode;
  String? showAccounts;
  String? msg;
  String? paymentRequest;
  String? paymentApproved;
  String? woRaise;
  String? woGenerated;
  String? woIssued;
  String? poPending;
  String? poAssing;
  String? poIssued;
  String? poDispute;
  String? paymentDue;
  String? paymentOverdue;
  String? totalCost;
  List<TowarList>? towarList;

  factory ResponseGetProjectAccountManagement.fromJson(
          Map<String, dynamic> json) =>
      ResponseGetProjectAccountManagement(
        errorCode: json["error_code"],
        showAccounts: json["show_accounts"],
        msg: json["msg"],
        paymentRequest: json["payment_request"],
        paymentApproved: json["payment_approved"],
        woRaise: json["wo_raise"],
        woGenerated: json["wo_generated"],
        woIssued: json["wo_issued"],
        poPending: json["po_pending"],
        poAssing: json["po_assing"],
        poIssued: json["po_issued"],
        poDispute: json["po_dispute"],
        paymentDue: json["payment_due"],
        paymentOverdue: json["payment_overdue"],
        totalCost: json["total_cost"],
        towarList: json["towar_list"] == null
            ? []
            : List<TowarList>.from(
                json["towar_list"].map((x) => TowarList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "show_accounts": showAccounts,
        "msg": msg,
        "payment_request": paymentRequest,
        "payment_approved": paymentApproved,
        "wo_raise": woRaise,
        "wo_generated": woGenerated,
        "wo_issued": woIssued,
        "po_pending": poPending,
        "po_assing": poAssing,
        "po_issued": poIssued,
        "po_dispute": poDispute,
        "payment_due": paymentDue,
        "payment_overdue": paymentOverdue,
        "total_cost": totalCost,
        "towar_list": towarList == null
            ? []
            : List<dynamic>.from(towarList!.map((x) => x.toJson())),
      };
}

class TowarList {
  TowarList({
    this.towarId,
    this.towarName,
  });

  String? towarId;
  String? towarName;

  factory TowarList.fromJson(Map<String, dynamic> json) => TowarList(
        towarId: json["towar_id"] ?? "",
        towarName: json["towar_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "towar_id": towarId ?? "",
        "towar_name": towarName ?? "",
      };
}
