// To parse this JSON data, do
//
//     final getOrderHistory = getOrderHistoryFromJson(jsonString);

import 'dart:convert';

GetOrderHistory getOrderHistoryFromJson(String str) =>
    GetOrderHistory.fromJson(json.decode(str));

String getOrderHistoryToJson(GetOrderHistory data) =>
    json.encode(data.toJson());

class GetOrderHistory {
  GetOrderHistory({
    this.response,
  });

  ResponseGetOrderHistory? response;

  factory GetOrderHistory.fromJson(Map<String, dynamic> json) =>
      GetOrderHistory(
        response: ResponseGetOrderHistory.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetOrderHistory {
  ResponseGetOrderHistory({
    this.errorCode,
    this.msg,
    this.offset,
    this.rccBookingHistory,
    this.orderList,
  });

  String? errorCode;
  String? msg;
  String? offset;
  List<RccBookingHistory>? rccBookingHistory;
  List<OrderList>? orderList;

  factory ResponseGetOrderHistory.fromJson(Map<String, dynamic> json) =>
      ResponseGetOrderHistory(
        errorCode: json["error_code"],
        msg: json["msg"],
        offset: json["offset"],
        rccBookingHistory: List<RccBookingHistory>.from(
            json["rcc_booking_history"]
                .map((x) => RccBookingHistory.fromJson(x))),
        orderList: List<OrderList>.from(
            json["order_list"].map((x) => OrderList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "offset": offset,
        "rcc_booking_history":
            List<dynamic>.from(rccBookingHistory!.map((x) => x.toJson())),
        "order_list": List<dynamic>.from(orderList!.map((x) => x.toJson())),
      };
}

class OrderList {
  OrderList({
    this.id,
    this.name,
    this.towarList,
  });

  String? id;
  String? name;
  List<TowarList>? towarList;

  factory OrderList.fromJson(Map<String, dynamic> json) => OrderList(
        id: json["id"] ?? "",
        name: json["name"] ?? "",
        towarList: json["towar_list"] == null
            ? []
            : List<TowarList>.from(
                json["towar_list"].map((x) => TowarList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id ?? "",
        "name": name ?? "",
        "towar_list": towarList == null
            ? []
            : List<dynamic>.from(towarList!.map((x) => x.toJson())),
      };
}

class RccBookingHistory {
  RccBookingHistory({
    this.castingUnit,
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
    this.venderName,
    this.venderPhone,
    this.raisedBy,
    this.orderDeliverDate,
    this.slabName,
    this.projectName,
    this.orderDetails,
    this.checkedBy,
    this.deliveryQuantity,
    this.poDocument,
    this.poCheckedBy,
    this.poCheckedByDate,
    this.grn_active,
    this.projectDelivered,
    this.arrPoDoc,
  });

  String? castingUnit;
  String? poCheckedByDate;

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
  DateTime? orderDeliveryDate;
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
  String? venderName;
  List<VenderPhone>? venderPhone;
  String? raisedBy;
  String? orderDeliverDate;
  String? slabName;
  String? projectName;
  List<OrderDetail>? orderDetails;
  String? checkedBy;
  String? deliveryQuantity;
  String? grn_active;
  List<String>? poDocument;
  String? poCheckedBy;
  String? projectDelivered;
  List<ArrPoDoc>? arrPoDoc;

  factory RccBookingHistory.fromJson(Map<String, dynamic> json) =>
      RccBookingHistory(
        castingUnit: json["casting_unit"],
        poCheckedByDate: json["po_checked_by_date"],
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
        orderDeliveryDate: DateTime.parse(json["order_delivery_date"]),
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
        venderName: json["vender_name"],
        venderPhone: List<VenderPhone>.from(
            json["vender_phone"].map((x) => VenderPhone.fromJson(x))),
        raisedBy: json["raised_by"],
        orderDeliverDate: json["order_deliver_date"],
        slabName: json["slab_name"],
        projectName: json["project_name"],
        orderDetails: List<OrderDetail>.from(
            json["order_details"].map((x) => OrderDetail.fromJson(x))),
        checkedBy: json["checked_by"],
        deliveryQuantity: json["delivery_quantity"],
        poCheckedBy: json["po_checked_by"],
        poDocument: json["po_document"] == null
            ? []
            : List<String>.from(json["po_document"]!.map((x) => x)),
        projectDelivered: json["project_delivered"],
        arrPoDoc: json["arr_po_doc"] == null
            ? []
            : List<ArrPoDoc>.from(
                json["arr_po_doc"]!.map((x) => ArrPoDoc.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "casting_unit": castingUnit,
        "po_checked_by_date": poCheckedByDate,
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
        "order_delivery_date":
            "${orderDeliveryDate!.year.toString().padLeft(4, '0')}-${orderDeliveryDate!.month.toString().padLeft(2, '0')}-${orderDeliveryDate!.day.toString().padLeft(2, '0')}",
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
        "vender_name": venderName,
        "po_checked_by": poCheckedBy,
        "vender_phone": List<dynamic>.from(venderPhone!.map((x) => x.toJson())),
        "raised_by": raisedBy,
        "order_deliver_date": orderDeliverDate,
        "slab_name": slabName,
        "project_name": projectName,
        "order_details":
            List<dynamic>.from(orderDetails!.map((x) => x.toJson())),
        "checked_by": checkedBy,
        "delivery_quantity": deliveryQuantity,
        "po_document": poDocument == null
            ? []
            : List<dynamic>.from(poDocument!.map((x) => x)),
        "project_delivered": projectDelivered,
        "arr_po_doc": arrPoDoc == null
            ? []
            : List<dynamic>.from(arrPoDoc!.map((x) => x.toJson())),
      };
}

class ArrPoDoc {
  String? fileName;
  String? createdAt;
  String? isPdf;
  String? filePath;

  ArrPoDoc({
    this.fileName,
    this.createdAt,
    this.isPdf,
    this.filePath,
  });

  factory ArrPoDoc.fromJson(Map<String, dynamic> json) => ArrPoDoc(
        fileName: json["file_name"],
        createdAt: json["created_at"],
        isPdf: json["is_pdf"],
        filePath: json["file_path"],
      );

  Map<String, dynamic> toJson() => {
        "file_name": fileName,
        "created_at": createdAt,
        "is_pdf": isPdf,
        "file_path": filePath,
      };
}

class OrderDetail {
  OrderDetail({
    this.castingUnit,
    this.gradeTypeName,
    this.gradeTypeId,
    this.supplieId,
    this.orderQuantity,
    this.castingFor,
    this.unitPrice,
    this.gradeName,
    this.gradeId,
    this.castingUnitName,
    this.castingUnitId,
    this.deliveryQuantity,
  });

  String? castingUnit;
  String? gradeTypeName;
  String? gradeTypeId;
  String? supplieId;
  String? orderQuantity;
  String? castingFor;
  String? unitPrice;
  String? gradeName;
  String? gradeId;
  String? castingUnitName;
  String? castingUnitId;
  String? deliveryQuantity;

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
        castingUnit: json["casting_unit"],
        gradeTypeName: json["grade_type_name"],
        gradeTypeId: json["grade_type_id"],
        supplieId: json["supplie_id"],
        orderQuantity: json["order_quantity"],
        castingFor: json["casting_for"],
        unitPrice: json["unit_price"],
        gradeName: json["grade_name"],
        gradeId: json["grade_id"],
        castingUnitName: json["casting_unit_name"],
        castingUnitId: json["casting_unit_id"],
        deliveryQuantity: json["delivery_quantity"],
      );

  Map<String, dynamic> toJson() => {
        "casting_unit": castingUnit,
        "grade_type_name": gradeTypeName,
        "grade_type_id": gradeTypeId,
        "supplie_id": supplieId,
        "order_quantity": orderQuantity,
        "casting_for": castingFor,
        "unit_price": unitPrice,
        "grade_name": gradeName,
        "grade_id": gradeId,
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
