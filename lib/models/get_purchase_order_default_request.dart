// To parse this JSON data, do
//
//     final purchaseDefaultOrderRequest = purchaseDefaultOrderRequestFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_po_requistion_vendor_list.dart';

import 'grade_description.dart';

PurchaseDefaultOrderRequest purchaseDefaultOrderRequestFromJson(String str) =>
    PurchaseDefaultOrderRequest.fromJson(json.decode(str));

String purchaseDefaultOrderRequestToJson(PurchaseDefaultOrderRequest data) =>
    json.encode(data.toJson());

class PurchaseDefaultOrderRequest {
  ResponsePurchaseDefaultOrderRequest? response;

  PurchaseDefaultOrderRequest({
    this.response,
  });

  factory PurchaseDefaultOrderRequest.fromJson(Map<String, dynamic> json) =>
      PurchaseDefaultOrderRequest(
        response: json["Response"] == null
            ? null
            : ResponsePurchaseDefaultOrderRequest.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponsePurchaseDefaultOrderRequest {
  String? errorCode;
  String? msg;
  List<SlabDetail>? slabDetails;
  String? poRequest;
  List<OrderList>? orderList;
  List<FinishingTypeList>? finishingTypeList;
  List<FinishingUnit>? finishingUnit;
  List<AssingToList>? assingToList;
  String? purchaseUserTrack;
  String? customeBtnActive;
  ResponsePurchaseDefaultOrderRequest({
    this.errorCode,
    this.msg,
    this.slabDetails,
    this.poRequest,
    this.orderList,
    this.finishingTypeList,
    this.finishingUnit,
    this.assingToList,
    this.purchaseUserTrack,
    this.customeBtnActive,
  });

  factory ResponsePurchaseDefaultOrderRequest.fromJson(
          Map<String, dynamic> json) =>
      ResponsePurchaseDefaultOrderRequest(
        errorCode: json["error_code"],
        msg: json["msg"],
        slabDetails: json["slab_details"] == null
            ? []
            : List<SlabDetail>.from(
                json["slab_details"]!.map((x) => SlabDetail.fromJson(x))),
        poRequest: json["po_request"],
        orderList: json["order_list"] == null
            ? []
            : List<OrderList>.from(
                json["order_list"]!.map((x) => OrderList.fromJson(x))),
        finishingTypeList: json["finishing_type_list"] == null
            ? []
            : List<FinishingTypeList>.from(json["finishing_type_list"]!
                .map((x) => FinishingTypeList.fromJson(x))),
        finishingUnit: json["finishing_unit"] == null
            ? []
            : List<FinishingUnit>.from(
                json["finishing_unit"]!.map((x) => FinishingUnit.fromJson(x))),
        assingToList: json["assing_to_list"] == null
            ? []
            : List<AssingToList>.from(
                json["assing_to_list"]!.map((x) => AssingToList.fromJson(x))),
        purchaseUserTrack: json["purchase_user_track"],
        customeBtnActive: json["custome_btn_active"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "slab_details": slabDetails == null
            ? []
            : List<dynamic>.from(slabDetails!.map((x) => x.toJson())),
        "po_request": poRequest,
        "order_list": orderList == null
            ? []
            : List<dynamic>.from(orderList!.map((x) => x.toJson())),
        "finishing_type_list": finishingTypeList == null
            ? []
            : List<dynamic>.from(finishingTypeList!.map((x) => x.toJson())),
        "finishing_unit": finishingUnit == null
            ? []
            : List<dynamic>.from(finishingUnit!.map((x) => x.toJson())),
        "assing_to_list": assingToList == null
            ? []
            : List<dynamic>.from(assingToList!.map((x) => x.toJson())),
        "purchase_user_track": purchaseUserTrack,
        "custome_btn_active": customeBtnActive,
      };
}

class FinishingTypeList {
  String? finishingId;
  String? finishingName;
  String? count;
  List<FinishingUnit>? finishingUnit;

  FinishingTypeList({
    this.finishingId,
    this.finishingName,
    this.count,
    this.finishingUnit,
  });

  factory FinishingTypeList.fromJson(Map<String, dynamic> json) =>
      FinishingTypeList(
        finishingId: json["finishing_id"],
        finishingName: json["finishing_name"],
        count: json["count"],
        finishingUnit: json["finishing_unit"] == null
            ? []
            : List<FinishingUnit>.from(
                json["finishing_unit"]!.map((x) => FinishingUnit.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "finishing_id": finishingId,
        "finishing_name": finishingName,
        "count": count,
        "finishing_unit": finishingUnit == null
            ? []
            : List<dynamic>.from(finishingUnit!.map((x) => x.toJson())),
      };
}

class OrderList {
  String? id;
  String? name;
  List<dynamic>? towarList;

  OrderList({
    this.id,
    this.name,
    this.towarList,
  });

  factory OrderList.fromJson(Map<String, dynamic> json) => OrderList(
        id: json["id"],
        name: json["name"],
        towarList: json["towar_list"] == null
            ? []
            : List<dynamic>.from(json["towar_list"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "towar_list": towarList == null
            ? []
            : List<dynamic>.from(towarList!.map((x) => x)),
      };
}

class SlabDetail {
  String? slab_name;
  String? slab_id;
  String? selected;

  SlabDetail({
    this.slab_name,
    this.slab_id,
    this.selected,
  });

  factory SlabDetail.fromJson(Map<String, dynamic> json) => SlabDetail(
        slab_name: json["slab_name"],
        slab_id: json["slab_id"],
        selected: json["selected"] ?? '0',
      );

  Map<String, dynamic> toJson() => {
        "slab_name": slab_name,
        "slab_id": slab_id,
        "selected": selected,
      };
}
