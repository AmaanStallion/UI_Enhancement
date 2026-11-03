import 'dart:convert';
import 'package:stallion/models/sop_document_response_model.dart';

DevSopSubHeadingResponse devSopSubHeadingResponseFromJson(String str) =>
    DevSopSubHeadingResponse.fromJson(json.decode(str));

String devSopSubHeadingResponseToJson(DevSopSubHeadingResponse data) =>
    json.encode(data.toJson());

bool? parseBoolHelper(dynamic val) {
  if (val == null) return null;
  if (val is bool) return val;
  if (val == 1 || val == '1' || val == 'true' || val == true) return true;
  if (val == 0 || val == '0' || val == 'false' || val == false) return false;
  return null;
}

class DevSopSubHeadingResponse {
  bool? success;
  String? message;
  List<DevSopSubHeading>? data;

  DevSopSubHeadingResponse({
    this.success,
    this.message,
    this.data,
  });

  factory DevSopSubHeadingResponse.fromJson(Map<String, dynamic> json) =>
      DevSopSubHeadingResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<DevSopSubHeading>.from(
                json["data"]!.map((x) => DevSopSubHeading.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class DevSopSubHeading {
  String? id;
  String? headingId;
  String? globalSubHeadingId;
  String? name;
  String? description;
  String? source;
  int? displayOrder;
  bool? mandatory;
  bool? isEnabled;
  bool? isDeleted;
  String? createdBy;
  String? updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  HeadingRef? heading;
  List<TowerAssignment>? towerAssignments;

  // Local state properties for sop_details.dart interactive cards
  String? status; // "yes", "no", or null
  String? checkFlag; // "1" = Yes, "2" = No, "0" = Pending
  String? remarks;
  DateTime? startDate;
  DateTime? endDate;
  String? assignedToId;
  String? assignedToName;
  List<SopDocumentItem> documents;
  bool isLoadingDocs;

  DevSopSubHeading({
    this.id,
    this.headingId,
    this.globalSubHeadingId,
    this.name,
    this.description,
    this.source,
    this.displayOrder,
    this.mandatory,
    this.isEnabled,
    this.isDeleted,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.heading,
    this.towerAssignments,
    this.status,
    this.checkFlag,
    this.remarks,
    this.startDate,
    this.endDate,
    this.assignedToId,
    this.assignedToName,
    List<SopDocumentItem>? documents,
    this.isLoadingDocs = false,
  }) : documents = documents ?? [];

  factory DevSopSubHeading.fromJson(Map<String, dynamic> json) {
    List<TowerAssignment> tAssignments = json["tower_assignments"] == null
        ? []
        : List<TowerAssignment>.from(
            json["tower_assignments"]!.map((x) => TowerAssignment.fromJson(x)));

    DateTime? parsedStart;
    DateTime? parsedEnd;
    String? currentRemarks;
    String? currentStatus;

    if (tAssignments.isNotEmpty) {
      currentRemarks = tAssignments.first.remarks;
      parsedStart = tAssignments.first.startDate;
      parsedEnd = tAssignments.first.endDate;
      currentStatus = tAssignments.first.status;
    }

    String? calcCheckFlag;
    if (currentStatus == "yes") {
      calcCheckFlag = "1";
    } else if (currentStatus == "no") {
      calcCheckFlag = "2";
    } else {
      calcCheckFlag = "0";
    }

    return DevSopSubHeading(
      id: json["id"]?.toString(),
      headingId: json["heading_id"]?.toString(),
      globalSubHeadingId: json["global_sub_heading_id"]?.toString(),
      name: json["name"],
      description: json["description"],
      source: json["source"],
      displayOrder: json["display_order"] is int
          ? json["display_order"]
          : int.tryParse(json["display_order"]?.toString() ?? ''),
      mandatory: parseBoolHelper(json["mandatory"]),
      isEnabled: parseBoolHelper(json["is_enabled"]),
      isDeleted: parseBoolHelper(json["is_deleted"]),
      createdBy: json["created_by"]?.toString(),
      updatedBy: json["updated_by"]?.toString(),
      createdAt: json["created_at"] == null
          ? null
          : DateTime.tryParse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.tryParse(json["updated_at"]),
      heading: json["heading"] == null
          ? null
          : HeadingRef.fromJson(json["heading"]),
      towerAssignments: tAssignments,
      status: currentStatus,
      checkFlag: calcCheckFlag,
      remarks: currentRemarks ?? json["description"],
      startDate: parsedStart,
      endDate: parsedEnd,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "heading_id": headingId,
        "global_sub_heading_id": globalSubHeadingId,
        "name": name,
        "description": description,
        "source": source,
        "display_order": displayOrder,
        "mandatory": mandatory,
        "is_enabled": isEnabled,
        "is_deleted": isDeleted,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "heading": heading?.toJson(),
        "tower_assignments": towerAssignments == null
            ? []
            : List<dynamic>.from(towerAssignments!.map((x) => x.toJson())),
      };
}

class HeadingRef {
  String? id;
  String? name;
  CategoryRef? category;

  HeadingRef({
    this.id,
    this.name,
    this.category,
  });

  factory HeadingRef.fromJson(Map<String, dynamic> json) => HeadingRef(
        id: json["id"]?.toString(),
        name: json["name"],
        category: json["category"] == null
            ? null
            : CategoryRef.fromJson(json["category"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category": category?.toJson(),
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

class TowerAssignment {
  TowerRef? tower;
  String? towerId;
  String? status;
  DateTime? startDate;
  DateTime? endDate;
  String? remarks;
  bool? isEnabled;

  TowerAssignment({
    this.tower,
    this.towerId,
    this.status,
    this.startDate,
    this.endDate,
    this.remarks,
    this.isEnabled,
  });

  factory TowerAssignment.fromJson(Map<String, dynamic> json) => TowerAssignment(
        tower: json["tower"] == null ? null : TowerRef.fromJson(json["tower"]),
        towerId: json["tower_id"]?.toString(),
        status: json["status"]?.toString(),
        startDate: json["start_date"] == null
            ? null
            : DateTime.tryParse(json["start_date"]),
        endDate: json["end_date"] == null
            ? null
            : DateTime.tryParse(json["end_date"]),
        remarks: json["remarks"],
        isEnabled: parseBoolHelper(json["is_enabled"]),
      );

  Map<String, dynamic> toJson() => {
        "tower": tower?.toJson(),
        "tower_id": towerId,
        "status": status,
        "start_date": startDate?.toIso8601String(),
        "end_date": endDate?.toIso8601String(),
        "remarks": remarks,
        "is_enabled": isEnabled,
      };
}

class TowerRef {
  String? id;
  String? name;

  TowerRef({
    this.id,
    this.name,
  });

  factory TowerRef.fromJson(Map<String, dynamic> json) => TowerRef(
        id: json["id"]?.toString(),
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
