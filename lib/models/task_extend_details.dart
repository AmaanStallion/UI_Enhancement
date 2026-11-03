// To parse this JSON data, do
//
//     final taskExtendDetails = taskExtendDetailsFromJson(jsonString);

import 'dart:convert';

TaskExtendDetails taskExtendDetailsFromJson(String str) =>
    TaskExtendDetails.fromJson(json.decode(str));

String taskExtendDetailsToJson(TaskExtendDetails data) =>
    json.encode(data.toJson());

class TaskExtendDetails {
  TaskExtendDetailsResponse? response;

  TaskExtendDetails({
    this.response,
  });

  factory TaskExtendDetails.fromJson(Map<String, dynamic> json) =>
      TaskExtendDetails(
        response: json["Response"] == null
            ? null
            : TaskExtendDetailsResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class TaskExtendDetailsResponse {
  String? errorCode;
  String? msg;
  List<ExtendTaskDetail>? extendTaskDetails;
  String? filePath;

  TaskExtendDetailsResponse({
    this.errorCode,
    this.msg,
    this.extendTaskDetails,
    this.filePath,
  });

  factory TaskExtendDetailsResponse.fromJson(Map<String, dynamic> json) =>
      TaskExtendDetailsResponse(
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
  String? taskExtendDate;
  String? taskExtendRemak;
  String? extendedBy;
  String? createdDate;
  List<Document>? documents;

  ExtendTaskDetail({
    this.taskExtendDate,
    this.taskExtendRemak,
    this.extendedBy,
    this.createdDate,
    this.documents,
  });

  factory ExtendTaskDetail.fromJson(Map<String, dynamic> json) =>
      ExtendTaskDetail(
        taskExtendDate: json["task_extend_date"],
        taskExtendRemak: json["task_extend_remak"],
        extendedBy: json["extended_by"],
        createdDate: json["created_date"],
        documents: json["documents"] == null
            ? []
            : List<Document>.from(
                json["documents"]!.map((x) => Document.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "task_extend_date": taskExtendDate,
        "task_extend_remak": taskExtendRemak,
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
