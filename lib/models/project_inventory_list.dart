// To parse this JSON data, do
//
//     final customerArchitectCertificate = customerArchitectCertificateFromJson(jsonString);

import 'dart:convert';

CustomerArchitectCertificate customerArchitectCertificateFromJson(String str) =>
    CustomerArchitectCertificate.fromJson(json.decode(str));

String customerArchitectCertificateToJson(CustomerArchitectCertificate data) =>
    json.encode(data.toJson());

class CustomerArchitectCertificate {
  ProjectInventoryListResponse? response;

  CustomerArchitectCertificate({
    this.response,
  });

  factory CustomerArchitectCertificate.fromJson(Map<String, dynamic> json) =>
      CustomerArchitectCertificate(
        response: json["Response"] == null
            ? null
            : ProjectInventoryListResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ProjectInventoryListResponse {
  String? errorCode;
  List<ProjectInventoryListDatum>? data;
  String? inventryTotalPoValue;
  String? inventryTotalStockInValue;

  ProjectInventoryListResponse({
    this.errorCode,
    this.data,
    this.inventryTotalPoValue,
    this.inventryTotalStockInValue,
  });

  factory ProjectInventoryListResponse.fromJson(Map<String, dynamic> json) =>
      ProjectInventoryListResponse(
        errorCode: json["error_code"],
        data: json["data"] == null
            ? []
            : List<ProjectInventoryListDatum>.from(json["data"]!
                .map((x) => ProjectInventoryListDatum.fromJson(x))),
        inventryTotalPoValue: json["inventry_total_po_value"],
        inventryTotalStockInValue: json["inventry_total_stock_in_value"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "inventry_total_po_value": inventryTotalPoValue,
        "inventry_total_stock_in_value": inventryTotalStockInValue,
      };
}

class ProjectInventoryListDatum {
  String? gradeIdFk;
  dynamic? totalQuantity;
  dynamic? totalConsum;
  dynamic? totalRemaing;
  String? gradeId;
  String? gradeName;
  dynamic? totalPoValue;
  dynamic? totalStockInValue;
  List<Description>? description;
  dynamic? inventryTotalPoValue;
  dynamic? inventryTotalStockInValue;
  String? isCollapse;

  ProjectInventoryListDatum({
    this.gradeIdFk,
    this.totalQuantity,
    this.totalConsum,
    this.totalRemaing,
    this.gradeId,
    this.gradeName,
    this.totalPoValue,
    this.totalStockInValue,
    this.description,
    this.inventryTotalPoValue,
    this.inventryTotalStockInValue,
    this.isCollapse = '0',
  });

  factory ProjectInventoryListDatum.fromJson(Map<String, dynamic> json) =>
      ProjectInventoryListDatum(
          gradeIdFk: json["grade_id_Fk"],
          totalQuantity: json["total_quantity"]?.toDouble(),
          totalConsum: json["total_consum"]?.toDouble(),
          totalRemaing: json["total_remaing"],
          gradeId: json["grade_id"],
          gradeName: json["grade_name"],
          totalPoValue: json["total_po_value"],
          totalStockInValue: json["total_stock_in_value"],
          description: json["description"] == null
              ? []
              : List<Description>.from(
                  json["description"]!.map((x) => Description.fromJson(x))),
          inventryTotalPoValue: json["inventry_total_po_value"],
          inventryTotalStockInValue: json["inventry_total_stock_in_value"],
          isCollapse: "0");

  Map<String, dynamic> toJson() => {
        "grade_id_Fk": gradeIdFk,
        "total_quantity": totalQuantity,
        "total_consum": totalConsum,
        "total_remaing": totalRemaing,
        "grade_id": gradeId,
        "grade_name": gradeName,
        "total_po_value": totalPoValue,
        "total_stock_in_value": totalStockInValue,
        "description": description == null
            ? []
            : List<dynamic>.from(description!.map((x) => x.toJson())),
        "inventry_total_po_value": inventryTotalPoValue,
        "inventry_total_stock_in_value": inventryTotalStockInValue,
      };
}

class Description {
  String? gradeTypeId;
  String? gradTypeName;
  String? gradeIdFk;
  String? gradeTypeIdFk;
  double? totalQuantity;
  dynamic? totalConsum;
  double? totalRemaing;
  String? unitPrice;
  String? stockOut;
  String? orderDeliveryDate;
  String? stockInCost;
  double? totalPoCost;

  Description({
    this.gradeTypeId,
    this.gradTypeName,
    this.gradeIdFk,
    this.gradeTypeIdFk,
    this.totalQuantity,
    this.totalConsum,
    this.totalRemaing,
    this.unitPrice,
    this.stockOut,
    this.orderDeliveryDate,
    this.stockInCost,
    this.totalPoCost,
  });

  factory Description.fromJson(Map<String, dynamic> json) => Description(
        gradeTypeId: json["grade_type_id"],
        gradTypeName: json["grad_type_name"],
        gradeIdFk: json["grade_id_Fk"],
        gradeTypeIdFk: json["grade_type_id_fk"],
        totalQuantity: json["total_quantity"]?.toDouble(),
        totalConsum: json["total_consum"],
        totalRemaing: json["total_remaing"]?.toDouble(),
        unitPrice: json["unit_price"],
        stockOut: json["stock_out"],
        orderDeliveryDate: json["order_delivery_date"],
        stockInCost: json["stock_in_cost"],
        totalPoCost: json["total_po_cost"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "grade_type_id": gradeTypeId,
        "grad_type_name": gradTypeName,
        "grade_id_Fk": gradeIdFk,
        "grade_type_id_fk": gradeTypeIdFk,
        "total_quantity": totalQuantity,
        "total_consum": totalConsum,
        "total_remaing": totalRemaing,
        "unit_price": unitPrice,
        "stock_out": stockOut,
        "order_delivery_date": orderDeliveryDate,
        "stock_in_cost": stockInCost,
        "total_po_cost": totalPoCost,
      };
}
