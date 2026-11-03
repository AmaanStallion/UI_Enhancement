import 'dart:convert';
import 'package:stallion/models/sop_document_response_model.dart';

TowerSopTaskListResponse towerSopTaskListResponseFromJson(String str) =>
    TowerSopTaskListResponse.fromJson(json.decode(str));

String towerSopTaskListResponseToJson(TowerSopTaskListResponse data) =>
    json.encode(data.toJson());

class TowerSopTaskListResponse {
  bool? success;
  String? message;
  TowerSopTaskData? data;

  TowerSopTaskListResponse({
    this.success,
    this.message,
    this.data,
  });

  factory TowerSopTaskListResponse.fromJson(Map<String, dynamic> json) =>
      TowerSopTaskListResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : TowerSopTaskData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class TowerSopTaskData {
  TowerInfo? tower;
  int? totalTasks;
  List<TowerSopTask>? tasks;

  TowerSopTaskData({
    this.tower,
    this.totalTasks,
    this.tasks,
  });

  factory TowerSopTaskData.fromJson(Map<String, dynamic> json) =>
      TowerSopTaskData(
        tower: json["tower"] == null ? null : TowerInfo.fromJson(json["tower"]),
        totalTasks: json["total_tasks"] is int
            ? json["total_tasks"]
            : int.tryParse(json["total_tasks"]?.toString() ?? ''),
        tasks: json["tasks"] == null
            ? []
            : List<TowerSopTask>.from(
                json["tasks"]!.map((x) => TowerSopTask.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "tower": tower?.toJson(),
        "total_tasks": totalTasks,
        "tasks": tasks == null
            ? []
            : List<dynamic>.from(tasks!.map((x) => x.toJson())),
      };
}

class TowerInfo {
  String? id;
  String? name;

  TowerInfo({
    this.id,
    this.name,
  });

  factory TowerInfo.fromJson(Map<String, dynamic> json) => TowerInfo(
        id: json["id"]?.toString(),
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class TowerSopTask {
  String? id;
  String? towerId;
  String? subHeadingId;
  String? assignedUserId;
  String? assignedBy;
  String? status;
  String? remarks;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? assignedAt;
  DateTime? completedAt;
  bool? isEnabled;
  bool? isDeleted;
  String? createdBy;
  String? updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  AssignedUser? assignedUser;
  AssignedUser? assignedByUser;
  SubHeadingDetail? subHeading;
  List<SopDocumentItem>? towerDocuments;

  TowerSopTask({
    this.id,
    this.towerId,
    this.subHeadingId,
    this.assignedUserId,
    this.assignedBy,
    this.status,
    this.remarks,
    this.startDate,
    this.endDate,
    this.assignedAt,
    this.completedAt,
    this.isEnabled,
    this.isDeleted,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.assignedUser,
    this.assignedByUser,
    this.subHeading,
    this.towerDocuments,
  });

  factory TowerSopTask.fromJson(Map<String, dynamic> json) {
    bool? parsedIsEnabled;
    if (json["is_enabled"] is bool) {
      parsedIsEnabled = json["is_enabled"];
    } else if (json["is_enabled"] != null) {
      parsedIsEnabled = json["is_enabled"] == true ||
          json["is_enabled"]?.toString() == "true" ||
          json["is_enabled"] == 1 ||
          json["is_enabled"]?.toString() == "1";
    }

    return TowerSopTask(
      id: json["id"]?.toString(),
      towerId: json["tower_id"]?.toString(),
      subHeadingId: json["sub_heading_id"]?.toString(),
      assignedUserId: json["assigned_user_id"]?.toString(),
      assignedBy: json["assigned_by"]?.toString(),
      status: json["status"],
      remarks: json["remarks"],
      startDate: json["start_date"] == null
          ? null
          : DateTime.tryParse(json["start_date"]),
      endDate: json["end_date"] == null
          ? null
          : DateTime.tryParse(json["end_date"]),
      assignedAt: json["assigned_at"] == null
          ? null
          : DateTime.tryParse(json["assigned_at"]),
      completedAt: json["completed_at"] == null
          ? null
          : DateTime.tryParse(json["completed_at"]),
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
      assignedUser: json["assigned_user"] == null
          ? null
          : AssignedUser.fromJson(json["assigned_user"]),
      assignedByUser: json["assigned_by_user"] == null
          ? null
          : AssignedUser.fromJson(json["assigned_by_user"]),
      subHeading: json["sub_heading"] == null
          ? null
          : SubHeadingDetail.fromJson(json["sub_heading"]),
      towerDocuments: json["tower_documents"] == null
          ? []
          : List<SopDocumentItem>.from(
              json["tower_documents"]!.map((x) => SopDocumentItem.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "tower_id": towerId,
        "sub_heading_id": subHeadingId,
        "assigned_user_id": assignedUserId,
        "assigned_by": assignedBy,
        "status": status,
        "remarks": remarks,
        "start_date": startDate?.toIso8601String(),
        "end_date": endDate?.toIso8601String(),
        "assigned_at": assignedAt?.toIso8601String(),
        "completed_at": completedAt?.toIso8601String(),
        "is_enabled": isEnabled,
        "is_deleted": isDeleted,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "assigned_user": assignedUser?.toJson(),
        "assigned_by_user": assignedByUser?.toJson(),
        "sub_heading": subHeading?.toJson(),
        "tower_documents": towerDocuments == null
            ? []
            : List<dynamic>.from(towerDocuments!.map((x) => x.toJson())),
      };
}

class AssignedUser {
  String? id;
  String? name;
  String? email;
  String? mobileNo;
  String? designation;
  String? profileImageUrl;

  AssignedUser({
    this.id,
    this.name,
    this.email,
    this.mobileNo,
    this.designation,
    this.profileImageUrl,
  });

  factory AssignedUser.fromJson(Map<String, dynamic> json) => AssignedUser(
        id: json["id"]?.toString(),
        name: json["name"],
        email: json["email"],
        mobileNo: json["mobile_no"],
        designation: json["designation"],
        profileImageUrl: json["profile_image_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "mobile_no": mobileNo,
        "designation": designation,
        "profile_image_url": profileImageUrl,
      };
}

class SubHeadingDetail {
  String? id;
  String? name;
  bool? mandatory;
  bool? isEnabled;
  HeadingNested? heading;

  SubHeadingDetail({
    this.id,
    this.name,
    this.mandatory,
    this.isEnabled,
    this.heading,
  });

  factory SubHeadingDetail.fromJson(Map<String, dynamic> json) {
    bool? parsedIsEnabled;
    if (json["is_enabled"] is bool) {
      parsedIsEnabled = json["is_enabled"];
    } else if (json["is_enabled"] != null) {
      parsedIsEnabled = json["is_enabled"] == true ||
          json["is_enabled"]?.toString() == "true" ||
          json["is_enabled"] == 1 ||
          json["is_enabled"]?.toString() == "1";
    }

    return SubHeadingDetail(
      id: json["id"]?.toString(),
      name: json["name"],
      mandatory: json["mandatory"],
      isEnabled: parsedIsEnabled,
      heading: json["heading"] == null
          ? null
          : HeadingNested.fromJson(json["heading"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "mandatory": mandatory,
        "is_enabled": isEnabled,
        "heading": heading?.toJson(),
      };
}

class HeadingNested {
  String? id;
  String? name;
  bool? isEnabled;
  CategoryNested? category;

  HeadingNested({
    this.id,
    this.name,
    this.isEnabled,
    this.category,
  });

  factory HeadingNested.fromJson(Map<String, dynamic> json) {
    bool? parsedIsEnabled;
    if (json["is_enabled"] is bool) {
      parsedIsEnabled = json["is_enabled"];
    } else if (json["is_enabled"] != null) {
      parsedIsEnabled = json["is_enabled"] == true ||
          json["is_enabled"]?.toString() == "true" ||
          json["is_enabled"] == 1 ||
          json["is_enabled"]?.toString() == "1";
    }

    return HeadingNested(
      id: json["id"]?.toString(),
      name: json["name"],
      isEnabled: parsedIsEnabled,
      category: json["category"] == null
          ? null
          : CategoryNested.fromJson(json["category"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "is_enabled": isEnabled,
        "category": category?.toJson(),
      };
}

class CategoryNested {
  String? id;
  String? name;
  bool? isEnabled;

  CategoryNested({
    this.id,
    this.name,
    this.isEnabled,
  });

  factory CategoryNested.fromJson(Map<String, dynamic> json) {
    bool? parsedIsEnabled;
    if (json["is_enabled"] is bool) {
      parsedIsEnabled = json["is_enabled"];
    } else if (json["is_enabled"] != null) {
      parsedIsEnabled = json["is_enabled"] == true ||
          json["is_enabled"]?.toString() == "true" ||
          json["is_enabled"] == 1 ||
          json["is_enabled"]?.toString() == "1";
    }

    return CategoryNested(
      id: json["id"]?.toString(),
      name: json["name"],
      isEnabled: parsedIsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "is_enabled": isEnabled,
      };
}
