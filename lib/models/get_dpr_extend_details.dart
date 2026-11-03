// To parse this JSON data, do
//
//     final getDprExtendDetails = getDprExtendDetailsFromJson(jsonString);

import 'dart:convert';

GetDprExtendDetails getDprExtendDetailsFromJson(String str) =>
    GetDprExtendDetails.fromJson(json.decode(str));

String getDprExtendDetailsToJson(GetDprExtendDetails data) =>
    json.encode(data.toJson());

class GetDprExtendDetails {
  GetDprExtendDetailsResponse? response;

  GetDprExtendDetails({
    this.response,
  });

  factory GetDprExtendDetails.fromJson(Map<String, dynamic> json) =>
      GetDprExtendDetails(
        response: json["Response"] == null
            ? null
            : GetDprExtendDetailsResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class GetDprExtendDetailsResponse {
  String? errorCode;
  String? msg;
  List<ExtendTaskDetail>? extendTaskDetails;
  String? filePath;

  GetDprExtendDetailsResponse({
    this.errorCode,
    this.msg,
    this.extendTaskDetails,
    this.filePath,
  });

  factory GetDprExtendDetailsResponse.fromJson(Map<String, dynamic> json) =>
      GetDprExtendDetailsResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        extendTaskDetails: json["extend_task_details"] == null
            ? []
            : List<ExtendTaskDetail>.from(json["extend_task_details"]!
                .map((x) => ExtendTaskDetail.fromJson(x))),
        filePath: json["file_path"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "extend_task_details": extendTaskDetails == null
            ? []
            : List<dynamic>.from(extendTaskDetails!.map((x) => x.toJson())),
        "file_path": filePath,
      };
}

class ExtendTaskDetail {
  String? dprExtendedDate;
  String? transDprTaskRemark;
  String? extendedBy;
  String? createdDate;
  List<Document>? documents;

  ExtendTaskDetail({
    this.dprExtendedDate,
    this.transDprTaskRemark,
    this.extendedBy,
    this.createdDate,
    this.documents,
  });

  factory ExtendTaskDetail.fromJson(Map<String, dynamic> json) =>
      ExtendTaskDetail(
        dprExtendedDate: json["dpr_extended_date"],
        transDprTaskRemark: json["trans_dpr_task_remark"],
        extendedBy: json["extended_by"],
        createdDate: json["created_date"],
        documents: json["documents"] == null
            ? []
            : List<Document>.from(
                json["documents"]!.map((x) => Document.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "dpr_extended_date": dprExtendedDate,
        "trans_dpr_task_remark": transDprTaskRemark,
        "extended_by": extendedBy,
        "created_date": createdDate,
        "documents": documents == null
            ? []
            : List<dynamic>.from(documents!.map((x) => x.toJson())),
      };
}

class Document {
  String? documentName;
  String? id;

  Document({
    this.documentName,
    this.id,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
        documentName: json["document_name"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "document_name": documentName,
        "id": id,
      };
}
