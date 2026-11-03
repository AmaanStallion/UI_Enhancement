// To parse this JSON data, do
//
//     final getPoDetailsByStatus = getPoDetailsByStatusFromJson(jsonString);

import 'dart:convert';

import 'package:stallion/models/get_status_of_supply_list.dart';

GetPoDetailsByStatus getPoDetailsByStatusFromJson(String str) =>
    GetPoDetailsByStatus.fromJson(json.decode(str));

String getPoDetailsByStatusToJson(GetPoDetailsByStatus data) =>
    json.encode(data.toJson());

class GetPoDetailsByStatus {
  GetPoDetailsByStatus({
    this.response,
  });

  ResponseGetPoDetailsByStatus? response;

  factory GetPoDetailsByStatus.fromJson(Map<String, dynamic> json) =>
      GetPoDetailsByStatus(
        response: ResponseGetPoDetailsByStatus.fromJson(json["Response"]),
      );

  Map<String, dynamic> toJson() => {
        "Response": response?.toJson(),
      };
}

class ResponseGetPoDetailsByStatus {
  ResponseGetPoDetailsByStatus({
    this.errorCode,
    this.msg,
    this.offset,
    this.rccBookingHistory,
    this.bookingType,
    this.venderList,
    this.handSignUrl,
    // this.authorizeFlag,
  });

  String? errorCode;
  String? msg;
  String? offset;
  List<RccBookingHistory>? rccBookingHistory;
  List<BookingType>? bookingType;
  List<VenderListPO>? venderList;
  String? handSignUrl;
  // String? authorizeFlag;

  factory ResponseGetPoDetailsByStatus.fromJson(Map<String, dynamic> json) =>
      ResponseGetPoDetailsByStatus(
        errorCode: json["error_code"],
        msg: json["msg"],
        offset: json["offset"],
        rccBookingHistory: List<RccBookingHistory>.from(
            json["rcc_booking_history"]
                .map((x) => RccBookingHistory.fromJson(x))),
        venderList: json["vender_list"] == null
            ? []
            : List<VenderListPO>.from(
                json["vender_list"]!.map((x) => VenderListPO.fromJson(x))),
        bookingType: List<BookingType>.from(
            json["booking_type"].map((x) => BookingType.fromJson(x))),
        handSignUrl: json["hand_sign_url"],
        // authorizeFlag: json["authorize_flag"],
      );

  Map<String, dynamic> toJson() => {
        "error_code": errorCode,
        "msg": msg,
        "offset": offset,
        "vender_list": venderList == null
            ? []
            : List<dynamic>.from(venderList!.map((x) => x.toJson())),
        "rcc_booking_history":
            List<dynamic>.from(rccBookingHistory!.map((x) => x.toJson())),
        "booking_type": List<dynamic>.from(bookingType!.map((x) => x.toJson())),
        "hand_sign_url": handSignUrl,
        // "authorize_flag": authorizeFlag,
      };
}

class BookingType {
  BookingType({
    this.gradeId,
    this.name,
    this.count,
    this.details,
  });

  String? gradeId;
  String? name;
  String? count;
  List<Detail>? details;

  factory BookingType.fromJson(Map<String, dynamic> json) => BookingType(
        gradeId: json["grade_id"],
        name: json["name"],
        count: json["count"],
        details:
            List<Detail>.from(json["details"].map((x) => Detail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "grade_id": gradeId,
        "name": name,
        "count": count,
        "details": List<dynamic>.from(details!.map((x) => x.toJson())),
      };
}

class Detail {
  Detail({
    this.gradeTypeId,
    this.gradeTypeName,
  });

  String? gradeTypeId;
  String? gradeTypeName;

  factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        gradeTypeId: json["grade_type_id"],
        gradeTypeName: json["grade_type_name"],
      );

  Map<String, dynamic> toJson() => {
        "grade_type_id": gradeTypeId,
        "grade_type_name": gradeTypeName,
      };
}

class RccBookingHistory {
  RccBookingHistory({

    this.poHandSignImg,
    this.poHandSignUserId,
    this.poHandSignDate,
    this.poAssingTo,
    this.poAssingDate,
    this.castingUnit,
    this.poVerifyDate,
    this.poCheckedByDate,
    this.poVerifyFlag,
    this.poVerifyBy,
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
    this.towarIdFk,
    this.poDocument,
    this.grnActive,
    this.slabSelected,
    this.isStarMarked,
    this.sortDt,
    this.poRequsition,
    this.venderName,
    this.venderPhone,
    this.raisedBy,
    this.poCheckedBy,
    this.poAssingToName,
    this.reApprovedReson,
    this.reApprovedDate,
    this.orderDeliverDate,
    this.slabName,
    this.projectName,
    this.orderDetails,
    this.checkedBy,
    this.deliveryQuantity,
    this.grn_active,
    this.towar_id_fk,
    this.is_star_marked,
    this.arrPoDoc,
    this.projectDelivered,
    this.authorizeFlag,
  });

