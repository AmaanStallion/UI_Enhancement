// To parse this JSON data, do
//
//     final projectPermission = projectPermissionFromJson(jsonString);

import 'dart:convert';

ProjectPermission projectPermissionFromJson(String str) =>
    ProjectPermission.fromJson(json.decode(str));

String projectPermissionToJson(ProjectPermission data) =>
    json.encode(data.toJson());

class ProjectPermission {
  ProjectPermissionResponse? response;

  ProjectPermission({
    this.response,
  });

  factory ProjectPermission.fromJson(Map<String, dynamic> json) =>
      ProjectPermission(
        response: json["Response"] == null
            ? null
            : ProjectPermissionResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ProjectPermissionResponse {
  String? errorCode;
  String? msg;
  List<PermissionDetail>? permissionDetails;
  List<SelectDetail>? selectDetails;
  List<AssingToList>? assingToList;
  String? permissionLodFlag;
  String? permissionUserTrack;

  ProjectPermissionResponse({
    this.errorCode,
    this.msg,
    this.permissionDetails,
    this.selectDetails,
    this.permissionLodFlag,
    this.assingToList,
    this.permissionUserTrack,
  });

  factory ProjectPermissionResponse.fromJson(Map<String, dynamic> json) =>
      ProjectPermissionResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        permissionLodFlag: json["permission-lod_flag"],
        permissionDetails: json["permission_details"] == null
            ? []
            : List<PermissionDetail>.from(json["permission_details"]
                .map((x) => PermissionDetail.fromJson(x))),
        selectDetails: json["select_details"] == null
            ? []
            : List<SelectDetail>.from(
                json["select_details"]!.map((x) => SelectDetail.fromJson(x))),
        assingToList: json["assing_to_list"] == null
            ? []
            : List<AssingToList>.from(
                json["assing_to_list"]!.map((x) => AssingToList.fromJson(x))),
        permissionUserTrack: json["permission_user_track"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "permission-lod_flag": permissionLodFlag,
        "permission_details": permissionDetails == null
            ? []
            : List<dynamic>.from(permissionDetails!.map((x) => x.toJson())),
        "select_details": selectDetails == null
            ? []
            : List<dynamic>.from(selectDetails!.map((x) => x.toJson())),
        "assing_to_list": assingToList == null
            ? []
            : List<dynamic>.from(assingToList!.map((x) => x.toJson())),
        "permission_user_track": permissionUserTrack,
      };
}

class AssingToList {
  String? transEmpProjectIdFk;
  String? transEmpDeveloperId;
  String? transEmpProjectStatus;
  String? transEmpProjectNumber;
  String? transEmpName;
  String? transEmpId;

  AssingToList({
    this.transEmpProjectIdFk,
    this.transEmpDeveloperId,
    this.transEmpProjectStatus,
    this.transEmpProjectNumber,
    this.transEmpName,
    this.transEmpId,
  });

  factory AssingToList.fromJson(Map<String, dynamic> json) => AssingToList(
        transEmpProjectIdFk: json["trans_emp_project_id_fk"],
        transEmpDeveloperId: json["trans_emp_developer_id"],
        transEmpProjectStatus: json["trans_emp_project_status"],
        transEmpProjectNumber: json["trans_emp_project_number"],
        transEmpName: json["trans_emp_name"],
        transEmpId: json["trans_emp_id"],
      );

  Map<String, dynamic> toJson() => {
        "trans_emp_project_id_fk": transEmpProjectIdFk,
        "trans_emp_developer_id": transEmpDeveloperId,
        "trans_emp_project_status": transEmpProjectStatus,
        "trans_emp_project_number": transEmpProjectNumber,
        "trans_emp_name": transEmpName,
        "trans_emp_id": transEmpId,
      };
}

class PermissionDetail {
  String? assignToName;
  String? permissionRemark;
  String? permissionName;
  String? assingToId;
  String? permissionId;
  String? transProjectPerId;
  String? expDate;
  String status;
  String? selectType;
  String? permissionFlag;
  String? isExpring;
  String? lastUpdateDate;
  List<SubPermission>? subPermission;
  String? uploadFlag;
  List<LodList>? lodList;
  String? expDateActual;

  PermissionDetail({
    this.assignToName,
    this.permissionRemark,
    this.permissionName,
    this.assingToId,
    this.permissionId,
    this.transProjectPerId,
    this.expDate,
    this.status = '0',
    this.selectType,
    this.permissionFlag,
    this.isExpring,
    this.lastUpdateDate,
    this.subPermission,
    this.uploadFlag,
    this.lodList,
    this.expDateActual,
  });

  factory PermissionDetail.fromJson(Map<String, dynamic> json) =>
      PermissionDetail(
        assignToName: json["assign_to_name"],
        permissionRemark: json["permission_remark"],
        permissionName: json["permission_name"],
        assingToId: json["assing_to_id"],
        permissionId: json["permission_id"],
        transProjectPerId: json["trans_project_per_id"],
        expDate: json["exp_date"],
        status: json["status"] == '' ? '0' : json["status"],
        selectType: json["select_type"],
        permissionFlag: json["permission_flag"],
        isExpring: json["is_expring"],
        lastUpdateDate: json["last_update_date"],
        subPermission: json["sub_permission"] == null
            ? []
            : List<SubPermission>.from(
                json["sub_permission"]!.map((x) => SubPermission.fromJson(x))),
        uploadFlag: json["upload_flag"],
        lodList: json["lod_list"] == null
            ? []
            : List<LodList>.from(
                json["lod_list"]!.map((x) => LodList.fromJson(x))),
        expDateActual: json["exp_date_actual"],
      );

  Map<String, dynamic> toJson() => {
        "assign_to_name": assignToName,
        "permission_remark": permissionRemark,
        "permission_name": permissionName,
        "assing_to_id": assingToId,
        "permission_id": permissionId,
        "trans_project_per_id": transProjectPerId,
        "exp_date": expDate,
        "status": status,
        "select_type": selectType,
        "permission_flag": permissionFlag,
        "is_expring": isExpring,
        "last_update_date": lastUpdateDate,
        "sub_permission": subPermission == null
            ? []
            : List<dynamic>.from(subPermission!.map((x) => x.toJson())),
        "upload_flag": uploadFlag,
        "lod_list": lodList == null
            ? []
            : List<dynamic>.from(lodList!.map((x) => x.toJson())),
        "exp_date_actual": expDateActual,
      };
}

class LodAttachment {
  String? fileId;
  String? fileName;
  String? viewUrl;

  LodAttachment({
    this.fileId,
    this.fileName,
    this.viewUrl,
  });

  factory LodAttachment.fromJson(Map<String, dynamic> json) => LodAttachment(
        fileId: json["file_id"]?.toString() ?? json["id"]?.toString() ?? "",
        fileName: json["file_name"] ?? json["filename"] ?? json["name"] ?? "",
        viewUrl: json["view_url"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "file_id": fileId,
        "file_name": fileName,
        "view_url": viewUrl,
      };
}

class LodList {
  String? transLodDocumentId;
  String? fileName;
  String? documentName;
  String? status;
  List<LodAttachment>? attachments;

  LodList({
    this.transLodDocumentId,
    this.fileName,
    this.documentName,
    this.status,
    this.attachments,
  });

  factory LodList.fromJson(Map<String, dynamic> json) => LodList(
        transLodDocumentId: json["trans_lod_document_id"],
        fileName: json["file_name"],
        documentName: json["document_name"],
        status: json["status"],
        attachments: json["attachments"] == null
            ? []
            : List<LodAttachment>.from(
                json["attachments"]!.map((x) => LodAttachment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "trans_lod_document_id": transLodDocumentId,
        "file_name": fileName,
        "document_name": documentName,
        "status": status,
        "attachments": attachments == null
            ? []
            : List<dynamic>.from(attachments!.map((x) => x.toJson())),
      };
}

class SubPermission {
  String? subPermissionName;
  List<String>? subPermissionPdf;
  List<String>? subPermissionDwg;
  String? lastUpdateDate;
  String? id;
  List<String>? supportedTypes;
  bool? isDisabled;

  SubPermission({
    this.subPermissionName,
    this.subPermissionPdf,
    this.subPermissionDwg,
    this.lastUpdateDate,
    this.id,
    this.supportedTypes,
    this.isDisabled = false,
  });

  factory SubPermission.fromJson(Map<String, dynamic> json) => SubPermission(
        subPermissionName: json["sub_permission_name"],
        subPermissionPdf: json["sub_permission_pdf"] == null
            ? []
            : List<String>.from(json["sub_permission_pdf"]!.map((x) => x)),
        subPermissionDwg: json["sub_permission_dwg"] == null
            ? []
            : List<String>.from(json["sub_permission_dwg"]!.map((x) => x)),
        lastUpdateDate: json["last_update_date"],
        id: json["id"],
        supportedTypes: json["supported_types"] == null
            ? []
            : List<String>.from(json["supported_types"]!.map((x) => x)),
        isDisabled: json["is_disabled"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "sub_permission_name": subPermissionName,
        "sub_permission_pdf": subPermissionPdf == null
            ? []
            : List<dynamic>.from(subPermissionPdf!.map((x) => x)),
        "sub_permission_dwg": subPermissionDwg == null
            ? []
            : List<dynamic>.from(subPermissionDwg!.map((x) => x)),
        "last_update_date": lastUpdateDate,
        "id": id,
        "supported_types": supportedTypes == null
            ? []
            : List<dynamic>.from(supportedTypes!.map((x) => x)),
        "is_disabled": isDisabled,
      };
}

class SelectDetail {
  String? name;
  String? selectType;
  String? totalCount;

  SelectDetail({
    this.name,
    this.selectType,
    this.totalCount,
  });

  factory SelectDetail.fromJson(Map<String, dynamic> json) => SelectDetail(
        name: json["name"],
        selectType: json["select_type"],
        totalCount: json["total_count"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "select_type": selectType,
        "total_count": totalCount,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
