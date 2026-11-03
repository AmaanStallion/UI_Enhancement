// To parse this JSON data, do
//
//     final getProjectAccountManagementNew = getProjectAccountManagementNewFromJson(jsonString);

import 'dart:convert';

GetProjectAccountManagementNew getProjectAccountManagementNewFromJson(
        String str) =>
    GetProjectAccountManagementNew.fromJson(json.decode(str));

String getProjectAccountManagementNewToJson(
        GetProjectAccountManagementNew data) =>
    json.encode(data.toJson());

class GetProjectAccountManagementNew {
  GetProjectAccountManagementNewResponse? response;

  GetProjectAccountManagementNew({
    this.response,
  });

  factory GetProjectAccountManagementNew.fromJson(Map<String, dynamic> json) =>
      GetProjectAccountManagementNew(
        response: json["Response"] == null
            ? null
            : GetProjectAccountManagementNewResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetProjectAccountManagementNewResponse {
  String? errorCode;
  String? msg;
  List<Vendor>? vendorDueList;
  List<Vendor>? vendorOverDue;
  String? paymentDue;
  String? paymentOverdue;
  String? totalPaidAmount;

  GetProjectAccountManagementNewResponse({
    this.errorCode,
    this.msg,
    this.vendorDueList,
    this.vendorOverDue,
    this.paymentDue,
    this.paymentOverdue,
    this.totalPaidAmount,
  });

  factory GetProjectAccountManagementNewResponse.fromJson(
          Map<String, dynamic> json) =>
      GetProjectAccountManagementNewResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        vendorDueList: json["vendor_due_list"] == null
            ? []
            : List<Vendor>.from(
                json["vendor_due_list"]!.map((x) => Vendor.fromJson(x))),
        vendorOverDue: json["vendor_over_due"] == null
            ? []
            : List<Vendor>.from(
                json["vendor_over_due"]!.map((x) => Vendor.fromJson(x))),
        paymentDue: json["payment_due"],
        paymentOverdue: json["payment_overdue"],
        totalPaidAmount: json["total_paid_amount"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "vendor_due_list": vendorDueList == null
            ? []
            : List<dynamic>.from(vendorDueList!.map((x) => x.toJson())),
        "vendor_over_due": vendorOverDue == null
            ? []
            : List<dynamic>.from(vendorOverDue!.map((x) => x.toJson())),
        "payment_due": paymentDue,
        "payment_overdue": paymentOverdue,
        "total_paid_amount": totalPaidAmount,
      };
}

class Vendor {
  String? venderName;
  String? venderId;
  String? gradIdFk;
  String? dueamount;
  String? gradeName;
  String? pendingInvoice;
  String? paidInvCount;
  String? totalInvCount;

  Vendor({
    this.venderName,
    this.venderId,
    this.gradIdFk,
    this.dueamount,
    this.gradeName,
    this.pendingInvoice,
    this.paidInvCount,
    this.totalInvCount,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        venderName: json["vender_name"],
        venderId: json["vender_id"],
        gradIdFk: json["grad_id_fk"],
        dueamount: json["dueamount"],
        gradeName: json["grade_name"],
        pendingInvoice: json["pending_invoice"],
        paidInvCount: json["paidInvCount"],
        totalInvCount: json["totalInvCount"],
      );

  Map<String, dynamic> toJson() => {
        "vender_name": venderName,
        "vender_id": venderId,
        "grad_id_fk": gradIdFk,
        "dueamount": dueamount,
        "grade_name": gradeName,
        "pending_invoice": pendingInvoice,
        "paidInvCount": paidInvCount,
        "totalInvCount": totalInvCount,
      };
}
