import 'dart:convert';

// --- API 1: Excavation History ---

ExcavationHistoryResponse excavationHistoryResponseFromJson(String str) =>
    ExcavationHistoryResponse.fromJson(json.decode(str));

String excavationHistoryResponseToJson(ExcavationHistoryResponse data) =>
    json.encode(data.toJson());

class ExcavationHistoryResponse {
  final bool success;
  final String message;
  final ExcavationHistoryData? data;

  ExcavationHistoryResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ExcavationHistoryResponse.fromJson(Map<String, dynamic> json) =>
      ExcavationHistoryResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null
            ? null
            : ExcavationHistoryData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class ExcavationHistoryData {
  final ExcavationEntityRef? tower;
  final ExcavationEntityRef? project;
  final List<RoyaltyFilterItem> royaltyFilters;
  final String selectedRoyaltyType;
  final List<ExcavationEntryItem> data;
  final PaginationInfo? pagination;

  ExcavationHistoryData({
    this.tower,
    this.project,
    this.royaltyFilters = const [],
    this.selectedRoyaltyType = "all",
    this.data = const [],
    this.pagination,
  });

  factory ExcavationHistoryData.fromJson(Map<String, dynamic> json) =>
      ExcavationHistoryData(
        tower: json["tower"] == null
            ? null
            : ExcavationEntityRef.fromJson(json["tower"]),
        project: json["project"] == null
            ? null
            : ExcavationEntityRef.fromJson(json["project"]),
        royaltyFilters: json["royalty_filters"] == null
            ? []
            : List<RoyaltyFilterItem>.from(json["royalty_filters"]
                .map((x) => RoyaltyFilterItem.fromJson(x))),
        selectedRoyaltyType: json["selected_royalty_type"]?.toString() ?? "all",
        data: json["data"] == null
            ? []
            : List<ExcavationEntryItem>.from(
                json["data"].map((x) => ExcavationEntryItem.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : PaginationInfo.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "tower": tower?.toJson(),
        "project": project?.toJson(),
        "royalty_filters":
            List<dynamic>.from(royaltyFilters.map((x) => x.toJson())),
        "selected_royalty_type": selectedRoyaltyType,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
      };
}

class RoyaltyFilterItem {
  final String? id;
  final String name;
  final String? description;
  final int entriesCount;
  final String cumLoaded;

  RoyaltyFilterItem({
    this.id,
    required this.name,
    this.description,
    this.entriesCount = 0,
    this.cumLoaded = "0",
  });

  factory RoyaltyFilterItem.fromJson(Map<String, dynamic> json) =>
      RoyaltyFilterItem(
        id: json["id"]?.toString(),
        name: json["name"]?.toString() ?? "",
        description: json["description"]?.toString(),
        entriesCount: json["entries_count"] ?? 0,
        cumLoaded: json["cum_loaded"]?.toString() ?? "0",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "entries_count": entriesCount,
        "cum_loaded": cumLoaded,
      };
}

class ExcavationEntryItem {
  final String id;
  final String? developerId;
  final String? projectId;
  final String? slabId;
  final String? vehicleTypeId;
  final String? truckSizeId;
  final String? royaltyTypeId;
  final String? remarks;
  final String? shiftFrom;
  final String? shiftTo;
  final String? shiftRequired;
  final String? hiringCharges;
  final String? vehicleNo;
  final String? cumLoaded;
  final String? challanNo;
  final String? excavationFrom;
  final String? entryDate;
  final bool isDeleted;
  final String? createdBy;
  final String? updatedBy;
  final String? createdAt;
  final String? updatedAt;
  final ExcavationEntityRef? project;
  final ExcavationSlabItem? slab;
  final VehicleTypeItem? vehicleType;
  final TruckSizeItem? truckSize;
  final RoyaltyTypeItem? royaltyType;
  final ExcavationUserRef? createdByUser;
  final ExcavationUserRef? updatedByUser;
  final List<ExcavationDocumentItem> documents;

  ExcavationEntryItem({
    required this.id,
    this.developerId,
    this.projectId,
    this.slabId,
    this.vehicleTypeId,
    this.truckSizeId,
    this.royaltyTypeId,
    this.remarks,
    this.shiftFrom,
    this.shiftTo,
    this.shiftRequired,
    this.hiringCharges,
    this.vehicleNo,
    this.cumLoaded,
    this.challanNo,
    this.excavationFrom,
    this.entryDate,
    this.isDeleted = false,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.project,
    this.slab,
    this.vehicleType,
    this.truckSize,
    this.royaltyType,
    this.createdByUser,
    this.updatedByUser,
    this.documents = const [],
  });

  bool get isDumper => vehicleTypeId == "4" || vehicleType?.name.toLowerCase() == "dumper";

  factory ExcavationEntryItem.fromJson(Map<String, dynamic> json) =>
      ExcavationEntryItem(
        id: json["id"]?.toString() ?? "",
        developerId: json["developer_id"]?.toString(),
        projectId: json["project_id"]?.toString(),
        slabId: json["slab_id"]?.toString(),
        vehicleTypeId: json["vehicle_type_id"]?.toString(),
        truckSizeId: json["truck_size_id"]?.toString(),
        royaltyTypeId: json["royalty_type_id"]?.toString(),
        remarks: json["remarks"]?.toString(),
        shiftFrom: json["shift_from"]?.toString(),
        shiftTo: json["shift_to"]?.toString(),
        shiftRequired: json["shift_required"]?.toString(),
        hiringCharges: json["hiring_charges"]?.toString(),
        vehicleNo: json["vehicle_no"]?.toString(),
        cumLoaded: json["cum_loaded"]?.toString(),
        challanNo: json["challan_no"]?.toString(),
        excavationFrom: json["excavation_from"]?.toString(),
        entryDate: json["entry_date"]?.toString(),
        isDeleted: json["is_deleted"] ?? false,
        createdBy: json["created_by"]?.toString(),
        updatedBy: json["updated_by"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
        project: json["project"] == null
            ? null
            : ExcavationEntityRef.fromJson(json["project"]),
        slab: json["slab"] == null
            ? null
            : ExcavationSlabItem.fromJson(json["slab"]),
        vehicleType: json["vehicle_type"] == null
            ? null
            : VehicleTypeItem.fromJson(json["vehicle_type"]),
        truckSize: json["truck_size"] == null
            ? null
            : TruckSizeItem.fromJson(json["truck_size"]),
        royaltyType: json["royalty_type"] == null
            ? null
            : RoyaltyTypeItem.fromJson(json["royalty_type"]),
        createdByUser: json["created_by_user"] == null
            ? null
            : ExcavationUserRef.fromJson(json["created_by_user"]),
        updatedByUser: json["updated_by_user"] == null
            ? null
            : ExcavationUserRef.fromJson(json["updated_by_user"]),
        documents: json["documents"] == null
            ? []
            : List<ExcavationDocumentItem>.from(
                json["documents"].map((x) => ExcavationDocumentItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "developer_id": developerId,
        "project_id": projectId,
        "slab_id": slabId,
        "vehicle_type_id": vehicleTypeId,
        "truck_size_id": truckSizeId,
        "royalty_type_id": royaltyTypeId,
        "remarks": remarks,
        "shift_from": shiftFrom,
        "shift_to": shiftTo,
        "shift_required": shiftRequired,
        "hiring_charges": hiringCharges,
        "vehicle_no": vehicleNo,
        "cum_loaded": cumLoaded,
        "challan_no": challanNo,
        "excavation_from": excavationFrom,
        "entry_date": entryDate,
        "is_deleted": isDeleted,
        "created_by": createdBy,
        "updated_by": updatedBy,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "project": project?.toJson(),
        "slab": slab?.toJson(),
        "vehicle_type": vehicleType?.toJson(),
        "truck_size": truckSize?.toJson(),
        "royalty_type": royaltyType?.toJson(),
        "created_by_user": createdByUser?.toJson(),
        "updated_by_user": updatedByUser?.toJson(),
        "documents": List<dynamic>.from(documents.map((x) => x.toJson())),
      };
}

class ExcavationEntityRef {
  final String id;
  final String name;

  ExcavationEntityRef({
    required this.id,
    required this.name,
  });

  factory ExcavationEntityRef.fromJson(Map<String, dynamic> json) =>
      ExcavationEntityRef(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class ExcavationSlabItem {
  final String id;
  final String? name;
  final String? slabNumber;
  final String? slabType;
  final int? sequence;
  final ExcavationEntityRef? tower;

  ExcavationSlabItem({
    required this.id,
    this.name,
    this.slabNumber,
    this.slabType,
    this.sequence,
    this.tower,
  });

  factory ExcavationSlabItem.fromJson(Map<String, dynamic> json) =>
      ExcavationSlabItem(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString(),
        slabNumber: json["slab_number"]?.toString(),
        slabType: json["slab_type"]?.toString(),
        sequence: json["sequence"],
        tower: json["tower"] == null
            ? null
            : ExcavationEntityRef.fromJson(json["tower"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slab_number": slabNumber,
        "slab_type": slabType,
        "sequence": sequence,
        "tower": tower?.toJson(),
      };
}

class ExcavationUserRef {
  final String id;
  final String name;
  final String? email;

  ExcavationUserRef({
    required this.id,
    required this.name,
    this.email,
  });

  factory ExcavationUserRef.fromJson(Map<String, dynamic> json) =>
      ExcavationUserRef(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        email: json["email"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
      };
}

class ExcavationDocumentItem {
  final String id;
  final String? fileName;
  final String? fileKey;
  final String? fileUrl;
  final String? mimeType;
  final String? extension;
  final String? fileSize;
  final String? uploadedBy;
  final String? createdAt;
  final ExcavationUserRef? uploadedByUser;

  ExcavationDocumentItem({
    required this.id,
    this.fileName,
    this.fileKey,
    this.fileUrl,
    this.mimeType,
    this.extension,
    this.fileSize,
    this.uploadedBy,
    this.createdAt,
    this.uploadedByUser,
  });

  factory ExcavationDocumentItem.fromJson(Map<String, dynamic> json) =>
      ExcavationDocumentItem(
        id: json["id"]?.toString() ?? "",
        fileName: json["file_name"]?.toString(),
        fileKey: json["file_key"]?.toString(),
        fileUrl: json["file_url"]?.toString(),
        mimeType: json["mime_type"]?.toString(),
        extension: json["extension"]?.toString(),
        fileSize: json["file_size"]?.toString(),
        uploadedBy: json["uploaded_by"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        uploadedByUser: json["uploaded_by_user"] == null
            ? null
            : ExcavationUserRef.fromJson(json["uploaded_by_user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "file_name": fileName,
        "file_key": fileKey,
        "file_url": fileUrl,
        "mime_type": mimeType,
        "extension": extension,
        "file_size": fileSize,
        "uploaded_by": uploadedBy,
        "created_at": createdAt,
        "uploaded_by_user": uploadedByUser?.toJson(),
      };
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationInfo({
    this.page = 1,
    this.limit = 20,
    this.total = 0,
    this.totalPages = 1,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
        page: json["page"] ?? 1,
        limit: json["limit"] ?? 20,
        total: json["total"] ?? 0,
        totalPages: json["total_pages"] ?? 1,
        hasNextPage: json["has_next_page"] ?? false,
        hasPreviousPage: json["has_previous_page"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "total": total,
        "total_pages": totalPages,
        "has_next_page": hasNextPage,
        "has_previous_page": hasPreviousPage,
      };
}

// --- API 2: Truck Sizes ---

TruckSizesResponse truckSizesResponseFromJson(String str) =>
    TruckSizesResponse.fromJson(json.decode(str));

class TruckSizesResponse {
  final bool success;
  final String message;
  final List<TruckSizeItem> truckSizes;
  final int total;

  TruckSizesResponse({
    required this.success,
    required this.message,
    this.truckSizes = const [],
    this.total = 0,
  });

  factory TruckSizesResponse.fromJson(Map<String, dynamic> json) {
    final data = json["data"];
    return TruckSizesResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      total: data?["total"] ?? 0,
      truckSizes: data?["truck_sizes"] == null
          ? []
          : List<TruckSizeItem>.from(
              data["truck_sizes"].map((x) => TruckSizeItem.fromJson(x))),
    );
  }
}

class TruckSizeItem {
  final String id;
  final String name;
  final String? description;
  final String? source;
  final bool isActive;

  TruckSizeItem({
    required this.id,
    required this.name,
    this.description,
    this.source,
    this.isActive = true,
  });

  factory TruckSizeItem.fromJson(Map<String, dynamic> json) => TruckSizeItem(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        description: json["description"]?.toString(),
        source: json["source"]?.toString(),
        isActive: json["is_active"] ?? true,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "source": source,
        "is_active": isActive,
      };
}

// --- API 3: Vehicle Types ---

VehicleTypesResponse vehicleTypesResponseFromJson(String str) =>
    VehicleTypesResponse.fromJson(json.decode(str));

class VehicleTypesResponse {
  final bool success;
  final String message;
  final List<VehicleTypeItem> vehicleTypes;
  final int total;

  VehicleTypesResponse({
    required this.success,
    required this.message,
    this.vehicleTypes = const [],
    this.total = 0,
  });

  factory VehicleTypesResponse.fromJson(Map<String, dynamic> json) {
    final data = json["data"];
    return VehicleTypesResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      total: data?["total"] ?? 0,
      vehicleTypes: data?["vehicle_types"] == null
          ? []
          : List<VehicleTypeItem>.from(
              data["vehicle_types"].map((x) => VehicleTypeItem.fromJson(x))),
    );
  }
}

class VehicleTypeItem {
  final String id;
  final String name;
  final String? description;
  final String? source;
  final bool isActive;

  VehicleTypeItem({
    required this.id,
    required this.name,
    this.description,
    this.source,
    this.isActive = true,
  });

  factory VehicleTypeItem.fromJson(Map<String, dynamic> json) => VehicleTypeItem(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        description: json["description"]?.toString(),
        source: json["source"]?.toString(),
        isActive: json["is_active"] ?? true,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "source": source,
        "is_active": isActive,
      };
}

// --- API 4: Royalty Types ---

RoyaltyTypesResponse royaltyTypesResponseFromJson(String str) =>
    RoyaltyTypesResponse.fromJson(json.decode(str));

class RoyaltyTypesResponse {
  final bool success;
  final String message;
  final List<RoyaltyTypeItem> royaltyTypes;
  final int total;

  RoyaltyTypesResponse({
    required this.success,
    required this.message,
    this.royaltyTypes = const [],
    this.total = 0,
  });

  factory RoyaltyTypesResponse.fromJson(Map<String, dynamic> json) {
    final data = json["data"];
    return RoyaltyTypesResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      total: data?["total"] ?? 0,
      royaltyTypes: data?["royalty_types"] == null
          ? []
          : List<RoyaltyTypeItem>.from(
              data["royalty_types"].map((x) => RoyaltyTypeItem.fromJson(x))),
    );
  }
}

class RoyaltyTypeItem {
  final String id;
  final String name;
  final String? description;
  final String? source;
  final bool isActive;

  RoyaltyTypeItem({
    required this.id,
    required this.name,
    this.description,
    this.source,
    this.isActive = true,
  });

  factory RoyaltyTypeItem.fromJson(Map<String, dynamic> json) => RoyaltyTypeItem(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
        description: json["description"]?.toString(),
        source: json["source"]?.toString(),
        isActive: json["is_active"] ?? true,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "source": source,
        "is_active": isActive,
      };
}

// --- Tower Slabs API ---

TowerSlabsResponse towerSlabsResponseFromJson(String str) =>
    TowerSlabsResponse.fromJson(json.decode(str));

class TowerSlabsResponse {
  final bool success;
  final String message;
  final List<TowerSlabItem> slabs;

  TowerSlabsResponse({
    required this.success,
    required this.message,
    this.slabs = const [],
  });

  factory TowerSlabsResponse.fromJson(Map<String, dynamic> json) {
    final data = json["data"];
    List<dynamic> slabList = [];
    if (data is Map && data["data"] is List) {
      slabList = data["data"];
    } else if (data is List) {
      slabList = data;
    }
    return TowerSlabsResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      slabs: slabList.map((x) => TowerSlabItem.fromJson(x)).toList(),
    );
  }
}

class TowerSlabItem {
  final String id;
  final String name;

  TowerSlabItem({
    required this.id,
    required this.name,
  });

  factory TowerSlabItem.fromJson(Map<String, dynamic> json) => TowerSlabItem(
        id: json["id"]?.toString() ?? "",
        name: json["name"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
