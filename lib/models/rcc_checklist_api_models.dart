import 'dart:convert';

// --- API 1: Slab Submissions History ---

SlabSubmissionsResponse slabSubmissionsResponseFromJson(String str) =>
    SlabSubmissionsResponse.fromJson(json.decode(str));

class SlabSubmissionsResponse {
  final bool success;
  final String message;
  final SlabSubmissionsData? data;

  SlabSubmissionsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SlabSubmissionsResponse.fromJson(Map<String, dynamic> json) =>
      SlabSubmissionsResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null
            ? null
            : SlabSubmissionsData.fromJson(json["data"]),
      );
}

class SlabSubmissionsData {
  final DeveloperInfo? developer;
  final List<SlabSubmissionEntry> data;
  final int total;

  SlabSubmissionsData({
    this.developer,
    required this.data,
    required this.total,
  });

  factory SlabSubmissionsData.fromJson(Map<String, dynamic> json) =>
      SlabSubmissionsData(
        developer: json["developer"] == null
            ? null
            : DeveloperInfo.fromJson(json["developer"]),
        data: json["data"] == null
            ? []
            : List<SlabSubmissionEntry>.from(
                json["data"]!.map((x) => SlabSubmissionEntry.fromJson(x))),
        total: json["total"] ?? 0,
      );
}

class DeveloperInfo {
  final String id;
  final String name;
  final String email;
  final String companyName;

  DeveloperInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.companyName,
  });

  factory DeveloperInfo.fromJson(Map<String, dynamic> json) => DeveloperInfo(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        email: json["email"]?.toString() ?? "",
        companyName: json["company_name"]?.toString() ?? "",
      );
}

class SlabSubmissionEntry {
  final String id;
  final String slabId;
  final SlabSubmissionTree? data;
  final bool isSubmitted;
  final String? fileUrl;
  final String? fileName;
  final String? fileKey;
  final String? remarks;
  final DateTime? submittedAt;
  final DateTime? createdAt;
  final List<SubmissionFile> files;
  final CreatedByUser? createdByUser;

  SlabSubmissionEntry({
    required this.id,
    required this.slabId,
    this.data,
    required this.isSubmitted,
    this.fileUrl,
    this.fileName,
    this.fileKey,
    this.remarks,
    this.submittedAt,
    this.createdAt,
    required this.files,
    this.createdByUser,
  });

  factory SlabSubmissionEntry.fromJson(Map<String, dynamic> json) =>
      SlabSubmissionEntry(
        id: json["id"]?.toString() ?? "",
        slabId: json["slab_id"]?.toString() ?? "",
        data: json["data"] == null
            ? null
            : SlabSubmissionTree.fromJson(json["data"]),
        isSubmitted: json["is_submitted"] ?? false,
        fileUrl: json["file_url"]?.toString(),
        fileName: json["file_name"]?.toString(),
        fileKey: json["file_key"]?.toString(),
        remarks: json["remarks"]?.toString(),
        submittedAt: DateTime.tryParse(json["submitted_at"] ?? ""),
        createdAt: DateTime.tryParse(json["created_at"] ?? ""),
        files: json["files"] == null
            ? []
            : List<SubmissionFile>.from(
                json["files"]!.map((x) => SubmissionFile.fromJson(x))),
        createdByUser: json["created_by_user"] == null
            ? null
            : CreatedByUser.fromJson(json["created_by_user"]),
      );
}

class SlabSubmissionTree {
  final List<SubmissionCategory> categories;

  SlabSubmissionTree({required this.categories});