  String? poHandSignImg;
  String? poHandSignUserId;
  String? poHandSignDate;
  String? is_star_marked;
  String? grn_active;
  String? towar_id_fk;
  String? poAssingTo;
  String? poAssingDate;
  String? castingUnit;
  String? poVerifyDate;
  String? poCheckedByDate;
  String? poVerifyFlag;
  String? poVerifyBy;
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
  dynamic orderDeliveryDate;
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
  String? towarIdFk;
  List<String>? poDocument;
  String? grnActive;
  List<SlabSelected>? slabSelected;
  String? isStarMarked;
  String? sortDt;
  String? poRequsition;
  String? venderName;
  List<VenderPhone>? venderPhone;
  String? raisedBy;
  String? poCheckedBy;
  String? poAssingToName;
  String? reApprovedReson;
  String? reApprovedDate;
  String? orderDeliverDate;
  String? slabName;
  String? projectName;
  List<OrderDetail>? orderDetails;
  String? checkedBy;
  String? deliveryQuantity;
  List<ArrPoDoc>? arrPoDoc;
  String? projectDelivered;
  String? authorizeFlag;

  factory RccBookingHistory.fromJson(Map<String, dynamic> json) =>
      RccBookingHistory(
        poHandSignImg: json["po_hand_sign_img"],
        poHandSignUserId: json["po_hand_sign_user_id"],
        poHandSignDate: json["po_hand_sign_date"],
        poAssingTo: json["po_assing_to"],
        poAssingDate: json["po_assing_date"],
        castingUnit: json["casting_unit"],
        poVerifyDate: json["po_verify_date"],
        poCheckedByDate: json["po_checked_by_date"],
        poVerifyFlag: json["po_verify_flag"],
        poVerifyBy: json["po_verify_by"],
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
        towarIdFk: json["towar_id_fk"],
        poDocument: json["po_document"] == null
            ? []
            : List<String>.from(json["po_document"]!.map((x) => x)),
        grnActive: json["grn_active"],
        slabSelected: json["slab_selected"] == null
            ? []
            : List<SlabSelected>.from(
                json["slab_selected"]!.map((x) => SlabSelected.fromJson(x))),
        isStarMarked: json["is_star_marked"],
        sortDt: json["sort_dt"],
        poRequsition: json["po_requsition"],
        venderName: json["vender_name"],
        venderPhone: json["vender_phone"] == null
            ? []
            : List<VenderPhone>.from(
                json["vender_phone"]!.map((x) => VenderPhone.fromJson(x))),
        raisedBy: json["raised_by"],
        poCheckedBy: json["po_checked_by"],
        poAssingToName: json["po_assing_to_name"],
        reApprovedReson: json["re_approved_reson"],
        reApprovedDate: json["re_approved_date"],
        orderDeliverDate: json["order_deliver_date"],
        slabName: json["slab_name"],
        projectName: json["project_name"],
        orderDetails: json["order_details"] == null
            ? []
            : List<OrderDetail>.from(
                json["order_details"]!.map((x) => OrderDetail.fromJson(x))),
        checkedBy: json["checked_by"],
        deliveryQuantity: json["delivery_quantity"],
        is_star_marked: json["is_star_marked"] ?? '',
        grn_active: json["grn_active"] ?? '',
        towar_id_fk: json["towar_id_fk"] ?? "",
        arrPoDoc: json["arr_po_doc"] == null
            ? []
            : List<ArrPoDoc>.from(
                json["arr_po_doc"]!.map((x) => ArrPoDoc.fromJson(x))),
        projectDelivered: json["project_delivered"],
        authorizeFlag: json["authorize_flag"],
      );

