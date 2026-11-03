// To parse this JSON data, do
//
//     final getDefaultWorkorderQuantityCreate = getDefaultWorkorderQuantityCreateFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';

GetDefaultWorkorderQuantityCreate getDefaultWorkorderQuantityCreateFromJson(
        String str) =>
    GetDefaultWorkorderQuantityCreate.fromJson(json.decode(str));

String getDefaultWorkorderQuantityCreateToJson(
        GetDefaultWorkorderQuantityCreate data) =>
    json.encode(data.toJson());

class GetDefaultWorkorderQuantityCreate {
  GetDefaultWorkorderQuantityCreate({
    this.response,
  });

  ResponseWorkorderQuantity? response;

  factory GetDefaultWorkorderQuantityCreate.fromJson(
          Map<String, dynamic> json) =>
      GetDefaultWorkorderQuantityCreate(
        response: ResponseWorkorderQuantity.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response!.toJson(),
      };
}

class ResponseWorkorderQuantity {
  ResponseWorkorderQuantity({
    this.errorCode,
    this.msg,
    this.projectList,
    this.gradeList,
    this.companyList,
    this.gradeUnit,
  });

  String? errorCode;
  String? msg;
  List<ProjectList>? projectList;
  List<GradeList>? gradeList;
  List<CompanyList>? companyList;
  List<dynamic>? gradeUnit;

  factory ResponseWorkorderQuantity.fromJson(Map<String, dynamic> json) =>
      ResponseWorkorderQuantity(
        errorCode: json["error_code"],
        msg: json["msg"],
        projectList: List<ProjectList>.from(
            json["project_list"].map((x) => ProjectList.fromJson(x))),
        gradeList: List<GradeList>.from(
            json["grade_list"].map((x) => GradeList.fromJson(x))),
        companyList: List<CompanyList>.from(
            json["company_list"].map((x) => CompanyList.fromJson(x))),
        gradeUnit: List<dynamic>.from(json["grade_unit"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "project_list": List<dynamic>.from(projectList!.map((x) => x.toJson())),
        "grade_list": List<dynamic>.from(gradeList!.map((x) => x.toJson())),
        "company_list": List<dynamic>.from(companyList!.map((x) => x.toJson())),
        "grade_unit": List<dynamic>.from(gradeUnit!.map((x) => x)),
      };
}

class CompanyList {
  CompanyList({
    this.companyId,
    this.companyName,
  });

  String? companyId;
  String? companyName;

  factory CompanyList.fromJson(Map<String, dynamic> json) => CompanyList(
        companyId: json["company_id"],
        companyName: json["company_name"],
      );

  Map<String, dynamic> toJson() => {
        "company_id": companyId,
        "company_name": companyName,
      };
}

class GradeList {
  GradeList({
    this.gradeId,
    this.graderName,
    this.companyIdFk,
    this.companyList,
    this.gradeUnit,
  });

  String? gradeId;
  String? graderName;
  String? companyIdFk;
  List<CompanyList>? companyList;
  List<GradeUnit>? gradeUnit;

  factory GradeList.fromJson(Map<String, dynamic> json) => GradeList(
        gradeId: json["grade_id"],
        graderName: json["grader_name"],
        companyIdFk: json["company_id_fk"],
        companyList: List<CompanyList>.from(
            json["company_list"].map((x) => CompanyList.fromJson(x))),
        gradeUnit: List<GradeUnit>.from(
            json["grade_unit"].map((x) => GradeUnit.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "grade_id": gradeId,
        "grader_name": graderName,
        "company_id_fk": companyIdFk,
        "company_list": List<dynamic>.from(companyList!.map((x) => x.toJson())),
        "grade_unit": List<dynamic>.from(gradeUnit!.map((x) => x.toJson())),
      };
}

class GradeUnit {
  GradeUnit({
    this.unitId,
    this.unitName,
  });

  String? unitId;
  String? unitName;

  factory GradeUnit.fromJson(Map<String, dynamic> json) => GradeUnit(
        unitId: json["unit_id"],
        unitName: json["unit_name"],
      );

  Map<String, dynamic> toJson() => {
        "unit_id": unitId,
        "unit_name": unitName,
      };
}

class ProjectList {
  ProjectList({
    this.projectId,
    this.towarId,
    this.projectName,
    this.developerId,
  });

  String? projectId;
  String? towarId;
  String? projectName;
  String? developerId;

  factory ProjectList.fromJson(Map<String, dynamic> json) => ProjectList(
        projectId: json["project_id"],
        towarId: json["towar_id"],
        projectName: json["project_name"],
        developerId: json["developer_id"],
      );

  Map<String, dynamic> toJson() => {
        "project_id": projectId,
        "towar_id": towarId,
        "project_name": projectName,
        "developer_id": developerId,
      };
}

class QtyWoItems {
  String? woUnit;
  String? castingUnit;
  String? woQuantity;
  String? woUnitPrice;
  String? totalAmount;
  String? woCastingFor;
  String? id;
  String? selectedUnitId;
  TextEditingController? controllerText = TextEditingController();

  QtyWoItems({
    this.woUnit = '',
    this.castingUnit = '',
    this.woQuantity = '',
    this.woUnitPrice = '',
    this.totalAmount = '',
    this.woCastingFor = '',
    this.id = '',
    this.controllerText,
    this.selectedUnitId = '',
  });

  factory QtyWoItems.fromJson(Map<String, dynamic> json) => QtyWoItems(
        woUnit: json["wo_unit"] ?? '',
        castingUnit: json["casting_unit"] ?? '',
        woQuantity: json["wo_quantity"] ?? '',
        woUnitPrice: json["wo_unit_price"] ?? '',
        totalAmount: json["total_amount"] ?? '',
        woCastingFor: json["wo_casting_for"] ?? '',
        id: json["id"] ?? '',
        controllerText: TextEditingController(),
        selectedUnitId: json["selectedUnitId"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "wo_unit": woUnit,
        "casting_unit": castingUnit,
        "wo_quantity": woQuantity,
        "wo_unit_price": woUnitPrice,
        "total_amount": totalAmount,
        "wo_casting_for": woCastingFor,
        "id": id,
        // "controllerText": TextEditingController(),
        "selectedUnitId": selectedUnitId,
      };
}
