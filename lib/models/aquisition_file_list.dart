// To parse this JSON data, do
//
//     final aquisitionFileList = aquisitionFileListFromJson(jsonString);

import 'dart:convert';

AquisitionFileList aquisitionFileListFromJson(String str) =>
    AquisitionFileList.fromJson(json.decode(str));

String aquisitionFileListToJson(AquisitionFileList data) =>
    json.encode(data.toJson());

class AquisitionFileList {
  AquisitionFileListResponse? response;

  AquisitionFileList({
    this.response,
  });

  factory AquisitionFileList.fromJson(Map<String, dynamic> json) =>
      AquisitionFileList(
        response: json["Response"] == null
            ? null
            : AquisitionFileListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class AquisitionFileListResponse {
  String? errorCode;
  String? msg;
  List<AcquisitionList>? acquisitionList;

  AquisitionFileListResponse({
    this.errorCode,
    this.msg,
    this.acquisitionList,
  });

  factory AquisitionFileListResponse.fromJson(Map<String, dynamic> json) =>
      AquisitionFileListResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        acquisitionList: json["acquisitionList"] == null
            ? []
            : List<AcquisitionList>.from(json["acquisitionList"]!
                .map((x) => AcquisitionList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "acquisitionList": acquisitionList == null
            ? []
            : List<dynamic>.from(acquisitionList!.map((x) => x.toJson())),
      };
}

class AcquisitionList {
  String? plotCategoryId;
  String? plotCategory;
  List<DocumentList>? documentList;

  AcquisitionList({
    this.plotCategoryId,
    this.plotCategory,
    this.documentList,
  });

  factory AcquisitionList.fromJson(Map<String, dynamic> json) =>
      AcquisitionList(
        plotCategoryId: json["plot_category_id"],
        plotCategory: json["plot_category"],
        documentList: json["document_list"] == null
            ? []
            : List<DocumentList>.from(
                json["document_list"]!.map((x) => DocumentList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "plot_category_id": plotCategoryId,
        "plot_category": plotCategory,
        "document_list": documentList == null
            ? []
            : List<dynamic>.from(documentList!.map((x) => x.toJson())),
      };
}

class DocumentList {
  String? id;
  String? fileName;
  String? status;

  DocumentList({
    this.id,
    this.fileName,
    this.status,
  });

  factory DocumentList.fromJson(Map<String, dynamic> json) => DocumentList(
        id: json["id"],
        fileName: json["file_name"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "file_name": fileName,
        "status": status,
      };
}
