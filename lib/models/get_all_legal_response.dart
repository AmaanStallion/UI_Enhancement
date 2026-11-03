// To parse this JSON data, do
//
//     final getAllLegal = getAllLegalFromJson(jsonString);

import 'dart:convert';

GetAllLegal getAllLegalFromJson(String str) =>
    GetAllLegal.fromJson(json.decode(str));

String getAllLegalToJson(GetAllLegal data) => json.encode(data.toJson());

class GetAllLegal {
  GetAllLegalResponse? response;

  GetAllLegal({
    this.response,
  });

  factory GetAllLegal.fromJson(Map<String, dynamic> json) => GetAllLegal(
        response: json["Response"] == null
            ? null
            : GetAllLegalResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetAllLegalResponse {
  String? errorCode;
  String? msg;
  String? offset;
  List<MainCategoryList>? mainCategoryList;
  List<LegalDetail>? legalDetails;
  List<String>? legalStatus;
  List<BottomBar>? bottomBar;

  GetAllLegalResponse({
    this.errorCode,
    this.msg,
    this.offset,
    this.mainCategoryList,
    this.legalDetails,
    this.legalStatus,
    this.bottomBar,
  });

  factory GetAllLegalResponse.fromJson(Map<String, dynamic> json) =>
      GetAllLegalResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        offset: json["offset"],
        mainCategoryList: json["main_category_list"] == null
            ? []
            : List<MainCategoryList>.from(json["main_category_list"]!
                .map((x) => MainCategoryList.fromJson(x))),
        legalDetails: json["legal_details"] == null
            ? []
            : List<LegalDetail>.from(
                json["legal_details"]!.map((x) => LegalDetail.fromJson(x))),
        legalStatus: json["legal_status"] == null
            ? []
            : List<String>.from(json["legal_status"]!.map((x) => x)),
        bottomBar: json["bottom_bar"] == null
            ? []
            : List<BottomBar>.from(
                json["bottom_bar"]!.map((x) => BottomBar.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "offset": offset,
        "main_category_list": mainCategoryList == null
            ? []
            : List<dynamic>.from(mainCategoryList!.map((x) => x.toJson())),
        "legal_details": legalDetails == null
            ? []
            : List<dynamic>.from(legalDetails!.map((x) => x.toJson())),
        "legal_status": legalStatus == null
            ? []
            : List<dynamic>.from(legalStatus!.map((x) => x)),
        "bottom_bar": bottomBar == null
            ? []
            : List<dynamic>.from(bottomBar!.map((x) => x.toJson())),
      };
}

class BottomBar {
  String? name;
  String? totalCount;

  BottomBar({
    this.name,
    this.totalCount,
  });

  factory BottomBar.fromJson(Map<String, dynamic> json) => BottomBar(
        name: json["name"],
        totalCount: json["total_count"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "total_count": totalCount,
      };
}

class LegalDetail {
  String? isExpring;
  String? legalName;
  String? legalId;
  String? projectLegalId;
  String? execDate;
  String? expDate;
  String? legalRemark;
  String? lastUpdateDate;
  String? uploadFlag;
  String? projectIdFk;
  String? legalFlag;
  String? legalStatus;
  String? transLegalNote;
  String? selectTypeId;
  String? selectTypeName;
  List<String>? documentPdf;

  LegalDetail({
    this.isExpring,
    this.legalName,
    this.legalId,
    this.projectLegalId,
    this.execDate,
    this.expDate,
    this.legalRemark,
    this.lastUpdateDate,
    this.uploadFlag,
    this.projectIdFk,
    this.legalFlag,
    this.legalStatus,
    this.transLegalNote,
    this.selectTypeId,
    this.selectTypeName,
    this.documentPdf,
  });

  factory LegalDetail.fromJson(Map<String, dynamic> json) => LegalDetail(
        isExpring: json["is_expring"],
        legalName: json["legal_name"],
        legalId: json["legal_id"],
        projectLegalId: json["project_legal_id"],
        execDate: json["exec_date"],
        expDate: json["exp_date"],
        legalRemark: json["legal_remark"],
        lastUpdateDate: json["last_update_date"],
        uploadFlag: json["upload_flag"],
        projectIdFk: json["project_id_fk"],
        legalFlag: json["legal_flag"],
        legalStatus: json["legal_status"],
        transLegalNote: json["trans_legal_note"],
        selectTypeId: json["select_type_id"],
        selectTypeName: json["select_type_name"],
        documentPdf: json["document_pdf"] == null
            ? []
            : List<String>.from(json["document_pdf"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "is_expring": isExpring,
        "legal_name": legalName,
        "legal_id": legalId,
        "project_legal_id": projectLegalId,
        "exec_date": execDate,
        "exp_date": expDate,
        "legal_remark": legalRemark,
        "last_update_date": lastUpdateDate,
        "upload_flag": uploadFlag,
        "project_id_fk": projectIdFk,
        "legal_flag": legalFlag,
        "legal_status": legalStatus,
        "trans_legal_note": transLegalNote,
        "select_type_id": selectTypeId,
        "select_type_name": selectTypeName,
        "document_pdf": documentPdf == null
            ? []
            : List<dynamic>.from(documentPdf!.map((x) => x)),
      };
}

class MainCategoryList {
  String? id;
  String? name;
  String? newName;
  String? count;

  MainCategoryList({
    this.id,
    this.name,
    this.newName,
    this.count,
  });

  factory MainCategoryList.fromJson(Map<String, dynamic> json) =>
      MainCategoryList(
        id: json["id"],
        name: json["name"],
        newName: json["new_name"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "new_name": newName,
        "count": count,
      };
}
