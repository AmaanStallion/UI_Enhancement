// To parse this JSON data, do
//
//     final getAllSlabReport = getAllSlabReportFromJson(jsonString);

import 'dart:convert';

GetAllSlabReport getAllSlabReportFromJson(String str) =>
    GetAllSlabReport.fromJson(json.decode(str));

String getAllSlabReportToJson(GetAllSlabReport data) =>
    json.encode(data.toJson());

class GetAllSlabReport {
  GetAllSlabReportResponse? response;

  GetAllSlabReport({
    this.response,
  });

  factory GetAllSlabReport.fromJson(Map<String, dynamic> json) =>
      GetAllSlabReport(
        response: json["Response"] == null
            ? null
            : GetAllSlabReportResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetAllSlabReportResponse {
  String? errorCode;
  String? msg;
  List<LabReportList>? labReportList;

  GetAllSlabReportResponse({
    this.errorCode,
    this.msg,
    this.labReportList,
  });

  factory GetAllSlabReportResponse.fromJson(Map<String, dynamic> json) =>
      GetAllSlabReportResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        labReportList: json["lab_report_list"] == null
            ? []
            : List<LabReportList>.from(
                json["lab_report_list"]!.map((x) => LabReportList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "lab_report_list": labReportList == null
            ? []
            : List<dynamic>.from(labReportList!.map((x) => x.toJson())),
      };
}

class LabReportList {
  String? labTestingReportId;
  String? labTestingReport;
  String? projectSlabIdFk;
  String? labTestingRemarks;
  dynamic userIdFk;
  String? labTestingReportStatus;
  DateTime? labTestingReportUpdateAt;
  DateTime? labTestingReportCreatedAt;

  LabReportList({
    this.labTestingReportId,
    this.labTestingReport,
    this.projectSlabIdFk,
    this.labTestingRemarks,
    this.userIdFk,
    this.labTestingReportStatus,
    this.labTestingReportUpdateAt,
    this.labTestingReportCreatedAt,
  });

  factory LabReportList.fromJson(Map<String, dynamic> json) => LabReportList(
        labTestingReportId: json["lab_testing_report_id"],
        labTestingReport: json["lab_testing_report"],
        projectSlabIdFk: json["project_slab_id_fk"],
        labTestingRemarks: json["lab_testing_remarks"],
        userIdFk: json["user_id_fk"],
        labTestingReportStatus: json["lab_testing_report_status"],
        labTestingReportUpdateAt: json["lab_testing_report_update_at"] == null
            ? null
            : DateTime.parse(json["lab_testing_report_update_at"]),
        labTestingReportCreatedAt: json["lab_testing_report_created_at"] == null
            ? null
            : DateTime.parse(json["lab_testing_report_created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "lab_testing_report_id": labTestingReportId,
        "lab_testing_report": labTestingReport,
        "project_slab_id_fk": projectSlabIdFk,
        "lab_testing_remarks": labTestingRemarks,
        "user_id_fk": userIdFk,
        "lab_testing_report_status": labTestingReportStatus,
        "lab_testing_report_update_at":
            labTestingReportUpdateAt?.toIso8601String(),
        "lab_testing_report_created_at":
            labTestingReportCreatedAt?.toIso8601String(),
      };
}
