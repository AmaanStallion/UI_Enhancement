// To parse this JSON data, do
//
//     final finishingInteriorQuantification = finishingInteriorQuantificationFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

FinishingInteriorQuantification finishingInteriorQuantificationFromJson(
        String str) =>
    FinishingInteriorQuantification.fromJson(json.decode(str));

String finishingInteriorQuantificationToJson(
        FinishingInteriorQuantification data) =>
    json.encode(data.toJson());

class FinishingInteriorQuantification {
  FinishingInteriorQuantificationResponse? response;

  FinishingInteriorQuantification({
    this.response,
  });

  factory FinishingInteriorQuantification.fromJson(Map<String, dynamic> json) =>
      FinishingInteriorQuantification(
        response: json["Response"] == null
            ? null
            : FinishingInteriorQuantificationResponse.fromJson(
                json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class FinishingInteriorQuantificationResponse {
  String? errorCode;
  String? msg;
  FinalDetails? finalDetails;

  FinishingInteriorQuantificationResponse({
    this.errorCode,
    this.msg,
    this.finalDetails,
  });

  factory FinishingInteriorQuantificationResponse.fromJson(
          Map<String, dynamic> json) =>
      FinishingInteriorQuantificationResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        finalDetails: json["final_details"] == null
            ? null
            : FinalDetails.fromJson(json["final_details"]),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "final_details": finalDetails?.toJson(),
      };
}

class FinalDetails {
  List<HeaderList>? headerList;
  List<BodyList>? bodyList;

  FinalDetails({
    this.headerList,
    this.bodyList,
  });

  factory FinalDetails.fromJson(Map<String, dynamic> json) => FinalDetails(
        headerList: json["header_list"] == null
            ? []
            : List<HeaderList>.from(
                json["header_list"]!.map((x) => HeaderList.fromJson(x))),
        bodyList: json["body_list"] == null
            ? []
            : List<BodyList>.from(
                json["body_list"]!.map((x) => BodyList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "header_list": headerList == null
            ? []
            : List<dynamic>.from(headerList!.map((x) => x.toJson())),
        "body_list": bodyList == null
            ? []
            : List<dynamic>.from(bodyList!.map((x) => x.toJson())),
      };
}

class BodyList {
  String? finishingId;
  String? name;
  String? unit;
  List<Detail>? details;
  String? totalBoq;

  BodyList({
    this.finishingId,
    this.name,
    this.unit,
    this.details,
    this.totalBoq,
  });

  factory BodyList.fromJson(Map<String, dynamic> json) => BodyList(
        finishingId: json["finishing_id"],
        name: json["name"],
        unit: json["unit"],
        details: json["details"] == null
            ? []
            : List<Detail>.from(
                json["details"]!.map((x) => Detail.fromJson(x))),
        totalBoq: json["total_boq"],
      );

  Map<String, dynamic> toJson() => {
        "finishing_id": finishingId,
        "name": name,
        "unit": unit,
        "details": details == null
            ? []
            : List<dynamic>.from(details!.map((x) => x.toJson())),
        "total_boq": totalBoq,
      };
}

class Detail {
  String? id;
  String? inputPunch;
  String? totalQty;
  String? totalBoq;
  String? finishingId;
  String? typeId;
  TextEditingController? controller;

  Detail({
    this.id,
    this.inputPunch,
    this.totalQty,
    this.totalBoq,
    this.controller,
    this.finishingId,
    this.typeId,
  });

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        id: json["id"],
        inputPunch: json["input_punch"],
        totalQty: json["total_qty"],
        totalBoq: json["total_boq"],
        finishingId: json["finishing_id"],
        typeId: json["type_id"],
        controller: TextEditingController(text: json["input_punch"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "input_punch": inputPunch,
        "total_qty": totalQty,
        "total_boq": totalBoq,
        "finishing_id": finishingId,
        "type_id": typeId,
        "controller": TextEditingController(text: "2"),
      };
}

class DetailTemp {
  String? qty;
  String? finishing_id;
  String? type_id;

  DetailTemp({
    this.qty,
    this.finishing_id,
    this.type_id,
  });

  factory DetailTemp.fromJson(Map<String, dynamic> json) => DetailTemp(
        qty: json["qty"],
        finishing_id: json["finishing_id"],
        type_id: json["type_id"],
      );

  Map<String, dynamic> toJson() => {
        "qty": qty,
        "finishing_id": finishing_id,
        "type_id": type_id,
      };
}

class HeaderList {
  String? mstInvFinishTypeId;
  String? projectIdFk;
  String? towarIdFk;
  String? invFinishTypeName;
  String? invFinishTypeSqft;
  String? invFinishTypeStatus;
  String? invFinishTypeCreatedAt;
  String? qtyPerFlat;
  String? inputTypeFlag;

  HeaderList({
    this.mstInvFinishTypeId,
    this.projectIdFk,
    this.towarIdFk,
    this.invFinishTypeName,
    this.invFinishTypeSqft,
    this.invFinishTypeStatus,
    this.invFinishTypeCreatedAt,
    this.qtyPerFlat,
    this.inputTypeFlag,
  });

  factory HeaderList.fromJson(Map<String, dynamic> json) => HeaderList(
        mstInvFinishTypeId: json["mst_inv_finish_type_id"],
        projectIdFk: json["project_id_fk"],
        towarIdFk: json["towar_id_fk"],
        invFinishTypeName: json["inv_finish_type_name"],
        invFinishTypeSqft: json["inv_finish_type_sqft"],
        invFinishTypeStatus: json["inv_finish_type_status"],
        invFinishTypeCreatedAt: json["inv_finish_type_created_at"],
        qtyPerFlat: json["qty_per_flat"],
        inputTypeFlag: json["input_type_flag"],
      );

  Map<String, dynamic> toJson() => {
        "mst_inv_finish_type_id": mstInvFinishTypeId,
        "project_id_fk": projectIdFk,
        "towar_id_fk": towarIdFk,
        "inv_finish_type_name": invFinishTypeName,
        "inv_finish_type_sqft": invFinishTypeSqft,
        "inv_finish_type_status": invFinishTypeStatus,
        "inv_finish_type_created_at": invFinishTypeCreatedAt,
        "qty_per_flat": qtyPerFlat,
        "input_type_flag": inputTypeFlag,
      };
}
