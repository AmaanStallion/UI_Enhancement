import 'dart:convert';

DevSopHistoryResponse devSopHistoryResponseFromJson(String str) =>
    DevSopHistoryResponse.fromJson(json.decode(str));

String devSopHistoryResponseToJson(DevSopHistoryResponse data) =>
    json.encode(data.toJson());

class DevSopHistoryResponse {
  bool? success;
  String? message;
  List<SopHistoryItem>? data;

  DevSopHistoryResponse({
    this.success,
    this.message,
    this.data,
  });

  factory DevSopHistoryResponse.fromJson(Map<String, dynamic> json) =>
      DevSopHistoryResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<SopHistoryItem>.from(
                json["data"]!.map((x) => SopHistoryItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class SopHistoryItem {
  String? id;
  String? submittedBy;
  String? fileName;
  String? date;
  String? viewUrl;

  SopHistoryItem({
    this.id,
    this.submittedBy,
    this.fileName,
    this.date,
    this.viewUrl,
  });

  factory SopHistoryItem.fromJson(Map<String, dynamic> json) => SopHistoryItem(
        id: json["id"]?.toString(),
        submittedBy: json["submitted_by"]?.toString() ?? json["userName"]?.toString() ?? '',
        fileName: json["file_name"]?.toString() ?? json["sopFileName"]?.toString() ?? '',
        date: json["date"]?.toString() ?? json["createdAt"]?.toString() ?? '',
        viewUrl: json["view_url"]?.toString() ?? json["filePath"]?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "submitted_by": submittedBy,
        "file_name": fileName,
        "date": date,
        "view_url": viewUrl,
      };
}
