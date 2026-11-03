// To parse this JSON data, do
//
//     final finishingFlatListing = finishingFlatListingFromJson(jsonString);

import 'dart:convert';

FinishingFlatListing finishingFlatListingFromJson(String str) =>
    FinishingFlatListing.fromJson(json.decode(str));

String finishingFlatListingToJson(FinishingFlatListing data) =>
    json.encode(data.toJson());

class FinishingFlatListing {
  Response? response;

  FinishingFlatListing({
    this.response,
  });

  factory FinishingFlatListing.fromJson(Map<String, dynamic> json) =>
      FinishingFlatListing(
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
  List<FinishingList>? finishingList;
  List<BottomBar>? bottomBar;

  Response({
    this.errorCode,
    this.msg,
    this.finishingList,
    this.bottomBar,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        errorCode: json["error_code"],
        msg: json["msg"],
        finishingList: json["finishing_list"] == null
            ? []
            : List<FinishingList>.from(
                json["finishing_list"]!.map((x) => FinishingList.fromJson(x))),
        bottomBar: json["bottom_bar"] == null
            ? []
            : List<BottomBar>.from(
                json["bottom_bar"]!.map((x) => BottomBar.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "finishing_list": finishingList == null
            ? []
            : List<dynamic>.from(finishingList!.map((x) => x.toJson())),
        "bottom_bar": bottomBar == null
            ? []
            : List<dynamic>.from(bottomBar!.map((x) => x.toJson())),
      };
}

class BottomBar {
  String? totalList;
  String? completed;
  String? pending;

  BottomBar({
    this.totalList,
    this.completed,
    this.pending,
  });

  factory BottomBar.fromJson(Map<String, dynamic> json) => BottomBar(
        totalList: json["total_list"],
        completed: json["completed"],
        pending: json["pending"],
      );

  Map<String, dynamic> toJson() => {
        "total_list": totalList,
        "completed": completed,
        "pending": pending,
      };
}

class FinishingList {
  String? id;
  String? name;
  String? unitId;
  String? unitName;
  String? totalQty;
  String? remaingQty;
  String? consumQty;
  String? gradeName;
  String? finishingId;
  String? mstFinishInvQtyId;
  String? finishInvQuantity;

  FinishingList({
    this.id,
    this.name,
    this.unitId,
    this.unitName,
    this.totalQty,
    this.remaingQty,
    this.consumQty,
    this.gradeName,
    this.finishingId,
    this.mstFinishInvQtyId,
    this.finishInvQuantity,
  });

  factory FinishingList.fromJson(Map<String, dynamic> json) => FinishingList(
        id: json["id"],
        name: json["name"],
        unitId: json["unit_id"],
        unitName: json["unit_name"],
        totalQty: json["total_qty"],
        remaingQty: json["remaing_qty"],
        consumQty: json["consum_qty"],
        gradeName: json["grade_name"],
        finishingId: json["finishing_id"],
        mstFinishInvQtyId: json["mst_finish_inv_qty_id"],
        finishInvQuantity: json["finish_inv_quantity"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "unit_id": unitId,
        "unit_name": unitName,
        "total_qty": totalQty,
        "remaing_qty": remaingQty,
        "consum_qty": consumQty,
        "grade_name": gradeName,
        "finishing_id": finishingId,
        "mst_finish_inv_qty_id": mstFinishInvQtyId,
        "finish_inv_quantity": finishInvQuantity,
      };
}

// enum UnitName { BUA, NOS, SQ_FT }

// final unitNameValues = EnumValues(
//     {"BUA": UnitName.BUA, "Nos": UnitName.NOS, "Sq.Ft ": UnitName.SQ_FT});

// class EnumValues<T> {
//   Map<String, T> map;
//   late Map<T, String> reverseMap;

//   EnumValues(this.map);

//   Map<T, String> get reverse {
//     reverseMap = map.map((k, v) => MapEntry(v, k));
//     return reverseMap;
//   }
// }
