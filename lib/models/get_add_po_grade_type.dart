// To parse this JSON data, do
//
//     final getPoGradeType = getPoGradeTypeFromJson(jsonString);

import 'dart:convert';

import 'get_purchase_order_default_request.dart';
import 'grade_description.dart';

GetPoGradeType getPoGradeTypeFromJson(String str) =>
    GetPoGradeType.fromJson(json.decode(str));

String getPoGradeTypeToJson(GetPoGradeType data) => json.encode(data.toJson());

class GetPoGradeType {
  GetPoGradeType({
    this.response,
  });

  ResponseGetPoGradeType? response;

  factory GetPoGradeType.fromJson(Map<String, dynamic> json) => GetPoGradeType(
        response: json["Response"],
      );

  Map<String, dynamic> toJson() => {
        "Response": response,
      };
}

class ResponseGetPoGradeType {
  ResponseGetPoGradeType({
    this.errorCode,
    this.msg,
    this.finishingTypeList,
    this.finishingUnit,
  });

  String? errorCode;
  String? msg;
  List<FinishingTypeList>? finishingTypeList;
  List<FinishingUnit>? finishingUnit;

  factory ResponseGetPoGradeType.fromJson(Map<String, dynamic> json) =>
      ResponseGetPoGradeType(
        errorCode: json["error_code"],
        msg: json["msg"],
        finishingTypeList: List<FinishingTypeList>.from(
            json["finishing_type_list"]!
                .map((x) => FinishingTypeList.fromJson(x))),
        finishingUnit: List<FinishingUnit>.from(
            json["finishing_unit"]!.map((x) => FinishingUnit.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "finishing_type_list":
            List<dynamic>.from(finishingTypeList!.map((x) => x.toJson())),
        "finishing_unit":
            List<dynamic>.from(finishingUnit!.map((x) => x.toJson())),
      };
}
