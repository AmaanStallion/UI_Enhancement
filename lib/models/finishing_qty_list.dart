// To parse this JSON data, do
//
//     final finishingQtyList = finishingQtyListFromJson(jsonString);

import 'dart:convert';

FinishingQtyList finishingQtyListFromJson(String str) =>
    FinishingQtyList.fromJson(json.decode(str));

String finishingQtyListToJson(FinishingQtyList data) =>
    json.encode(data.toJson());

class FinishingQtyList {
  FinishingQtyListResponse? response;

  FinishingQtyList({
    this.response,
  });

  factory FinishingQtyList.fromJson(Map<String, dynamic> json) =>
      FinishingQtyList(
        response: json["Response"] == null
            ? null
            : FinishingQtyListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class FinishingQtyListResponse {
  String? errorCode;
  String? msg;
  List<FinishingConsumeDetail>? finishingConsumeDetails;
  final List<CompanyDetail>? companyDetails;
  final List<FinishingUnit>? finishingUnit;

  String? path;

  FinishingQtyListResponse({
    this.errorCode,
    this.msg,
    this.finishingConsumeDetails,
    this.companyDetails,
    this.path,
    this.finishingUnit,
  });

  factory FinishingQtyListResponse.fromJson(Map<String, dynamic> json) =>
      FinishingQtyListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        finishingConsumeDetails: json["finishing_consume_details"] == null
            ? []
            : List<FinishingConsumeDetail>.from(
                json["finishing_consume_details"]!
                    .map((x) => FinishingConsumeDetail.fromJson(x))),
        path: json["path"],
        finishingUnit: json["finishing_unit"] == null
            ? []
            : List<FinishingUnit>.from(
                json["finishing_unit"]!.map((x) => FinishingUnit.fromJson(x))),
        companyDetails: json["company_details"] == null
            ? []
            : List<CompanyDetail>.from(
                json["company_details"]!.map((x) => CompanyDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "finishing_consume_details": finishingConsumeDetails == null
            ? []
            : List<dynamic>.from(
                finishingConsumeDetails!.map((x) => x.toJson())),
        "path": path,
        "finishing_unit": finishingUnit == null
            ? []
            : List<dynamic>.from(finishingUnit!.map((x) => x.toJson())),
        "company_details": companyDetails == null
            ? []
            : List<dynamic>.from(companyDetails!.map((x) => x.toJson())),
      };
}

class CompanyDetail {
  final String? companyName;
  final String? companyId;

  CompanyDetail({
    this.companyName,
    this.companyId,
  });

  factory CompanyDetail.fromJson(Map<String, dynamic> json) => CompanyDetail(
        companyName: json["company_name"],
        companyId: json["company_id"],
      );

  Map<String, dynamic> toJson() => {
        "company_name": companyName,
        "company_id": companyId,
      };
}

class FinishingConsumeDetail {
  String? mstFinishingConsumeId;
  String? finishingIdFk;
  String? floorIdFk;
  String? companyIdFk;
  String? finishingConsumQty;
  String? finishingConsumRemark;
  String? userIdFk;
  String? finishingConsumStatus;
  DateTime? finishingConsumUpdateAt;
  DateTime? finishingConsumCreatedAt;
  String? companyName;
  String? userName;
  List<DocumentList>? documentList = [];
  final String? unitName;
  String? finishingConsumeUnitId;

  FinishingConsumeDetail({
    this.mstFinishingConsumeId,
    this.finishingIdFk,
    this.floorIdFk,
    this.companyIdFk,
    this.finishingConsumQty,
    this.finishingConsumRemark,
    this.userIdFk,
    this.finishingConsumStatus,
    this.finishingConsumUpdateAt,
    this.finishingConsumCreatedAt,
    this.companyName,
    this.userName,
    this.unitName,
    this.documentList,
    this.finishingConsumeUnitId,
  });

  factory FinishingConsumeDetail.fromJson(Map<String, dynamic> json) =>
      FinishingConsumeDetail(
        mstFinishingConsumeId: json["mst_finishing_consume_id"],
        finishingIdFk: json["finishing_id_fk"],
        floorIdFk: json["floor_id_fk"],
        companyIdFk: json["company_id_fk"],
        finishingConsumQty: json["finishing_consum_qty"],
        finishingConsumRemark: json["finishing_consum_remark"],
        userIdFk: json["user_id_fk"],
        finishingConsumStatus: json["finishing_consum_status"],
        finishingConsumUpdateAt: json["finishing_consum_update_at"] == null
            ? null
            : DateTime.parse(json["finishing_consum_update_at"]),
        finishingConsumCreatedAt: json["finishing_consum_created_at"] == null
            ? null
            : DateTime.parse(json["finishing_consum_created_at"]),
        companyName: json["company_name"],
        userName: json["user_name"],
        unitName: json["unit_name"],
        finishingConsumeUnitId: json["finishing_consume_unit_id"],
        documentList: json["document_list"] == null
            ? []
            : List<DocumentList>.from(
                json["document_list"]!.map((x) => DocumentList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "mst_finishing_consume_id": mstFinishingConsumeId,
        "finishing_id_fk": finishingIdFk,
        "floor_id_fk": floorIdFk,
        "company_id_fk": companyIdFk,
        "finishing_consum_qty": finishingConsumQty,
        "finishing_consum_remark": finishingConsumRemark,
        "user_id_fk": userIdFk,
        "finishing_consum_status": finishingConsumStatus,
        "finishing_consum_update_at":
            finishingConsumUpdateAt?.toIso8601String(),
        "finishing_consum_created_at":
            finishingConsumCreatedAt?.toIso8601String(),
        "company_name": companyName,
        "user_name": userName,
        "unit_name": unitName,
        "finishing_consume_unit_id": finishingConsumeUnitId,
        "document_list": documentList == null
            ? []
            : List<dynamic>.from(documentList!.map((x) => x.toJson())),
      };
}

class DocumentList {
  String? documentId;
  String? documentName;

  DocumentList({
    this.documentId,
    this.documentName,
  });

  factory DocumentList.fromJson(Map<String, dynamic> json) => DocumentList(
        documentId: json["document_id"],
        documentName: json["document_name"],
      );

  Map<String, dynamic> toJson() => {
        "document_id": documentId,
        "document_name": documentName,
      };
}

class FinishingUnit {
  final String? mstFinishingUnitId;
  final String? mstFinishingUnitName;

  FinishingUnit({
    this.mstFinishingUnitId,
    this.mstFinishingUnitName,
  });

  factory FinishingUnit.fromJson(Map<String, dynamic> json) => FinishingUnit(
        mstFinishingUnitId: json["mst_finishing_unit_id"],
        mstFinishingUnitName: json["mst_finishing_unit_name"],
      );

  Map<String, dynamic> toJson() => {
        "mst_finishing_unit_id": mstFinishingUnitId,
        "mst_finishing_unit_name": mstFinishingUnitName,
      };
}
