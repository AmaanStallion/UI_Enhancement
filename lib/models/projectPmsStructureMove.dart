// To parse this JSON data, do
//
//     final projectPmsStructureMove = projectPmsStructureMoveFromJson(jsonString);

import 'dart:convert';

ProjectPmsStructureMove projectPmsStructureMoveFromJson(String str) =>
    ProjectPmsStructureMove.fromJson(json.decode(str));

String projectPmsStructureMoveToJson(ProjectPmsStructureMove data) =>
    json.encode(data.toJson());

class ProjectPmsStructureMove {
  ProjectPmsStructureMoveResponse? response;

  ProjectPmsStructureMove({
    this.response,
  });

  factory ProjectPmsStructureMove.fromJson(Map<String, dynamic> json) =>
      ProjectPmsStructureMove(
        response: json["Response"] == null
            ? null
            : ProjectPmsStructureMoveResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ProjectPmsStructureMoveResponse {
  String? errorCode;
  String? msg;

  ProjectPmsStructureMoveResponse({
    this.errorCode,
    this.msg,
  });

  factory ProjectPmsStructureMoveResponse.fromJson(Map<String, dynamic> json) =>
      ProjectPmsStructureMoveResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
      };
}
