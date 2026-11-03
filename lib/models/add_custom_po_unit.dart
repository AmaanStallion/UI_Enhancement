// To parse this JSON data, do
//
//     final getFinishingUnit = getFinishingUnitFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

import 'grade_description.dart';

GetFinishingUnit getFinishingUnitFromJson(String str) =>
    GetFinishingUnit.fromJson(json.decode(str));

String getFinishingUnitToJson(GetFinishingUnit data) =>
    json.encode(data.toJson());

class GetFinishingUnit {
  GetFinishingUnit({
    this.response,
  });

  ResponseGetFinishingUnit? response;

  factory GetFinishingUnit.fromJson(Map<String, dynamic> json) =>
      GetFinishingUnit(
        response: ResponseGetFinishingUnit.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetFinishingUnit {
  ResponseGetFinishingUnit({
    this.errorCode,
    this.msg,
    this.finishingUnit,
    this.similarDescription,
  });

  String? errorCode;
  String? msg;
  List<FinishingUnit>? finishingUnit;
  List<SimilarDescription>? similarDescription;

  factory ResponseGetFinishingUnit.fromJson(Map<String, dynamic> json) =>
      ResponseGetFinishingUnit(
        errorCode: json["error_code"],
        msg: json["msg"],
        finishingUnit: List<FinishingUnit>.from(
            json["finishing_unit"].map((x) => FinishingUnit.fromJson(x))),
        similarDescription: List<SimilarDescription>.from(
            json["similar_description"]
                .map((x) => SimilarDescription.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "finishing_unit":
            List<dynamic>.from(finishingUnit!.map((x) => x.toJson())),
        "similar_description":
            List<dynamic>.from(similarDescription!.map((x) => x.toJson())),
      };
}

class POformDataArrayList {
  POformDataArrayList({
    required this.grade_id,
    required this.grade_type_name,
    required this.casting_date,
    required this.casting_for,
    required this.casting_unit_name,
    required this.casting_unit,
    required this.quantity,
    required this.unit_price,
    required this.total_amount,
    required this.description,
    required this.brand_supplier_name,
    required this.id,
    required this.editingControllerGradeTypeName, //req type
    required this.editingControllerDescription, // descrip/ sub type
    required this.editingControllerCastingFor, // req for
    required this.editingControllerCastingDate, // req date
    required this.editingControllerQuantity, // qty
    required this.editingControllerCastingUnitName, // qty unit
    required this.editingControllerUnitPrice, // unitprice
    required this.editingControllerTotalAmount, // total price
    required this.editingControllerBrandName, //  brand NAME
    this.vendor_type_grade_id,
    this.slab_ids,
  });

  String grade_id;
  String grade_type_name; //req type
  String casting_date; // req date
  String casting_for; // req for
  String casting_unit_name; // qty unit
  String casting_unit;
  String quantity; // qty
  String unit_price; // unitprice
  String total_amount; // total price
  String description; // descrip/ sub type
  String brand_supplier_name; // descrip/ sub type
  String? vendor_type_grade_id;
  List<String>? slab_ids;

  String id;
  TextEditingController? editingControllerGradeTypeName; //req type
  TextEditingController? editingControllerDescription; // descrip/ sub type
  TextEditingController? editingControllerCastingFor; // req for
  TextEditingController? editingControllerBrandName; // req for

  TextEditingController? editingControllerCastingDate; // req date
  TextEditingController? editingControllerQuantity; // qty
  TextEditingController? editingControllerCastingUnitName; // qty unit
  TextEditingController? editingControllerUnitPrice; // unitprice
  TextEditingController? editingControllerTotalAmount; // total price
  Map<String, dynamic> toJson() => {
        "grade_id": grade_id,
        "grade_type_name": grade_type_name,
        "casting_date": casting_date,
        "casting_for": casting_for,
        "casting_unit_name": casting_unit_name,
        "casting_unit": casting_unit,
        "quantity": quantity,
        "unit_price": unit_price,
        "total_amount": total_amount,
        "description": description,
        "brand_supplier_name": brand_supplier_name,
        "id": id,
        "vendor_type_id": grade_id,
        "vendor_type_grade_id": vendor_type_grade_id,
        "po_unit_id": casting_unit,
        "slab_ids": slab_ids ?? [],
        "requirement_date": casting_date,
        "brand_name": brand_supplier_name,
      };
}
