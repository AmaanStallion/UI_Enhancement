// To parse this JSON data, do
//
//     final poDeliveryDetails = poDeliveryDetailsFromJson(jsonString);

import 'dart:convert';

PoDeliveryDetails poDeliveryDetailsFromJson(String str) =>
    PoDeliveryDetails.fromJson(json.decode(str));

String poDeliveryDetailsToJson(PoDeliveryDetails data) =>
    json.encode(data.toJson());

class PoDeliveryDetails {
  PoDeliveryDetailsResponse? response;

  PoDeliveryDetails({
    this.response,
  });

  factory PoDeliveryDetails.fromJson(Map<String, dynamic> json) =>
      PoDeliveryDetails(
        response: json["Response"] == null
            ? null
            : PoDeliveryDetailsResponse.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class PoDeliveryDetailsResponse {
  String? errorCode;
  String? msg;
  List<OrderDetail>? orderDetails;
  String? checkedBy;
  String? deliveryQuantity;
  String? orderQuantity;

  PoDeliveryDetailsResponse({
    this.errorCode,
    this.msg,
    this.orderDetails,
    this.checkedBy,
    this.deliveryQuantity,
    this.orderQuantity,
  });

  factory PoDeliveryDetailsResponse.fromJson(Map<String, dynamic> json) =>
      PoDeliveryDetailsResponse(
        errorCode: json["error_code"],
        msg: json["msg"],
        orderDetails: json["order_details"] == null
            ? []
            : List<OrderDetail>.from(
                json["order_details"]!.map((x) => OrderDetail.fromJson(x))),
        checkedBy: json["checked_by"],
        deliveryQuantity: json["delivery_quantity"],
        orderQuantity: json["order_quantity"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "order_details": orderDetails == null
            ? []
            : List<dynamic>.from(orderDetails!.map((x) => x.toJson())),
        "checked_by": checkedBy,
        "delivery_quantity": deliveryQuantity,
        "order_quantity": orderQuantity,
      };
}

class OrderDetail {
  String? castingUnit;
  String? supplieId;
  String? orderQuantity;
  String? castingFor;
  String? unitPrice;
  String? gradeTypeIdFk;
  String? gradeIdFk;
  String? gradeName;
  String? gradeId;
  String? castingUnitName;
  String? castingUnitId;
  String? deliveryQuantity;

  OrderDetail({
    this.castingUnit,
    this.supplieId,
    this.orderQuantity,
    this.castingFor,
    this.unitPrice,
    this.gradeTypeIdFk,
    this.gradeIdFk,
    this.gradeName,
    this.gradeId,
    this.castingUnitName,
    this.castingUnitId,
    this.deliveryQuantity,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
        castingUnit: json["casting_unit"],
        supplieId: json["supplie_id"],
        orderQuantity: json["order_quantity"],
        castingFor: json["casting_for"],
        unitPrice: json["unit_price"],
        gradeTypeIdFk: json["grade_type_id_fk"],
        gradeIdFk: json["grade_id_Fk"],
        gradeName: json["grade_name"],
        gradeId: json["grade_id"],
        castingUnitName: json["casting_unit_name"],
        castingUnitId: json["casting_unit_id"],
        deliveryQuantity: json["delivery_quantity"],
      );

  Map<String, dynamic> toJson() => {
        "casting_unit": castingUnit,
        "supplie_id": supplieId,
        "order_quantity": orderQuantity,
        "casting_for": castingFor,
        "unit_price": unitPrice,
        "grade_type_id_fk": gradeTypeIdFk,
        "grade_id_Fk": gradeIdFk,
        "grade_name": gradeName,
        "grade_id": gradeId,
        "casting_unit_name": castingUnitName,
        "casting_unit_id": castingUnitId,
        "delivery_quantity": deliveryQuantity,
      };
}
