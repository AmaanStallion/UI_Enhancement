import 'dart:convert';
import 'package:stallion/models/sop_sub_heading_model.dart';

DevSopHeadingResponse devSopHeadingResponseFromJson(String str) =>
    DevSopHeadingResponse.fromJson(json.decode(str));

String devSopHeadingResponseToJson(DevSopHeadingResponse data) =>
    json.encode(data.toJson());

class DevSopHeadingResponse {
  bool? success;
  String? message;
  List<DevSopHeading>? data;

  DevSopHeadingResponse({
    this.success,
    this.message,
    this.data,
  });

  factory DevSopHeadingResponse.fromJson(Map<String, dynamic> json) =>
      DevSopHeadingResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<DevSopHeading>.from(
                json["data"]!.map((x) => DevSopHeading.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class DevSopHeading {
  String? id;
  String? categoryId;
  String? globalHeadingId;
  String? name;
  String? description;
  String? source;
  int? displayOrder;
  bool? isEnabled;
  bool? isHeadingComplete;
  bool? isDeleted;
  String? createdBy;
  String? updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  CategoryRef? category;

  // Local state for UI expansion and nested subheadings
  bool isOpen;
  List<DevSopSubHeading> subHeadings;
  bool isLoadingSubHeadings;

  DevSopHeading({
    this.id,
    this.categoryId,
    this.globalHeadingId,
    this.name,
    this.description,
    this.source,
    this.displayOrder,
    this.isEnabled,
    this.isHeadingComplete,
    this.isDeleted,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.isOpen = false,
    List<DevSopSubHeading>? subHeadings,
    this.isLoadingSubHeadings = false,
  }) : subHeadings = subHeadings ?? [];

  factory DevSopHeading.fromJson(Map<String, dynamic> json) {
    bool? parsedIsEnabled;
    if (json["is_enabled"] is bool) {
      parsedIsEnabled = json["is_enabled"];
    } else if (json["is_enabled"] != null) {
      parsedIsEnabled = json["is_enabled"] == true ||
          json["is_enabled"]?.toString() == "true" ||
          json["is_enabled"] == 1 ||
          json["is_enabled"]?.toString() == "1";
    }

    bool? parsedIsHeadingComplete;
    if (json["is_heading_complete"] is bool) {
      parsedIsHeadingComplete = json["is_heading_complete"];
    } else if (json["is_heading_complete"] != null) {
      parsedIsHeadingComplete = json["is_heading_complete"] == true ||
          json["is_heading_complete"]?.toString() == "true" ||
          json["is_heading_complete"] == 1 ||
          json["is_heading_complete"]?.toString() == "1";
    }

    return DevSopHeading(
      id: json["id"]?.toString(),
      categoryId: json["category_id"]?.toString(),
      globalHeadingId: json["global_heading_id"]?.toString(),
      name: json["name"],
      description: json["description"],
      source: json["source"],
      displayOrder: json["display_order"] is int
          ? json["display_order"]
          : int.tryParse(json["display_order"]?.toString() ?? ''),
      isEnabled: parsedIsEnabled,
      isHeadingComplete: parsedIsHeadingComplete,
      isDeleted: json["is_deleted"],
      createdBy: json["created_by"]?.toString(),
      updatedBy: json["updated_by"]?.toString(),
      createdAt: json["created_at"] == null
          ? null
          : DateTime.tryParse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.tryParse(json["updated_at"]),
      category: json["category"] == null
          ? null
          : CategoryRef.fromJson(json["category"]),
      subHeadings: json["sub_headings"] == null
          ? []
          : List<DevSopSubHeading>.from(
              json["sub_headings"]!.map((x) => DevSopSubHeading.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "category_id": categoryId,
        "global_heading_id": globalHeadingId,
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
        "category": category?.toJson(),
        "sub_headings": List<dynamic>.from(subHeadings.map((x) => x.toJson())),
      };
}

class CategoryRef {
  String? id;
  String? name;

  CategoryRef({
    this.id,
    this.name,
  });

  factory CategoryRef.fromJson(Map<String, dynamic> json) => CategoryRef(
        id: json["id"]?.toString(),
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
