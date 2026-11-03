import 'dart:convert';

DevSopCategoryResponse devSopCategoryResponseFromJson(String str) =>
    DevSopCategoryResponse.fromJson(json.decode(str));

String devSopCategoryResponseToJson(DevSopCategoryResponse data) =>
    json.encode(data.toJson());

class DevSopCategoryResponse {
  bool? success;
  String? message;
  List<DevSopCategory>? data;

  DevSopCategoryResponse({
    this.success,
    this.message,
    this.data,
  });

  factory DevSopCategoryResponse.fromJson(Map<String, dynamic> json) =>
      DevSopCategoryResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<DevSopCategory>.from(
                json["data"]!.map((x) => DevSopCategory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class DevSopCategory {
  String? id;
  String? developerId;
  String? globalCategoryId;
  String? name;
  String? description;
  String? source;
  int? displayOrder;
  bool? isEnabled;
  bool? isDeleted;
  String? createdBy;
  String? updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;

  int? totalHeadings;
  int? completedHeadings;
  bool logsPresent;

  // Client-side computed properties for UI display on sop_screen.dart
  int totalCount = 0;
  int pendingCount = 0;
  int completedCount = 0;

  DevSopCategory({
    this.id,
    this.developerId,
    this.globalCategoryId,
    this.name,
    this.description,
    this.source,
    this.displayOrder,
    this.isEnabled,
    this.isDeleted,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.totalHeadings,
    this.completedHeadings,
    this.logsPresent = false,
    this.totalCount = 0,
    this.pendingCount = 0,
    this.completedCount = 0,
  });

  factory DevSopCategory.fromJson(Map<String, dynamic> json) {
    int totalH = json["total_headings"] is int
        ? json["total_headings"]
        : int.tryParse(json["total_headings"]?.toString() ?? '') ?? 0;
    int completedH = json["completed_headings"] is int
        ? json["completed_headings"]
        : int.tryParse(json["completed_headings"]?.toString() ?? '') ?? 0;
    int pendingH = (totalH - completedH) < 0 ? 0 : (totalH - completedH);

    bool parsedLogsPresent = json["logs_present"] == true ||
        json["logs_present"]?.toString() == "true" ||
        json["logs_present"] == 1 ||
        json["logs_present"]?.toString() == "1";

    bool? parsedIsEnabled;
    if (json["is_enabled"] is bool) {
      parsedIsEnabled = json["is_enabled"];
    } else if (json["is_enabled"] != null) {
      parsedIsEnabled = json["is_enabled"] == true ||
          json["is_enabled"]?.toString() == "true" ||
          json["is_enabled"] == 1 ||
          json["is_enabled"]?.toString() == "1";
    }

    return DevSopCategory(
      id: json["id"]?.toString(),
      developerId: json["developer_id"]?.toString(),
      globalCategoryId: json["global_category_id"]?.toString(),
      name: json["name"],
      description: json["description"],
      source: json["source"],
      displayOrder: json["display_order"] is int
          ? json["display_order"]
          : int.tryParse(json["display_order"]?.toString() ?? ''),
      isEnabled: parsedIsEnabled,
      isDeleted: json["is_deleted"],
      createdBy: json["created_by"]?.toString(),
      updatedBy: json["updated_by"]?.toString(),
      createdAt: json["created_at"] == null
          ? null
          : DateTime.tryParse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.tryParse(json["updated_at"]),
      totalHeadings: totalH,
      completedHeadings: completedH,
      logsPresent: parsedLogsPresent,
      totalCount: totalH,
      completedCount: completedH,
      pendingCount: pendingH,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "developer_id": developerId,
        "global_category_id": globalCategoryId,
        "name": name,
        "description": description,
        "source": source,
        "display_order": displayOrder,
        "is_enabled": isEnabled,
        "is_deleted": isDeleted,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "total_headings": totalHeadings,
        "completed_headings": completedHeadings,
        "logs_present": logsPresent,
      };
}
