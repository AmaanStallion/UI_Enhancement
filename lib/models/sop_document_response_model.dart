import 'dart:convert';

DevSopDocResponse devSopDocResponseFromJson(String str) =>
    DevSopDocResponse.fromJson(json.decode(str));

String devSopDocResponseToJson(DevSopDocResponse data) =>
    json.encode(data.toJson());

class DevSopDocResponse {
  bool? success;
  String? message;
  dynamic data; // Can be a List<SopDocumentItem> (upload API) or Map with "documents" key (view API)

  DevSopDocResponse({
    this.success,
    this.message,
    this.data,
  });

  factory DevSopDocResponse.fromJson(Map<String, dynamic> json) =>
      DevSopDocResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data,
      };

  List<SopDocumentItem> get documentList {
    if (data == null) return [];
    if (data is List) {
      return (data as List)
          .map((x) => SopDocumentItem.fromJson(x as Map<String, dynamic>))
          .toList();
    } else if (data is Map && data["documents"] is List) {
      return (data["documents"] as List)
          .map((x) => SopDocumentItem.fromJson(x as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

class SopDocumentItem {
  String? id;
  String? towerSopSubHeadingId;
  String? uploadedBy;
  String? fileName;
  String? fileKey;
  String? fileUrl;
  String? mimeType;
  String? extension;
  String? fileSize;
  int? version;
  bool? isLatestVersion;
  DateTime? createdAt;
  DateTime? updatedAt;
  UploaderInfo? uploader;

  SopDocumentItem({
    this.id,
    this.towerSopSubHeadingId,
    this.uploadedBy,
    this.fileName,
    this.fileKey,
    this.fileUrl,
    this.mimeType,
    this.extension,
    this.fileSize,
    this.version,
    this.isLatestVersion,
    this.createdAt,
    this.updatedAt,
    this.uploader,
  });

  factory SopDocumentItem.fromJson(Map<String, dynamic> json) => SopDocumentItem(
        id: json["id"]?.toString(),
        towerSopSubHeadingId: json["tower_sop_sub_heading_id"]?.toString(),
        uploadedBy: json["uploaded_by"]?.toString(),
        fileName: json["file_name"],
        fileKey: json["file_key"],
        fileUrl: json["file_url"],
        mimeType: json["mime_type"],
        extension: json["extension"],
        fileSize: json["file_size"]?.toString(),
        version: json["version"] is int
            ? json["version"]
            : int.tryParse(json["version"]?.toString() ?? ''),
        isLatestVersion: json["is_latest_version"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"]),
        uploader: json["uploader"] == null
            ? null
            : UploaderInfo.fromJson(json["uploader"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tower_sop_sub_heading_id": towerSopSubHeadingId,
        "uploaded_by": uploadedBy,
        "file_name": fileName,
        "file_key": fileKey,
        "file_url": fileUrl,
        "mime_type": mimeType,
        "extension": extension,
        "file_size": fileSize,
        "version": version,
        "is_latest_version": isLatestVersion,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "uploader": uploader?.toJson(),
      };
}

class UploaderInfo {
  String? id;
  String? name;
  String? email;

  UploaderInfo({
    this.id,
    this.name,
    this.email,
  });

  factory UploaderInfo.fromJson(Map<String, dynamic> json) => UploaderInfo(
        id: json["id"]?.toString(),
        name: json["name"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
      };
}
