import 'dart:convert';

/// Models for Purchase Order Requests API (New REST Backend)

// --- 1. Vendor Types & Grades (GET /vendor/po-vendor-types) ---

List<PoVendorType> poVendorTypesFromJson(String str) {
  final decoded = json.decode(str);
  List<dynamic> list = [];
  if (decoded is List) {
    list = decoded;
  } else if (decoded is Map && decoded['data'] is List) {
    list = decoded['data'];
  } else if (decoded is Map && decoded['data'] is Map && decoded['data']['data'] is List) {
    list = decoded['data']['data'];
  }
  return list.map((x) => PoVendorType.fromJson(x)).toList();
}

class PoVendorType {
  final String id;
  final String name;
  final int vendorCount;
  final List<PoVendorGrade> grades;

  PoVendorType({
    required this.id,
    required this.name,
    this.vendorCount = 0,
    this.grades = const [],
  });

  factory PoVendorType.fromJson(Map<String, dynamic> json) {
    final rawGrades = json['grades'];
    List<PoVendorGrade> parsedGrades = [];
    if (rawGrades is List) {
      parsedGrades = rawGrades.map((x) => PoVendorGrade.fromJson(x)).toList();
    }

    return PoVendorType(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['vendor_type_name']?.toString() ?? '',
      vendorCount: int.tryParse(json['vendor_count']?.toString() ?? '0') ?? 0,
      grades: parsedGrades,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'vendor_count': vendorCount,
        'grades': grades.map((x) => x.toJson()).toList(),
      };
}

class PoVendorGrade {
  final String id;
  final String? vendorTypeId;
  final String name;
  final bool isActive;

  PoVendorGrade({
    required this.id,
    this.vendorTypeId,
    required this.name,
    this.isActive = true,
  });

  factory PoVendorGrade.fromJson(Map<String, dynamic> json) {
    final dynamic activeVal = json['is_active'] ?? json['status'];
    final bool active = activeVal == null ||
        activeVal == true ||
        activeVal == 1 ||
        activeVal == '1' ||
        activeVal == 'true';

    return PoVendorGrade(
      id: json['id']?.toString() ?? '',
      vendorTypeId: json['vendor_type_id']?.toString(),
      name: json['name']?.toString() ??
          json['grade_name']?.toString() ??
          json['description']?.toString() ??
          '',
      isActive: active,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (vendorTypeId != null) 'vendor_type_id': vendorTypeId,
        'name': name,
        'is_active': isActive,
      };
}

// --- 2. PO Measuring Units (GET & POST /vendor/po-measuring-units) ---

List<PoMeasuringUnit> poMeasuringUnitsFromJson(String str) {
  final decoded = json.decode(str);
  List<dynamic> list = [];
  if (decoded is List) {
    list = decoded;
  } else if (decoded is Map && decoded['data'] is List) {
    list = decoded['data'];
  } else if (decoded is Map && decoded['data'] is Map && decoded['data']['data'] is List) {
    list = decoded['data']['data'];
  }
  return list.map((x) => PoMeasuringUnit.fromJson(x)).toList();
}

class PoMeasuringUnit {
  final String id;
  final String name;
  final String symbol;

  PoMeasuringUnit({
    required this.id,
    required this.name,
    required this.symbol,
  });

  factory PoMeasuringUnit.fromJson(Map<String, dynamic> json) {
    final String parsedName = json['name']?.toString() ??
        json['unit_name']?.toString() ??
        '';
    final String parsedSymbol = json['symbol']?.toString() ??
        json['unit_symbol']?.toString() ??
        parsedName;

    return PoMeasuringUnit(
      id: json['id']?.toString() ?? '',
      name: parsedName,
      symbol: parsedSymbol,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'symbol': symbol,
      };
}

// --- 3. Create PO Request Payload (POST /purchase-order-requests) ---

class PoCreateItem {
  final String vendorTypeId;
  final String? vendorTypeGradeId;
  final String? brandName;
  final List<String> slabIds;
  final String requirementDate;
  final String quantity;
  final String poUnitId;
  final String? unitPrice;

