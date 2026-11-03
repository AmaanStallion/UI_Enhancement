// To parse this JSON data, do
//
//     final getAllCheckList = getAllCheckListFromJson(jsonString);

import 'dart:convert';

getAllCheckListFromJson(String str) =>
    GetAllCheckList.fromJson(json.decode(str));

String getAllCheckListToJson(GetAllCheckList data) =>
    json.encode(data.toJson());

class GetAllCheckList {
  GetAllCheckListResponse? response;

  GetAllCheckList({
    this.response,
  });

  factory GetAllCheckList.fromJson(Map<String, dynamic> json) =>
      GetAllCheckList(
        response: json["Response"] == null
            ? null
            : GetAllCheckListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetAllCheckListResponse {
  String? errorCode;
  String? msg;
  String? slabCheckPath;
  String? editFlag;
  List<CheckList>? checkList;
  String? webCheckListUrl;

  GetAllCheckListResponse({
    this.errorCode,
    this.msg,
    this.slabCheckPath,
    this.editFlag,
    this.checkList,
    this.webCheckListUrl,
  });

  factory GetAllCheckListResponse.fromJson(Map<String, dynamic> json) =>
      GetAllCheckListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        slabCheckPath: json["slab_check_path"],
        editFlag: json["edit_flag"],
        checkList: json["check_list"] == null
            ? []
            : List<CheckList>.from(
                json["check_list"]!.map((x) => CheckList.fromJson(x))),
        webCheckListUrl: json["web_check_list_url"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "slab_check_path": slabCheckPath,
        "edit_flag": editFlag,
        "check_list": checkList == null
            ? []
            : List<dynamic>.from(checkList!.map((x) => x.toJson())),
        "web_check_list_url": webCheckListUrl,
      };
}

class CheckList {
  String? userName;
  String? companyName;
  String? projectSlabCheckId;
  String? projectSlabCheckNo;
  String? projectSlabCheckDate;
  String? salbCheckPdf;
  String? projectSlabSaveStatus;
  String? projectSlabRemark;
  List<SlabCheckDocument>? slabCheckDocument;
  String? webCheckListUrl;
  String? webCheckType;
  String? checklistType;
  String? categoryName;

  CheckList({
    this.userName,
    this.companyName,
    this.projectSlabCheckId,
    this.projectSlabCheckNo,
    this.projectSlabCheckDate,
    this.salbCheckPdf,
    this.projectSlabSaveStatus,
    this.projectSlabRemark,
    this.slabCheckDocument,
    this.webCheckListUrl,
    this.webCheckType,
    this.checklistType,
    this.categoryName,
  });

  factory CheckList.fromJson(Map<String, dynamic> json) => CheckList(
        userName: json["user_name"],
        companyName: json["company_name"],
        projectSlabCheckId: json["project_slab_check_id"],
        projectSlabCheckNo: json["project_slab_check_no"],
        projectSlabCheckDate: json["project_slab_check_date"],
        salbCheckPdf: json["salb_check_pdf"],
        projectSlabSaveStatus: json["project_slab_save_status"],
        projectSlabRemark: json["project_slab_remark"],
        slabCheckDocument: json["slab_check_document"] == null
            ? []
            : List<SlabCheckDocument>.from(json["slab_check_document"]!
                .map((x) => SlabCheckDocument.fromJson(x))),
        webCheckListUrl: json["web_check_list_url"],
        webCheckType: json["web_check_type"],
        checklistType: json["checklist_type"],
        categoryName: json["category_name"],
      );

  Map<String, dynamic> toJson() => {
        "user_name": userName,
        "company_name": companyName,
        "project_slab_check_id": projectSlabCheckId,
        "project_slab_check_no": projectSlabCheckNo,
        "project_slab_check_date": projectSlabCheckDate,
        "salb_check_pdf": salbCheckPdf,
        "project_slab_save_status": projectSlabSaveStatus,
        "project_slab_remark": projectSlabRemark,
        "slab_check_document": slabCheckDocument == null
            ? []
            : List<dynamic>.from(slabCheckDocument!.map((x) => x.toJson())),
        "web_check_list_url": webCheckListUrl,
        "web_check_type": webCheckType,
        "checklist_type": checklistType,
        "category_name": categoryName,
      };
}

class SlabCheckDocument {
  String? documentId;
  String? documentName;

  SlabCheckDocument({
    this.documentId,
    this.documentName,
  });

  factory SlabCheckDocument.fromJson(Map<String, dynamic> json) =>
      SlabCheckDocument(
        documentId: json["document_id"],
        documentName: json["document_name"],
      );

  Map<String, dynamic> toJson() => {
        "document_id": documentId,
        "document_name": documentName,
      };
}
