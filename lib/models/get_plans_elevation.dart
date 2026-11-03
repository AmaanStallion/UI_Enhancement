import 'dart:convert';

GetPlansElevation getPlansElevationFromJson(String str) =>
    GetPlansElevation.fromJson(json.decode(str));

String getPlansElevationToJson(GetPlansElevation data) =>
    json.encode(data.toJson());

class GetPlansElevation {
  GetPlansElevation({
    this.success,
    this.message,
    this.data,
  });

  bool? success;
  String? message;
  List<PlansElevation>? data;

  factory GetPlansElevation.fromJson(Map<String, dynamic> json) => GetPlansElevation(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : List<PlansElevation>.from(
                json["data"].map((x) => PlansElevation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class PlansElevation {
  PlansElevation({
    this.id,
    this.towerId,
    this.documentName,
    this.fileKey,
    this.fileUrl,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  String? id;
  String? towerId;
  String? documentName;
  String? fileKey;
  String? fileUrl;
  String? createdBy;
  String? updatedBy;
  String? createdAt;
  String? updatedAt;

  factory PlansElevation.fromJson(Map<String, dynamic> json) => PlansElevation(
        id: json["id"]?.toString(),
        towerId: json["tower_id"]?.toString(),
        documentName: json["document_name"],
        fileKey: json["file_key"],
        fileUrl: json["file_url"],
        createdBy: json["created_by"]?.toString(),
        updatedBy: json["updated_by"]?.toString(),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tower_id": towerId,
        "document_name": documentName,
        "file_key": fileKey,
        "file_url": fileUrl,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
