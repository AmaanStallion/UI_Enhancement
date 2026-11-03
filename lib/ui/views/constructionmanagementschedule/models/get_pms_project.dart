// To parse this JSON data, do
//
//     final getyPmsProjectResponse = getyPmsProjectResponseFromJson(jsonString);

import 'dart:convert';

GetyPmsProjectResponse getyPmsProjectResponseFromJson(String str) =>
    GetyPmsProjectResponse.fromJson(json.decode(str));

String getyPmsProjectResponseToJson(GetyPmsProjectResponse data) =>
    json.encode(data.toJson());

class GetyPmsProjectResponse {
  ResponseGetyPmsProjectResponse? response;

  GetyPmsProjectResponse({
    this.response,
  });

  factory GetyPmsProjectResponse.fromJson(Map<String, dynamic> json) =>
      GetyPmsProjectResponse(
        response: json["Response"] == null
            ? null
            : ResponseGetyPmsProjectResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetyPmsProjectResponse {
  String? errorCode;
  String? msg;
  List<ProjectDefaultLsit>? projectPmsDetails;
  List<ProjectDefaultLsit>? projectDefaultLsit;

  ResponseGetyPmsProjectResponse({
    this.errorCode,
    this.msg,
    this.projectPmsDetails,
    this.projectDefaultLsit,
  });

  factory ResponseGetyPmsProjectResponse.fromJson(Map<String, dynamic> json) =>
      ResponseGetyPmsProjectResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        projectPmsDetails: json["project_pms_details"] == null
            ? []
            : List<ProjectDefaultLsit>.from(json["project_pms_details"]!
                .map((x) => ProjectDefaultLsit.fromJson(x))),
        // json["project_pms_details"] == null
        //     ? []
        //     : List<dynamic>.from(json["project_pms_details"]!.map((x) => x)),
        projectDefaultLsit: json["project_default_lsit"] == null
            ? []
            : List<ProjectDefaultLsit>.from(json["project_default_lsit"]!
                .map((x) => ProjectDefaultLsit.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "project_pms_details": projectPmsDetails == null
            ? []
            : List<dynamic>.from(projectPmsDetails!.map((x) => x)),
        "project_default_lsit": projectDefaultLsit == null
            ? []
            : List<dynamic>.from(projectDefaultLsit!.map((x) => x.toJson())),
      };
}

class ProjectDefaultLsit {
  String? mstProjectPmsId;
  String? projectPmsName;
  String? selectedFlag;
  String? deleteFlag;
  String? projectPmsDecs;

  ProjectDefaultLsit({
    required this.mstProjectPmsId,
    required this.projectPmsName,
    this.projectPmsDecs,
    required this.selectedFlag,
    this.deleteFlag,
  });

  factory ProjectDefaultLsit.fromJson(Map<String, dynamic> json) =>
      ProjectDefaultLsit(
        mstProjectPmsId: json["mst_project_pms_id"],
        projectPmsName: json["project_pms_name"],
        selectedFlag: json["selected_flag"],
        projectPmsDecs: json["project_pms_decs"],
        deleteFlag: json["delete_flag"],
      );

  Map<String, dynamic> toJson() => {
        "mst_project_pms_id": mstProjectPmsId,
        "project_pms_name": projectPmsName,
        "selected_flag": selectedFlag,
        "project_pms_decs": projectPmsDecs,
        "delete_flag": deleteFlag,
      };
}
