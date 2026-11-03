// // To parse this JSON data, do
// //
// //     final manageFinishingWorkType = manageFinishingWorkTypeFromJson(jsonString);

// import 'dart:convert';

// ManageFinishingWorkType manageFinishingWorkTypeFromJson(String str) =>
//     ManageFinishingWorkType.fromJson(json.decode(str));

// String manageFinishingWorkTypeToJson(ManageFinishingWorkType data) =>
//     json.encode(data.toJson());

// class ManageFinishingWorkType {
//   ManageFinishingWorkTypeResponse? response;

//   ManageFinishingWorkType({
//     this.response,
//   });

//   factory ManageFinishingWorkType.fromJson(Map<String, dynamic> json) =>
//       ManageFinishingWorkType(
//         response: json["Response"] == null
//             ? null
//             : ManageFinishingWorkTypeResponse.fromJson(json["Response"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "Response": response?.toJson(),
//       };
// }

// class ManageFinishingWorkTypeResponse {
//   String? errorCode;
//   String? msg;
//   List<FinishingProjectList>? finishingProjectList;

//   ManageFinishingWorkTypeResponse({
//     this.errorCode,
//     this.msg,
//     this.finishingProjectList,
//   });

//   factory ManageFinishingWorkTypeResponse.fromJson(Map<String, dynamic> json) =>
//       ManageFinishingWorkTypeResponse(
//         errorCode: json["error_code"],
//         msg: json["msg"],
//         finishingProjectList: json["finishing_project_list"] == null
//             ? []
//             : List<FinishingProjectList>.from(json["finishing_project_list"]!
//                 .map((x) => FinishingProjectList.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "error_code": errorCode,
//         "msg": msg,
//         "finishing_project_list": finishingProjectList == null
//             ? []
//             : List<dynamic>.from(finishingProjectList!.map((x) => x.toJson())),
//       };
// }

// class FinishingProjectList {
//   final String? mstFinishingId;
//   String? developerIdFk;
//   String? finishingType;
//   String? finishingName;
//   String? finishingUnit;
//   String? finishingStatus;
//   String? pushGlobal;
//   DateTime? finishingUpdatedAt;
//   DateTime? finishingCreatedAt;
//   String? unitName;
//   String? unitId;
//   String? isActive;
//   List<dynamic>? skillList;

//   FinishingProjectList({
//     this.mstFinishingId,
//     this.developerIdFk,
//     this.finishingType,
//     this.finishingName,
//     this.finishingUnit,
//     this.finishingStatus,
//     this.pushGlobal,
//     this.finishingUpdatedAt,
//     this.finishingCreatedAt,
//     this.unitName,
//     this.unitId,
//     this.isActive,
//     this.skillList,
//   });

//   factory FinishingProjectList.fromJson(Map<String, dynamic> json) =>
//       FinishingProjectList(
//         mstFinishingId: json["mst_finishing_id"],
//         developerIdFk: json["developer_id_fk"],
//         finishingType: json["finishing_type"],
//         finishingName: json["finishing_name"],
//         finishingUnit: json["finishing_unit"],
//         finishingStatus: json["finishing_status"],
//         pushGlobal: json["push_global"],
//         finishingUpdatedAt: json["finishing_updated_at"] == null
//             ? null
//             : DateTime.parse(json["finishing_updated_at"]),
//         finishingCreatedAt: json["finishing_created_at"] == null
//             ? null
//             : DateTime.parse(json["finishing_created_at"]),
//         unitName: json["unit_name"],
//         unitId: json["unit_id"],
//         isActive: json["is_active"],
//         skillList: json["skill_list"] == null
//             ? []
//             : List<dynamic>.from(json["skill_list"]!.map((x) => x)),
//       );

