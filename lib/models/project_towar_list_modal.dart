// To parse this JSON data, do
//
//     final projectTowarListModal = projectTowarListModalFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_project_list.dart';

ProjectTowarListModal projectTowarListModalFromJson(String str) =>
    ProjectTowarListModal.fromJson(json.decode(str));

String projectTowarListModalToJson(ProjectTowarListModal data) =>
    json.encode(data.toJson());

class ProjectTowarListModal {
  ProjectTowarListModalResponse? response;

  ProjectTowarListModal({
    this.response,
  });

  factory ProjectTowarListModal.fromJson(Map<String, dynamic> json) =>
      ProjectTowarListModal(
        response: json["Response"] == null
            ? null
            : ProjectTowarListModalResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ProjectTowarListModalResponse {
  String? errorCode;
  String? msg;
  List<ProjectDetails>? towerList;

  ProjectTowarListModalResponse({
    this.errorCode,
    this.msg,
    this.towerList,
  });

  factory ProjectTowarListModalResponse.fromJson(Map<String, dynamic> json) =>
      ProjectTowarListModalResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        towerList: json["tower_list"] == null
            ? []
            : List<ProjectDetails>.from(
                json["tower_list"]!.map((x) => ProjectDetails.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "tower_list": towerList == null
            ? []
            : List<dynamic>.from(towerList!.map((x) => x.toJson())),
      };
}

// class TowerList {
//   String? projectId;
//   String? projectName;
//   String? projectTowerId;
//   String? towerName;
//   String? placeName;
//   String? projectImgName;
//   DateTime? endDt;
//   String? projectIssue;
//   String? contractorMagicLink;
//   String? vendMagicLink;
//   String? consultantMagicLink;

//   TowerList({
//     this.projectId,
//     this.projectName,
//     this.projectTowerId,
//     this.towerName,
//     this.placeName,
//     this.projectImgName,
//     this.endDt,
//     this.projectIssue,
//     this.contractorMagicLink,
//     this.vendMagicLink,
//     this.consultantMagicLink,
//   });

//   factory TowerList.fromJson(Map<String, dynamic> json) => TowerList(
//         projectId: json["project_id"],
//         projectName: json["project_name"],
//         projectTowerId: json["project_tower_id"],
//         towerName: json["tower_name"],
//         placeName: json["place_name"],
//         projectImgName: json["project_img_name"],
//         endDt: json["end_dt"] == null ? null : DateTime.parse(json["end_dt"]),
//         projectIssue: json["project_issue"],
//         contractorMagicLink: json["contractor_magic_link"],
//         vendMagicLink: json["vend_magic_link"],
//         consultantMagicLink: json["consultant_magic_link"],
//       );

//   Map<String, dynamic> toJson() => {
//         "project_id": projectId,
//         "project_name": projectName,
//         "project_tower_id": projectTowerId,
//         "tower_name": towerName,
//         "place_name": placeName,
//         "project_img_name": projectImgName,
//         "end_dt": endDt?.toIso8601String(),
//         "project_issue": projectIssue,
//         "contractor_magic_link": contractorMagicLink,
//         "vend_magic_link": vendMagicLink,
//         "consultant_magic_link": consultantMagicLink,
//       };
// }
