// To parse this JSON data, do
//
//     final gradeDescription = gradeDescriptionFromJson(jsonString);

import 'dart:convert';

GradeDescription gradeDescriptionFromJson(String str) =>
    GradeDescription.fromJson(json.decode(str));

String gradeDescriptionToJson(GradeDescription data) =>
    json.encode(data.toJson());

class GradeDescription {
  GradeDescription({
    this.response,
  });

  ResponseGradeDescription? response;

  factory GradeDescription.fromJson(Map<String, dynamic> json) =>
      GradeDescription(
        response: ResponseGradeDescription.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGradeDescription {
  ResponseGradeDescription({
    this.errorCode,
    this.msg,
    this.finishingUnit,
    this.similarDescription,
  });

  String? errorCode;
  String? msg;
  List<FinishingUnit>? finishingUnit;
  List<SimilarDescription>? similarDescription;

  factory ResponseGradeDescription.fromJson(Map<String, dynamic> json) =>
      ResponseGradeDescription(
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

class FinishingUnit {
  FinishingUnit({
    this.unitId,
    this.unitName,
    this.flag,
  });

  String? unitId;
  String? unitName;
  String? flag;

  factory FinishingUnit.fromJson(Map<String, dynamic> json) => FinishingUnit(
        unitId: json["unit_id"],
        unitName: json["unit_name"],
        flag: json["flag"],
      );

  Map<String, dynamic> toJson() => {
        "unit_id": unitId,
        "unit_name": unitName,
        "flag": flag,
      };
}

class SimilarDescription {
  SimilarDescription({
    this.transGradeTypeName,
  });

  String? transGradeTypeName;

  factory SimilarDescription.fromJson(Map<String, dynamic> json) =>
      SimilarDescription(
        transGradeTypeName: json["trans_grade_type_name"],
      );

  Map<String, dynamic> toJson() => {
        "trans_grade_type_name": transGradeTypeName,
      };
}
