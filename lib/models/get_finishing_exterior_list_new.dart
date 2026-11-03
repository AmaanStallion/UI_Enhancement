// To parse this JSON data, do
//
//     final getFinishingExteriorListNew = getFinishingExteriorListNewFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

GetFinishingExteriorListNew getFinishingExteriorListNewFromJson(String str) =>
    GetFinishingExteriorListNew.fromJson(json.decode(str));

String getFinishingExteriorListNewToJson(GetFinishingExteriorListNew data) =>
    json.encode(data.toJson());

class GetFinishingExteriorListNew {
  Response? response;

  GetFinishingExteriorListNew({
    this.response,
  });

  factory GetFinishingExteriorListNew.fromJson(Map<String, dynamic> json) =>
      GetFinishingExteriorListNew(
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
  List<FinalResult>? finalResult;

  Response({
    this.errorCode,
    this.msg,
    this.finalResult,
  });

  factory Response.fromJson(Map<String, dynamic> json) => Response(
        errorCode: json["error_code"],
        msg: json["msg"],
        finalResult: json["final_result"] == null
            ? []
            : List<FinalResult>.from(
                json["final_result"]!.map((x) => FinalResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "final_result": finalResult == null
            ? []
            : List<dynamic>.from(finalResult!.map((x) => x.toJson())),
      };
}

class FinalResult {
  String? projectIdFk;
  String? towarIdFk;
  String? finishingName;
  String? finishingUnit;
  String? unitName;
  String? cetifyQuantity;
  String? boqQuantity;
  String? finishingId;
  String? boqQuantityTemp;
  TextEditingController? controller;

  FinalResult({
    this.projectIdFk,
    this.towarIdFk,
    this.finishingName,
    this.finishingUnit,
    this.unitName,
    this.cetifyQuantity,
    this.boqQuantity,
    this.finishingId,
    this.controller,
    this.boqQuantityTemp,
  });

  factory FinalResult.fromJson(Map<String, dynamic> json) => FinalResult(
        projectIdFk: json["project_id_fk"],
        towarIdFk: json["towar_id_fk"],
        finishingName: json["finishing_name"],
        finishingUnit: json["finishing_unit"],
        unitName: json["unit_name"],
        cetifyQuantity: json["cetify_quantity"],
        boqQuantity: json["boq_quantity"],
        boqQuantityTemp: json["boq_quantity"],
        finishingId: json["finishing_id"],
        controller: TextEditingController(),
      );

  Map<String, dynamic> toJson() => {
        "project_id_fk": projectIdFk,
        "towar_id_fk": towarIdFk,
        "finishing_name": finishingName,
        "finishing_unit": finishingUnit,
        "unit_name": unitName,
        "cetify_quantity": cetifyQuantity,
        "boq_quantity": boqQuantity,
        "finishing_id": finishingId,
      };
}

class FinalResultTemp {
  String? qty;
  String? id;

  FinalResultTemp({
    this.id,
    this.qty,
  });

  factory FinalResultTemp.fromJson(Map<String, dynamic> json) =>
      FinalResultTemp(
        qty: json["qty"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "qty": qty,
        "id": id,
      };
}