  Map<String, dynamic> toJson() => {
        "po_hand_sign_img": poHandSignImg,
        "po_hand_sign_user_id": poHandSignUserId,
        "po_hand_sign_date": poHandSignDate,
        "is_star_marked": is_star_marked,
        "towar_id_fk": towar_id_fk,
        "grn_active": grn_active,
        "po_assing_to": poAssingTo,
        "po_assing_date": poAssingDate,
        "casting_unit": castingUnit,
        "po_verify_date": poVerifyDate,
        "po_checked_by_date": poCheckedByDate,
        "po_verify_flag": poVerifyFlag,
        "po_verify_by": poVerifyBy,
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
        "po_document": poDocument == null
            ? []
            : List<dynamic>.from(poDocument!.map((x) => x)),
        "slab_selected": slabSelected == null
            ? []
            : List<dynamic>.from(slabSelected!.map((x) => x.toJson())),
        "sort_dt": sortDt,
        "po_requsition": poRequsition,
        "vender_name": venderName,
        "vender_phone": venderPhone == null
            ? []
            : List<dynamic>.from(venderPhone!.map((x) => x.toJson())),
        "raised_by": raisedBy,
        "po_checked_by": poCheckedBy,
        "po_assing_to_name": poAssingToName,
        "re_approved_reson": reApprovedReson,
        "re_approved_date": reApprovedDate,
        "order_deliver_date": orderDeliverDate,
        "slab_name": slabName,
        "project_name": projectName,
        "order_details": orderDetails == null
            ? []
            : List<dynamic>.from(orderDetails!.map((x) => x.toJson())),
        "checked_by": checkedBy,
        "delivery_quantity": deliveryQuantity,
        "arr_po_doc": arrPoDoc == null
            ? []
            : List<dynamic>.from(arrPoDoc!.map((x) => x.toJson())),
        "project_delivered": projectDelivered,
        "authorize_flag": authorizeFlag,
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
    this.brandSupplierName,
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
  String? brandSupplierName;

  factory OrderDetail.fromJson(Map<String, dynamic> json) => OrderDetail(
        castingUnit: json["casting_unit"] ?? '',
        gradeTypeName: json["grade_type_name"] ?? '',
        brandSupplierName: json["brand_supplier_name"],
        gradeTypeId: json["grade_type_id"] ?? '',
        supplieId: json["supplie_id"] ?? '',
        orderQuantity: json["order_quantity"] ?? '',
        castingFor: json["casting_for"] ?? '',
        unitPrice: json["unit_price"] ?? '',
        gradeName: json["grade_name"] ?? '',
        gradeId: json["grade_id"] ?? '',
        castingUnitName: json["casting_unit_name"] ?? '',
        castingUnitId: json["casting_unit_id"] ?? '',
        deliveryQuantity: json["delivery_quantity"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "casting_unit": castingUnit,
        "brand_supplier_name": brandSupplierName,
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

class VenderListPO {
  String? venderId;
  String? venderCompanyName;
  String? venderName;

  VenderListPO({
    this.venderId,
    this.venderCompanyName,
    this.venderName,
  });

  factory VenderListPO.fromJson(Map<String, dynamic> json) => VenderListPO(
        venderId: json["vender_id"],
        venderCompanyName: json["vender_company_name"],
        venderName: json["vender_name"],
      );

  Map<String, dynamic> toJson() => {
        "vender_id": venderId,
        "vender_company_name": venderCompanyName,
        "vender_name": venderName,
      };
}

class SlabSelected {
  String? poSlabIdFk;
  String? poSlabName;

  SlabSelected({
    this.poSlabIdFk,
    this.poSlabName,
  });

  factory SlabSelected.fromJson(Map<String, dynamic> json) => SlabSelected(
        poSlabIdFk: json["po_slab_id_fk"],
        poSlabName: json["po_slab_name"],
      );

  Map<String, dynamic> toJson() => {
        "po_slab_id_fk": poSlabIdFk,
        "po_slab_name": poSlabName,
      };
}
