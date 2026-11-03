// To parse this JSON data, do
//
//     final addCustomUnit = addCustomUnitFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_default_qorkorder_qty_create.dart';

AddCustomUnit addCustomUnitFromJson(String str) =>
    AddCustomUnit.fromJson(json.decode(str));

String addCustomUnitToJson(AddCustomUnit data) => json.encode(data.toJson());

class AddCustomUnit {
  AddCustomUnit({
    this.response,
  });

  ResponseAddCustomUnit? response;

  factory AddCustomUnit.fromJson(Map<String, dynamic> json) => AddCustomUnit(
        response: ResponseAddCustomUnit.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseAddCustomUnit {
  ResponseAddCustomUnit({
    this.errorCode,
    this.msg,
    this.gradeUnit,
  });

  String? errorCode;
  String? msg;
  List<GradeUnit>? gradeUnit;

  factory ResponseAddCustomUnit.fromJson(Map<String, dynamic> json) =>
      ResponseAddCustomUnit(
        errorCode: json["error_code"],
        msg: json["msg"],
        gradeUnit: List<GradeUnit>.from(
            json["grade_unit"].map((x) => GradeUnit.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "grade_unit": List<dynamic>.from(gradeUnit!.map((x) => x.toJson())),
      };
}

/*class GradeUnit {
  GradeUnit({
    this.unitId,
    this.unitName,
  });

  String? unitId;
  String? unitName;

  factory GradeArrUnit.fromJson(Map<String, dynamic> json) => GradeArrUnit(
    unitId: json["unit_id"],
    unitName: json["unit_name"],
  );

  Map<String, dynamic> toJson() => {
    "unit_id": unitId,
    "unit_name": unitName,
  };
}*/
