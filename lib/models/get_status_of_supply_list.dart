// To parse this JSON data, do
//
//     final getPoStatusOfSupply = getPoStatusOfSupplyFromJson(jsonString);

import 'dart:convert';

GetPoStatusOfSupply getPoStatusOfSupplyFromJson(String str) =>
    GetPoStatusOfSupply.fromJson(json.decode(str));

String getPoStatusOfSupplyToJson(GetPoStatusOfSupply data) =>
    json.encode(data.toJson());

class GetPoStatusOfSupply {
  GetPoStatusOfSupply({
    this.response,
  });

  ResponseGetPoStatusOfSupply? response;

  factory GetPoStatusOfSupply.fromJson(Map<String, dynamic> json) =>
      GetPoStatusOfSupply(
        response: ResponseGetPoStatusOfSupply.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetPoStatusOfSupply {
  ResponseGetPoStatusOfSupply({
    this.errorCode,
    this.msg,
    this.offset,
    this.rccBookingHistory,
    this.towarList,
    this.poRawMaterialFlag,
  });

  String? errorCode;
  String? msg;
  String? offset;
  List<RccBookingHistory>? rccBookingHistory;
  List<TowarList>? towarList;
  String? poRawMaterialFlag;

  factory ResponseGetPoStatusOfSupply.fromJson(Map<String, dynamic> json) =>
      ResponseGetPoStatusOfSupply(
        errorCode: json["error_code"],
        msg: json["msg"],
        offset: json["offset"],
        rccBookingHistory: List<RccBookingHistory>.from(
            json["rcc_booking_history"]
                .map((x) => RccBookingHistory.fromJson(x))),
        towarList: json["towar_list"] == null
            ? []
            : List<TowarList>.from(
                json["towar_list"].map((x) => TowarList.fromJson(x))),
        poRawMaterialFlag: json["po_raw_material_flag"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "offset": offset,
        "rcc_booking_history":
            List<dynamic>.from(rccBookingHistory!.map((x) => x.toJson())),
        "towar_list": towarList == null
            ? []
            : List<dynamic>.from(towarList!.map((x) => x.toJson())),
        "po_raw_material_flag": poRawMaterialFlag,
      };
}

class RccBookingHistory {
  RccBookingHistory(
      {this.castingUnit,
      this.projectIdFk,
      this.supplierFrom,
      this.poSignDate,
      this.orderRemark,
      this.remarks,
      this.chalanCompletStatus,
      this.poApproveStatus,
      this.poApproveBy,
      this.userIdFk,
      this.poCreatedAt,
      this.invoiceAmount,
      this.gstPer,
      this.orderStatus,
      this.orderDeliveryDate,
      this.orderQuantity,
      this.orderId,
      this.gradeName,
      this.gradeUnit,
      this.gradeTypeName,
      this.castingDate,
      this.castingFor,
      this.slabIdFk,
      this.poNo,
      this.venderIdFk,
      this.poStatus,
      this.poAmount,
      this.venderPhone,
      this.venderName,
      this.raisedBy,
      this.orderDeliverDate,
      this.slabName,
      this.projectName,
      this.orderDetails,
      this.checkedBy,
      this.deliveryQuantity,
      this.poCheckedByDate,
      this.poCheckedBy,
      this.isStarMarked,
      this.grn_active});
  String? poCheckedByDate;
  String? isStarMarked;

  String? castingUnit;
  String? poCheckedBy;

  String? projectIdFk;
  String? supplierFrom;
  String? poSignDate;
  String? orderRemark;
  String? remarks;
  String? chalanCompletStatus;
  String? poApproveStatus;
  String? poApproveBy;
  String? userIdFk;
  String? poCreatedAt;
  String? invoiceAmount;
  String? gstPer;
  String? orderStatus;
  String? orderDeliveryDate;
  String? orderQuantity;
  String? orderId;
  String? gradeName;
  String? gradeUnit;
  String? gradeTypeName;
  String? castingDate;
  String? castingFor;
  String? slabIdFk;
  String? poNo;
  String? venderIdFk;
  String? poStatus;
  String? poAmount;
  List<VenderPhone>? venderPhone;
  String? venderName;
  String? raisedBy;
  String? orderDeliverDate;
  String? slabName;
  String? projectName;
  List<OrderDetail>? orderDetails;
  String? checkedBy;
  String? deliveryQuantity;
  String? grn_active;

  factory RccBookingHistory.fromJson(Map<String, dynamic> json) =>
      RccBookingHistory(
        castingUnit: json["casting_unit"],
        grn_active: json["grn_active"],
        projectIdFk: json["project_id_fk"],
        supplierFrom: json["supplier_from"],
        poSignDate: json["po_sign_date"],
        orderRemark: json["order_remark"],
        remarks: json["remarks"],
        chalanCompletStatus: json["chalan_complet_status"],
        poApproveStatus: json["po_approve_status"],
        poApproveBy: json["po_approve_by"],
        userIdFk: json["user_id_fk"],
        poCreatedAt: json["po_created_at"],
        invoiceAmount: json["invoice_amount"],
        gstPer: json["gst_per"],
        orderStatus: json["order_status"],
        orderDeliveryDate: json["order_delivery_date"],
        orderQuantity: json["order_quantity"],
        orderId: json["order_id"],
        gradeName: json["grade_name"],
        gradeUnit: json["grade_unit"],
        gradeTypeName: json["grade_type_name"],
        castingDate: json["casting_date"],
        castingFor: json["casting_for"],
        slabIdFk: json["slab_id_fk"],
        poNo: json["po_no"],
        venderIdFk: json["vender_id_fk"],
        poStatus: json["po_status"],
        poAmount: json["po_amount"],
        venderPhone: List<VenderPhone>.from(
            json["vender_phone"].map((x) => VenderPhone.fromJson(x))),
        venderName: json["vender_name"],
        raisedBy: json["raised_by"],
        orderDeliverDate: json["order_deliver_date"],
        slabName: json["slab_name"],
        projectName: json["project_name"],
        orderDetails: List<OrderDetail>.from(
            json["order_details"].map((x) => OrderDetail.fromJson(x))),
        checkedBy: json["checked_by"],
        deliveryQuantity: json["delivery_quantity"],
        poCheckedByDate: json["po_checked_by_date"],
        poCheckedBy: json["po_checked_by"],
        isStarMarked: json["is_star_marked"],
      );

  Map<String, dynamic> toJson() => {
        "casting_unit": castingUnit,
        "grn_active": grn_active,
        "project_id_fk": projectIdFk,
        "supplier_from": supplierFrom,
        "po_sign_date": poSignDate,
        "order_remark": orderRemark,
        "remarks": remarks,
        "chalan_complet_status": chalanCompletStatus,
        "po_approve_status": poApproveStatus,
        "po_approve_by": poApproveBy,
        "user_id_fk": userIdFk,
        "po_created_at": poCreatedAt,
        "invoice_amount": invoiceAmount,
        "gst_per": gstPer,
        "order_status": orderStatus,
        "order_delivery_date": orderDeliveryDate,
        "order_quantity": orderQuantity,
        "order_id": orderId,
        "grade_name": gradeName,
        "grade_unit": gradeUnit,
        "grade_type_name": gradeTypeName,
        "casting_date": castingDate,
        "casting_for": castingFor,
        "slab_id_fk": slabIdFk,
        "po_no": poNo,
        "vender_id_fk": venderIdFk,
        "po_status": poStatus,
        "po_amount": poAmount,
        "vender_phone": List<dynamic>.from(venderPhone!.map((x) => x.toJson())),
        "vender_name": venderName,
        "raised_by": raisedBy,
        "order_deliver_date": orderDeliverDate,
        "slab_name": slabName,
        "project_name": projectName,
        "order_details":
            List<dynamic>.from(orderDetails!.map((x) => x.toJson())),
        "checked_by": checkedBy,
        "delivery_quantity": deliveryQuantity,
        "po_checked_by_date": poCheckedByDate,
        "po_checked_by": poCheckedBy,
        "is_star_marked": isStarMarked,
      };
}

class OrderDetail {
  OrderDetail({
    this.castingUnit,
    this.brandSupplierName,
    this.castingDate,
    this.gradeTypeName,
    this.gradeTypeId,
    this.supplieId,
    this.orderQuantity,
    this.castingFor,
    this.unitPrice,
    this.castingUnitName,
    this.castingUnitId,
    this.deliveryQuantity,
  });
  String? castingUnit;
  String? brandSupplierName;
  DateTime? castingDate;
  String? gradeTypeName;
  String? gradeTypeId;
  String? supplieId;
  String? orderQuantity;
  String? castingFor;
  String? unitPrice;
  String? castingUnitName;
  String? castingUnitId;
  String? deliveryQuantity;

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
        castingUnit: json["casting_unit"],
        brandSupplierName: json["brand_supplier_name"],
        castingDate: json["casting_date"] == null
            ? null
            : DateTime.parse(json["casting_date"]),
        gradeTypeName: json["grade_type_name"],
        gradeTypeId: json["grade_type_id"],
        supplieId: json["supplie_id"],
        orderQuantity: json["order_quantity"],
        castingFor: json["casting_for"],
        unitPrice: json["unit_price"],
        castingUnitName: json["casting_unit_name"],
        castingUnitId: json["casting_unit_id"],
        deliveryQuantity: json["delivery_quantity"],
      );

  Map<String, dynamic> toJson() => {
        "casting_unit": castingUnit,
        "brand_supplier_name": brandSupplierName,
        "casting_date":
            "${castingDate!.year.toString().padLeft(4, '0')}-${castingDate!.month.toString().padLeft(2, '0')}-${castingDate!.day.toString().padLeft(2, '0')}",
        "grade_type_name": gradeTypeName,
        "grade_type_id": gradeTypeId,
        "supplie_id": supplieId,
        "order_quantity": orderQuantity,
        "casting_for": castingFor,
        "unit_price": unitPrice,
        "casting_unit_name": castingUnitName,
        "casting_unit_id": castingUnitId,
        "delivery_quantity": deliveryQuantity,
      };
}

class VenderPhone {
  VenderPhone({
    this.venderName,
    this.venderPhoneNumber,
  });

  String? venderName;
  String? venderPhoneNumber;

  factory VenderPhone.fromJson(Map<String, dynamic> json) => VenderPhone(
        venderName: json["vender_name"],
        venderPhoneNumber: json["vender_phone_number"],
      );

  Map<String, dynamic> toJson() => {
        "vender_name": venderName,
        "vender_phone_number": venderPhoneNumber,
      };
}

class TowarList {
  TowarList({
    this.towarId,
    this.towarName,
  });

  String? towarId;
  String? towarName;

  factory TowarList.fromJson(Map<String, dynamic> json) => TowarList(
        towarId: json["towar_id"] ?? "",
        towarName: json["towar_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "towar_id": towarId ?? "",
        "towar_name": towarName ?? "",
      };
}
