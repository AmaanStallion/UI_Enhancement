import 'dart:convert';

DeveloperRccCountResponse developerRccCountResponseFromJson(String str) =>
    DeveloperRccCountResponse.fromJson(json.decode(str));

String developerRccCountResponseToJson(DeveloperRccCountResponse data) =>
    json.encode(data.toJson());

class DeveloperRccCountResponse {
  final bool success;
  final String message;
  final DeveloperRccCountData? data;

  DeveloperRccCountResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DeveloperRccCountResponse.fromJson(Map<String, dynamic> json) =>
      DeveloperRccCountResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? "",
        data: json["data"] == null
            ? null
            : DeveloperRccCountData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class DeveloperRccCountData {
  final TowerInfo? tower;
  final int totalSlabs;
  final int developerCheckedCount;
  final int rccContractorCheckedCount;
  final int developerAndRccCheckedCount;
  final int pendingCount;
  final List<String> developerAndRccCheckedSlabIds;

  DeveloperRccCountData({
    this.tower,
    required this.totalSlabs,
    required this.developerCheckedCount,
    required this.rccContractorCheckedCount,
    required this.developerAndRccCheckedCount,
    required this.pendingCount,
    required this.developerAndRccCheckedSlabIds,
  });

  factory DeveloperRccCountData.fromJson(Map<String, dynamic> json) =>
      DeveloperRccCountData(
        tower: json["tower"] == null ? null : TowerInfo.fromJson(json["tower"]),
        totalSlabs: int.tryParse(json["total_slabs"]?.toString() ?? '') ?? 0,
        developerCheckedCount:
            int.tryParse(json["developer_checked_count"]?.toString() ?? '') ?? 0,
        rccContractorCheckedCount:
            int.tryParse(json["rcc_contractor_checked_count"]?.toString() ?? '') ?? 0,
        developerAndRccCheckedCount:
            int.tryParse(json["developer_and_rcc_checked_count"]?.toString() ?? '') ?? 0,
        pendingCount: int.tryParse(json["pending_count"]?.toString() ?? '') ?? 0,
        developerAndRccCheckedSlabIds: json["developer_and_rcc_checked_slab_ids"] == null
            ? []
            : List<String>.from(
                json["developer_and_rcc_checked_slab_ids"].map((x) => x.toString())),
      );

  Map<String, dynamic> toJson() => {
        "tower": tower?.toJson(),
        "total_slabs": totalSlabs,
        "developer_checked_count": developerCheckedCount,
        "rcc_contractor_checked_count": rccContractorCheckedCount,
        "developer_and_rcc_checked_count": developerAndRccCheckedCount,
        "pending_count": pendingCount,
        "developer_and_rcc_checked_slab_ids": developerAndRccCheckedSlabIds,
      };

  double get percentage {
    if (totalSlabs <= 0) return 0.0;
    return ((developerAndRccCheckedCount / totalSlabs) * 100).clamp(0.0, 100.0);
  }
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