  factory SlabSubmissionTree.fromJson(Map<String, dynamic> json) =>
      SlabSubmissionTree(
        categories: json["categories"] == null
            ? []
            : List<SubmissionCategory>.from(
                json["categories"]!.map((x) => SubmissionCategory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categories": categories.map((x) => x.toJson()).toList(),
      };
}

class SubmissionCategory {
  final dynamic id;
  final String name;
  final List<SubmissionQuestionItem> items;
  bool isCollapse;

  SubmissionCategory({
    required this.id,
    required this.name,
    required this.items,
    this.isCollapse = false,
  });

  factory SubmissionCategory.fromJson(Map<String, dynamic> json) =>
      SubmissionCategory(
        id: json["id"],
        name: json["name"] ?? "",
        items: json["items"] == null
            ? []
            : List<SubmissionQuestionItem>.from(
                json["items"]!.map((x) => SubmissionQuestionItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "items": items.map((x) => x.toJson()).toList(),
      };
}

class SubmissionQuestionItem {
  final dynamic id;
  final String question;
  String status; // "Yes", "No", or ""
  String remarks;
  bool disabled;

  SubmissionQuestionItem({
    required this.id,
    required this.question,
    required this.status,
    required this.remarks,
    this.disabled = false,
  });

  factory SubmissionQuestionItem.fromJson(Map<String, dynamic> json) =>
      SubmissionQuestionItem(
        id: json["id"],
        question: json["question"] ?? json["name"] ?? "",
        status: json["status"] ?? "",
        remarks: json["remarks"] ?? "",
        disabled: false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "question": question,
        "status": status,
        "remarks": remarks,
      };
}

class SubmissionFile {
  final String id;
  final String? fileUrl;
  final String? fileName;
  final String? extension;
  final String? mimeType;
  final String? fileSize;

  SubmissionFile({
    required this.id,
    this.fileUrl,
    this.fileName,
    this.extension,
    this.mimeType,
    this.fileSize,
  });

  factory SubmissionFile.fromJson(Map<String, dynamic> json) => SubmissionFile(
        id: json["id"]?.toString() ?? "",
        fileUrl: json["file_url"]?.toString(),
        fileName: json["file_name"]?.toString(),
        extension: json["extension"]?.toString(),
        mimeType: json["mime_type"]?.toString(),
        fileSize: json["file_size"]?.toString(),
      );
}

class CreatedByUser {
  final String id;
  final String name;

  CreatedByUser({required this.id, required this.name});

  factory CreatedByUser.fromJson(Map<String, dynamic> json) => CreatedByUser(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
      );
}

// --- API 2: Blank Checklist Category & Questions (Grouped) ---

ChecklistGroupedResponse checklistGroupedResponseFromJson(String str) =>
    ChecklistGroupedResponse.fromJson(json.decode(str));

class ChecklistGroupedResponse {
  final bool success;
  final String message;
  final ChecklistGroupedData? data;

  ChecklistGroupedResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ChecklistGroupedResponse.fromJson(Map<String, dynamic> json) =>
      ChecklistGroupedResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null
            ? null
            : ChecklistGroupedData.fromJson(json["data"]),
      );
}

class ChecklistGroupedData {
  final List<GroupedCategory> data;

  ChecklistGroupedData({required this.data});

  factory ChecklistGroupedData.fromJson(Map<String, dynamic> json) =>
      ChecklistGroupedData(
        data: json["data"] == null
            ? []
            : List<GroupedCategory>.from(
                json["data"]!.map((x) => GroupedCategory.fromJson(x))),
      );
}

class GroupedCategory {
  final String categoryId;
  final String categoryName;
  final List<GroupedQuestion> checklistTypes;

  GroupedCategory({
    required this.categoryId,
    required this.categoryName,
    required this.checklistTypes,
  });

  factory GroupedCategory.fromJson(Map<String, dynamic> json) => GroupedCategory(
        categoryId: json["category_id"]?.toString() ?? "",
        categoryName: json["category_name"]?.toString() ?? "",
        checklistTypes: json["checklist_types"] == null
            ? []
            : List<GroupedQuestion>.from(
                json["checklist_types"]!.map((x) => GroupedQuestion.fromJson(x))),
      );
}

class GroupedQuestion {
  final String id;
  final String categoryId;
  final String name;

  GroupedQuestion({
    required this.id,
    required this.categoryId,
    required this.name,
  });

  factory GroupedQuestion.fromJson(Map<String, dynamic> json) => GroupedQuestion(
        id: json["id"]?.toString() ?? "",
        categoryId: json["category_id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
      );
}

// --- API 3: Latest Submitted Details ---

LatestSubmissionResponse latestSubmissionResponseFromJson(String str) =>
    LatestSubmissionResponse.fromJson(json.decode(str));

class LatestSubmissionResponse {
  final bool success;
  final String message;
  final LatestSubmissionData? data;

  LatestSubmissionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LatestSubmissionResponse.fromJson(Map<String, dynamic> json) =>
      LatestSubmissionResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null
            ? null
            : LatestSubmissionData.fromJson(json["data"]),
      );
}

class LatestSubmissionData {
  final SlabSubmissionEntry? data;

  LatestSubmissionData({this.data});

  factory LatestSubmissionData.fromJson(Map<String, dynamic> json) =>
      LatestSubmissionData(
        data: json["data"] == null || json["data"] is List
            ? null
            : SlabSubmissionEntry.fromJson(json["data"]),
      );
}
