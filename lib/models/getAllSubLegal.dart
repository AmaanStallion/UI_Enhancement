// To parse this JSON data, do
//
//     final getAllSubLegal = getAllSubLegalFromJson(jsonString);

import 'dart:convert';

GetAllSubLegal getAllSubLegalFromJson(String str) =>
    GetAllSubLegal.fromJson(json.decode(str));

String getAllSubLegalToJson(GetAllSubLegal data) => json.encode(data.toJson());

class GetAllSubLegal {
  GetAllSubLegalResponse? response;

  GetAllSubLegal({
    this.response,
  });

  factory GetAllSubLegal.fromJson(Map<String, dynamic> json) => GetAllSubLegal(
        response: json["Response"] == null
            ? null
            : GetAllSubLegalResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetAllSubLegalResponse {
  String? errorCode;
  String? msg;
  String? offset;
  List<SubLegalDetail>? subLegalDetails;
  List<String>? legalStatus;
  List<dynamic>? bottomBar;

  GetAllSubLegalResponse({
    this.errorCode,
    this.msg,
    this.offset,
    this.subLegalDetails,
    this.legalStatus,
    this.bottomBar,
  });

  factory GetAllSubLegalResponse.fromJson(Map<String, dynamic> json) =>
      GetAllSubLegalResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        offset: json["offset"],
        subLegalDetails: json["sub_legal_details"] == null
            ? []
            : List<SubLegalDetail>.from(json["sub_legal_details"]!
                .map((x) => SubLegalDetail.fromJson(x))),
        legalStatus: json["legal_status"] == null
            ? []
            : List<String>.from(json["legal_status"]!.map((x) => x)),
        bottomBar: json["bottom_bar"] == null
            ? []
            : List<dynamic>.from(json["bottom_bar"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "offset": offset,
        "sub_legal_details": subLegalDetails == null
            ? []
            : List<dynamic>.from(subLegalDetails!.map((x) => x.toJson())),
        "legal_status": legalStatus == null
            ? []
            : List<dynamic>.from(legalStatus!.map((x) => x)),
        "bottom_bar": bottomBar == null
            ? []
            : List<dynamic>.from(bottomBar!.map((x) => x)),
      };
}

class SubLegalDetail {
  String? subLegalName;
  String? subLegalId;
  String? legalIdFk;
  String? subLegalStartDate;
  String? subLegalEndDate;
  String? subLegalLastUpdateDate;
  String? uploadFlag;
  String? projectIdFk;
  String? legalStatus;
  String? documentPdf;
  String? isExpring;
  String? status;

  SubLegalDetail({
    this.subLegalName,
    this.subLegalId,
    this.legalIdFk,
    this.subLegalStartDate,
    this.subLegalEndDate,
    this.subLegalLastUpdateDate,
    this.uploadFlag,
    this.projectIdFk,
    this.legalStatus,
    this.documentPdf,
    this.isExpring,
    this.status,
  });

  factory SubLegalDetail.fromJson(Map<String, dynamic> json) => SubLegalDetail(
        subLegalName: json["sub_legal_name"],
        subLegalId: json["sub_legal_id"],
        legalIdFk: json["legal_id_fk"],
        subLegalStartDate: json["sub_legal_start_date"],
        subLegalEndDate: json["sub_legal_end_date"],
        subLegalLastUpdateDate: json["sub_legal_last_update_date"],
        uploadFlag: json["upload_flag"],
        projectIdFk: json["project_id_fk"],
        legalStatus: json["legal_status"],
        documentPdf: json["document_pdf"],
        isExpring: json["is_expring"],
        status: json["status"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "sub_legal_name": subLegalName,
        "sub_legal_id": subLegalId,
        "legal_id_fk": legalIdFk,
        "sub_legal_start_date": subLegalStartDate,
        "sub_legal_end_date": subLegalEndDate,
        "sub_legal_last_update_date": subLegalLastUpdateDate,
        "upload_flag": uploadFlag,
        "project_id_fk": projectIdFk,
        "legal_status": legalStatus,
        "document_pdf": documentPdf,
        "is_expring": isExpring,
        "status": status,
      };
}