  PoCreateItem({
    required this.vendorTypeId,
    this.vendorTypeGradeId,
    this.brandName,
    required this.slabIds,
    required this.requirementDate,
    required this.quantity,
    required this.poUnitId,
    this.unitPrice,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'vendor_type_id': vendorTypeId,
      'slab_ids': slabIds,
      'requirement_date': requirementDate,
      'quantity': quantity,
      'po_unit_id': poUnitId,
    };
    if (vendorTypeGradeId != null && vendorTypeGradeId!.isNotEmpty) {
      map['vendor_type_grade_id'] = vendorTypeGradeId;
    }
    if (brandName != null && brandName!.trim().isNotEmpty) {
      map['brand_name'] = brandName!.trim();
    }
    if (unitPrice != null && unitPrice!.trim().isNotEmpty) {
      map['unit_price'] = unitPrice!.trim();
    }
    return map;
  }

  factory PoCreateItem.fromJson(Map<String, dynamic> json) {
    List<String> parsedSlabs = [];
    if (json['slab_ids'] is List) {
      parsedSlabs = (json['slab_ids'] as List)
          .map((e) => e.toString())
          .toList();
    }

    return PoCreateItem(
      vendorTypeId: json['vendor_type_id']?.toString() ?? '',
      vendorTypeGradeId: json['vendor_type_grade_id']?.toString(),
      brandName: json['brand_name']?.toString(),
      slabIds: parsedSlabs,
      requirementDate: json['requirement_date']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '0',
      poUnitId: json['po_unit_id']?.toString() ?? '',
      unitPrice: json['unit_price']?.toString(),
    );
  }
}

class PoCreatePayload {
  final String towerId;
  final String? remarks;
  final List<PoCreateItem> items;

  PoCreatePayload({
    required this.towerId,
    this.remarks,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'tower_id': towerId,
      'items': items.map((x) => x.toJson()).toList(),
    };
    if (remarks != null && remarks!.trim().isNotEmpty) {
      map['remarks'] = remarks!.trim();
    }
    return map;
  }
}

// --- 4. PO Request Response & Preview ---

class PoRequestCreateResponse {
  final bool success;
  final String message;
  final String? requestId;
  final String? previewUrl;
  final Map<String, dynamic>? rawData;

  PoRequestCreateResponse({
    required this.success,
    this.message = '',
    this.requestId,
    this.previewUrl,
    this.rawData,
  });

  factory PoRequestCreateResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    final String? id = data['id']?.toString() ?? json['id']?.toString();
    final String? preview = data['preview_pdf_signed_url']?.toString() ??
        data['preview_pdf_url']?.toString() ??
        data['preview_url']?.toString() ??
        json['preview_pdf_signed_url']?.toString() ??
        json['preview_pdf_url']?.toString() ??
        json['preview_url']?.toString();

    return PoRequestCreateResponse(
      success: json['success'] ?? true,
      message: json['message']?.toString() ?? '',
      requestId: id,
      previewUrl: preview,
      rawData: data is Map<String, dynamic> ? data : null,
    );
  }
}

class PoPreviewResponse {
  final bool success;
  final String message;
  final String? previewUrl;

  PoPreviewResponse({
    required this.success,
    this.message = '',
    this.previewUrl,
  });

  factory PoPreviewResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    final String? preview = data['preview_pdf_signed_url']?.toString() ??
        data['preview_pdf_url']?.toString() ??
        data['preview_url']?.toString() ??
        json['preview_pdf_signed_url']?.toString() ??
        json['preview_pdf_url']?.toString() ??
        json['preview_url']?.toString();

    return PoPreviewResponse(
      success: json['success'] ?? true,
      message: json['message']?.toString() ?? '',
      previewUrl: preview,
    );
  }
}