//   Map<String, dynamic> toJson() => {
//         "mst_finishing_id": mstFinishingId,
//         "developer_id_fk": developerIdFk,
//         "finishing_type": finishingType,
//         "finishing_name": finishingName,
//         "finishing_unit": finishingUnit,
//         "finishing_status": finishingStatus,
//         "push_global": pushGlobal,
//         "finishing_updated_at": finishingUpdatedAt?.toIso8601String(),
//         "finishing_created_at": finishingCreatedAt?.toIso8601String(),
//         "unit_name": unitName,
//         "unit_id": unitId,
//         "is_active": isActive,
//         "skill_list": skillList == null
//             ? []
//             : List<dynamic>.from(skillList!.map((x) => x)),
//       };
// }

// class FinishingProjectListTemp {
//   String? mstFinishingId;
//   String? isActive;

//   FinishingProjectListTemp({
//     this.mstFinishingId,
//     this.isActive,
//   });

//   factory FinishingProjectListTemp.fromJson(Map<String, dynamic> json) =>
//       FinishingProjectListTemp(
//         isActive: json["is_active"],
//       );

//   Map<String, dynamic> toJson() => {
//         "mst_finishing_id": mstFinishingId,
//         "is_active": isActive,
//       };
// }

// To parse this JSON data, do
//
//     final manageFinishingWorkType = manageFinishingWorkTypeFromJson(jsonString);

import 'dart:convert';

ManageFinishingWorkType manageFinishingWorkTypeFromJson(String str) =>
    ManageFinishingWorkType.fromJson(json.decode(str));

String manageFinishingWorkTypeToJson(ManageFinishingWorkType data) =>
    json.encode(data.toJson());

class ManageFinishingWorkType {
  final ManageFinishingWorkTypeResponse? response;

  ManageFinishingWorkType({
    this.response,
  });

  factory ManageFinishingWorkType.fromJson(Map<String, dynamic> json) =>
      ManageFinishingWorkType(
        response: json["Response"] == null
            ? null
            : ManageFinishingWorkTypeResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ManageFinishingWorkTypeResponse {
  final String? errorCode;
  final String? msg;
  final List<FinishingProjectList>? finishingProjectList;

  ManageFinishingWorkTypeResponse({
    this.errorCode,
    this.msg,
    this.finishingProjectList,
  });

  factory ManageFinishingWorkTypeResponse.fromJson(Map<String, dynamic> json) =>
      ManageFinishingWorkTypeResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        finishingProjectList: json["finishing_project_list"] == null
            ? []
            : List<FinishingProjectList>.from(json["finishing_project_list"]!
                .map((x) => FinishingProjectList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "finishing_project_list": finishingProjectList == null
            ? []
            : List<dynamic>.from(finishingProjectList!.map((x) => x.toJson())),
      };
}

class FinishingProjectList {
  final String? mstWorkId;
  final String? mstWorkName;
  final String? mstFinishingId;
  String? isActive;
  final String? unit;

  FinishingProjectList({
    this.mstWorkId,
    this.mstWorkName,
    this.mstFinishingId,
    this.isActive,
    this.unit,
  });

  factory FinishingProjectList.fromJson(Map<String, dynamic> json) =>
      FinishingProjectList(
        mstWorkId: json["mst_work_id"],
        mstWorkName: json["mst_work_name"],
        mstFinishingId: json["mst_finishing_id"],
        isActive: json["is_active"],
        unit: json["unit"],
      );

  Map<String, dynamic> toJson() => {
        "mst_work_id": mstWorkId,
        "mst_work_name": mstWorkName,
        "mst_finishing_id": mstFinishingId,
        "is_active": isActive,
        "unit": unit,
      };
}

class FinishingProjectListTemp {
  String? mstFinishingId;
  String? isActive;

  FinishingProjectListTemp({
    this.mstFinishingId,
    this.isActive,
  });

  factory FinishingProjectListTemp.fromJson(Map<String, dynamic> json) =>
      FinishingProjectListTemp(
        isActive: json["is_active"],
      );

  Map<String, dynamic> toJson() => {
        "mst_finishing_id": mstFinishingId,
        "is_active": isActive,
      };
}
