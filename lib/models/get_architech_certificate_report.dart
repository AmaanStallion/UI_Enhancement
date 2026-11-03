// To parse this JSON data, do
//
//     final getArchitechCertificateReport = getArchitechCertificateReportFromJson(jsonString);

import 'dart:convert';

GetArchitechCertificateReport getArchitechCertificateReportFromJson(
        String str) =>
    GetArchitechCertificateReport.fromJson(json.decode(str));

String getArchitechCertificateReportToJson(
        GetArchitechCertificateReport data) =>
    json.encode(data.toJson());

class GetArchitechCertificateReport {
  GetArchitechCertificateReportResponse? response;

  GetArchitechCertificateReport({
    this.response,
  });

  factory GetArchitechCertificateReport.fromJson(Map<String, dynamic> json) =>
      GetArchitechCertificateReport(
        response: json["Response"] == null
            ? null
            : GetArchitechCertificateReportResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetArchitechCertificateReportResponse {
  String? errorCode;
  String? msg;
  List<ArchitechCertificateList>? architechCertificateList;
  String? filePath;

  GetArchitechCertificateReportResponse({
    this.errorCode,
    this.msg,
    this.architechCertificateList,
    this.filePath,
  });

  factory GetArchitechCertificateReportResponse.fromJson(
          Map<String, dynamic> json) =>
      GetArchitechCertificateReportResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        architechCertificateList: json["architech_certificate_list"] == null
            ? []
            : List<ArchitechCertificateList>.from(
                json["architech_certificate_list"]!
                    .map((x) => ArchitechCertificateList.fromJson(x))),
        filePath: json["file_path"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "architech_certificate_list": architechCertificateList == null
            ? []
            : List<dynamic>.from(
                architechCertificateList!.map((x) => x.toJson())),
        "file_path": filePath,
      };
}

class ArchitechCertificateList {
  String? id;
  String? architechCertificateReport;
  String? projectSlabIdFk;
  String? architechCertificateRemark;
  String? userIdFk;
  String? architechCertificateStatus;
  String? fileDelete;
  DateTime? createdAt;
  DateTime? updatedAt;

  ArchitechCertificateList({
    this.id,
    this.architechCertificateReport,
    this.projectSlabIdFk,
    this.architechCertificateRemark,
    this.userIdFk,
    this.architechCertificateStatus,
    this.fileDelete,
    this.createdAt,
    this.updatedAt,
  });

  factory ArchitechCertificateList.fromJson(Map<String, dynamic> json) =>
      ArchitechCertificateList(
        id: json["id"],
        architechCertificateReport: json["architech_certificate_report"],
        projectSlabIdFk: json["project_slab_id_fk"],
        architechCertificateRemark: json["architech_certificate_remark"],
        userIdFk: json["user_id_fk"],
        architechCertificateStatus: json["architech_certificate_status"],
        fileDelete: json["file_delete"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "architech_certificate_report": architechCertificateReport,
        "project_slab_id_fk": projectSlabIdFk,
        "architech_certificate_remark": architechCertificateRemark,
        "user_id_fk": userIdFk,
        "architech_certificate_status": architechCertificateStatus,
        "file_delete": fileDelete,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
