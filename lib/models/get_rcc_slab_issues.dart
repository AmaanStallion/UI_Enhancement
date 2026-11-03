import 'dart:convert';
import 'package:stallion/models/get_rccissuereport_data.dart';

GetRccSlabIssuesResponse getRccSlabIssuesResponseFromJson(String str) =>
    GetRccSlabIssuesResponse.fromJson(json.decode(str));

String formatDateToDdMmYyyy(String? dateStr) {
  if (dateStr == null || dateStr.trim().isEmpty) return '';
  final cleaned = dateStr.trim();
  try {
    final dt = DateTime.parse(cleaned);
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}';
  } catch (_) {}
  try {
    final rawDate = cleaned.contains('T') ? cleaned.split('T')[0] : cleaned;
    final parts = rawDate.split('-');
    if (parts.length == 3 && parts[0].length == 4) {
      return '${parts[2].padLeft(2, '0')}/${parts[1].padLeft(2, '0')}/${parts[0]}';
    }
  } catch (_) {}
  return cleaned;
}

class GetRccSlabIssuesResponse {
  bool success;
  String message;
  SlabIssuesData? data;

  GetRccSlabIssuesResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory GetRccSlabIssuesResponse.fromJson(Map<String, dynamic> json) {
    SlabIssuesData? parsedData;
    if (json["data"] is Map<String, dynamic>) {
      parsedData = SlabIssuesData.fromJson(json["data"]);
    } else if (json["data"] is List) {
      parsedData = SlabIssuesData.fromJson({"issues": json["data"]});
    } else if (json["issues"] is List) {
      parsedData = SlabIssuesData.fromJson({"issues": json["issues"]});
    }

    return GetRccSlabIssuesResponse(
      success: json["success"] == true || json["success"]?.toString() == "true",
      message: json["message"]?.toString() ?? "",
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class SlabIssuesData {
  int totalRecords;
  int currentPage;
  int pageSize;
  int totalPages;
  List<SlabIssueItem> issues;

  SlabIssuesData({
    required this.totalRecords,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.issues,
  });

  factory SlabIssuesData.fromJson(Map<String, dynamic> json) {
    List rawIssues = [];
    if (json["issues"] is List) {
      rawIssues = json["issues"];
    } else if (json["data"] is List) {
      rawIssues = json["data"];
    } else if (json["data"] is Map && json["data"]["issues"] is List) {
      rawIssues = json["data"]["issues"];
    }

    return SlabIssuesData(
      totalRecords: _parseInt(json["totalRecords"] ?? json["total_records"]),
      currentPage: _parseInt(json["currentPage"] ?? json["current_page"]),
      pageSize: _parseInt(json["pageSize"] ?? json["page_size"]),
      totalPages: _parseInt(json["totalPages"] ?? json["total_pages"]),
      issues: List<SlabIssueItem>.from(
          rawIssues.map((x) => SlabIssueItem.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "totalRecords": totalRecords,
        "currentPage": currentPage,
        "pageSize": pageSize,
        "totalPages": totalPages,
        "issues": List<dynamic>.from(issues.map((x) => x.toJson())),
      };

  static int _parseInt(dynamic val) {
    if (val is int) return val;
    if (val != null) return int.tryParse(val.toString()) ?? 0;
    return 0;
  }
}

class SlabIssueItem {
  String id;
  String? developerId;
  String? projectId;
  String? towerId;
  String? slabId;
  String? targetType;
  String? slabDrawingTypeId;
  String? issueNo;
  String? title;
  String? message;
  String? priority;
  String? reportedBy;
  String? assignedTo;
  String? submittedOn;
  String? completedOn;
  String? status;
  bool isActive;
  String? createdAt;
  String? updatedAt;
  List<AuthorityAssignment> authorityAssignments;
  UserRef? reporter;
  UserRef? assignee;
  DrawingTypeRef? drawingType;
  SlabRef? slab;
  List<IssueHistoryItem> history;
  List<IssueAttachment> attachments;

  SlabIssueItem({
    required this.id,
    this.developerId,
    this.projectId,
    this.towerId,
    this.slabId,
    this.targetType,
    this.slabDrawingTypeId,
    this.issueNo,
    this.title,
    this.message,
    this.priority,
    this.reportedBy,
    this.assignedTo,
    this.submittedOn,
    this.completedOn,
    this.status,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    required this.authorityAssignments,
    this.reporter,
    this.assignee,
    this.drawingType,
    this.slab,
    required this.history,
    required this.attachments,
  });

  factory SlabIssueItem.fromJson(Map<String, dynamic> json) => SlabIssueItem(
        id: json["id"]?.toString() ?? "",
        developerId: json["developer_id"]?.toString(),
        projectId: json["project_id"]?.toString(),
        towerId: json["tower_id"]?.toString(),
        slabId: json["slab_id"]?.toString(),
        targetType: json["target_type"]?.toString(),
        slabDrawingTypeId: json["slab_drawing_type_id"]?.toString(),
        issueNo: json["issue_no"]?.toString(),
        title: json["title"]?.toString(),
        message: json["message"]?.toString(),
        priority: json["priority"]?.toString(),
        reportedBy: json["reported_by"]?.toString(),
        assignedTo: json["assigned_to"]?.toString(),
        submittedOn: json["submitted_on"]?.toString(),
        completedOn: json["completed_on"]?.toString(),
        status: json["status"]?.toString(),
        isActive: json["is_active"] == true || json["is_active"]?.toString() == "true",
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
        authorityAssignments: json["authority_assignments"] == null
            ? []
            : List<AuthorityAssignment>.from(json["authority_assignments"]
                .map((x) => AuthorityAssignment.fromJson(x))),
        reporter: json["reporter"] != null
            ? UserRef.fromJson(json["reporter"])
            : null,
        assignee: json["assignee"] != null
            ? UserRef.fromJson(json["assignee"])
            : null,
        drawingType: json["drawing_type"] != null
            ? DrawingTypeRef.fromJson(json["drawing_type"])
            : null,
        slab: json["slab"] != null ? SlabRef.fromJson(json["slab"]) : null,
        history: json["history"] == null
            ? []
            : List<IssueHistoryItem>.from(
                json["history"].map((x) => IssueHistoryItem.fromJson(x))),
        attachments: json["attachments"] == null
            ? []
            : List<IssueAttachment>.from(
                json["attachments"].map((x) => IssueAttachment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "developer_id": developerId,
        "project_id": projectId,
        "tower_id": towerId,
        "slab_id": slabId,
        "target_type": targetType,
        "slab_drawing_type_id": slabDrawingTypeId,
        "issue_no": issueNo,
        "title": title,
        "message": message,
        "priority": priority,
        "reported_by": reportedBy,
        "assigned_to": assignedTo,
        "submitted_on": submittedOn,
        "completed_on": completedOn,
        "status": status,
        "is_active": isActive,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "authority_assignments":
            List<dynamic>.from(authorityAssignments.map((x) => x.toJson())),
        "reporter": reporter?.toJson(),
        "assignee": assignee?.toJson(),
        "drawing_type": drawingType?.toJson(),
        "slab": slab?.toJson(),
        "history": List<dynamic>.from(history.map((x) => x.toJson())),
        "attachments": List<dynamic>.from(attachments.map((x) => x.toJson())),
      };

  IssueHistoryItem? get latestHistory {
    if (history.isEmpty) return null;
    IssueHistoryItem mostRecent = history.first;
    DateTime? mostRecentDt = mostRecent.createdAt != null
        ? DateTime.tryParse(mostRecent.createdAt!)
        : null;
    int mostRecentId = int.tryParse(mostRecent.id) ?? 0;

    for (int i = 1; i < history.length; i++) {
      final cur = history[i];
      final curDt =
          cur.createdAt != null ? DateTime.tryParse(cur.createdAt!) : null;
      final curId = int.tryParse(cur.id) ?? 0;

      bool isCurNewer = false;
      if (curDt != null && mostRecentDt != null) {
        if (curDt.isAfter(mostRecentDt)) {
          isCurNewer = true;
        } else if (curDt.isAtSameMomentAs(mostRecentDt)) {
          isCurNewer = curId > mostRecentId;
        }
      } else if (curDt != null) {
        isCurNewer = true;
      } else {
        isCurNewer = curId > mostRecentId;
      }

      if (isCurNewer) {
        mostRecent = cur;
        mostRecentDt = curDt;
        mostRecentId = curId;
      }
    }
    return mostRecent;
  }

  SlabIssueReport toSlabIssueReport() {
    List<String> imgUrls = [];
    List<String> vidUrls = [];

    for (var att in attachments) {
      if (att.fileUrl != null && att.fileUrl!.isNotEmpty) {
        final fUrl = att.fileUrl!;
        final ext = (att.fileName ?? fUrl).toLowerCase();
        final type = (att.type ?? '').toLowerCase();
        if (type == 'video' ||
            ext.endsWith('.mp4') ||
            ext.endsWith('.mov') ||
            ext.endsWith('.avi') ||
            ext.endsWith('.mkv')) {
          if (!vidUrls.contains(fUrl)) {
            vidUrls.add(fUrl);
          }
        } else {
          if (!imgUrls.contains(fUrl)) {
            imgUrls.add(fUrl);
          }
        }
      }
    }

    final recentHistory = latestHistory;

    // Determine current effective status from the recent-most history item
    final String currentStatus = (recentHistory?.newStatus?.isNotEmpty == true
            ? recentHistory!.newStatus!
            : (status?.isNotEmpty == true ? status! : 'pending'))
        .toLowerCase()
        .trim();

    final bool isResolved = currentStatus == 'resolved';

    // Resolution media from the recent-most history record (only when resolved)
    List<String> resImgUrls = [];
    List<String> resVidUrls = [];
    if (isResolved && recentHistory != null) {
      for (var att in recentHistory.attachments) {
        if (att.fileUrl != null && att.fileUrl!.isNotEmpty) {
          final fUrl = att.fileUrl!;
          final ext = (att.fileName ?? fUrl).toLowerCase();
          final type = (att.type ?? '').toLowerCase();
          if (type == 'video' ||
              ext.endsWith('.mp4') ||
              ext.endsWith('.mov') ||
              ext.endsWith('.avi') ||
              ext.endsWith('.mkv')) {
            if (!resVidUrls.contains(fUrl)) {
              resVidUrls.add(fUrl);
            }
          } else {
            if (!resImgUrls.contains(fUrl)) {
              resImgUrls.add(fUrl);
            }
          }
        }
      }
    }

    List<String> authNames = [];
    for (var aa in authorityAssignments) {
      String formatted = aa.getFormattedAuthorityName();
      if (formatted.isNotEmpty && !authNames.contains(formatted)) {
        authNames.add(formatted);
      }
    }

    // Remarks from recent history, or fallback to original message/title/issueNo
    String remarkStr;
    if (recentHistory?.remarks != null &&
        recentHistory!.remarks!.trim().isNotEmpty) {
      remarkStr = recentHistory.remarks!.trim();
    } else if (message != null && message!.trim().isNotEmpty) {
      remarkStr = message!.trim();
    } else if (title != null && title!.trim().isNotEmpty) {
      remarkStr = title!.trim();
    } else {
      remarkStr = issueNo ?? '';
    }

    String dateStr = formatDateToDdMmYyyy(submittedOn ?? createdAt);

    // Resolved Date: Only set if issue is currently resolved
    String resolveDateStr = isResolved
        ? formatDateToDdMmYyyy(
            recentHistory?.createdAt ?? completedOn ?? updatedAt)
        : '';

    // Resolved By user name from changedByUser or changedBy
    String resolvedByName = reporter?.name ?? 'User';
    if (isResolved && recentHistory != null) {
      if (recentHistory.changedByUser?.name?.isNotEmpty == true) {
        resolvedByName = recentHistory.changedByUser!.name!;
      } else if (recentHistory.changedBy != null) {
        final changedById = recentHistory.changedBy!.trim();
        for (var aa in authorityAssignments) {
          if (aa.towerAuthority?.assignedToUser?.id == changedById &&
              aa.towerAuthority?.assignedToUser?.name?.isNotEmpty == true) {
            resolvedByName = aa.towerAuthority!.assignedToUser!.name!;
            break;
          }
          if (aa.createdByUser?.id == changedById &&
              aa.createdByUser?.name?.isNotEmpty == true) {
            resolvedByName = aa.createdByUser!.name!;
            break;
          }
        }
        if (reporter?.id == changedById && reporter?.name?.isNotEmpty == true) {
          resolvedByName = reporter!.name!;
        }
      }
    }

    String issueInLabel = slab?.name?.isNotEmpty == true
        ? slab!.name!
        : (drawingType?.getDrawingTypeName().isNotEmpty == true
            ? drawingType!.getDrawingTypeName()
            : (targetType == 'drawing' ? 'Drawing Issue' : 'Slab Issue'));

    return SlabIssueReport(
      mstSlabIssuerReportId: id,
      issueIn: slabDrawingTypeId ?? '',
      issusInName: issueInLabel,
      reports: remarkStr,
      extracomment: remarkStr,
      submitdate: dateStr,
      resolvedate: resolveDateStr,
      userIdFk: reportedBy ?? '',
      issueResolve: isResolved ? "1" : "0",
      reportBy: reporter?.name ?? 'User',
      reportedBy: reporter?.name ?? 'User',
      reportToName: authNames.join(', '),
      reportTo: authNames.join(', '),
      issueResolveBtn: isResolved ? "1" : "0",
      resolvedDate: resolveDateStr,
      empname: isResolved ? resolvedByName : (reporter?.name ?? 'User'),
      imagePath: "",
      image: imgUrls,
      slabVedio: vidUrls,
      resolutionImages: resImgUrls,
      resolutionVideos: resVidUrls,
    );
  }
}

class AuthorityAssignment {
  String id;
  String issueId;
  String towerAuthorityId;
  TowerAuthorityRef? towerAuthority;
  UserRef? createdByUser;

  AuthorityAssignment({
    required this.id,
    required this.issueId,
    required this.towerAuthorityId,
    this.towerAuthority,
    this.createdByUser,
  });

  factory AuthorityAssignment.fromJson(Map<String, dynamic> json) =>
      AuthorityAssignment(
        id: json["id"]?.toString() ?? "",
        issueId: json["issue_id"]?.toString() ?? "",
        towerAuthorityId: json["tower_authority_id"]?.toString() ?? "",
        towerAuthority: json["tower_authority"] != null
            ? TowerAuthorityRef.fromJson(json["tower_authority"])
            : null,
        createdByUser: json["created_by_user"] != null
            ? UserRef.fromJson(json["created_by_user"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "issue_id": issueId,
        "tower_authority_id": towerAuthorityId,
        "tower_authority": towerAuthority?.toJson(),
        "created_by_user": createdByUser?.toJson(),
      };

  String getFormattedAuthorityName() {
    if (towerAuthority?.type == null) return '';
    final typeStr = towerAuthority!.type!.trim().toLowerCase();
    if (typeStr == 'structural_consultant' || typeStr.contains('structural')) {
      return 'Structural Consultant';
    } else if (typeStr == 'developer') {
      return 'Developer';
    } else if (typeStr == 'municipal_architect' || typeStr.contains('architect')) {
      return 'Municipal Architect';
    } else if (typeStr == 'rcc_contractor' || typeStr.contains('contractor')) {
      return 'RCC Contractor';
    }
    return towerAuthority!.type!;
  }
}

class TowerAuthorityRef {
  String id;
  String? towerId;
  String? type;
  String? assignedTo;
  UserRef? assignedToUser;

  TowerAuthorityRef({
    required this.id,
    this.towerId,
    this.type,
    this.assignedTo,
    this.assignedToUser,
  });

  factory TowerAuthorityRef.fromJson(Map<String, dynamic> json) =>
      TowerAuthorityRef(
        id: json["id"]?.toString() ?? "",
        towerId: json["tower_id"]?.toString(),
        type: json["type"]?.toString(),
        assignedTo: json["assigned_to"]?.toString(),
        assignedToUser: json["assigned_to_user"] != null
            ? UserRef.fromJson(json["assigned_to_user"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tower_id": towerId,
        "type": type,
        "assigned_to": assignedTo,
        "assigned_to_user": assignedToUser?.toJson(),
      };
}

class SlabRef {
  String id;
  String? name;

  SlabRef({required this.id, this.name});

  factory SlabRef.fromJson(Map<String, dynamic> json) => SlabRef(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class UserRef {
  String id;
  String? name;
  String? email;

  UserRef({
    required this.id,
    this.name,
    this.email,
  });

  factory UserRef.fromJson(Map<String, dynamic> json) => UserRef(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString(),
        email: json["email"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
      };
}

class DrawingTypeRef {
  String id;
  Map<String, dynamic>? drawingTypeMap;

  DrawingTypeRef({
    required this.id,
    this.drawingTypeMap,
  });

  factory DrawingTypeRef.fromJson(Map<String, dynamic> json) => DrawingTypeRef(
        id: json["id"]?.toString() ?? "",
        drawingTypeMap: json["drawing_type"] is Map ? json["drawing_type"] : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "drawing_type": drawingTypeMap,
      };

  String getDrawingTypeName() {
    if (drawingTypeMap != null && drawingTypeMap!["name"] != null) {
      return drawingTypeMap!["name"].toString();
    }
    return '';
  }
}

class IssueAttachment {
  String id;
  String? type;
  String? fileName;
  String? fileUrl;

  IssueAttachment({
    required this.id,
    this.type,
    this.fileName,
    this.fileUrl,
  });

  factory IssueAttachment.fromJson(Map<String, dynamic> json) => IssueAttachment(
        id: json["id"]?.toString() ?? "",
        type: json["type"]?.toString(),
        fileName: json["file_name"]?.toString(),
        fileUrl: json["file_url"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "file_name": fileName,
        "file_url": fileUrl,
      };
}

class IssueHistoryItem {
  String id;
  String? issueId;
  String? oldStatus;
  String? newStatus;
  String? remarks;
  String? changedBy;
  UserRef? changedByUser;
  String? createdAt;
  List<IssueAttachment> attachments;

  IssueHistoryItem({
    required this.id,
    this.issueId,
    this.oldStatus,
    this.newStatus,
    this.remarks,
    this.changedBy,
    this.changedByUser,
    this.createdAt,
    required this.attachments,
  });

  factory IssueHistoryItem.fromJson(Map<String, dynamic> json) => IssueHistoryItem(
        id: json["id"]?.toString() ?? "",
        issueId: json["issue_id"]?.toString(),
        oldStatus: json["old_status"]?.toString(),
        newStatus: json["new_status"]?.toString(),
        remarks: json["remarks"]?.toString(),
        changedBy: json["changed_by"]?.toString(),
        changedByUser: json["changed_by_user"] != null
            ? UserRef.fromJson(json["changed_by_user"])
            : null,
        createdAt: json["created_at"]?.toString(),
        attachments: json["attachments"] == null
            ? []
            : List<IssueAttachment>.from(
                json["attachments"].map((x) => IssueAttachment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "issue_id": issueId,
        "old_status": oldStatus,
        "new_status": newStatus,
        "remarks": remarks,
        "changed_by": changedBy,
        "changed_by_user": changedByUser?.toJson(),
        "created_at": createdAt,
        "attachments": List<dynamic>.from(attachments.map((x) => x.toJson())),
      };
}
