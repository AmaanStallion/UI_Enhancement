// To parse this JSON data, do
//
//     final finishingExterior = finishingExteriorFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/finishing_flat_listing.dart';

FinishingExterior finishingExteriorFromJson(String str) =>
    FinishingExterior.fromJson(json.decode(str));

String finishingExteriorToJson(FinishingExterior data) =>
    json.encode(data.toJson());

class FinishingExterior {
  FinishingExteriorResponse? response;

  FinishingExterior({
    this.response,
  });

  factory FinishingExterior.fromJson(Map<String, dynamic> json) =>
      FinishingExterior(
        response: json["Response"] == null
            ? null
            : FinishingExteriorResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class FinishingExteriorResponse {
  String? errorCode;
  String? msg;
  List<Final>? finalTotalData;
  List<Final>? finalResult;
  List<FinishingList>? finishingList;

  FinishingExteriorResponse({
    this.errorCode,
    this.msg,
    this.finalTotalData,
    this.finalResult,
    this.finishingList,
  });

  factory FinishingExteriorResponse.fromJson(Map<String, dynamic> json) =>
      FinishingExteriorResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        finalTotalData: json["final_total_data"] == null
            ? []
            : List<Final>.from(
                json["final_total_data"]!.map((x) => Final.fromJson(x))),
        finalResult: json["final_result"] == null
            ? []
            : List<Final>.from(
                json["final_result"]!.map((x) => Final.fromJson(x))),
        finishingList: json["finishing_list"] == null
            ? []
            : List<FinishingList>.from(
                json["finishing_list"]!.map((x) => FinishingList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "final_total_data": finalTotalData == null
            ? []
            : List<dynamic>.from(finalTotalData!.map((x) => x.toJson())),
        "final_result": finalResult == null
            ? []
            : List<dynamic>.from(finalResult!.map((x) => x.toJson())),
        "finishing_list": finishingList == null
            ? []
            : List<dynamic>.from(finishingList!.map((x) => x.toJson())),
      };
}

class Final {
  String? gradeName;
  String? finishingId;
  String? floorId;
  String? finishingQty;
  String? consumeQty;

  Final({
    this.gradeName,
    this.finishingId,
    this.floorId,
    this.finishingQty,
    this.consumeQty,
  });

  factory Final.fromJson(Map<String, dynamic> json) => Final(
        gradeName: json["grade_name"],
        finishingId: json["finishing_id"],
        floorId: json["floor_id"],
        finishingQty: json["finishing_qty"],
        consumeQty: json["consume_qty"],
      );

  Map<String, dynamic> toJson() => {
        "grade_name": gradeName,
        "finishing_id": finishingId,
        "floor_id": floorId,
        "finishing_qty": finishingQty,
        "consume_qty": consumeQty,
      };
}

// class FinishingList {
//   String? gradeName;
//   String? finishingId;
//   String? mstFinishInvQtyId;
//   String? finishInvQuantity;

//   FinishingList({
//     this.gradeName,
//     this.finishingId,
//     this.mstFinishInvQtyId,
//     this.finishInvQuantity,
//   });

//   factory FinishingList.fromJson(Map<String, dynamic> json) => FinishingList(
//         gradeName: json["grade_name"],
//         finishingId: json["finishing_id"],
//         mstFinishInvQtyId: json["mst_finish_inv_qty_id"],
//         finishInvQuantity: json["finish_inv_quantity"],
//       );

//   Map<String, dynamic> toJson() => {
//         "grade_name": gradeName,
//         "finishing_id": finishingId,
//         "mst_finish_inv_qty_id": mstFinishInvQtyId,
//         "finish_inv_quantity": finishInvQuantity,
//       };
// }
