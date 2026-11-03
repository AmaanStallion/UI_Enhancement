// To parse this JSON data, do
//
//     final getPaymentDueList = getPaymentDueListFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_po_new.dart';

GetPaymentDueList getPaymentDueListFromJson(String str) =>
    GetPaymentDueList.fromJson(json.decode(str));

String getPaymentDueListToJson(GetPaymentDueList data) =>
    json.encode(data.toJson());

class GetPaymentDueList {
  GetPaymentDueList({
    this.response,
  });

  ResponseGetPaymentDueList? response;

  factory GetPaymentDueList.fromJson(Map<String, dynamic> json) =>
      GetPaymentDueList(
        response: ResponseGetPaymentDueList.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetPaymentDueList {
  ResponseGetPaymentDueList({
    this.errorCode,
    this.msg,
    this.vendorDueList,
    this.totalDue,
  });

  String? errorCode;
  String? msg;
  List<Vendor>? vendorDueList;
  String? totalDue;

  factory ResponseGetPaymentDueList.fromJson(Map<String, dynamic> json) =>
      ResponseGetPaymentDueList(
        errorCode: json["error_code"],
        msg: json["msg"],
        vendorDueList: json["vendor_due_list"] == null
            ? []
            : List<Vendor>.from(
                json["vendor_due_list"]!.map((x) => Vendor.fromJson(x))),

        // vendorDueList: List<Vendor>.from(
        //     json["vender_due_list"].map((x) => Vendor.fromJson(x))),
        totalDue: json["total_due"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "vender_due_list":
            List<dynamic>.from(vendorDueList!.map((x) => x.toJson())),
        "total_due": totalDue,
      };
}

// class VenderDueList {
//   VenderDueList({
//     this.venderName,
//     this.venderId,
//     this.gradIdFk,
//     this.dueamount,
//     this.gradeName,
//     this.pendingInvoice,
//   });

//   String? venderName;
//   String? venderId;
//   String? gradIdFk;
//   String? dueamount;
//   String? gradeName;
//   String? pendingInvoice;

//   factory VenderDueList.fromJson(Map<String, dynamic> json) => VenderDueList(
//         venderName: json["vender_name"],
//         venderId: json["vender_id"],
//         gradIdFk: json["grad_id_fk"],
//         dueamount: json["dueamount"],
//         gradeName: json["grade_name"] ?? "",
//         pendingInvoice: json["pending_invoice"],
//       );

//   Map<String, dynamic> toJson() => {
//         "vender_name": venderName,
//         "vender_id": venderId,
//         "grad_id_fk": gradIdFk,
//         "dueamount": dueamount,
//         "grade_name": gradeName,
//         "pending_invoice": pendingInvoice,
//       };
// }
