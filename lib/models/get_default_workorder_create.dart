// To parse this JSON data, do
//
//     final getDefaultWorkorderCreate = getDefaultWorkorderCreateFromJson(jsonString);

import 'dart:convert';

GetDefaultWorkorderCreate getDefaultWorkorderCreateFromJson(String str) =>
    GetDefaultWorkorderCreate.fromJson(json.decode(str));

String getDefaultWorkorderCreateToJson(GetDefaultWorkorderCreate data) =>
    json.encode(data.toJson());

class GetDefaultWorkorderCreate {
  GetDefaultWorkorderCreate({
    this.response,
  });

  ResponseWorkorderCreate? response;

  factory GetDefaultWorkorderCreate.fromJson(Map<String, dynamic> json) =>
      GetDefaultWorkorderCreate(
        response: ResponseWorkorderCreate.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseWorkorderCreate {
  ResponseWorkorderCreate({
    this.errorCode,
    this.msg,
    this.projectList,
    this.gradeList,
    this.companyList,
    this.gradeUnit,
  });

  String? errorCode;
  String? msg;
  List<ProjectList>? projectList = [];
  List<GradeList>? gradeList = [];
  List<CompanyList>? companyList = [];
  List<dynamic>? gradeUnit = [];

  factory ResponseWorkorderCreate.fromJson(Map<String, dynamic> json) =>
      ResponseWorkorderCreate(
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
    this.companyName,
    this.companyId,
    this.projectIdFk,
  });

  String? companyName;
  String? companyId;
  String? projectIdFk;

  factory CompanyList.fromJson(Map<String, dynamic> json) => CompanyList(
        companyName: json["company_name"],
        companyId: json["company_id"],
        projectIdFk: json["project_id_fk"],
      );

  Map<String, dynamic> toJson() => {
        "company_name": companyName,
        "company_id": companyId,
        "project_id_fk": projectIdFk,
      };
}

class GradeList {
  GradeList({
    this.graderName,
    this.gradeId,
    this.companyIdFk,
    this.projectIdFk,
    this.companyList,
  });

  String? graderName;
  String? gradeId;
  String? companyIdFk;
  String? projectIdFk;
  List<CompanyList>? companyList;

  factory GradeList.fromJson(Map<String, dynamic> json) => GradeList(
        graderName: json["grader_name"],
        gradeId: json["grade_id"],
        companyIdFk: json["company_id_fk"],
        projectIdFk: json["project_id_fk"],
        companyList: List<CompanyList>.from(
            json["company_list"].map((x) => CompanyList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "grader_name": graderName,
        "grade_id": gradeId,
        "company_id_fk": companyIdFk,
        "project_id_fk": projectIdFk,
        "company_list": List<dynamic>.from(companyList!.map((x) => x.toJson())),
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
