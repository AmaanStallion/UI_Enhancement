import 'dart:convert';

RccDprActivityResponse rccDprActivityResponseFromJson(String str) =>
    RccDprActivityResponse.fromJson(json.decode(str));

String rccDprActivityResponseToJson(RccDprActivityResponse data) =>
    json.encode(data.toJson());

class RccDprActivityResponse {
  final bool success;
  final String? message;
  final List<RccDprActivity> data;

  RccDprActivityResponse({
    required this.success,
    this.message,
    required this.data,
  });

  factory RccDprActivityResponse.fromJson(Map<String, dynamic> json) =>
      RccDprActivityResponse(
        success: json["success"] ?? false,
        message: json["message"]?.toString(),
        data: json["data"] == null
            ? []
            : List<RccDprActivity>.from(
                (json["data"] as List).map((x) => RccDprActivity.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class RccDprActivity {
  final String id;
  final String? dprId;
  final String? towerId;
  final String? slabId;
  final String? parentActivityId;
  final String activityName;
  DateTime? targetCompletionDate;
  bool isCompleted;
  DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? assignor;
  final String? completedBy;
  final TowerInfo? tower;
  final SlabInfo? slab;
  final DprInfo? dpr;
  final List<DprActivityLog> logs;

  RccDprActivity({
    required this.id,
    this.dprId,
    this.towerId,
    this.slabId,
    this.parentActivityId,
    required this.activityName,
    this.targetCompletionDate,
    required this.isCompleted,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.assignor,
    this.completedBy,
    this.tower,
    this.slab,
    this.dpr,
    required this.logs,
  });

  bool get hasValidSlab {
    final sId = slabId ?? slab?.id;
    return sId != null &&
        sId.trim().isNotEmpty &&
        sId.toLowerCase() != "null";
  }

  bool get isOverdue {
    if (isCompleted) return false;
    if (targetCompletionDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      targetCompletionDate!.year,
      targetCompletionDate!.month,
      targetCompletionDate!.day,
    );
    return target.isBefore(today);
  }

  List<DprActivityLog> get extensionLogs =>
      logs.where((l) => l.logType == "DEADLINE_EXTENDED").toList();

  DprActivityLog? get completionLog {
    try {
      return logs.firstWhere((l) => l.logType == "COMPLETED");
    } catch (_) {
      return null;
    }
  }

  String? get resolvedAssignor {
    if (dpr?.createdByUser?.name != null && dpr!.createdByUser!.name.trim().isNotEmpty) {
      return dpr!.createdByUser!.name;
    }
    if (assignor != null && assignor!.trim().isNotEmpty && assignor != "null") {
      return assignor;
    }
    if (createdBy != null && createdBy!.trim().isNotEmpty && createdBy != "null") {
      return createdBy;
    }
    return null;
  }

  String? get resolvedCompletedBy {
    final compLog = completionLog;
    if (compLog?.createdByUser?.name != null && compLog!.createdByUser!.name.trim().isNotEmpty) {
      return compLog.createdByUser!.name;
    }
    if (completedBy != null && completedBy!.trim().isNotEmpty && completedBy != "null") {
      return completedBy;
    }
    if (compLog?.createdBy != null && compLog!.createdBy!.trim().isNotEmpty && compLog.createdBy != "null") {
      return compLog.createdBy;
    }
    return null;
  }

  factory RccDprActivity.fromJson(Map<String, dynamic> json) => RccDprActivity(
        id: json["id"]?.toString() ?? "",
        dprId: json["dpr_id"]?.toString(),
        towerId: json["tower_id"]?.toString(),
        slabId: json["slab_id"]?.toString(),
        parentActivityId: json["parent_activity_id"]?.toString(),
        activityName: json["activity_name"]?.toString() ?? "",
        targetCompletionDate: json["target_completion_date"] == null
            ? null
            : DateTime.tryParse(json["target_completion_date"].toString()),
        isCompleted: json["is_completed"] == true,
        completedAt: json["completed_at"] == null
            ? null
            : DateTime.tryParse(json["completed_at"].toString()),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"].toString()),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"].toString()),
        createdBy: json["created_by"]?.toString(),
        assignor: json["assignor"]?.toString() ?? json["assign_by"]?.toString(),
        completedBy: json["completed_by"]?.toString(),
        tower: json["tower"] == null ? null : TowerInfo.fromJson(json["tower"]),
        slab: json["slab"] == null ? null : SlabInfo.fromJson(json["slab"]),
        dpr: json["dpr"] == null ? null : DprInfo.fromJson(json["dpr"]),
        logs: json["logs"] == null
            ? []
            : List<DprActivityLog>.from(
                (json["logs"] as List).map((x) => DprActivityLog.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "dpr_id": dprId,
        "tower_id": towerId,
        "slab_id": slabId,
        "parent_activity_id": parentActivityId,
        "activity_name": activityName,
        "target_completion_date": targetCompletionDate?.toIso8601String(),
        "is_completed": isCompleted,
        "completed_at": completedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "created_by": createdBy,
        "assignor": assignor,
        "completed_by": completedBy,
        "tower": tower?.toJson(),
        "slab": slab?.toJson(),
        "dpr": dpr?.toJson(),
        "logs": List<dynamic>.from(logs.map((x) => x.toJson())),
      };
}

class DprUserInfo {
  final String id;
  final String name;
  final String? companyName;
  final String? role;

  DprUserInfo({
    required this.id,
    required this.name,
    this.companyName,
    this.role,
  });

  factory DprUserInfo.fromJson(Map<String, dynamic> json) => DprUserInfo(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        companyName: json["company_name"]?.toString(),
        role: json["role"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "company_name": companyName,
        "role": role,
      };
}

class DprInfo {
  final DprUserInfo? createdByUser;

  DprInfo({this.createdByUser});

  factory DprInfo.fromJson(Map<String, dynamic> json) => DprInfo(
        createdByUser: json["created_by_user"] == null
            ? null
            : DprUserInfo.fromJson(json["created_by_user"]),
      );

  Map<String, dynamic> toJson() => {
        "created_by_user": createdByUser?.toJson(),
      };
}

class TowerInfo {
  final String id;
  final String name;

  TowerInfo({
    required this.id,
    required this.name,
  });

  factory TowerInfo.fromJson(Map<String, dynamic> json) => TowerInfo(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class SlabInfo {
  final String id;
  final String name;
  final int? slabNumber;

  SlabInfo({
    required this.id,
    required this.name,
    this.slabNumber,
  });

  factory SlabInfo.fromJson(Map<String, dynamic> json) => SlabInfo(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        slabNumber: json["slab_number"] is int
            ? json["slab_number"]
            : int.tryParse(json["slab_number"]?.toString() ?? ""),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slab_number": slabNumber,
      };
}

class DprActivityLog {
  final String id;
  final String? activityId;
  final String logType;
  final String? remarks;
  final DateTime? previousDeadline;
  final DateTime? newDeadline;
  final String? createdBy;
  final DateTime? createdAt;
  final DprUserInfo? createdByUser;
  final List<DprActivityDocument> documents;

  DprActivityLog({
    required this.id,
    this.activityId,
    required this.logType,
    this.remarks,
    this.previousDeadline,
    this.newDeadline,
    this.createdBy,
    this.createdAt,
    this.createdByUser,
    required this.documents,
  });

  factory DprActivityLog.fromJson(Map<String, dynamic> json) => DprActivityLog(
        id: json["id"]?.toString() ?? "",
        activityId: json["activity_id"]?.toString(),
        logType: json["log_type"]?.toString() ?? "",
        remarks: json["remarks"]?.toString(),
        previousDeadline: json["previous_deadline"] == null
            ? null
            : DateTime.tryParse(json["previous_deadline"].toString()),
        newDeadline: json["new_deadline"] == null
            ? null
            : DateTime.tryParse(json["new_deadline"].toString()),
        createdBy: json["created_by"]?.toString(),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"].toString()),
        createdByUser: json["created_by_user"] == null
            ? null
            : DprUserInfo.fromJson(json["created_by_user"]),
        documents: json["documents"] == null
            ? []
            : List<DprActivityDocument>.from((json["documents"] as List)
                .map((x) => DprActivityDocument.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "activity_id": activityId,
        "log_type": logType,
        "remarks": remarks,
        "previous_deadline": previousDeadline?.toIso8601String(),
        "new_deadline": newDeadline?.toIso8601String(),
        "created_by": createdBy,
        "created_at": createdAt?.toIso8601String(),
        "created_by_user": createdByUser?.toJson(),
        "documents": List<dynamic>.from(documents.map((x) => x.toJson())),
      };
}

class DprActivityDocument {
  final String id;
  final String? activityLogId;
  final String fileName;
  final String? fileKey;
  final String fileUrl;
  final String? mimeType;
  final String? extension;
  final String? fileSize;
  final String? uploadedBy;
  final DateTime? createdAt;

  DprActivityDocument({
    required this.id,
    this.activityLogId,
    required this.fileName,
    this.fileKey,
    required this.fileUrl,
    this.mimeType,
    this.extension,
    this.fileSize,
    this.uploadedBy,
    this.createdAt,
  });

  factory DprActivityDocument.fromJson(Map<String, dynamic> json) =>
      DprActivityDocument(
        id: json["id"]?.toString() ?? "",
        activityLogId: json["activity_log_id"]?.toString(),
        fileName: json["file_name"]?.toString() ?? "",
        fileKey: json["file_key"]?.toString(),
        fileUrl: json["file_url"]?.toString() ?? "",
        mimeType: json["mime_type"]?.toString(),
        extension: json["extension"]?.toString(),
        fileSize: json["file_size"]?.toString(),
        uploadedBy: json["uploaded_by"]?.toString(),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "activity_log_id": activityLogId,
        "file_name": fileName,
        "file_key": fileKey,
        "file_url": fileUrl,
        "mime_type": mimeType,
        "extension": extension,
        "file_size": fileSize,
        "uploaded_by": uploadedBy,
        "created_at": createdAt?.toIso8601String(),
      };
}
